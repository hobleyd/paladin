import 'package:flutter/material.dart' hide Notification, NotificationListener;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paladin/providers/status_provider.dart';

class SyncNotifications extends ConsumerWidget {
  const SyncNotifications({super.key, });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<String> updates = ref.watch(statusProvider);

    return Column(
      children: [
        Text("Progress", style: Theme.of(context).textTheme.labelMedium),
        Expanded(
          child: Container(
            alignment: Alignment.topLeft,
            margin: const EdgeInsets.all(15.0),
            padding: const EdgeInsets.all(3.0),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black)
            ),
            child: ListView.builder(
              itemCount: updates.length,
              itemBuilder: (context, index) {
                return Container(
                  color: index % 2 == 0 ? Colors.grey[50] : Colors.blue[50],
                  child: Text(
                    updates[index],
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodySmall,
                    textAlign: TextAlign.left,
                  ),
                );
              },
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
            ),
          ),
        ),
      ],
    );
  }
}
