import 'package:cpu_sim/src/bit.dart';

class Byte {
  static const length = 8;
  Byte() : _bits = List.filled(length, Bit.off);
  Byte.fromList(List<Bit> bits)
    : assert(bits.length == 8, "A byte always has 8 bits"),
      _bits = bits;

  Byte.all(Bit bit) : _bits = List.filled(length, bit);

  factory Byte.fromValue(int value) {
    var bits = [
      for (var index in bitIndexes) ...[
        if ((value & 1 << index) == 0) Bit.off else Bit.on,
      ],
    ];

    return Byte.fromList(bits);
  }
  final List<Bit> _bits;

  List<Bit> get bits => List<Bit>.from(_bits);

  Bit operator [](int i) {
    assert(i >= 0);
    assert(i < 8);
    return bits[i];
  }

  /// Debugging values
  int get value => bits.indexed.fold(
    0,
    (value, bit) => value | (bit.$2.value << length - (bit.$1 + 1)),
  );

  Nibble get leftNibble {
    return (bits[0], bits[1], bits[2], bits[3]);
  }

  Nibble get rightNibble {
    return (bits[4], bits[5], bits[6], bits[7]);
  }

  static Iterable<int> get bitIndexes =>
      List.generate(length, (index) => index).reversed;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Byte &&
        rightNibble == other.rightNibble &&
        leftNibble == other.leftNibble;
  }

  @override
  int get hashCode => bits.map((bit) => bit.hashCode).reduce((a, b) => a ^ b);
}
