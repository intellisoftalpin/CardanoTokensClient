import 'package:crypto_offline/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthApi {
  static final _auth = LocalAuthentication();

  static Future<bool> hasBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException catch(e) {
      print("hasBiometrics PlatformException = $e");
      return false;
    }
  }

  static Future<bool> getFaceId() async {
    final List<BiometricType> availableBiometrics =
        await _auth.getAvailableBiometrics();
    print(availableBiometrics);
    print(await _auth.canCheckBiometrics);
    try {
      return availableBiometrics.contains(BiometricType.face);
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> availableBiometric() async {
    final List<BiometricType> availableBiometrics =
    await _auth.getAvailableBiometrics();
    print('availableBiometrics === $availableBiometrics');
    if (availableBiometrics.isEmpty){
      return false;
    }
    else {
      return true;
    }
  }

  static Future<bool> getFingerPrint() async {
    final List<BiometricType> availableBiometrics =
        await _auth.getAvailableBiometrics();
    try {
      return availableBiometrics.contains(BiometricType.fingerprint);
    } on PlatformException catch(e) {
      print("getFingerPrint PlatformException = $e");
      return false;
    }
  }

  static Future<bool> authenticate() async {
    final isAvailable = await hasBiometrics();
    if (!isAvailable) return false;
    try {
      return await _auth.authenticate(
          localizedReason: LocaleKeys.auth_reason.tr(),
          options: const AuthenticationOptions(
            useErrorDialogs: true,
            stickyAuth: true,
            biometricOnly: true,
          ));
    } on PlatformException catch(e) {
      print("authenticate PlatformException = $e");
      return false;
    }
  }
}
