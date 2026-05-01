import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/app_settings_repository.dart';

class AutoUpdateShelfSetting extends ConsumerWidget {
  const AutoUpdateShelfSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsRepositoryProvider);

    return settings.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
      data: (s) => SwitchListTile(
        title: const Text('Auto-update shelf when opening a series book'),
        value: s.autoUpdateShelf,
        onChanged: (enabled) =>
            ref.read(appSettingsRepositoryProvider.notifier).updateAutoUpdateShelf(enabled),
      ),
    );
  }
}
