# 🇮🇹 Tax Code App

A modern, fast, and user-friendly cross-platform application to calculate and manage Italian Tax Codes (*Codici Fiscali*) with offline calculation, cloud synchronization, AI-powered document scanning, and Wear OS companion support.

![Version](https://img.shields.io/badge/version-1.7.2-blue)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20Wear%20OS-brightgreen)
![Flutter](https://img.shields.io/badge/flutter-3.22%2B-02569B?logo=flutter)
![License](https://img.shields.io/badge/license-MIT-green)

---

## ✨ Features

- 🧮 **In-House Italian Tax Code Calculator**
  - Instant and 100% offline calculation using official ministerial algorithms.
  - Comprehensive database of Italian municipalities and foreign countries with Belfiore codes.
  - Barcode generation (Code39 format) for quick optical scanning at pharmacies and administrative desks.

- 📸 **Smart Document Scanning (Gemini AI)**
  - State-of-the-art multimodal document scanning (ID card / *Carta d'Identità* and Health Card / *Tessera Sanitaria*).
  - Powered by Google Vertex AI Gemini Flash models via Firebase Cloud Functions.
  - Real-time card overlay guide and automatic form autofill.

- 💾 **Data Management & Cloud Sync**
  - Offline-first local storage using Hive CE.
  - Full CRUD operations, search, and custom card ordering.
  - Real-time cross-device data synchronization via Cloud Firestore.
  - Safe guest mode with seamless migration upon Google Sign-In.

- ⌚ **Wear OS Companion App**
  - Dedicated Wear OS app written in Flutter.
  - Quick glance at saved tax codes and high-brightness barcode presentation on your smartwatch.

- 🔐 **Security & Authentication**
  - Secure Google Sign-In integration and anonymous guest access.
  - Account deletion and GDPR-compliant data wipeout with re-authentication safeguards.

- 🎨 **Modern Design & User Experience**
  - Material 3 theme ("Emerald Ledger" palette) with dynamic Dark and Light mode support.
  - Full English and Italian localization (`.arb`).
  - Haptic feedback and subtle animations.

---

## ⚡ Architecture & Tech Stack

### Monorepo Structure

```
tax_code_flutter/
├── shared/         # Core models, services, tax code logic, database & sync repositories
├── mobile/         # Main Flutter Android app with Material 3 UI & OCR camera scanner
├── wearable/       # Flutter Wear OS companion application
└── functions/      # Firebase Cloud Functions (TypeScript, Node.js, Vertex AI Gemini Flash)
```

### Technologies

- **Frontend & Companion:** Flutter & Dart (Strict Typing, `very_good_analysis`)
- **Backend & Cloud:** Firebase Cloud Functions (Node.js 24, ESM, Vitest 5.x)
- **AI & Multimodal OCR:** Google Vertex AI Gemini Flash (`gemini-3.8-flash` / `gemini-3.7-flash` with zero-redeploy dynamic config)
- **Database & Sync:** Cloud Firestore & Hive CE
- **Storage:** Firebase Cloud Storage (dynamic birthplace dataset updates)
- **Authentication:** Firebase Authentication & Google Sign-In

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `3.22.0` or higher
- Dart SDK `3.8.0` or higher
- Node.js `24.x` (for Cloud Functions development)

### Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/TommasoScalici/tax_code_flutter.git
   cd tax_code_flutter
   ```

2. **Configure Firebase:**
   Ensure you have configured your Firebase project with Firestore, Authentication (Google & Anonymous), Cloud Functions, and Cloud Storage.
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

3. **Install dependencies:**
   ```bash
   # In shared
   cd shared && flutter pub get

   # In mobile
   cd ../mobile && flutter pub get

   # In wearable
   cd ../wearable && flutter pub get

   # In functions
   cd ../functions && npm install
   ```

4. **Run tests:**
   ```bash
   # Flutter suites
   cd shared && flutter test
   cd ../mobile && flutter test
   cd ../wearable && flutter test

   # Cloud functions suite
   cd ../functions && npm test
   ```

5. **Launch the application:**
   ```bash
   cd mobile
   flutter run
   ```

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/TommasoScalici/tax_code_flutter/issues).

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
