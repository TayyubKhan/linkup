import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../../Components/backicon.dart';

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
        body: Lottie.asset('assets/search.json'));
  }
}
