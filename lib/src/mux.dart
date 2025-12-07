import 'package:cpu_sim/src/bit.dart';
import 'package:cpu_sim/src/bit_operators.dart';
import 'package:cpu_sim/src/byte.dart';
import 'package:cpu_sim/src/byte_operators.dart';
import 'package:cpu_sim/src/instruction_memory.dart';

Byte muxByte(Byte a, Byte b, Bit input) {
  return orByte(andByte(a, Byte.all(input.not())), andByte(b, Byte.all(input)));
}

Nibble muxNibble(Nibble a, Nibble b, Bit input) {
  var nibbleA = a.andWithBit(input.not());
  var nibbleB = b.andWithBit(input);

  return (
    nibbleA.$1.or(nibbleB.$1),
    nibbleA.$2.or(nibbleB.$2),
    nibbleA.$3.or(nibbleB.$3),
    nibbleA.$4.or(nibbleB.$4),
  );
}

Bit muxBit(Bit a, Bit b, Bit input) {
  return (and(a, input.not())).or(and(b, input));
}

InstructionAddress muxInstructionAddress(InstructionAddress addressA, InstructionAddress addressB, Bit input) {
  return (
    muxBit(addressA.$1, addressB.$1, input),
    muxBit(addressA.$2, addressB.$2, input),
    muxBit(addressA.$3, addressB.$3, input),
    muxBit(addressA.$4, addressB.$4, input),
    muxBit(addressA.$5, addressB.$5, input),
    muxBit(addressA.$6, addressB.$6, input),
    muxBit(addressA.$7, addressB.$7, input),
    muxBit(addressA.$8, addressB.$8, input),
    muxBit(addressA.$9, addressB.$9, input),
    muxBit(addressA.$10, addressB.$10, input),
  );
}