# AES Encryption App

A Flutter application for encrypting and decrypting text and files using the AES algorithm.  
This app features a modern UI, supports multiple screens, and uses the GetX package for routing and state management.

## Features

- **Text Encryption/Decryption:** Securely encrypt and decrypt text using AES.
- **File Encryption/Decryption:** Encrypt and decrypt files with ease.
- **Modern UI:** Uses Google Fonts and a custom hacker-themed background.
- **Navigation:** Smooth navigation with GetX.


## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Git](https://git-scm.com/downloads)
- An IDE like VS Code or Android Studio

### Installation

1. **Clone the repository:**
    ```sh
    git clone https://github.com/raotalha71/Encryption-AES-app.git
    cd Encryption-AES-app
    ```

2. **Install dependencies:**
    ```sh
    flutter pub get
    ```

3. **Run the app:**
    - For Android/iOS:
        ```sh
        flutter run
        ```
    - For Web:
        ```sh
        flutter run -d chrome
        ```
    - For Desktop (Windows/Linux/MacOS):
        ```sh
        flutter run -d windows
        # or
        flutter run -d linux
        # or
        flutter run -d macos
        ```

### Project Structure

```
lib/
├── main.dart
├── screens/
│   ├── home_screen.dart
│   ├── text_encryption.dart
│   └── file_encryption.dart
```

### Dependencies

- [flutter](https://flutter.dev/)
- [get](https://pub.dev/packages/get)
- [google_fonts](https://pub.dev/packages/google_fonts)

### Troubleshooting

- If you encounter issues, run:
    ```sh
    flutter doctor
    ```
  and follow the recommendations.

## License

MIT License (or specify your license here)

---

*Made with Flutter*
