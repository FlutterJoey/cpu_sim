import 'package:cpu_sim/src/bit.dart';
import 'package:cpu_sim/src/bit_operators.dart';
import 'package:cpu_sim/src/byte.dart';
import 'package:cpu_sim/src/byte_operators.dart';
import 'package:cpu_sim/src/mux.dart';

class DataMemory {
  Map<Byte, MemoryAttachment> memory = {
    for (int i = 0; i < 256; i++) Byte.fromValue(i): StorageAttachment(),
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
    var address = muxByte(_address, Byte.fromValue(0), shouldRead.not());
    return memory[address]!.read();
  }

  void clock() {
    var shouldWrite = and(_enabled, _readMode.not());
    var address = andByte(_address, Byte.all(shouldWrite));
    memory[address]!.write(_data);
  }

  void attach(Byte address, MemoryAttachment attachMent) {
    memory[address] = attachMent;
  }
}

abstract class MemoryAttachment {
  Byte read();
  void write(Byte write);
}

class StorageAttachment extends MemoryAttachment {
  Byte value = Byte.fromValue(0);

  @override
  Byte read() => value;

  @override
  void write(Byte write) {
    value = write;
  }

  @override
  String toString() {
    return value.value.toString();
  }
}
