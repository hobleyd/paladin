import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'status_provider.g.dart';

@Riverpod(keepAlive: true)
class Status extends _$Status {
  @override
  List<String> build() {
    return [];
  }

  void addStatus(String status) {
    List<String> messages = List.from(state);
    messages.add(status);

    state = messages;
  }
}
