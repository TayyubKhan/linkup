
import '../../../core/discoveredDevicesModel.dart';

class SearchModel {
  final bool isAdvertising;
  final bool isDiscovering;
  final bool isConnected;
  final List<String> connectedDevices;
  final List<DiscoveredDevice> discoveredDevices;
  final List<String> messages;

  SearchModel({
    this.isAdvertising = false,
    this.isDiscovering = false,
    this.isConnected = false,
    this.connectedDevices = const [],
    this.discoveredDevices = const [],
    this.messages = const [],
  });

  SearchModel copyWith({
    bool? isAdvertising,
    bool? isDiscovering,
    bool? isConnected,
    List<String>? connectedDevices,
    List<DiscoveredDevice>? discoveredDevices,
    List<String>? messages,
  }) {
    return SearchModel(
      isAdvertising: isAdvertising ?? this.isAdvertising,
      isDiscovering: isDiscovering ?? this.isDiscovering,
      isConnected: isConnected ?? this.isConnected,
      connectedDevices: connectedDevices ?? this.connectedDevices,
      discoveredDevices: discoveredDevices ?? this.discoveredDevices,
      messages: messages ?? this.messages,
    );
  }
}
