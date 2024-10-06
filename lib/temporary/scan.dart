import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart';

class NearbyCommunicationScreen extends StatefulWidget {
  @override
  _NearbyCommunicationScreenState createState() =>
      _NearbyCommunicationScreenState();
}

class _NearbyCommunicationScreenState extends State<NearbyCommunicationScreen> {
  final Strategy strategy = Strategy.P2P_STAR;
  List<String> connectedDevices = [];
  List<DiscoveredDevice> discoveredDevices = [];
  bool isConnected = false;
  String connectedEndpointId = '';
  bool isAdvertising = false;
  bool isDiscovering = false;

  @override
  void initState() {
    super.initState();
    permission();
  }

  Future<void> permission() async {
    // Request location permission
    await Permission.location.request();
    await Location.instance.requestService();

    // Request external storage permission
    await Permission.storage.request();

    // Request Bluetooth permissions
    await [
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
    ].request();

    // Android 12+
    await Permission.nearbyWifiDevices.request();
  }

  Future<void> startAdvertising() async {
    setState(() {
      isAdvertising = true;
    });

    try {
      await Nearby().startAdvertising(
        'AdvertiserDevice',
        strategy,
        onConnectionInitiated: (String id, ConnectionInfo info) {
          Nearby().acceptConnection(id,
              onPayLoadRecieved: (String endpointId, Payload payload) {
            String receivedMessage = String.fromCharCodes(payload.bytes!);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Received message: $receivedMessage")),
            );
          });

          setState(() {
            connectedDevices.add(id);
            connectedEndpointId = id;
            isConnected = true;
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MessagingScreen(
                deviceId: id,
                sendMessage: sendMessage,
              ),
            ),
          );
        },
        onConnectionResult: (String id, Status status) {
          if (status == Status.CONNECTED) {
            setState(() {
              connectedDevices.add(id);
              isConnected = true;
            });
          }
        },
        onDisconnected: (String id) {
          setState(() {
            connectedDevices.remove(id);
            isConnected = false;
          });
        },
      );
      print("Advertising started.");
    } catch (e) {
      setState(() {
        isAdvertising = false;
      });
      print("Error starting advertising: $e");
    }
  }

  Future<void> startDiscovery() async {
    setState(() {
      isDiscovering = true;
    });

    try {
      await Nearby().startDiscovery(
        'ScannerDevice',
        strategy,
        onEndpointFound: (String id, String name, String serviceId) {
          setState(() {
            discoveredDevices.add(DiscoveredDevice(id: id, name: name));
          });
        },
        onEndpointLost: (String? id) {
          setState(() {
            discoveredDevices.removeWhere((device) => device.id == id);
          });
        },
      );
      print("Discovery started.");
    } catch (e) {
      setState(() {
        isDiscovering = false;
      });
      print("Error starting discovery: $e");
    }
  }

  // Send Message to Connected Device
  void sendMessage(String message) async {
    if (isConnected) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Communication"),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: !isAdvertising ? startAdvertising : null,
            child: const Text('Start Advertising'),
          ),
          ElevatedButton(
            onPressed: !isDiscovering ? startDiscovery : null,
            child: const Text('Start Discovering'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: discoveredDevices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(discoveredDevices[index].name),
                  onTap: () {
                    connectToDevice(discoveredDevices[index].id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Connect to a discovered device
  void connectToDevice(String deviceId) {
    Nearby().requestConnection(
      'ScannerDevice',
      deviceId,
      onConnectionInitiated: (String id, ConnectionInfo info) {
        Nearby().acceptConnection(id,
            onPayLoadRecieved: (String endpointId, Payload payload) {
          String receivedMessage = String.fromCharCodes(payload.bytes!);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Received message: $receivedMessage")),
          );
        });

        setState(() {
          connectedEndpointId = id;
          connectedDevices.add(id);
          isConnected = true;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessagingScreen(
              deviceId: id,
              sendMessage: sendMessage,
            ),
          ),
        );
      },
      onConnectionResult: (String id, Status status) {
        if (status == Status.CONNECTED) {
          setState(() {
            connectedDevices.add(id);
            isConnected = true;
          });
        }
      },
      onDisconnected: (String id) {
        setState(() {
          connectedDevices.remove(id);
          isConnected = false;
        });
      },
    );
  }
}

// Model for Discovered Device
class DiscoveredDevice {
  final String id;
  final String name;

  DiscoveredDevice({required this.id, required this.name});
}

class MessagingScreen extends StatelessWidget {
  final String deviceId;
  final Function(String) sendMessage; // Function to send message

  const MessagingScreen(
      {super.key, required this.deviceId, required this.sendMessage});

  @override
  Widget build(BuildContext context) {
    TextEditingController messageController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Messaging"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: messageController,
              decoration: const InputDecoration(
                hintText: 'Enter message',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              String message = messageController.text;
              if (message.isNotEmpty) {
                // Send the message to the connected device
                sendMessage(message);
                messageController.clear(); // Clear the input field
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Message cannot be empty")),
                );
              }
            },
            child: const Text('Send Message'),
          ),
        ],
      ),
    );
  }
}
