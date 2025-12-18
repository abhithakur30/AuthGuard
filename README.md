# AuthGuard

AuthGuard is a Flutter-based mobile authentication application designed to function as a secure authenticator similar to Google Authenticator or Authy, with additional enterprise-oriented controls such as remote disablement, secure storage, and FIDO-based authentication hooks. The application is architected with clear separation of concerns across UI, services, models, and utilities.

---

## 1. High-Level Architecture

AuthGuard follows a layered Flutter architecture:

* **UI Layer (Screens):** Handles user interaction and navigation
* **Service Layer:** Encapsulates security, authentication, storage, and remote configuration logic
* **Model Layer:** Defines data structures used across the app
* **Utility Layer:** Provides helpers for parsing and transformation
* **Backend Integration:** Supabase is used for backend services and remote control

State management is handled using the **Provider** package.

---

## 2. Core Features

* Time-based One-Time Password (TOTP) generation
* QR code scanning for account onboarding
* Manual TOTP account entry
* Secure credential storage
* App-level lock/unlock flow
* Remote app disable capability
* Supabase backend integration
* Environment-based configuration using dotenv
* FIDO service abstraction (future-ready)

---

## 3. Project Structure

```
Authguard1-main/
├── main.dart
├── supabase_initializer.dart
├── models/
│   └── account_model.dart
├── screens/
│   ├── home_screen.dart
│   ├── login_screen.dart
│   ├── unlock_screen.dart
│   ├── add_account_screen.dart
│   ├── manual_entry_screen.dart
│   ├── qr_scanner_screen.dart
│   └── disabled_screen.dart
├── services/
│   ├── secure_storage_service.dart
│   ├── totp_service.dart
│   ├── fido_service.dart
│   └── remote_config_service.dart
└── utils/
    └── uri_parser.dart
```

---

## 4. Entry Point

### `main.dart`

* Loads environment variables using `flutter_dotenv`
* Initializes Supabase via `supabase_initializer.dart`
* Sets up Providers (SecureStorageService, RemoteConfigService)
* Defines app routes and initial navigation logic

The app dynamically decides which screen to load based on:

* Remote disable flag
* Authentication / unlock state

---

## 5. Screens (UI Layer)

### Home Screen

* Displays registered TOTP accounts
* Generates and refreshes OTP codes
* Entry point for adding new accounts

### Login Screen

* Handles Supabase-backed authentication (if enabled)

### Unlock Screen

* Local app-level security gate
* Can be extended for biometric / PIN unlock

### Add Account Screen

* Entry hub for adding new authenticators
* Routes to QR scanner or manual entry

### QR Scanner Screen

* Scans `otpauth://` URIs
* Parses and registers TOTP secrets

### Manual Entry Screen

* Allows manual input of:

  * Issuer
  * Account name
  * Secret key

### Disabled Screen

* Rendered when app is remotely disabled
* Controlled via remote config

---

## 6. Services Layer

### SecureStorageService

* Wraps secure local storage
* Stores secrets, account metadata, and flags
* Abstracted to allow future platform changes

### TOTPService

* Implements RFC 6238-compliant TOTP generation
* Handles time windowing and OTP refresh logic

### FIDOService

* Placeholder abstraction for FIDO / passkey integration
* Intended for hardware-backed authentication expansion

### RemoteConfigService

* Fetches remote flags from Supabase
* Enables centralized control (e.g., kill-switch)
* Evaluated at startup and runtime

---

## 7. Model Layer

### AccountModel

Represents a registered TOTP account:

* Issuer
* Account label
* Secret key
* Algorithm / digits / period (extensible)

Used by both UI and TOTP service for rendering and OTP generation.

---

## 8. Utilities

### URI Parser

* Parses `otpauth://totp/...` URIs
* Extracts issuer, label, secret, and parameters
* Shared between QR scanner and manual flows

---

## 9. Backend Integration

### Supabase

* Initialized in `supabase_initializer.dart`
* Used for:

  * Authentication (optional)
  * Remote configuration

Environment variables expected:

```
SUPABASE_URL=...
SUPABASE_ANON_KEY=...
```

---

## 10. Security Considerations

* Secrets are never stored in plaintext outside secure storage
* App can be remotely disabled if compromised
* Architecture supports future biometric and FIDO expansion
* No secrets are hardcoded

---

## 11. Build & Run

1. Install Flutter SDK
2. Configure `.env` file
3. Run:

```
flutter pub get
flutter run
```

---

## 12. Extensibility Roadmap

* Biometric unlock (Face ID / Fingerprint)
* Hardware-backed FIDO authentication
* Cloud sync with encrypted secrets
* Multi-device account recovery
* Enterprise MDM integration

---

## 13. Intended Use Cases

* Personal 2FA authenticator
* Enterprise secure access companion
* Research / academic security prototype
* Foundation for passkey-based authentication apps

---

## 14. License & Disclaimer

This project is intended for educational and research purposes. Review and audit all cryptographic and storage implementations before production use.
