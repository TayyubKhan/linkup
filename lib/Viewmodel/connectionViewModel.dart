
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../temporary/scan.dart';
final connectedDevicesProvider = StateProvider<List<String>>((ref) => const []);
final connectedEndpointIdProvider = StateProvider<String>((ref) => '');
final isConnectedProvider = StateProvider<bool>((ref) => false);
final isAdvertisingProvider = StateProvider<bool>((ref) => false);
final isDiscoveringProvider = StateProvider<bool>((ref) => false);
final isLoadingProvider = StateProvider<bool>((ref) => true);
final endpointNameProvider = StateProvider<String>((ref) => '');
final discoveredDevicesProvider =
    StateProvider<List<DiscoveredDevice>>((ref) => const []);
final connectedIdProvider = StateProvider<String>((ref) => '');