import 'dart:math' as math;

extension MinMax on Iterable<int> {
  int get max => isEmpty ? 0 : reduce(math.max);

  int get min => isEmpty ? 0 : reduce(math.min);
}