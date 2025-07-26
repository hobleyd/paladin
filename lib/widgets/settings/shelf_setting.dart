import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/shelf.dart';

import 'shelf_name.dart';
import 'shelf_size.dart';
import 'shelf_type.dart';

class ShelfSetting extends ConsumerWidget {
  final Shelf shelf;

  const ShelfSetting({super.key, required this.shelf});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(children: [
      ShelfType(shelf: shelf),
      Expanded(flex: 4, child: ShelfName(shelf: shelf)),
      if (shelf.needsSize)
        Expanded(flex: 1, child: ShelfSize(shelf: shelf)),
    ]);
  }
}