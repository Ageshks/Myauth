import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:myauth/privacy%20polocy.dart';
import 'package:otp/otp.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF08101E),
      ),
      home: SplashPage(),
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 1700), () {
      Get.off(() => HomePage());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F1F3B), Color(0xFF152A54)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset(
        'assets/images/myauth.png',
        width: 140,
        height: 140,
        fit: BoxFit.contain,
      ),

      SizedBox(height: 24),

      Text(
        'Authenticator',
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
      ),

      SizedBox(height: 8),

      Text(
        'Secure OTP storage',
        style: TextStyle(
          color: Colors.grey[300],
          fontSize: 16,
        ),
      ),

      SizedBox(height: 24),

      CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Color(0xFF4F7BFF)),
      ),
    ],
  ),
),
      ),
    );
  }
}

// MODEL
class AccountModel {
  final String issuer;
  final String accountName;
  final String secret;
  final int interval;
  final int digits;
  final Algorithm algorithm;

  AccountModel({
    required this.issuer,
    required this.accountName,
    required this.secret,
    this.interval = 30,
    this.digits = 6,
    this.algorithm = Algorithm.SHA1,
  });
}

Algorithm parseAlgorithm(String value) {
  switch (value.toUpperCase()) {
    case 'SHA256':
      return Algorithm.SHA256;
    case 'SHA512':
      return Algorithm.SHA512;
    default:
      return Algorithm.SHA1;
  }
}

String algorithmToString(Algorithm algorithm) {
  switch (algorithm) {
    case Algorithm.SHA256:
      return 'SHA256';
    case Algorithm.SHA512:
      return 'SHA512';
    case Algorithm.SHA1:
      return 'SHA1';
  }
}

// 🔐 FIXED TOTP (FINAL)
class TOTPService {
  static String generate(
    String secret, {
    int interval = 30,
    int length = 6,
    Algorithm algorithm = Algorithm.SHA1,
  }) {
    return OTP.generateTOTPCodeString(
      secret.replaceAll(' ', '').toUpperCase(), // 🔥 FIX
      DateTime.now().millisecondsSinceEpoch,    // 🔥 FIX
      interval: interval,
      length: length,
      algorithm: algorithm,
      isGoogle: true,
    );
  }
}

// STORAGE
class StorageService {
  final _storage = FlutterSecureStorage();

  Future<void> save(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<Map<String, String>> getAll() async {
    return await _storage.readAll();
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }
}

// CONTROLLER
class HomeController extends GetxController {
  var accounts = <AccountModel>[].obs;
  var time = DateTime.now().obs;

  final storage = StorageService();
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    loadAccounts();
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      time.value = DateTime.now();
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void loadAccounts() async {
    final data = await storage.getAll();
    accounts.value = data.entries
        .where((e) => e.key != 'settings')
        .map((e) {
      final parts = e.value.split('|');
      if (parts.length < 3 || parts[2].trim().isEmpty) {
        return null;
      }
      return AccountModel(
        issuer: parts[0],
        accountName: parts[1],
        secret: parts[2],
        interval: parts.length > 3 ? int.tryParse(parts[3]) ?? 30 : 30,
        digits: parts.length > 4 ? int.tryParse(parts[4]) ?? 6 : 6,
        algorithm: parts.length > 5 ? parseAlgorithm(parts[5]) : Algorithm.SHA1,
      );
    }).whereType<AccountModel>().toList();
  }

  void addAccount(AccountModel acc) async {
    await storage.save(
      acc.accountName,
      "${acc.issuer}|${acc.accountName}|${acc.secret}|${acc.interval}|${acc.digits}|${algorithmToString(acc.algorithm)}",
    );
    loadAccounts();
  }

  void deleteAccount(String key) async {
    await storage.delete(key);
    loadAccounts();
  }

  String serializeAccounts() {
    final list = accounts.map((acc) => {
          'issuer': acc.issuer,
          'accountName': acc.accountName,
          'secret': acc.secret,
          'interval': acc.interval,
          'digits': acc.digits,
          'algorithm': algorithmToString(acc.algorithm),
        }).toList();
    return jsonEncode(list);
  }

  List<int> _deriveKey(String password, String salt) {
    return sha256.convert(utf8.encode(password + salt)).bytes;
  }

