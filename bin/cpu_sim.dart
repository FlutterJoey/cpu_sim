import 'package:cpu_sim/cpu_sim.dart';
import 'package:cpu_sim/src/byte.dart';
import 'package:cpu_sim/src/keyboard_input.dart';
import 'package:cpu_sim/src/printer.dart';
import 'package:cpu_sim/src/random.dart';

import '../build/program.dart' as program;

void main(List<String> arguments) async {
  var cpu = CPUSim();
  var instructions = program.programInstructions.map((instruction) {
    return (
      Byte.fromList(instruction.sublist(0, 8)),
      Byte.fromList(instruction.sublist(8, 16)),
    );
  }).toList();

  final printer = Printer(memory: cpu.dataMemory);
  final KeyboardInput keyboardInput = KeyboardInput(memory: cpu.dataMemory);

  cpu.dataMemory.attach(Byte.fromValue(0xFD), RandomAttachment());
  
  cpu.loadProgram(instructions);
  
  await cpu.start();

  printer.clearBuffer();
  keyboardInput.dispose();
  print("Final memory dump:\n ${cpu.prettyRegisters()}");
}

extension on CPUSim {
  String prettyRegisters() {
    return registers.registers
        .map((key, value) => MapEntry(key, value.read().bits))
        .values.indexed
        .map((indexedBits) => "${indexedBits.$1}: 0x${Byte.fromList(indexedBits.$2).value.toRadixString(16).padLeft(2, '0')} ${Byte.fromList(indexedBits.$2).value}")
        .join("\n");
  }
}
