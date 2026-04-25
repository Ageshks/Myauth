import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 🔵 Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F1F3B), Color(0xFF152A54)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 🖼️ Logo Watermark
          Center(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                'assets/images/myauth.png',
                width: 250,
              ),
            ),
          ),

          // 📄 Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                ),
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Last updated: April 25, 2026\n",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),

                      const _Title("Introduction"),
                      const _Body(
                          "Thank you for using Myauth. Your privacy is important to us."),

                      const _Title("1. Information We Collect"),
                      const _Body(
                          "We do not collect any personal information such as your name, email, or phone number."),

                      const _Title("2. Authentication Data"),
                      const _Body(
                          "All authentication data (OTP secrets) are stored securely on your device only. We do not send any data to our servers."),

                      const _Title("3. Permissions"),
                      const _Body(
                          "Camera: Used only for scanning QR codes.\nBiometric (optional): Used for app security."),

                      const _Title("4. Data Usage"),
                      const _Body(
                          "We only use data to generate OTP codes and ensure app functionality."),

                      const _Title("5. Data Sharing"),
                      const _Body("We do not share or sell your data."),

                      const _Title("6. Security"),
                      const _Body(
                          "All data is stored locally using secure storage methods."),

                      const _Title("7. Children's Privacy"),
                      const _Body(
                          "Our app is not intended for children under 13."),

                      const _Title("8. Changes to Policy"),
                      const _Body(
                          "We may update this policy. Changes will be reflected here."),

                      const _Title("9. Contact Us"),
                      const _Body("Email: ageshksks@gmail.com"),

                      // 🔥 FOOTER
                      const SizedBox(height: 30),
                      const Divider(color: Colors.white12),
                      const SizedBox(height: 16),

                      Center(
                        child: Column(
                          children: [
                            Opacity(
                              opacity: 0.8,
                              child: Image.asset(
                                'assets/images/myauth.png',
                                width: 40,
                                height: 40,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Myauth",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "© 2026 Myauth",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🔹 TITLE STYLE
class _Title extends StatelessWidget {
  final String text;
  const _Title(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// 🔹 BODY STYLE
class _Body extends StatelessWidget {
  final String text;
  const _Body(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.grey[300],
        fontSize: 14,
        height: 1.6,
      ),
    );
  }
}