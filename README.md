# 🔐 AuthGuard — Authenticator App

A secure, lightweight two-factor authentication (2FA) app that generates TOTP (Time-based One-Time Passwords) to protect your accounts.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Security](#security)
- [Environment Variables](#environment-variables)
- [API Reference](#api-reference)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

AuthGuard is a modern authenticator application that implements the TOTP standard (RFC 6238) to provide secure two-factor authentication. It works seamlessly with services like Google, GitHub, AWS, and any platform that supports TOTP-based 2FA.

---

## ✨ Features

- 🔑 **TOTP Code Generation** — Generates time-based one-time passwords that refresh every 30 seconds
- 📷 **QR Code Scanning** — Add accounts instantly by scanning QR codes
- 🔐 **Encrypted Storage** — All secrets are encrypted locally on your device
- 🌐 **Multi-Account Support** — Manage multiple accounts across different services
- 🔄 **Auto-Refresh** — Codes automatically regenerate with a countdown timer
- 📤 **Backup & Restore** — Export/import encrypted account backups
- 🌙 **Dark Mode** — Full dark and light theme support
- 📱 **Offline-First** — Works completely offline; no internet required for code generation

---

## 🛠 Tech Stack

- **Frontend** — React Native / Flutter
- **Authentication Standard** — TOTP (RFC 6238), HOTP (RFC 4226)
- **Encryption** — AES-256-GCM for local secret storage
- **QR Scanning** — Camera API with QR code parsing
- **Storage** — Encrypted local storage (Keychain on iOS, Keystore on Android)

---

## 🚀 Getting Started

### Prerequisites

- Node.js >= 18.x
- npm or yarn
- iOS Simulator / Android Emulator (or physical device)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/authguard.git
   cd authguard
   ```

2. **Install dependencies**
   ```bash
   npm install
   # or
   yarn install
   ```

3. **Start the development server**
   ```bash
   npm run start
   ```

4. **Run on your platform**
   ```bash
   # iOS
   npm run ios

   # Android
   npm run android
   ```

---

## 📖 Usage

### Adding an Account

1. Open the app and tap the **"+"** button
2. Choose one of the following methods:
   - **Scan QR Code** — Point your camera at the QR code provided by the service
   - **Enter Manually** — Input the account name and secret key manually
3. The account will appear on your dashboard with a live 6-digit code

### Using a Code

1. Open AuthGuard and find the account you need
2. Copy the 6-digit code shown (valid for 30 seconds)
3. Enter the code in the 2FA prompt of your service
4. A countdown ring indicates how long the current code is valid

### Backing Up Accounts

1. Go to **Settings → Backup & Restore**
2. Tap **Export Accounts**
3. Set an encryption password for the backup file
4. Save or share the encrypted `.authguard` backup file

---
