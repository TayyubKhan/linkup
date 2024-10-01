// A provider to manage and check permissions
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

final permissionProvider =
    StateNotifierProvider<PermissionNotifier, bool>((ref) {
  return PermissionNotifier();
});

// Permission Notifier to manage state related to permissions
class PermissionNotifier extends StateNotifier<bool> {
  PermissionNotifier() : super(false) {
    _checkPermissions(); // Initial check when the app starts
  }

  // Method to check and request necessary permissions
  Future<void> _checkPermissions() async {
    final bluetoothStatus = await Permission.bluetooth.request();
    final locationStatus = await Permission.location.request();

    if (bluetoothStatus.isGranted && locationStatus.isGranted) {
      state = true; // All permissions granted
    } else {
      state = false; // One or more permissions denied
    }
  }

  // Method to request permissions again (e.g., on button click)
  Future<void> requestPermissions() async {
    await _checkPermissions();
  }
}
