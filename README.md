# 🇮🇹 Tax Code App

A powerful and user-friendly application to calculate and manage Italian Tax Codes (Codici Fiscali) with advanced features and cross-device synchronization.

![Version](https://img.shields.io/badge/version-1.3.2-blue)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20Wear%20OS-brightgreen)
![License](https://img.shields.io/badge/license-MIT-green)

## ✨ Features

- 🧮 **Italian Tax Code Calculator**

  - Instant calculation through miocodicefiscale.com API
  - Accurate results based on personal data input
  - Barcode generation (Code39 format)

- 📸 **Smart Document Scanning**

  - ID card and health card recognition
  - Powered by Google Vision API
  - Automatic form filling from scanned data

- 💾 **Data Management**

  - Create, Read, Update, Delete operations
  - Custom card sorting and organization
  - Cross-device data synchronization

- 🔐 **Security & Authentication**

  - Google SSO integration
  - Secure data storage
  - Cloud backup with Firestore

- 🎨 **User Experience**
  - Intuitive user interface
  - Light/Dark theme support
  - Responsive design

## ⚡ Technical Stack

### Core Technologies

- **Frontend:** Flutter
- **Backend:** Firebase
- **Primary Language:** Dart
- **Wearable Support:** Kotlin

### Key Components

- 🔥 **Firebase Services**

  - Firestore (data storage)
  - Authentication
  - Remote Config
  - Analytics and Crashlytics

- 🔌 **APIs Integration**
  - Google Vision API
  - miocodicefiscale.com API

## 📱 Supported Platforms

### Mobile

- Android devices running Android 5.0 (Lollipop) and above
- Full feature set including document scanning and barcode generation

### Wear OS

- Optimized companion app for Wear OS devices
- Core features:
  - Tax code viewing
  - Barcode display
- Native wearable integration using Kotlin

## 🚀 Getting Started

1. Clone the repository
2. Configure Firebase project
3. Set up Google Vision API credentials, Google SSO and Remote Config settings
4. Run `dart pub global activate flutterfire_cli` and `flutterfire configure`
5. Run `flutter pub get` to install dependencies
6. Launch the app using `flutter run`

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Contact

For support or queries, please open an issue in the repository.

---

Made with ❤️ using Dart, Flutter and Firebase
