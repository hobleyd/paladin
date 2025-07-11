import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FatalError extends ConsumerWidget {
  final String error;
  final StackTrace trace;

  const FatalError({super.key, required this.error, required this.trace});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Be more helpful.
    return Center(
        child: Text(error)
    );
  }
}