  Future<String> createEncryptedExport(String password) async {
    final jsonData = serializeAccounts();
    final saltBytes = encrypt.IV.fromSecureRandom(16).bytes;
    final salt = base64Encode(saltBytes);
    final keyHash = _deriveKey(password, salt);
    final key = encrypt.Key(Uint8List.fromList(keyHash));
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    final encrypted = encrypter.encrypt(jsonData, iv: iv);

    final payload = jsonEncode({
      'salt': salt,
      'iv': base64Encode(iv.bytes),
      'data': encrypted.base64,
    });
    return base64Encode(utf8.encode(payload));
  }

  Future<List<AccountModel>> decryptImport(String encryptedPayload, String password) async {
    final decoded = utf8.decode(base64Decode(encryptedPayload));
    final payload = jsonDecode(decoded) as Map<String, dynamic>;
    final salt = payload['salt'] as String;
    final iv = encrypt.IV(base64Decode(payload['iv'] as String));
    final data = payload['data'] as String;
    final keyHash = _deriveKey(password, salt);
    final key = encrypt.Key(Uint8List.fromList(keyHash));
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    final decrypted = encrypter.decrypt64(data, iv: iv);
    final list = jsonDecode(decrypted) as List<dynamic>;
    return list.map((item) {
      final map = item as Map<String, dynamic>;
      return AccountModel(
        issuer: map['issuer'] as String,
        accountName: map['accountName'] as String,
        secret: map['secret'] as String,
        interval: (map['interval'] as num).toInt(),
        digits: (map['digits'] as num).toInt(),
        algorithm: parseAlgorithm(map['algorithm'] as String),
      );
    }).toList();
  }

  Future<void> importAccounts(String encryptedPayload, String password) async {
    final imported = await decryptImport(encryptedPayload, password);
    for (var account in imported) {
      await storage.save(
        account.accountName,
        "${account.issuer}|${account.accountName}|${account.secret}|${account.interval}|${account.digits}|${algorithmToString(account.algorithm)}",
      );
    }
    loadAccounts();
  }

  String getCode(AccountModel acc) {
    return TOTPService.generate(
      acc.secret,
      interval: acc.interval,
      length: acc.digits,
      algorithm: acc.algorithm,
    );
  }

  String formatCode(String code) {
    if (code.length == 6) {
      return "${code.substring(0, 3)} ${code.substring(3)}";
    }
    return code;
  }

  double getProgress() {
    final ms = time.value.millisecondsSinceEpoch;
    final seconds = (ms / 1000) % 30;
    return seconds / 30;
  }

