import 'package:cpu_sim/src/bit.dart';
import 'package:cpu_sim/src/bit_operators.dart';
import 'package:cpu_sim/src/byte.dart';

(Byte, Bit) addByte(Byte a, Byte b) {
  return _addByte(a, b);
}

(Byte, Bit) _addByte(Byte a, Byte b, [Bit overflow = Bit.off]) {
  var carryOver = overflow;
  var list = List.filled(Byte.length, Bit.off);
  for (var bitIndex in Byte.bitIndexes) {
    var bitA = a[bitIndex];
    var bitB = b[bitIndex];
    var (result, carry) = add(bitA, bitB, carryOver);
    list[bitIndex] = result;
    carryOver = carry;
  }
  return (Byte.fromList(list), carryOver);
}

Byte invertByte(Byte byte) {
  return Byte.fromList(byte.bits.map((bit) => bit.not()).toList());
}

Byte orByte(Byte a, Byte b) {
  return _combineByte(a, b, (a, b) => a.or(b));
}

Byte andByte(Byte a, Byte b) {
  return _combineByte(a, b, and);
}

Byte nandByte(Byte a, Byte b) {
  return _combineByte(a, b, nand);
}

Byte xnorByte(Byte a, Byte b) {
  return _combineByte(a, b, xnor);
}

Byte xorByte(Byte a, Byte b) {
  return _combineByte(a, b, xor);
}

Byte norByte(Byte a, Byte b) {
  return _combineByte(a, b, nor);
}


Byte _combineByte(Byte a, Byte b, Bit Function(Bit, Bit) combiner) {
  return Byte.fromList([
    for (var index = 0; index < Byte.length; index++) combiner(a[index], b[index]),
  ]);
}

(Byte, Bit) subtractByte(Byte a, Byte b) {
  return _addByte(a, invertByte(b), Bit.on);
}

Byte shiftLeft(Byte a) {
  var (result, _) = _addByte(a, a);
  return result;
}

Byte shiftRight(Byte a) {
  return Byte.fromList([Bit.off, ...a.bits.sublist(0, Byte.length - 1)]);
}
