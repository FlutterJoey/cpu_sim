import 'package:cpu_sim/cpu_sim.dart';
import 'package:cpu_sim/src/call_stack.dart';
import 'package:cpu_sim/src/instruction_memory.dart';
import 'package:test/test.dart';

void main() {
  group("Call Stack", () {
    test("Should push value appropriately", () {
      var sut = CallStack();

      sut.setInput(addressFromInt(1));
      sut.setEnabled(Bit.on);
      sut.setMode(Bit.off); // PUSH

      sut.clock();

      expect(sut.getOutput(), equals(addressFromInt(1)));
    });

    test("Should pop value appropriately", () {
      var sut = CallStack();

      sut.setInput(addressFromInt(1));
      sut.setEnabled(Bit.on);
      sut.setMode(Bit.off); // PUSH

      sut.clock();

      sut.setInput(addressFromInt(2));
      sut.clock();
      sut.setInput(addressFromInt(3));
      sut.clock();

      expect(sut.getOutput(), equals(addressFromInt(3)));

      sut.setMode(Bit.on);
      sut.clock();

      expect(sut.getOutput(), equals(addressFromInt(2)));
    });
  });
}
