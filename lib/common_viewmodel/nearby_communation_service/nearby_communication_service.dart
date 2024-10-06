import 'dart:typed_data';
import 'package:linkup/features/continue/model/ConitnueModel.dart';
import 'package:linkup/features/continue/viewModel/ContinueViewModel.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'nearby_communication_service.g.dart';

@riverpod
class NearbyCommunicationService extends _$NearbyCommunicationService {
  final Strategy strategy = Strategy.P2P_STAR;
  bool isAdvertising = false;
  bool isDiscovering = false;
  bool isConnected = false;
  String connectedEndpointId = '';
  List<String> connectedDevices = [];
  List<DiscoveredDevice> discoveredDevices = [];
  ContinueModel? name;
  @override
  Future<List<DiscoveredDevice>> build() async {
    name = await ref.read(continueViewModelProvider.future)!;
    discoveredDevices = await startDiscovery();
    return discoveredDevices;
    // Initialize the service
  }

  // Start advertising
  void startAdvertising() async {
    // Stop any ongoing advertisement before starting a new one
    await Nearby().stopAllEndpoints();
    isAdvertising = true;

    Nearby().startAdvertising(
      name!.name!,
      strategy,
      onConnectionInitiated: (String id, ConnectionInfo info) {
        Nearby().acceptConnection(id,
            onPayLoadRecieved: (String endpointId, Payload payload) {
          handleReceivedMessage(endpointId, payload);
        });
        connectedDevices.add(id);
        connectedEndpointId = id;
        isConnected = true;
      },
      onConnectionResult: (String id, Status status) {
        if (status == Status.CONNECTED) {
          connectedDevices.add(id);
          isConnected = true;
        }
      },
      onDisconnected: (String id) {
        connectedDevices.remove(id);
        isConnected = false;
      },
    );
  }

  // Start discovery
  Future<List<DiscoveredDevice>> startDiscovery() async {
    await Nearby().stopAllEndpoints();
    isDiscovering = true;

    Nearby().startDiscovery(
      name!.name!,
      strategy,
      onEndpointFound: (String id, String name, String serviceId) {
        discoveredDevices.add(DiscoveredDevice(id: id, name: name));
      },
      onEndpointLost: (String? id) {
        discoveredDevices.removeWhere((device) => device.id == id);
      },
    );
    return discoveredDevices;
  }

  // Connect to a device
  void connectToDevice(String deviceId) async {
    Nearby().requestConnection(
      name!.name!,
      deviceId,
      onConnectionInitiated: (String id, ConnectionInfo info) {
        Nearby().acceptConnection(id,
            onPayLoadRecieved: (String endpointId, Payload payload) {
          handleReceivedMessage(endpointId, payload);
        });
        connectedEndpointId = id;
        connectedDevices.add(id);
        isConnected = true;
      },
      onConnectionResult: (String id, Status status) {
        if (status == Status.CONNECTED) {
          connectedDevices.add(id);
          isConnected = true;
        }
      },
      onDisconnected: (String id) {
        connectedDevices.remove(id);
        isConnected = false;
      },
    );
  }

  // Send a message to the connected devices
  void sendMessage(String message) async {
    if (isConnected) {
      for (var device in connectedDevices) {
        await Nearby().sendBytesPayload(
          device,
          Uint8List.fromList(message.codeUnits),
        );
      }
    }
  }

  // Stop Nearby services
  void stopServices() async {
    if (isAdvertising) await Nearby().stopAdvertising();
    if (isDiscovering) await Nearby().stopDiscovery();
  }

  // Handle message reception and filter based on advertising name
  void receiveMessagesByAdvName(
      String advName, void Function(String message) onMessageReceived) {
    if (isConnected && connectedDevices.contains(connectedEndpointId)) {
      for (var device in connectedDevices) {
        // Ensure we are only receiving messages from the desired advertising name
        if (discoveredDevices.any((d) => d.name == advName)) {
          Nearby().acceptConnection(
            device,
            onPayLoadRecieved: (String endpointId, Payload payload) {
              String receivedMessage = String.fromCharCodes(payload.bytes!);
              onMessageReceived(receivedMessage);
            },
          );
        }
      }
    }
  }

  // Private function to handle received messages
  void handleReceivedMessage(String endpointId, Payload payload) {
    if (payload.bytes != null) {
      String receivedMessage = String.fromCharCodes(payload.bytes!);
      // You can handle the received message here as needed or trigger other events.
    }
  }
}

// Model for Discovered Device
class DiscoveredDevice {
  final String id;
  final String name;

  DiscoveredDevice({required this.id, required this.name});
}
