import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../../Components/backicon.dart';
import '../viewmodel/search_viewmodel.dart'; // Import the BluetoothChatModelController

// The SearchView which handles Bluetooth device searching using Riverpod
class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  @override
  void initState() {
    super.initState();
    // Start scanning for Bluetooth devices when the screen loads

  }

  @override
  Widget build(BuildContext context) {
    final bluetoothState = ref.watch(bluetoothChatModelControllerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Search",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        automaticallyImplyLeading: true,
      ),
      body: bluetoothState.isScanning
          ? Center(
        child: Lottie.asset(
            'assets/search.json'), // Show loading animation while scanning
      )
          : bluetoothState.connectedDevices.isEmpty
          ? const Center(
        child: Text("No devices found. Please try again."),
      )
          : ListView.builder(
        itemCount: bluetoothState.connectedDevices.length,
        itemBuilder: (context, index) {
          final device = bluetoothState.connectedDevices[index];
          return ListTile(
            title: Text(device.advName.isNotEmpty
                ? device.advName
                : "Unknown Device"),
            subtitle: Text(device.remoteId.toString()),
            trailing: ElevatedButton(
              onPressed: () async {
                // Connect to the selected device
                await ref
                    .read(bluetoothChatModelControllerProvider.notifier)
                    .connectToDevice(device);

                // You can navigate to ChatModel Screen after connection
                // Navigator.push(context, MaterialPageRoute(builder: (context) => ChatModelScreen(device: device)));
              },
              child: const Text("Connect"),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    // Stop scanning when the widget is disposed
    ref.read(bluetoothChatModelControllerProvider.notifier).stopScanning();
  }
}
