import 'package:cpu_sim/src/byte.dart';
import 'package:cpu_sim/src/byte_operators.dart';
import 'package:test/test.dart';

void main() {
  group("Add byte", () {
    test("Add 3 + 5 should return 8", () {
      var byteWithValue3 = Byte.fromValue(3);
      var byteWithValue5 = Byte.fromValue(5);
      var (result, _) = addByte(byteWithValue5, byteWithValue3);

      expect(result.value, 8);
    });

    test("Subtract 5 with 3 should return 2", () {
      var byteWithValue3 = Byte.fromValue(3);
      var byteWithValue5 = Byte.fromValue(5);
      var (result, _) = subtractByte(byteWithValue5, byteWithValue3);

      expect(result.value, 2);
    });
  });

  group("Shift byte", () {
    test("Shift left on 8 should result in 16", () {
      var byteWithValue8 = Byte.fromValue(8);
      
      var result = shiftLeft(byteWithValue8);
      expect(result.value, 16);
    });

    test("Shift right on 8 should result in 4", () {
      var byteWithValue8 = Byte.fromValue(8);
      
      var result = shiftRight(byteWithValue8);
      expect(result.value, 4);
    });
  });
}