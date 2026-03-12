# 🎫 Vouch

**Vouch** is a centralized mobile application designed to streamline student event attendance, payment tracking, and academic clearance for the Faculty of Computing, Engineering, and Technology (FaCET) at Davao Oriental State University.

By replacing traditional paper-based activity cards with a digital system, Vouch ensures secure, real-time tracking of student obligations and seamless administrative oversight.

## ✨ Key Features
* **Role-Based Access:** Distinct experiences for Administrators (event/fee management, approval workflows) and Students (compliance tracking).
* **Digital Activity Cards:** Real-time visibility into clearance status for the active academic term.
* **Smart Attendance:** Log event Time-In and Time-Out seamlessly.
* **Payment Processing:** Upload GCash transaction receipts for administrative verification.
* **Unified Dashboard:** A single view combining all obligatory events and payment requirements.

## 🛠 Tech Stack
* **Frontend:** Flutter & Dart
* **Backend as a Service (BaaS):** Supabase
  * **Database:** PostgreSQL
  * **Authentication:** Supabase Auth
* **Media Storage:** Cloudinary (Direct unsigned uploads for optimized performance)

## ⚙️ Prerequisites
Before running this project, ensure you have the following installed:
* [Flutter SDK](https://docs.flutter.dev/get-started/install)
* An active [Supabase](https://supabase.com/) project
* An active [Cloudinary](https://cloudinary.com/) account

## 🚀 Installation & Setup

### 1. Database Setup (Supabase)
1. Navigate to the SQL Editor in your Supabase Dashboard.
2. Copy the contents of `database/schema.sql` (your database creation script).
3. Run the script to generate all tables, views, and seed data (including the default FaCET Admin account).

### 2. Environment Variables
Create a `.env` file in the root of your project. **Do not commit this file to version control.** Add the following variables, replacing the bracketed values with your actual project keys:

```env
SUPABASE_URL=https://[YOUR_SUPABASE_PROJECT_REF].supabase.co
SUPABASE_ANON_KEY=[YOUR_SUPABASE_ANON_KEY]
CLOUDINARY_CLOUD_NAME=[YOUR_CLOUD_NAME]
CLOUDINARY_UPLOAD_PRESET=event_pictures
CLOUDINARY_PROFILE_UPLOAD_PRESET=profile_pictures
CLOUDINARY_RECEIPT_UPLOAD_PRESET=receipt_pictures

### 3. Run the App
Clone the repository, install the dependencies, and run the project on your emulator or physical device.

git clone https://github.com/jeslitogeverola30/vouch_mobileApp.git
cd vouch-app
flutter pub get
flutter run

📚 Documentation
Database Design & ERD: Detailed breakdown of the PostgreSQL schema and entity relationships.

API & Integration Docs: Comprehensive guide on Supabase database interactions and Cloudinary media upload flows.

👥 Team
Group: Vouch
Academic Year: 2025–2026 (Second Semester)
Course: ITMSD 2 — Advance Mobile Application Development

GEVEROLA, JESLITO G.- Senior Full Stack
CARPIO, JIAN P.- Junior Full Stack
ESTOLOGA, JOEMARIE L.- Junior Full Stack
LANDOY, NICOLE JAMES S.- Quality Assurance
SARITA, AIME JOYCE C.- Project Manager
DAGANSAN, NIEL LORENCE D.- Junior Full Stack
QUIRANTE, HARLY QUENN A.- Quality Assurance
