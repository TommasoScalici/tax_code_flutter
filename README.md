# 🇮🇹 Tax Code App

A modern, fast, and user-friendly cross-platform application to calculate and manage Italian Tax Codes (*Codici Fiscali*) with offline calculation, cloud synchronization, AI-powered document scanning, and Wear OS companion support.

![Version](https://img.shields.io/badge/version-2.0.0-blue)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20Wear%20OS-brightgreen)
![Flutter](https://img.shields.io/badge/flutter-3.22%2B-02569B?logo=flutter)
![License](https://img.shields.io/badge/license-MIT-green)

---

## ✨ Features

- 🧮 **In-House Italian Tax Code Calculator**
  - Instant and 100% offline calculation using official ministerial algorithms.
  - Comprehensive database of Italian municipalities and foreign countries with Belfiore codes.
  - Barcode generation (Code 39 & Code 128) for quick optical scanning at pharmacies and administrative desks.

- 📸 **Smart Document Scanning (Gemini AI)**
  - State-of-the-art multimodal document scanning (ID card / *Carta d'Identità* and Health Card / *Tessera Sanitaria*).
  - Powered by Google Vertex AI Gemini Flash models via Firebase Cloud Functions.
  - Real-time card overlay guide and automatic form autofill.

- 💾 **Data Management & Cloud Sync**
  - Offline-first local storage using Hive CE.
  - Full CRUD operations, search, and custom card ordering.
  - Real-time cross-device data synchronization via Cloud Firestore.
  - Safe guest mode with seamless migration upon Google Sign-In.

- ⌚ **Pure Flutter Wear OS Companion App**
  - Modern, 100% Pure Flutter architecture with zero legacy native Android fragments.
  - **Rotary Input Support**: Smooth crown and physical bezel scrolling.
  - **Dual Optical Presentation**: Instant tap-toggle between 1D Barcode (Code 128) and 2D QR Code with automatic display brightness boost for laser and camera scanners.
  - **Gesture Navigation**: Swipe-to-dismiss gesture to quickly return to the contact list.
  - **Adaptive & Responsive Layout**: Calibrated for round, small-round (384x384 / 1.2"), and square smartwatch screens.
  - Real-time Cloud Firestore synchronization and standalone Google Sign-In.

- 🔐 **Security & Authentication**
  - Secure Google Sign-In integration and anonymous guest access.
  - Account deletion and GDPR-compliant data wipeout with re-authentication safeguards.

- 🎨 **Modern Design System & UX**
  - Unified Material 3 design system (**"Emerald Ledger"** palette) shared across mobile and wearable.
  - Deep OLED dark-mode optimization with emerald accents.
  - Full English and Italian localization (`.arb`) with automated sorting scripts.
  - Haptic feedback and subtle animations.

---

## ⚡ Architecture & Tech Stack

### Monorepo Structure

```
tax_code_flutter/
├── shared/         # Core models, services, tax code logic, database, sync & shared theme tokens
├── mobile/         # Main Flutter Android app with Material 3 UI & OCR camera scanner
├── wearable/       # Pure Flutter Wear OS companion app with rotary scroll & barcode display
├── functions/      # Firebase Cloud Functions (TypeScript, Node.js, Vertex AI Gemini Flash)
└── scripts/        # Repository maintenance tools (e.g. batch ARB sorting)
```

### Technologies

- **Frontend & Companion:** Flutter & Dart (Strict Typing, `very_good_analysis`)
- **Design System:** Material 3 "Emerald Ledger" tokens centralized in `shared`
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

5. **Launch the applications:**
   ```bash
   # Main mobile app (Android phone / emulator)
   cd mobile
   flutter run

   # Wear OS companion app (Smartwatch / Wear emulator)
   cd wearable
   flutter run -d <emulator-or-device-id>
   ```

6. **Maintenance & Tools:**
   ```bash
   # Format and sort all ARB localization files alphabetically
   dart scripts/sort_arb.dart
   ```

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/TommasoScalici/tax_code_flutter/issues).

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
