import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paladin/providers/navigator_stack.dart';

import '../../screens/calibresync.dart';
import '../../repositories/books_repository.dart';
import '../menu/paladin_menu.dart';
import 'fatal_error.dart';

class InitialInstructions extends ConsumerWidget {
  const InitialInstructions({super.key,});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var bookCountAsync = ref.watch(booksRepositoryProvider);

    return bookCountAsync.when(error: (error, stackTrace) {
      return FatalError(error: error.toString(), trace: stackTrace);
    }, loading: () {
    return const Center(child: CircularProgressIndicator());
    }, data: (int count) {
      return Expanded(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0, bottom: 2.0),
                child: count == 0
                    ? TextButton(
                        onPressed: () => ref.read(navigatorStackProvider.notifier).push(context, "calibre_sync", MaterialPageRoute(builder: (context) => CalibreSync())),
                        style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.white), foregroundColor: WidgetStatePropertyAll(Colors.black)),
                        child: Text(
                          'Synchronise Library',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelSmall,
                  ),
                )
                    : Text('Congratulations on your new eReader. Pick a book. Enjoy!', textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PaladinMenu(),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}