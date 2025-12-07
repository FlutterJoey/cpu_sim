import 'package:cpu_sim/src/bit.dart';
import 'package:cpu_sim/src/bit_operators.dart';
import 'package:cpu_sim/src/byte.dart';
import 'package:cpu_sim/src/byte_operators.dart';
import 'package:cpu_sim/src/mux.dart';

class DataMemory {
  Map<Byte, Byte> memory = {
    for (int i = 0; i < 256; i++) Byte.fromValue(i): Byte.fromValue(0),
  };

  Bit _enabled = Bit.off;
  void setEnabled(Bit bit) {
    _enabled = bit;
  }

  Bit _readMode = Bit.off;
  void setMode(Bit readMode) {
    _readMode = readMode;
  }

  Byte _address = Byte.all(Bit.off);
  void setAddress(Byte input) {
    _address = input;
  }

  Byte _data = Byte.all(Bit.off);
  void setData(Byte data) {
    _data = data;
  }

  Byte read() {
    var shouldRead = and(_enabled, _readMode);
    return andByte(memory[_address]!, Byte.all(shouldRead));
  }

  void clock() {
    var shouldWrite = and(_enabled, _readMode.not());
    memory[_address] = muxByte(memory[_address]!, _data, shouldWrite);
  }
}
