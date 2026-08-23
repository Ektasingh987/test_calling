import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  PermissionHelper._();

  /// Request camera and microphone permissions required for calls.
  static Future<bool> requestCallPermissions() async {
    final statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    final cameraGranted = statuses[Permission.camera]?.isGranted ?? false;
    final micGranted = statuses[Permission.microphone]?.isGranted ?? false;
    return cameraGranted && micGranted;
  }

  /// Check if both camera and mic are already granted.
  static Future<bool> hasCallPermissions() async {
    final camera = await Permission.camera.isGranted;
    final mic = await Permission.microphone.isGranted;
    return camera && mic;
  }

  /// Open app settings if permissions were permanently denied.
  static Future<void> openSettings() => openAppSettings();
}

