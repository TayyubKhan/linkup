import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:linkup/Viewmodel/connectionViewModel.dart';
import 'package:linkup/main.dart';
import 'package:linkup/temporary/scan.dart';
import 'package:lottie/lottie.dart';
import '../../../Components/backicon.dart';
import '../../../core/repository/connection_repository.dart';
import '../../../utils/colors.dart';

class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  final connectionRepo = GetIt.I<ConnectionRepositoryImplementation>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      connectionRepo.startDiscovery();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDiscovering = ref.watch(isDiscoveringProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final discoveredDevice = ref.watch(discoveredDevicesProvider);
    return Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(),
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            "Search",
            style: TextStyle(color: primaryBlack),
          ),
          automaticallyImplyLeading: true,
          actions: [
            InkWell(
              onTap: connectionRepo.startAdvertising,
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.refresh,
                  color: primaryBlack,
                ),
              ),
            ),
            InkWell(
              onTap: !isDiscovering
                  ? connectionRepo.startDiscovery
                  : connectionRepo.stopDiscovery,
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: switch (isDiscovering) {
                  true => Icon(
                      Icons.pause,
                      color: primaryBlack,
                    ),
                  false => Icon(
                      Icons.play_arrow_outlined,
                      color: primaryBlack,
                    ),
                },
              ),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? Center(child: Lottie.asset('assets/search.json'))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Available Users',
                      style: theme.textTheme.bodySmall,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: discoveredDevice.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Icon(
                              Icons.phone_android_outlined,
                              color: primaryBlack,
                            ),
                            title: Text(discoveredDevice[index].name),
                            trailing: InkWell(
                              onTap: () {
                                connectionRepo.connectDevice(
                                    discoveredDevice[index].id,
                                    discoveredDevice[index].name);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: primaryBlack,
                                    borderRadius: BorderRadius.circular(35)),
                                padding: const EdgeInsets.all(10),
                                child: Text('Connect',
                                    style: TextStyle(
                                        color: primaryWhite, fontSize: 11)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ));
  }
}
