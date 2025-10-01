import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/shelves_repository.dart';
import '../widgets/home/fatal_error.dart';
import '../widgets/settings/calibre_sync_server.dart';
import '../widgets/settings/paladin_update.dart';
import '../widgets/settings/shelf_setting.dart';

class Settings extends ConsumerWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var shelves = ref.watch(shelvesRepositoryProvider);

    return shelves.when(error: (error, stackTrace) {
      return FatalError(
          error: "Your shelves have gone missing; it's a catastrophe! Seriously though, maybe add a Shelf below...\n$error",
          trace: stackTrace,
      );
    }, loading: () {
      return const Center(child: CircularProgressIndicator());
    }, data: (List<int> shelfIds) {
      final List<Widget> settings = shelfIds.map((shelfId) {
        return ShelfSetting(shelfId: shelfId);
      }).toList();

      final List<Widget> add = [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(padding: const EdgeInsets.only(top: 10), child: IconButton(icon: const Icon(Icons.remove), onPressed: () => shelfIds.length > 1 ? _removeShelf(ref) : null)),
            const SizedBox(width: 10),
            Padding(padding: const EdgeInsets.only(top: 10), child: IconButton(icon: const Icon(Icons.add), onPressed: () => _addShelf(ref))),
          ],
        ),
      ];

      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 6, left: 10, right: 10),
            child: Column(children: [CalibreSyncServer(), ...settings, ...add, PaladinUpdate()]),
          ),
        ),
      );
    });
  }

  void _addShelf(WidgetRef ref) {
    ref.read(shelvesRepositoryProvider.notifier).addShelf();
  }

  void _removeShelf(WidgetRef ref) {
    ref.read(shelvesRepositoryProvider.notifier).removeShelf();
  }
}