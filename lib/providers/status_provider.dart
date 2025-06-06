import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'status_provider.g.dart';

@Riverpod(keepAlive: true)
class Status extends _$Status {
  @override
  String build() {
    return "";
  }

  void setStatus(String status) {
    state = status;
  }
}
