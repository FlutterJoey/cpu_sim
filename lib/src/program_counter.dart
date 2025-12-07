import 'package:cpu_sim/src/bit.dart';
import 'package:cpu_sim/src/bit_operators.dart';
import 'package:cpu_sim/src/instruction_memory.dart';

class ProgramCounter {
  InstructionAddress _currentAddress = addressFromInt(0);

  InstructionAddress _in = addressFromInt(0);
  void setIn(InstructionAddress input) {
    _in = input;
  }

  void clock() {
    _currentAddress = _in;
  }

  InstructionAddress get currentAddress => _currentAddress;

  InstructionAddress get incrementAddress {
    var carryOver = Bit.on;
    var list = List.filled(10, Bit.off);
    var currentAddress = this.currentAddress.asList();
    
    for (var bitIndex in List.generate(10, (i) => 9 - i)) {
      var bitA = currentAddress[bitIndex];
      var (result, carry) = add(bitA, Bit.off, carryOver);
      list[bitIndex] = result;
      carryOver = carry;
    }

    return (
      list[0], list[1], list[2], list[3], //
      list[4], list[5], list[6], list[7], //
      list[8], list[9], //
    );
  }
}
