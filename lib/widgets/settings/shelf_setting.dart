import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/shelf.dart';

import 'shelf_name.dart';
import 'shelf_size.dart';
import 'shelf_type.dart';

class ShelfSetting extends ConsumerWidget {
  final int shelfId;

  const ShelfSetting({super.key, required this.shelfId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(children: [
      ShelfType(shelfId: shelfId),
      Expanded(flex: 4, child: ShelfName(shelfId: shelfId)),
      Expanded(flex: 1, child: ShelfSize(shelfId: shelfId)),
    ]);
  }
}