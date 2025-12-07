import 'package:cpu_sim/cpu_sim.dart';
import 'package:cpu_sim/src/byte.dart';

typedef InstructionAddress = (Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit);

extension ListAddress on InstructionAddress {
  List<Bit> asList() {
    return [$1, $2, $3, $4, $5, $6, $7, $8, $9, $10];
  }
}

typedef Instruction = (Byte, Byte);

InstructionAddress addressFromInt(int i) {
  Bit bitAt(int offset) {
    return i >> offset & 1 == 1 ? Bit.on : Bit.off;
  }

  return (
    bitAt(9),
    bitAt(8),
    bitAt(7),
    bitAt(6),
    bitAt(5),
    bitAt(4),
    bitAt(3),
    bitAt(2),
    bitAt(1),
    bitAt(0),
  );
}

Map<InstructionAddress, Instruction> initializeInstructionMemory() {
  return List.generate(1024, (i) => (Byte(), Byte())).asMap().map((key, value) {
    return MapEntry(addressFromInt(key), value);
  });
}

class InstructionMemory {
  final Map<InstructionAddress, Instruction> _memory =
      initializeInstructionMemory();

  void insertProgram(List<Instruction> instructions) {
    for (var (index, instruction) in instructions.indexed) {
      _memory[addressFromInt(index + 1)] = instruction;
    }
  }
  
  InstructionAddress address = addressFromInt(0);
  void setCurrentAddress(InstructionAddress address) {
    this.address = address;
  }

  Instruction get currentInstruction => _memory[address]!;
}
