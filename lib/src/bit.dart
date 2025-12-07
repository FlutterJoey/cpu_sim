import 'package:cpu_sim/src/bit_operators.dart';

class Bit {
  final bool _inner;
  static const off = Bit._(false);
  static const on = Bit._(true);
  const Bit._(this._inner);

  Bit not() {
    return Bit._(!_inner);
  }

  Bit or(Bit other) {
    return Bit._(other._inner | _inner);
  }

  int get value => _inner ? 1 : 0;
  
  @override
  String toString() {
    return value.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Bit && other._inner == _inner;
  }

  @override
  int get hashCode => _inner.hashCode;
}

typedef Nibble = (Bit a, Bit b, Bit c, Bit d);

extension Operations on Nibble {
  Nibble andWithBit(Bit bit) {
    return (and($1, bit), and($2, bit), and($3, bit), and($4, bit));
  }
}
