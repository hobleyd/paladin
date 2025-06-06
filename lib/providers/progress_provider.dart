import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'progress_provider.g.dart';

@Riverpod(keepAlive: true)
class Progress extends _$Progress {
  @override
  double build() {
    return 0.0;
  }

  void setProgress(double progress) {
    state = progress;
  }
}
