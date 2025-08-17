import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paladin/providers/calibre_network_service.dart';

import '../database/library_db.dart';
import '../widgets/home/home_screen.dart';

class Paladin extends ConsumerWidget {
  const Paladin({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Open the Database here. Need to ensure it is open before we proceed.
    var asyncDb = ref.watch(libraryDBProvider);
    ref.read(calibreNetworkServiceProvider);

    return asyncDb.when(error: (error, stackTrace) {
      return const Text("It's time to panic; we can't open the database!");
    }, loading: () {
      return const Center(child: CircularProgressIndicator());
    }, data: (var db) {
      return Scaffold(
        appBar: null,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 6),
            child: HomeScreen(),
          ),
        ),
      );
    });
  }
}
