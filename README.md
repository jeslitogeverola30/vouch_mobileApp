Vouch App 📱
Vouch is a robust Flutter mobile application designed to simplify campus life by digitizing event tracking and administrative workflows. It bridges the gap between student organizations and university administrations through automated clearance systems.

✨ Key Features

- QR-Based Attendance: Quick, contactless check-ins at events using unique QR code generation and scanning.

- Digital Fee Management: Securely upload and store proof of payment (receipts) for organization dues and university fees.

- Automated Clearance: Instantly updates student activity card status upon verification of attendance and payments.

- Real-time Synchronization: Powered by a cloud backend to ensure data is consistent across all student and admin devices.

🛠 Tech Stack
Framework: Flutter (v3.0+)

- Language: Dart

- Backend: Supabase (Supabase for database, Storage for receipts, Auth for security)

- Scanning: mobile_scanner & qr_flutter

🔐 Environment Setup

- Create a local env file: `cp .env.example .env`
- Fill in your own values for `SUPABASE_URL` and `SUPABASE_ANON_KEY`
- `.env` is ignored by Git, so secrets are not pushed to GitHub
