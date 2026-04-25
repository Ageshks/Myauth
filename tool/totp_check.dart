import 'package:otp/otp.dart';
void main() {
  final secret = 'JBSWY3DPEHPK3PXP';
  print('time=0 -> ${OTP.generateTOTPCodeString(secret, 0, algorithm: Algorithm.SHA1, interval: 30, length: 6, isGoogle: true)}');
  print('time=59000 -> ${OTP.generateTOTPCodeString(secret, 59000, algorithm: Algorithm.SHA1, interval: 30, length: 6, isGoogle: true)}');
  print('time=60000 -> ${OTP.generateTOTPCodeString(secret, 60000, algorithm: Algorithm.SHA1, interval: 30, length: 6, isGoogle: true)}');
}
