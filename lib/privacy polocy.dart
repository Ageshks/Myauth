import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        centerTitle: true,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            '''
Last updated: April 25, 2026

Thank you for using Myauth. Your privacy is important to us.

1. Information We Collect
We do not collect any personal information such as your name, email, or phone number.

2. Authentication Data
All authentication data (OTP secrets) are stored securely on your device only. We do not send any data to our servers.

3. Permissions
- Camera: Used only for scanning QR codes
- Biometric (optional): Used for app security

4. Data Usage
We only use data to generate OTP codes and ensure app functionality.

5. Data Sharing
We do not share or sell your data.

6. Security
All data is stored locally using secure storage methods.

7. Children's Privacy
Our app is not intended for children under 13.

8. Changes to Policy
We may update this policy. Changes will be reflected here.

9. Contact Us
Email: ageshksks@gmail.com
            ''',
            style: TextStyle(fontSize: 14, height: 1.6),
          ),
        ),
      ),
    );
  }
}