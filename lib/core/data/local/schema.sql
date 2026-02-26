-- 1. Admins Table
CREATE TABLE Admins (
    id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL
);

-- 2. Students Table
CREATE TABLE Students (
    student_id VARCHAR(50) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    faculty VARCHAR(100) NOT NULL,
    program VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE, 
    password_hash VARCHAR(255) NOT NULL,
    profile_photo_url TEXT NOT NULL,
    account_status VARCHAR(20) DEFAULT 'active',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 3. Events Table
CREATE TABLE Events (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    short_description VARCHAR(255),
    full_description TEXT,
    location VARCHAR(255) NOT NULL,
    event_date DATE NOT NULL,
    schedule_time_in TIME NOT NULL,
    schedule_time_out TIME NOT NULL,
    is_mandatory BOOLEAN DEFAULT 0,
    admin_id INT,
    FOREIGN KEY(admin_id) REFERENCES Admins(id)
);

-- 4. Event_Attendance Table
CREATE TABLE Event_Attendance (
    id INT PRIMARY KEY AUTO_INCREMENT,
    event_id INT,
    student_id VARCHAR(50),
    scanned_time_in DATETIME,
    scanned_time_out DATETIME,
    status VARCHAR(20) DEFAULT 'pending',
    FOREIGN KEY(event_id) REFERENCES Events(id),
    FOREIGN KEY(student_id) REFERENCES Students(student_id)
);

-- 5. Payment_Requirements Table
CREATE TABLE Payment_Requirements (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    receiver_gcash VARCHAR(20) NOT NULL,
    receiver_name VARCHAR(100) NOT NULL,
    is_mandatory BOOLEAN DEFAULT 0,
    admin_id INT,
    FOREIGN KEY(admin_id) REFERENCES Admins(id)
);

-- 6. Student_Transactions Table
CREATE TABLE Student_Transactions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    student_id VARCHAR(50),
    requirement_id INT,
    reference_number VARCHAR(50) NOT NULL,
    proof_photo_url TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'to_pay',
    reviewed_by INT,
    FOREIGN KEY(student_id) REFERENCES Students(student_id),
    FOREIGN KEY(requirement_id) REFERENCES Payment_Requirements(id),
    FOREIGN KEY(reviewed_by) REFERENCES Admins(id)
);

-- 7. Activity_Cards Table
CREATE TABLE Activity_Cards (
    id INT PRIMARY KEY AUTO_INCREMENT,
    student_id VARCHAR(50),
    academic_period VARCHAR(50) NOT NULL,
    is_cleared BOOLEAN DEFAULT 0,
    FOREIGN KEY(student_id) REFERENCES Students(student_id)
);


-- 1. Disable foreign key constraints so you can delete tables in any order
SET FOREIGN_KEY_CHECKS = 0; 

-- 2. Drop each of your tables
DROP TABLE IF EXISTS Activity_Cards;
DROP TABLE IF EXISTS Student_Transactions;
DROP TABLE IF EXISTS Payment_Requirements;
DROP TABLE IF EXISTS Event_Attendance;
DROP TABLE IF EXISTS Events;
DROP TABLE IF EXISTS Students;
DROP TABLE IF EXISTS Admins;

-- 3. Re-enable foreign key constraints
SET FOREIGN_KEY_CHECKS = 1;


SELECT * FROM Admins;
SELECT * FROM Students;
SELECT * FROM Events;
SELECT * FROM Event_Attendance; 