import 'package:local_auth/local_auth.dart';

class BiometricAuthService {
  BiometricAuthService({LocalAuthentication? authentication})
    : _authentication = authentication ?? LocalAuthentication();

  final LocalAuthentication _authentication;

  Future<bool> canAuthenticate() async {
    try {
      final canAuthenticate = await _authentication.canCheckBiometrics;
      final isDeviceSupported = await _authentication.isDeviceSupported();
      return canAuthenticate && isDeviceSupported;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate(String reason) async {
    if (!await canAuthenticate()) return false;

    try {
      return _authentication.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}
