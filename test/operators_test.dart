import 'package:cpu_sim/src/bit.dart';
import 'package:cpu_sim/src/bit_operators.dart';
import 'package:test/test.dart';

void main() {
  group("Not operator", () {
    test("Should invert the bit", () {
      var bit = Bit.off;
      var onBit = bit.not();
      var offBit = onBit.not();

      expect(onBit.value, 1);
      expect(offBit.value, 0);
    });
  });

  group("Or operator", () {
    test("Should be on if b is on and a is on", () {
      var bitA = Bit.on;
      var bitB = Bit.on;
      var result = bitB.or(bitA);
      expect(result.value, 1);
    });

    test("Should be on if b is off and a is on", () {
      var bitA = Bit.on;
      var bitB = Bit.off;
      var result = bitB.or(bitA);
      expect(result.value, 1);
    });

    test("Should be on if b is on and a is off", () {
      var bitA = Bit.off;
      var bitB = Bit.on;
      var result = bitB.or(bitA);
      expect(result.value, 1);
    });

    test("Should be off if b is off and a is off", () {
      var bitA = Bit.off;
      var bitB = Bit.off;
      var result = bitB.or(bitA);
      expect(result.value, 0);
    });
  });

  group("And operator", () {
    test("Should be on if b is on and a is on", () {
      var bitA = Bit.on;
      var bitB = Bit.on;
      var result = and(bitA, bitB);
      expect(result.value, 1);
    });

    test("Should be off if b is off and a is on", () {
      var bitA = Bit.on;
      var bitB = Bit.off;
      var result = and(bitA, bitB);
      expect(result.value, 0);
    });

    test("Should be off if b is on and a is off", () {
      var bitA = Bit.off;
      var bitB = Bit.on;
      var result = and(bitA, bitB);
      expect(result.value, 0);
    });

    test("Should be off if b is off and a is off", () {
      var bitA = Bit.off;
      var bitB = Bit.off;
      var result = and(bitA, bitB);
      expect(result.value, 0);
    });
  });

  group("Xor operator", () {
    test("Should be off if b is on and a is on", () {
      var bitA = Bit.on;
      var bitB = Bit.on;
      var result = xor(bitA, bitB);
      expect(result.value, 0);
    });

    test("Should be on if b is off and a is on", () {
      var bitA = Bit.on;
      var bitB = Bit.off;
      var result = xor(bitA, bitB);
      expect(result.value, 1);
    });

    test("Should be on if b is on and a is off", () {
      var bitA = Bit.off;
      var bitB = Bit.on;
      var result = xor(bitA, bitB);
      expect(result.value, 1);
    });

    test("Should be off if b is off and a is off", () {
      var bitA = Bit.off;
      var bitB = Bit.off;
      var result = xor(bitA, bitB);
      expect(result.value, 0);
    });
  });

  group("HalfAdd operator", () {
    test("Should be off if b is on and a is on", () {
      var bitA = Bit.on;
      var bitB = Bit.on;
      var (result, overflow) = halfAdd(bitA, bitB);
      expect(result.value, 0);
      expect(overflow.value, 1);
    });

    test("Should be on if b is off and a is on", () {
      var bitA = Bit.on;
      var bitB = Bit.off;
      var (result, overflow) = halfAdd(bitA, bitB);
      expect(result.value, 1);
      expect(overflow.value, 0);
    });

    test("Should be on if b is on and a is off", () {
      var bitA = Bit.off;
      var bitB = Bit.on;
      var (result, overflow) = halfAdd(bitA, bitB);
      expect(result.value, 1);
      expect(overflow.value, 0);
    });

    test("Should be off if b is off and a is off", () {
      var bitA = Bit.off;
      var bitB = Bit.off;
      var (result, overflow) = halfAdd(bitA, bitB);
      expect(result.value, 0);
      expect(overflow.value, 0);
    });
  });
}
