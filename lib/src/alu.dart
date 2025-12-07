import 'package:cpu_sim/src/bit.dart';
import 'package:cpu_sim/src/byte.dart';
import 'package:cpu_sim/src/byte_operators.dart';
import 'package:cpu_sim/src/mux.dart';

enum AluOperations {
  add(0x01),
  subtract(0x02),
  xor(0x03),
  xnor(0x04),
  or(0x05),
  and(0x06),
  nand(0x07),
  nor(0x08),
  shiftLeft(0x09),
  shiftRight(0x0A),
  invert(0x0B),
  noop(0x00);

  const AluOperations(this._value);
  final int _value;

  static AluOperations getByNibble(Nibble operation) {
    var opByte = Byte.fromList([
      Bit.off,
      Bit.off,
      Bit.off,
      Bit.off,
      operation.$1,
      operation.$2,
      operation.$3,
      operation.$4,
    ]);

    return AluOperations.values
            .where((opertion) => opertion._value == opByte.value)
            .firstOrNull ??
        AluOperations.noop;
  }

  Nibble get operation => Byte.fromValue(_value).rightNibble;
}

// First flag is zero, second bit is car
typedef AluFlags = (Bit, Bit);

const AluFlags _noFlags = (Bit.off, Bit.off);

Bit isZero(Byte byte) {
  return byte.bits.fold(Bit.off, (previous, next) => next.or(previous)).not();
}

(Byte, AluFlags) run(Byte byteA, Byte byteB, Nibble operation) {
  var op = AluOperations.getByNibble(operation);
  switch (op) {
    case AluOperations.add:
      var (result, carryFlag) = addByte(byteA, byteB);
      return (result, (isZero(result), carryFlag));
    case AluOperations.subtract:
      var (result, carryFlag) = subtractByte(byteA, byteB);
      return (result, (isZero(result), carryFlag));
    case AluOperations.xor:
      var result = xorByte(byteA, byteB);
      return (result, (isZero(result), Bit.off));
    case AluOperations.xnor:
      var result = xnorByte(byteA, byteB);
      return (result, (isZero(result), Bit.off));
    case AluOperations.or:
      var result = orByte(byteA, byteB);
      return (result, (isZero(result), Bit.off));
    case AluOperations.and:
      var result = andByte(byteA, byteB);
      return (result, (isZero(result), Bit.off));
    case AluOperations.nand:
      var result = nandByte(byteA, byteB);
      return (result, (isZero(result), Bit.off));
    case AluOperations.nor:
      var result = norByte(byteA, byteB);
      return (result, (isZero(result), Bit.off));
    case AluOperations.shiftLeft:
      var (result, carry) = addByte(byteA, byteA);
      return (result, (isZero(result), carry));
    case AluOperations.shiftRight:
      var result = shiftRight(byteA);
      return (result, (isZero(result), Bit.off));
    case AluOperations.invert:
      var result = invertByte(byteA);
      return (result, (isZero(result), Bit.off));
    case _:
      var result = Byte();
      return (result, (isZero(result), Bit.off));
  }
}

class Alu {
  Byte _a = Byte();
  void setByteA(Byte a) {
    _a = a;
  }

  Byte _b = Byte();
  void setByteB(Byte b) {
    _b = b;
  }

  Nibble _operation = (Bit.off, Bit.off, Bit.off, Bit.off);
  void setOperation(Nibble operation) {
    _operation = operation;
  }

  AluFlags get flags => _currentFlags;

  AluFlags _currentFlags = _noFlags;
  Byte getOutput(Bit setFlags) {
    var (result, flags) = run(_a, _b, _operation);
    _currentFlags = (
      muxBit(_currentFlags.$1, flags.$1, setFlags),
      muxBit(_currentFlags.$2, flags.$2, setFlags),
    );
    return result;
  }
}
