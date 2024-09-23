import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../Components/backicon.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Center(child: Lottie.asset('assets/search.json'))],
      ),
    );
  }
}
