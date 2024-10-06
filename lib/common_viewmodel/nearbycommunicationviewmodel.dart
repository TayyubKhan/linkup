import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';

class NearbyCommunicationService {
  final Strategy strategy = Strategy.P2P_STAR;
  bool isAdvertising = false;
  bool isDiscovering = false;
  bool isConnected = false;
  String connectedEndpointId = '';
  List<String> connectedDevices = [];
  List<DiscoveredDevice> discoveredDevices = [];

  Future<void> startAdvertising(BuildContext context,String name) async {
    try {
      // Stop any ongoing advertisement before starting a new one
      await Nearby().stopAllEndpoints();

      isAdvertising = true;

      await Nearby().startAdvertising(
        name,
        strategy,
        onConnectionInitiated: (String id, ConnectionInfo info) {
          Nearby().acceptConnection(id, onPayLoadRecieved: (String endpointId, Payload payload) {
            String receivedMessage = String.fromCharCodes(payload.bytes!);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Received message: $receivedMessage")));
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
    } catch (e) {
      isAdvertising = false;
      print("Error starting advertising: $e");
    }
  }

  Future<void> startDiscovery(BuildContext context,String name) async {
    try {
      // Stop any ongoing discovery before starting a new one
      await Nearby().stopAllEndpoints();
      isDiscovering = true;

      await Nearby().startDiscovery(
        name,
        strategy,
        onEndpointFound: (String id, String name, String serviceId) {
          discoveredDevices.add(DiscoveredDevice(id: id, name: name));
        },
        onEndpointLost: (String? id) {
          discoveredDevices.removeWhere((device) => device.id == id);
        },
      );
    } catch (e) {
      isDiscovering = false;
      print("Error starting discovery: $e");
    }
  }

  Future<void> connectToDevice(BuildContext context, String deviceId,String name) async {
    Nearby().requestConnection(
      name,
      deviceId,
      onConnectionInitiated: (String id, ConnectionInfo info) {
        Nearby().acceptConnection(id, onPayLoadRecieved: (String endpointId, Payload payload) {
          String receivedMessage = String.fromCharCodes(payload.bytes!);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Received message: $receivedMessage")));
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

  Future<void> sendMessage(String message) async {
    if (isConnected) {
      for (var device in connectedDevices) {
        await Nearby().sendBytesPayload(
          device,
          Uint8List.fromList(message.codeUnits),
        );
      }
    } else {
      print("No device is connected. Cannot send message.");
    }
  }

  Future<void> stopServices() async {
    if (isAdvertising) await Nearby().stopAdvertising();
    if (isDiscovering) await Nearby().stopDiscovery();
  }
}

// Model for Discovered Device
class DiscoveredDevice {
  final String id;
  final String name;

  DiscoveredDevice({required this.id, required this.name});
}
