import 'package:cpu_sim/src/bit.dart';
import 'package:cpu_sim/src/bit_operators.dart';
import 'package:test/test.dart';

void main() {
  group("Add operation", () {
    var truthTable = {
      // With overflow bit off
      (Bit.off, Bit.off, Bit.off): (Bit.off, Bit.off),
      (Bit.on, Bit.off, Bit.off): (Bit.on, Bit.off),
      (Bit.off, Bit.on, Bit.off): (Bit.on, Bit.off),
      (Bit.on, Bit.on, Bit.off): (Bit.off, Bit.on),

      // with overflow bit on
      (Bit.off, Bit.off, Bit.on): (Bit.on, Bit.off),
      (Bit.on, Bit.off, Bit.on): (Bit.off, Bit.on),
      (Bit.off, Bit.on, Bit.on): (Bit.off, Bit.on),
      (Bit.on, Bit.on, Bit.on): (Bit.on, Bit.on),
    };

    for (var entry in truthTable.entries) {
      var (bitA, bitB, overflowBit) = entry.key;
      var (expectedResult, expectedOverflow) = entry.value;
      test("Test should handle case: ${entry.key} with the result ${entry.value}", () {
        var (result, overflow) = add(bitA, bitB, overflowBit);
        expect(result.value, expectedResult.value);
        expect(overflow.value, expectedOverflow.value);
      });
    }
  });
}
