# ✅ TaskMaster - Todo App with Firebase

A complete Todo application with Firebase Authentication and Realtime Database.

## ✨ Features

- **Authentication**: Email/Password signup & login via Firebase Auth
- **Task Management**: Create, Read, Update, Delete tasks
- **Task Status**: Mark tasks as completed/pending
- **Filter Tasks**: View All, Active, or Completed tasks
- **Real-time Sync**: Data stored in Firebase Realtime Database
- **Responsive UI**: Works on all screen sizes (flutter_screenutil)
- **Modern Design**: Clean UI with Google Fonts

## 🛠️ Tech Stack:

- Flutter 3.x
- Firebase Authentication
- Firebase Realtime Database (REST API)
- State Management: setState
- flutter_screenutil (Responsive)
- google_fonts (Typography)

## 📂 Project Structure:
```
lib/
├── main.dart
├── models/
│   └── task.dart
├── screens/
│   ├── auth_screen.dart
│   ├── home_screen.dart
│   └── add_edit_task_screen.dart
├── services/
│   ├── auth_service.dart
│   └── database_service.dart
└── widgets/
    └── task_tile.dart
```

## 🚀 Quick Start

### Prerequisites
- Flutter SDK installed
- Firebase project created

### Setup Steps

1. **Clone repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/todo-firebase-app.git
   cd todo-firebase-app
   
2. **Add Firebase config**
    - Download google-services.json from Firebase Console
    - Place in android/app/

3. **Update Database URL**
    - Open lib/services/database_service.dart
    - Replace _baseUrl with your Firebase Realtime Database URL

4. **Install dependencies**
    ```bash
   flutter pub get
   
5. **Install dependencies**
    ```bash
   flutter run