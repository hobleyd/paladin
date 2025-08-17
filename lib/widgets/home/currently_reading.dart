import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paladin/repositories/shelf_repository.dart';
import 'package:paladin/widgets/home/currently_reading_shelf.dart';

import '../../models/shelf.dart';
import 'fatal_error.dart';

class CurrentlyReading extends ConsumerWidget {
  final int shelfId;

  const CurrentlyReading({super.key, required this.shelfId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var shelfAsync = ref.watch(shelfRepositoryProvider(shelfId));

    return shelfAsync.when(error: (error, stackTrace) {
      return FatalError(error: error.toString(), trace: stackTrace);
    }, loading: () {
      return const Center(child: CircularProgressIndicator());
    }, data: (Shelf shelf) {
      return CurrentlyReadingShelf(currentlyReading: shelf);
    });
  }
}