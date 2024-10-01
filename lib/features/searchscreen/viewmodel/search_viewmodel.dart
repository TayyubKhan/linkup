import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_viewmodel.g.dart'; // For code generation

// State class for holding the Bluetooth ChatModel state.
class BluetoothChatModelState {
  final List<BluetoothDevice> connectedDevices;
  final bool isScanning;
  final bool isAdvertising;
  final List<String> receivedmessages;

  BluetoothChatModelState({
    this.connectedDevices = const [],
    this.isScanning = false,
    this.isAdvertising = false,
    this.receivedmessages = const [],
  });

  BluetoothChatModelState copyWith({
    List<BluetoothDevice>? connectedDevices,
    bool? isScanning,
    bool? isAdvertising,
    List<String>? receivedmessages,
  }) {
    return BluetoothChatModelState(
      connectedDevices: connectedDevices ?? this.connectedDevices,
      isScanning: isScanning ?? this.isScanning,
      isAdvertising: isAdvertising ?? this.isAdvertising,
      receivedmessages: receivedmessages ?? this.receivedmessages,
    );
  }
}

@riverpod
class BluetoothChatModelController extends _$BluetoothChatModelController {

  @override
  BluetoothChatModelState build() {
    _initializeBluetoothService();
    return BluetoothChatModelState();
  }

  // Initialize Bluetooth scanning and connection listeners.
  void _initializeBluetoothService() {
    // Get currently connected devices
    List<BluetoothDevice> devices = FlutterBluePlus.connectedDevices;
    state = state.copyWith(connectedDevices: devices);

    // Listen for scan results and update state with discovered devices
    FlutterBluePlus.scanResults.listen((results) {
      final devices = results.map((r) => r.device).toList();
      state = state.copyWith(connectedDevices: devices);
    });
  }

  // Request necessary Bluetooth permissions.
  Future<void> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetooth,
      Permission.locationWhenInUse, // Location might also be needed for scanning on Android
    ].request();

    if (statuses.values.any((status) => !status.isGranted)) {
      throw Exception('Bluetooth permissions are required.');
    }
  }

  // Start scanning for Bluetooth devices.
  Future<void> startScanning() async {
    await requestPermissions();
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    state = state.copyWith(isScanning: true);
  }

  // Stop scanning for Bluetooth devices.
  Future<void> stopScanning() async {
    await FlutterBluePlus.stopScan();
    state = state.copyWith(isScanning: false);
  }

  // Connect to a discovered Bluetooth device.
  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect();
    // Get updated list of connected devices
    List<BluetoothDevice> devices = FlutterBluePlus.connectedDevices;
    state = state.copyWith(connectedDevices: devices);
  }

  // Disconnect from a connected Bluetooth device.
  Future<void> disconnectFromDevice(BluetoothDevice device) async {
    await device.disconnect();
    state = state.copyWith(
      connectedDevices: state.connectedDevices
          .where((d) => d.id != device.id)
          .toList(),
    );
  }

  // Reset the state (used for cleanup).
  void resetState() {
    state = BluetoothChatModelState();
  }
}
