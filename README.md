# Pegas Salary & Attendance App

A comprehensive Flutter mobile application for sales representative attendance tracking and salary calculation with multi-language support (English, Sinhala, Tamil).

## 🌟 Features

### Core Functionality
- **Multi-Language Support**: English, Sinhala (සිංහල), Tamil (தமிழ்)
- **Employee Authentication**: Secure login system
- **Attendance Management**: Daily attendance tracking with presence/absence status
- **Time Tracking**: Start and end time recording
- **Bills Counting**: Sales bills tracking with automatic incentive calculation
- **Salary Calculation**: Real-time salary computation based on business rules
- **Monthly Summaries**: Comprehensive monthly reports and analytics
- **PDF Export**: Generate and share salary reports in multiple languages
- **Data Visualization**: Interactive charts showing daily bills performance

### Business Logic
- **Base Payment**: Rs. 1000 for present days
- **Half Payment**: Rs. 500 if bills count < 10
- **Incentives**: 
  - Rs. 500 for 20-24 bills per day
  - Rs. 1000 for 25+ bills per day
- **Automatic Calculation**: Real-time salary updates as you enter data

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.8.1)
- Node.js (>=14.0.0)
- MongoDB (local or cloud instance)
- Android Studio/VS Code with Flutter extensions

### Backend Setup

1. **Navigate to backend directory:**
```bash
cd backend
```

2. **Install dependencies:**
```bash
npm install
```

3. **Set up environment variables:**
Update `.env` file with your configuration:
```env
NODE_ENV=development
PORT=3000
MONGODB_URI=mongodb://localhost:27017/pegas_attendance
JWT_SECRET=your-super-secret-jwt-key
```

4. **Create demo users:**
```bash
node createDemoUsers.js
```

5. **Start the server:**
```bash
npm run dev
```

### Frontend Setup

1. **Install Flutter dependencies:**
```bash
flutter pub get
```

2. **Generate localization files:**
```bash
flutter gen-l10n
```

3. **Update API base URL:**
Edit `lib/services/api_service.dart` and update the `baseUrl` to match your backend server.

4. **Run the app:**
```bash
flutter run
```

## 🎯 Demo Accounts

**Employee Account:**
- Username: `demo`
- Password: `demo`

**Admin Account:**
- Username: `admin`
- Password: `admin123`

## 📱 App Features

- Clean and professional UI with Material 3 design
- Complete multi-language support (English, Sinhala, Tamil)
- Real-time salary calculations
- Interactive charts and data visualization
- PDF report generation and export
- Secure authentication and data storage
- Comprehensive form validation
