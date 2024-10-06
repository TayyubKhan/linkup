import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nearby_connections/nearby_connections.dart';

import '../../../temporary/chat.dart';
import '../../../temporary/scan.dart';

class SearchScreenRepo {
   Strategy strategy = Strategy.P2P_STAR;

  Future<void> startAdvertising(WidgetRef ref, BuildContext context) async {
    ref.read(isAdvertisingProvider.notifier).state = true;

    try {
      await Nearby().startAdvertising(
        'AdvertiserDevice',
        strategy,
        onConnectionInitiated: (String id, ConnectionInfo info) {
          Nearby().acceptConnection(id,
              onPayLoadRecieved: (String endpointId, Payload payload) {
            String receivedMessage = String.fromCharCodes(payload.bytes!);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Received message: $receivedMessage")));
          });

          ref.read(connectedDevicesProvider.notifier).addDevice(id);
          ref.read(isConnectedProvider.notifier).state = true;
          ref.read(connectedEndpointIdProvider.notifier).state = id;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MessagingScreen(
                deviceId: id,
              ),
            ),
          );
        },
        onConnectionResult: (String id, Status status) {
          if (status == Status.CONNECTED) {
            ref.read(connectedDevicesProvider.notifier).addDevice(id);
            ref.read(isConnectedProvider.notifier).state = true;
          }
        },
        onDisconnected: (String id) {
          ref.read(connectedDevicesProvider.notifier).removeDevice(id);
          ref.read(isConnectedProvider.notifier).state = false;
        },
      );
      print("Advertising started.");
    } catch (e) {
      ref.read(isAdvertisingProvider.notifier).state = false;
      print("Error starting advertising: $e");
    }
  }

  Future<void> startDiscovery(WidgetRef ref) async {
    ref.read(isDiscoveringProvider.notifier).state = true;

    try {
      await Nearby().startDiscovery(
        'ScannerDevice',
        strategy,
        onEndpointFound: (String id, String name, String serviceId) {
          ref
              .read(discoveredDevicesProvider.notifier)
              .addDevice(DiscoveredDevice(id: id, name: name));
        },
        onEndpointLost: (String? id) {
          ref.read(discoveredDevicesProvider.notifier).removeDevice(id!);
        },
      );
      print("Discovery started.");
    } catch (e) {
      ref.read(isDiscoveringProvider.notifier).state = false;
      print("Error starting discovery: $e");
    }
  }

  void sendMessage(WidgetRef ref, String message) async {
    final connectedDevices = ref.read(connectedDevicesProvider);

    if (ref.read(isConnectedProvider)) {
      for (var device in connectedDevices) {
        await Nearby().sendBytesPayload(
          device,
          Uint8List.fromList(message.codeUnits),
        );
        print("Sent message: $message to $device");
      }
    } else {
      print("No device is connected. Cannot send message.");
    }
  }

  void connectToDevice(WidgetRef ref, String deviceId, BuildContext context) {
    Nearby().requestConnection(
      'ScannerDevice',
      deviceId,
      onConnectionInitiated: (String id, ConnectionInfo info) {
        Nearby().acceptConnection(id,
            onPayLoadRecieved: (String endpointId, Payload payload) {
          String receivedMessage = String.fromCharCodes(payload.bytes!);
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Received message: $receivedMessage")));
        });

        ref.read(connectedEndpointIdProvider.notifier).state = id;
        ref.read(connectedDevicesProvider.notifier).addDevice(id);
        ref.read(isConnectedProvider.notifier).state = true;
      },
      onConnectionResult: (String id, Status status) {
        if (status == Status.CONNECTED) {
          ref.read(connectedDevicesProvider.notifier).addDevice(id);
          ref.read(isConnectedProvider.notifier).state = true;
        }
      },
      onDisconnected: (String id) {
        ref.read(connectedDevicesProvider.notifier).removeDevice(id);
        ref.read(isConnectedProvider.notifier).state = false;
      },
    );
  }
}
