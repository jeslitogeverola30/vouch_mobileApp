-- THIS SQL SCRIPT IS BASED ON MY SUPABASE DATABASE
-- 

-- ==============================================================================
-- 0. WIPE EXISTING TABLES & VIEWS (CLEAN SLATE)
-- ==============================================================================
DROP VIEW IF EXISTS Obligatory_Requirements CASCADE;
DROP TABLE IF EXISTS Activity_Cards CASCADE;
DROP TABLE IF EXISTS Student_Transactions CASCADE;
DROP TABLE IF EXISTS Payment_Receiver CASCADE;
DROP TABLE IF EXISTS Payment_Requirements CASCADE;
DROP TABLE IF EXISTS Event_Ratings CASCADE;
DROP TABLE IF EXISTS Event_Attendance CASCADE;
DROP TABLE IF EXISTS Events CASCADE;
DROP TABLE IF EXISTS Academic_Terms CASCADE;
DROP TABLE IF EXISTS Students CASCADE;
DROP TABLE IF EXISTS Admins CASCADE;
DROP FUNCTION IF EXISTS single_active_term CASCADE;

-- ==============================================================================
-- 1. USERS & ACCOUNTS (ADMINS & STUDENTS)
-- ==============================================================================
CREATE TABLE Admins (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    faculty VARCHAR(100) NOT NULL, 
    email VARCHAR(255) NOT NULL UNIQUE,
    profile_photo_url VARCHAR(2048), 
    password_hash VARCHAR(255) NOT NULL
);

CREATE TABLE Students (
    student_id VARCHAR(50) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    faculty VARCHAR(100) NOT NULL,
    program VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    profile_photo_url VARCHAR(2048), 
    account_status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ==============================================================================
-- 2. ACADEMIC TERMS (NORMALIZED YEAR & SEMESTER)
-- ==============================================================================
CREATE TABLE Academic_Terms (
    id SERIAL PRIMARY KEY,
    academic_year VARCHAR(20) NOT NULL, 
    semester VARCHAR(50) NOT NULL,      
    is_active BOOLEAN DEFAULT FALSE,    
    UNIQUE(academic_year, semester)     
);

-- Trigger to ensure ONLY ONE term is active at a time
CREATE OR REPLACE FUNCTION single_active_term()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.is_active = TRUE THEN
        UPDATE Academic_Terms SET is_active = FALSE WHERE id <> NEW.id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ensure_single_active_term
BEFORE INSERT OR UPDATE ON Academic_Terms
FOR EACH ROW EXECUTE FUNCTION single_active_term();

-- ==============================================================================
-- 3. EVENTS, ATTENDANCE & RATINGS
-- ==============================================================================
CREATE TABLE Events (
    id SERIAL PRIMARY KEY,
    term_id INT REFERENCES Academic_Terms(id) ON DELETE RESTRICT,
    name VARCHAR(255) NOT NULL,
    short_description VARCHAR(255),
    full_description TEXT,
    image_url VARCHAR(2048), 
    location VARCHAR(255) NOT NULL,
    event_date DATE NOT NULL,
    schedule_time_in_start TIME NOT NULL,
    schedule_time_in_end TIME NOT NULL,
    schedule_time_out_start TIME NOT NULL,
    schedule_time_out_end TIME NOT NULL,
    is_mandatory BOOLEAN DEFAULT FALSE,
    admin_id INT REFERENCES Admins(id)
);

CREATE TABLE Event_Attendance (
    id SERIAL PRIMARY KEY,
    event_id INT REFERENCES Events(id) ON DELETE CASCADE,
    student_id VARCHAR(50) REFERENCES Students(student_id) ON DELETE CASCADE,
    scanned_time_in TIMESTAMP WITH TIME ZONE,
    scanned_time_out TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) DEFAULT 'pending'
);

CREATE TABLE Event_Ratings (
    id SERIAL PRIMARY KEY,
    event_id INT REFERENCES Events(id) ON DELETE CASCADE,
    student_id VARCHAR(50) REFERENCES Students(student_id) ON DELETE CASCADE,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(event_id, student_id)
);

