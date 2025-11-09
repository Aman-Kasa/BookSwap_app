# 📚 BookSwap - Student Textbook Exchange Platform

<div align="center">

![BookSwap Logo](https://img.shields.io/badge/BookSwap-Student%20Exchange-FFC107?style=for-the-badge&logo=book&logoColor=white)

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)

**A modern Flutter mobile application enabling students to exchange textbooks through a marketplace system with real-time chat functionality.**

[🚀 Live Demo](#demo) • [📖 Documentation](#documentation) • [🛠️ Installation](#installation) • [🎯 Features](#features)

</div>

---

## 🌟 Overview

BookSwap revolutionizes how students exchange textbooks by providing a seamless, real-time platform for book trading. Built with Flutter and Firebase, it offers a premium dark-themed UI with smooth animations and instant synchronization across devices.

### 👨‍💻 Developer Information
- **Developer**: Aman Kasa
- **Email**: a.kasa@alustudent.com
- **University**: African Leadership University
- **Coach/Facilitator**: Samiratu
- **Repository**: [BookSwap_app](https://github.com/Aman-Kasa/BookSwap_app.git)

---

## ✨ Features

### 🔐 **Authentication System**
- Firebase Authentication with email/password
- Email verification requirement
- Secure user session management
- Profile management with university details

### 📖 **Book Management (CRUD)**
- **Create**: Add books with photo upload and condition rating
- **Read**: Browse all available books with real-time updates
- **Update**: Edit book details, condition, and images
- **Delete**: Remove book listings with confirmation

### 🔄 **Swap System**
- Real-time swap offer creation and management
- State tracking: Available → Pending → Accepted/Rejected
- Instant notifications for swap status changes
- Owner can accept/reject incoming offers

### 💬 **Real-time Chat**
- Instant messaging between users
- Chat rooms created automatically on swap initiation
- Message history and timestamps
- User information display

### 🎨 **Premium UI/UX**
- Modern dark theme with gradient accents
- Smooth animations and transitions
- Responsive design for all screen sizes
- Intuitive navigation with animated bottom bar

### 📱 **Cross-Platform**
- Works on Android, iOS, and Web
- Consistent experience across platforms
- Optimized image handling for web and mobile

---

## 🏗️ Architecture

### **Clean Architecture Pattern**
```
lib/
├── models/          # Data models and entities
├── services/        # Firebase service layer
├── providers/       # State management (Provider pattern)
├── screens/         # UI screens and pages
├── widgets/         # Reusable UI components
└── utils/           # Utilities and themes
```

### **State Management**
- **Provider Pattern** for reactive state management
- **Stream Builders** for real-time data binding
- **Consumer Widgets** for efficient UI updates

### **Firebase Integration**
- **Firestore**: Real-time database for books, users, chats
- **Authentication**: Secure user management
- **Storage**: Image upload and CDN delivery
- **Real-time Listeners**: Instant data synchronization

---

## 🚀 Installation

### Prerequisites
- Flutter SDK (3.9.2+)
- Firebase CLI
- Android Studio / VS Code
- Git

### Setup Steps

1. **Clone the Repository**
   ```bash
   git clone https://github.com/Aman-Kasa/BookSwap_app.git
   cd BookSwap_app
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Configure FlutterFire
   flutterfire configure
   ```

4. **Configure Firebase Options**
   ```bash
   # Copy template and add your Firebase keys
   cp lib/firebase_options_template.dart lib/firebase_options.dart
   # Edit firebase_options.dart with your project keys
   ```

5. **Run the Application**
   ```bash
   # For web
   flutter run -d chrome
   
   # For mobile
   flutter run
   ```

---

## 🎯 Usage Guide

### **Getting Started**
1. **Sign Up**: Create account with university email
2. **Verify Email**: Check inbox and verify email address
3. **Add Books**: Upload your textbooks with photos
4. **Browse & Swap**: Find books and make swap offers
5. **Chat**: Communicate with other students
6. **Manage**: Track your offers and listings

### **Key Workflows**

#### **Adding a Book**
1. Tap the floating "Add Book" button
2. Fill in book details (title, author, condition)
3. Upload a cover photo
4. Submit to make it available for swapping

#### **Making a Swap Offer**
1. Browse available books
2. Tap "Swap" on desired book
3. Automatic chat room creation
4. Negotiate with book owner
5. Wait for acceptance/rejection

#### **Managing Swaps**
- **My Listings**: View your books and pending offers
- **My Offers**: Track swap requests you've made
- **Accept/Reject**: Respond to incoming swap offers

---

## 🛠️ Technical Details

### **Dependencies**
```yaml
dependencies:
  flutter: sdk
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.3
  firebase_storage: ^12.3.2
  provider: ^6.1.2
  image_picker: ^1.2.0
  flutter_image_compress: ^2.1.0
  cached_network_image: ^3.4.1
```

### **Database Schema**
```
📊 Firestore Collections:
├── users/           # User profiles and settings
├── books/           # Book listings and swap status
├── swapOffers/      # Swap offer management
└── chatRooms/       # Chat rooms and messages
    └── messages/    # Individual chat messages
```

### **State Management Flow**
```
UI Widget → Provider → Service → Firebase → Stream → Provider → UI Update
```

---

## 🎨 Screenshots

<div align="center">

| Login Screen | Browse Books | Chat Interface |
|:---:|:---:|:---:|
| ![Login](https://via.placeholder.com/250x400?text=Login+Screen) | ![Browse](https://via.placeholder.com/250x400?text=Browse+Books) | ![Chat](https://via.placeholder.com/250x400?text=Chat+Interface) |

| Add Book | My Listings | Swap Offers |
|:---:|:---:|:---:|
| ![Add](https://via.placeholder.com/250x400?text=Add+Book) | ![Listings](https://via.placeholder.com/250x400?text=My+Listings) | ![Offers](https://via.placeholder.com/250x400?text=Swap+Offers) |

</div>

---

## 🧪 Testing

### **Manual Testing Checklist**
- ✅ User registration and email verification
- ✅ Book CRUD operations with image upload
- ✅ Real-time swap offer creation and management
- ✅ Chat functionality between users
- ✅ State synchronization across multiple devices
- ✅ Responsive design on different screen sizes

### **Test Accounts**
For demo purposes, you can create test accounts or use the sample data feature in Settings.

---

## 🚀 Deployment

### **Web Deployment**
```bash
flutter build web
firebase deploy --only hosting
```

### **Mobile Deployment**
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Samiratu** - Coach and Facilitator for guidance and support
- **African Leadership University** - Educational institution
- **Flutter Team** - For the amazing framework
- **Firebase Team** - For the backend infrastructure
- **Open Source Community** - For the packages and inspiration

---

## 📞 Contact & Support

<div align="center">

**Aman Kasa**

[![Email](https://img.shields.io/badge/Email-a.kasa%40alustudent.com-red?style=for-the-badge&logo=gmail)](mailto:a.kasa@alustudent.com)
[![Phone](https://img.shields.io/badge/Phone-%2B250798694600-green?style=for-the-badge&logo=whatsapp)](tel:+250798694600)
[![GitHub](https://img.shields.io/badge/GitHub-Aman--Kasa-black?style=for-the-badge&logo=github)](https://github.com/Aman-Kasa)

**African Leadership University**

</div>

---

<div align="center">

**⭐ If you found this project helpful, please give it a star! ⭐**

Made with ❤️ by [Aman Kasa](https://github.com/Aman-Kasa)

</div>