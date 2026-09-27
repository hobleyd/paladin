import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/misc.dart' show ProviderListenable;

/// Keeps an autoDispose provider alive for the rest of the current test, the
/// same way a widget watching it would. Without this, a bare `container.read`
/// can dispose the provider again before a later read/mutation on it runs.
void keepAlive<T>(ProviderContainer container, ProviderListenable<T> provider) {
  addTearDown(container.listen<T>(provider, (_, _) {}).close);
}
