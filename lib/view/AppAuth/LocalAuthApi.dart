import 'package:crypto_offline/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthApi {
  LocalAuthentication _auth = LocalAuthentication();

  Future<bool> hasBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException catch(e) {
      print("hasBiometrics PlatformException = $e");
      return false;
    }
  }

  Future<bool> getFaceId() async {
    List<BiometricType> availableBiometrics =
        await _auth.getAvailableBiometrics();
    print(availableBiometrics);
    print(await _auth.canCheckBiometrics);
    try {
      return availableBiometrics.contains(BiometricType.face);
    } on PlatformException {
      return false;
    }
  }

  Future<bool> availableBiometric() async {
    List<BiometricType> availableBiometrics =
    await _auth.getAvailableBiometrics();
    print('availableBiometrics === $availableBiometrics');
    if (availableBiometrics.isEmpty){
      return false;
    }
    else {
      return true;
    }
  }

  Future<bool> getFingerPrint() async {
    List<BiometricType> availableBiometrics =
        await _auth.getAvailableBiometrics();
    try {
      return availableBiometrics.contains(BiometricType.fingerprint);
    } on PlatformException catch(e) {
      print("getFingerPrint PlatformException = $e");
      return false;
    }
  }

  Future<bool> authenticate() async {
    bool isAvailable = await hasBiometrics();
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
