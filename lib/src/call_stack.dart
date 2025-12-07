import 'package:cpu_sim/cpu_sim.dart';
import 'package:cpu_sim/src/byte.dart';
import 'package:cpu_sim/src/byte_operators.dart';
import 'package:cpu_sim/src/instruction_memory.dart';
import 'package:cpu_sim/src/mux.dart';

class CallStack {
  final Map<Byte, InstructionAddress> _stack = {
    for (var i = 0; i < 16; i++) ...{Byte.fromValue(i): addressFromInt(0)},
  };

  Bit _enabled = Bit.off;
  void setEnabled(Bit enabled) {
    _enabled = enabled;
  }

  Bit _pushPopMode = Bit.off;
  void setMode(Bit pushPopMode) {
    _pushPopMode = pushPopMode;
  }

  InstructionAddress _input = addressFromInt(0);
  void setInput(InstructionAddress address) {
    _input = address;
  }

  InstructionAddress getOutput() {
    return _stack[Byte.all(Bit.off)]!;
  }

  void clock() {
    var result = <Byte, InstructionAddress>{};
    for (var entry in _stack.entries) {
      var (nextKey, _) = addByte(
        entry.key,
        muxByte(Byte.fromValue(1), Byte.fromValue(255), _pushPopMode),
      );
      var newKey = muxByte(entry.key, nextKey, _enabled);
      result[newKey] = entry.value;
    }

    _stack.updateAll((key, _) => result[key] ?? addressFromInt(0));
    
    _stack.update(Byte.fromValue(0), (value) => muxInstructionAddress(_input, value, _pushPopMode.or(_enabled.not())));
  }
}
