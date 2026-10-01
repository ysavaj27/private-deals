import 'dart:math' as math;

extension JoinList on List {
  String get joinList {
    return join('|');
  }
}

extension FancyIterable on Iterable<double> {
  double get max => reduce(math.max);

  double get min => reduce(math.min);
}