  int getRemainingSeconds() {
    final sec = time.value.second;
    return 30 - (sec % 30);
  }
}

// UI (MODERN)
class HomePage extends StatelessWidget {
  final controller = Get.put(HomeController());

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
  title: Row(
    children: [
      Image.asset(
        'assets/images/myauth.png',
        height: 28,
      ),
      SizedBox(width: 10),
      Text(
        "Myauth",
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
    ],
  ),
  actions: [
    IconButton(
      icon: Icon(Icons.privacy_tip_outlined),
      tooltip: 'Privacy Policy',
      onPressed: () => Get.to(() => const PrivacyPolicyPage()),
    ),
    IconButton(
      icon: Icon(Icons.upload_file_outlined),
      tooltip: 'Export accounts',
      onPressed: () => showExportDialog(context),
    ),
    IconButton(
      icon: Icon(Icons.download_outlined),
      tooltip: 'Import accounts',
      onPressed: () => showImportDialog(context),
    ),
  ],
  flexibleSpace: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF0E1A33), Color(0xFF172E52)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ),
),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => ScanPage()),
        backgroundColor: Color(0xFF4F7BFF),
        child: Icon(Icons.add, size: 28),
      ),
      body: Obx(() {
        controller.time.value;

        return SafeArea(
          top: true,
          child: Column(
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Your secure codes',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Authenticator',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Fast access to your two-factor codes.',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18),
              Expanded(
                child: controller.accounts.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF101C33),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white12),
                          ),
                          padding: EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock_outline,
                                  size: 48, color: Colors.blue[200]),
                              SizedBox(height: 18),
                              Text(
                                'No accounts yet',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Scan a QR code to add your first account and start generating codes instantly.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        itemCount: controller.accounts.length,
                        separatorBuilder: (_, __) => SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final acc = controller.accounts[i];
                          return Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF101C33),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha((0.18 * 255).round()),
                                  blurRadius: 20,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFF4F7BFF),
                                              Color(0xFF6C9DFF),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: Center(
                                          child: Text(
                                            acc.issuer.isNotEmpty
                                                ? acc.issuer[0].toUpperCase()
                                                : '?',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 22),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              acc.issuer,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              acc.accountName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.grey[400],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          onTap: () => controller
                                              .deleteAccount(acc.accountName),
                                          child: Padding(
                                            padding: EdgeInsets.all(8),
                                            child: Icon(
                                              Icons.delete_outline,
                                              color: Colors.grey[500],
                                              size: 22,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 18),
                                  Text(
                                    controller.formatCode(
                                        controller.getCode(acc)),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 38,
                                      letterSpacing: 5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 18),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: LinearProgressIndicator(
                                            minHeight: 8,
                                            value: controller.getProgress(),
                                            color: Color(0xFF4F7BFF),
                                            backgroundColor: Colors.white10,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 14),
                                      Text(
                                        '${controller.getRemainingSeconds()}s',
                                        style: TextStyle(
                                          color: Colors.grey[350],
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> showExportDialog(BuildContext context) async {
    final passwordController = TextEditingController();
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Export Accounts'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter export password',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (passwordController.text.trim().isNotEmpty) {
                Get.back(result: true);
              }
            },
            child: Text('Export'),
          ),
        ],
      ),
    );

    if (result == true) {
      final exportString = await controller.createEncryptedExport(passwordController.text.trim());
      await Get.dialog(
        AlertDialog(
          title: Text('Encrypted Export'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 220,
                  width: 220,
                  child: QrImageView(
                    data: exportString,
                    size: 220,
                  ),
                ),
                SizedBox(height: 14),
                SelectableText(exportString),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: exportString));
                Get.snackbar('Copied', 'Export text copied to clipboard');
              },
              child: Text('Copy'),
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> showImportDialog(BuildContext context) async {
    final importController = TextEditingController();
    final passwordController = TextEditingController();

    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Import Accounts'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: importController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Encrypted payload',
                  hintText: 'Paste encrypted export text here',
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter export password',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (importController.text.trim().isNotEmpty &&
                  passwordController.text.trim().isNotEmpty) {
                Get.back(result: true);
              }
            },
            child: Text('Import'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await controller.importAccounts(
          importController.text.trim(),
          passwordController.text.trim(),
        );
        Get.snackbar('Success', 'Accounts imported successfully');
      } catch (e) {
        Get.snackbar('Import failed', 'Invalid payload or password');
      }
    }
  }
}

// SCANNER
class ScanPage extends StatelessWidget {
  final controller = Get.find<HomeController>();

  ScanPage({super.key});

  AccountModel parse(String url) {
    final uri = Uri.parse(url.trim());
    final params = Map<String, String>.fromEntries(
      uri.queryParameters.entries
          .map((e) => MapEntry(e.key.toLowerCase(), e.value)),
    );

    final secret = params['secret'] ?? '';
    final issuer = params['issuer'] ?? 'Unknown';

    final label = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
    final parts = label.split(':');
    final accountName =
        parts.length > 1 ? parts.sublist(1).join(':') : label;

    final interval = int.tryParse(params['period'] ?? params['interval'] ?? '30') ?? 30;
    final digits = int.tryParse(params['digits'] ?? '6') ?? 6;
    final algorithm = parseAlgorithm(params['algorithm'] ?? 'SHA1');

    return AccountModel(
      issuer: issuer,
      accountName: accountName.isNotEmpty ? accountName : issuer,
      secret: secret,
      interval: interval,
      digits: digits,
      algorithm: algorithm,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan QR")),
      body: MobileScanner(
        onDetect: (barcode) {
          final String? code = barcode.barcodes.first.rawValue;
          if (code != null) {
            controller.addAccount(parse(code));
            Get.back();
          }
        },
      ),
    );
  }
}