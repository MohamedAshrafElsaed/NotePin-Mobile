// lib/core/utils/permissions.dart
import 'package:permission_handler/permission_handler.dart';

class PermissionsUtil {
  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  static Future<bool> checkMicrophonePermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }
}