-- ==============================================================================
-- 4. PAYMENTS & TRANSACTIONS
-- ==============================================================================
CREATE TABLE Payment_Receiver (
    receiver_id VARCHAR(50) PRIMARY KEY,
    receiver_name VARCHAR(100) NOT NULL,
    receiver_gcash VARCHAR(20) NOT NULL,
    receiver_position VARCHAR(100) NOT NULL, 
    is_active BOOLEAN DEFAULT TRUE           
);

CREATE TABLE Payment_Requirements (
    id SERIAL PRIMARY KEY,
    term_id INT REFERENCES Academic_Terms(id) ON DELETE RESTRICT,
    title VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    receiver_gcash VARCHAR(20) NOT NULL,
    receiver_name VARCHAR(100) NOT NULL,
    is_mandatory BOOLEAN DEFAULT FALSE,
    admin_id INT REFERENCES Admins(id)
);

CREATE TABLE Student_Transactions (
    id SERIAL PRIMARY KEY,
    student_id VARCHAR(50) REFERENCES Students(student_id) ON DELETE CASCADE,
    requirement_id INT REFERENCES Payment_Requirements(id) ON DELETE CASCADE,
    reference_number VARCHAR(50) NOT NULL,
    proof_photo_url VARCHAR(2048), 
    status VARCHAR(20) DEFAULT 'to_pay', 
    rejection_note TEXT,                 
    reviewed_by INT REFERENCES Admins(id),
    reviewed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ==============================================================================
-- 5. ACTIVITY CARDS (CLEARANCE)
-- ==============================================================================
CREATE TABLE Activity_Cards (
    id SERIAL PRIMARY KEY,
    student_id VARCHAR(50) REFERENCES Students(student_id) ON DELETE CASCADE,
    term_id INT REFERENCES Academic_Terms(id) ON DELETE RESTRICT,
    is_cleared BOOLEAN DEFAULT FALSE,
    is_stamp BOOLEAN DEFAULT FALSE,
    UNIQUE(student_id, term_id)
);

CREATE TABLE Admin_Activity_Cards (
    id SERIAL PRIMARY KEY,
    admin_id INT REFERENCES Admins(id) ON DELETE CASCADE,
    term_id INT REFERENCES Academic_Terms(id) ON DELETE RESTRICT,
    is_stamp BOOLEAN DEFAULT FALSE,
    -- Prevents the same admin from getting duplicate cards for the same term,
    -- but allows multiple different admins to have a card for that term.
    UNIQUE(admin_id, term_id) 
);

-- ==============================================================================
-- 6. VIEWS (COMBINED OBLIGATORY REQUIREMENTS)
-- ==============================================================================
CREATE OR REPLACE VIEW Obligatory_Requirements AS
SELECT 
    'Event' AS requirement_type,
    e.id AS source_id,
    e.name AS title,
    e.short_description AS description,
    e.event_date::TEXT AS date_or_deadline,
    0.00 AS amount,
    t.academic_year,       
    t.semester AS academic_period      
FROM Events e
JOIN Academic_Terms t ON e.term_id = t.id
WHERE e.is_mandatory = TRUE

UNION ALL

SELECT 
    'Payment' AS requirement_type,
    p.id AS source_id,
    p.title AS title,
    p.description AS description,
    'TBA' AS date_or_deadline, 
    p.amount,
    t.academic_year,       
    t.semester AS academic_period      
FROM Payment_Requirements p
JOIN Academic_Terms t ON p.term_id = t.id
WHERE p.is_mandatory = TRUE;

-- ==============================================================================
-- 7. SECURITY & DEFAULT SEED DATA
-- ==============================================================================
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 7a. Seed the initial Academic Term so you can start adding events immediately
INSERT INTO Academic_Terms (academic_year, semester, is_active)
VALUES ('2025-2026', '1st Semester', TRUE)
ON CONFLICT (academic_year, semester) DO NOTHING;

-- 7b. Seed the default Admin Account
INSERT INTO Admins (full_name, faculty, email, password_hash)
VALUES (
    'FaCET Admin',
    'Faculty of Computing, Engineering, and Technology', 
    'jeslito.geverola@dorsu.edu.ph',
    crypt('Jeslito-2005', gen_salt('bf'))
)
ON CONFLICT (email) DO NOTHING;