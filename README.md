# CareerBridge - College Alumni Networking Platform

CareerBridge is a college alumni networking platform built with Flutter and Node.js. It allows placed alumni to guide pre-final/final-year students by reviewing resumes, scheduling mock/mentorship sessions, listing internships/jobs, and managing referrals.

---

## 🚀 Features

1. **Splash Screen**: Interactive branding with auto-routing.
2. **Home Screen**: Tailored greetings based on user role (Student, Alumni, Admin), search registries, featured alumni lists, job snippets, and notifications.
3. **Alumni Directory**: Filterable search (by skills, company) listing all verified alumni.
4. **Alumni Profile**: Direct connection with alumni, including links to LinkedIn, "Request Referral" dialogs, and "Schedule Mentorship" calendars.
5. **Opportunities Board (Jobs)**: Listing internships, fulltime, and referral job posts. Alumni and Admins can publish new opportunities directly.
6. **Referral Management System**: Triggers notifications for alumni on referral requests; tracks request statuses.
7. **Mentorship Module**: Standard scheduling, slot reviews, and note allocations.
8. **Community Hub**: Posts feed with like updates and nested discussions/comment logs.
9. **Role Switcher Widget**: Interactive floating button allowing reviewers to swap profiles (Student, Alumni, Admin) to instantly test each dashboard.

---

## 📂 Project Structure

### Flutter Frontend
```text
lib/
 ├── core/
 │    ├── constants/       # AppColors configurations
 │    └── theme/           # AppTheme & ThemeProvider setups
 ├── models/               # Data model parsers (User, Job, Referral, Mentorship, Post, Notification)
 ├── repositories/         # Mapped CRUD backend fetch layers
 ├── services/             # Centralized ApiClient network agent
 ├── providers/            # State holders (Auth, Alumni, Jobs, Referrals, Mentorship, Feed, Notifications)
 ├── screens/              # UI pages (Splash, Home, Dashboards, Feed, Board, Profile)
 ├── widgets/              # Reusable UI controls (Buttons, inputs, FAB controllers)
 ├── routes/               # App Router GoRouter definitions
 └── main.dart             # Provider injection setup
```

### Express.js Backend
```text
backend/
 ├── config/               # DB connections
 │    └── db.js
 ├── controllers/          # Endpoint handler scripts
 ├── middleware/           # Express error handler pipelines
 ├── models/               # MongoDB Mongoose Schemas (User, Job, Referral, Mentorship, Post, Notification)
 ├── routes/               # Express endpoints routes configurations
 ├── utils/                # Seeder mock data script
 ├── .env                  # Port and MongoDB Connection URIs
 ├── package.json          # Server dependencies registry
 └── server.js             # Express entry point
```

---

## 🛠️ Installation & Setup

### Prerequisites
- [Flutter SDK (v3.x+)](https://docs.flutter.dev/get-started/install)
- [Node.js (v18+)](https://nodejs.org/en/download)
- [MongoDB (Community Edition/Atlas)](https://www.mongodb.com/try/download/community)

---

### Step 1: Run the Backend Server

1. Open a terminal and navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Install npm dependencies:
   ```bash
   npm install
   ```
3. Ensure you have MongoDB running locally:
   - Default URI: `mongodb://127.0.0.1:27017/careerbridge`
   - You can customize this inside `backend/.env`.
4. Seed the database with initial mock users (Student, Alumni, Admin), jobs, feed posts, and sessions:
   ```bash
   npm run seed
   ```
5. Launch the Express API development server:
   ```bash
   npm run dev
   ```
   *The server runs on `http://localhost:5000`.*

---

### Step 2: Run the Flutter App

1. Ensure the backend server is active.
2. If compiling for **Android Emulator**:
   - The `ApiClient` automatically routes server calls to host machine loopback address (`http://10.0.2.2:5000/api`).
3. If compiling for **iOS Simulator / Web / Desktop**:
   - The client defaults to `http://localhost:5000/api`.
4. Open the project root in your editor and fetch packages:
   ```bash
   flutter pub get
   ```
5. Launch the app on your choice of emulator or browser:
   ```bash
   flutter run
   ```

---

## 🧪 Testing instructions

### Dynamic User Simulation
CareerBridge includes a floating **Developer Swap FAB** (bottom right icon `swap_horiz`) to enable testing all roles without needing signup. Tap the FAB to switch profiles:
1. **Yuraj Patil (Student)**: Request referrals on job listings, schedule mentorship sessions, update resume links, send community posts, and track application pipelines.
2. **Anjali Sharma (Alumni - Google)**: Review incoming referral applications, approve/decline mentorship bookings, create jobs, and monitor the Alumni Dashboard.
3. **Dr. Sandeep Poddar (Admin)**: Access platform metrics, total account stats, and referral pipeline success conversions.
