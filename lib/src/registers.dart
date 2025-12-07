import 'package:cpu_sim/src/bit.dart';
import 'package:cpu_sim/src/byte.dart';
import 'package:cpu_sim/src/byte_operators.dart';

class BitRegister {
  Bit _currentValue = Bit.off;

  Bit _in = Bit.off;

  void setIn(Bit bit) {
    _in = bit;
  }

  void writeBit() {
    _currentValue = _in;
  }

  Bit read() {
    return _currentValue;
  }
}

class ByteRegister {
  final List<BitRegister> _bitRegisters = List.generate(
    Byte.length,
    (_) => BitRegister(),
    growable: false,
  );

  Byte read() {
    return Byte.fromList(
      _bitRegisters.map((register) => register.read()).toList(),
    );
  }

  void setIn(Byte byte) {
    for (var index = 0; index < Byte.length; index++) {
      _bitRegisters[index].setIn(byte[index]);
    }
  }

  void write() {
    for (var register in _bitRegisters) {
      register.writeBit();
    }
  }
}

class Registers {
  Map<Nibble, ByteRegister> registers = {
    (Bit.off, Bit.off, Bit.off, Bit.off): ByteRegister(), // 0x0
    (Bit.off, Bit.off, Bit.off, Bit.on): ByteRegister(), // 0x1
    (Bit.off, Bit.off, Bit.on, Bit.off): ByteRegister(), // 0x2
    (Bit.off, Bit.off, Bit.on, Bit.on): ByteRegister(), // 0x3
    (Bit.off, Bit.on, Bit.off, Bit.off): ByteRegister(), // 0x4
    (Bit.off, Bit.on, Bit.off, Bit.on): ByteRegister(), // 0x5
    (Bit.off, Bit.on, Bit.on, Bit.off): ByteRegister(), // 0x6
    (Bit.off, Bit.on, Bit.on, Bit.on): ByteRegister(), // 0x7
    (Bit.on, Bit.off, Bit.off, Bit.off): ByteRegister(), // 0x8
    (Bit.on, Bit.off, Bit.off, Bit.on): ByteRegister(), // 0x9
    (Bit.on, Bit.off, Bit.on, Bit.off): ByteRegister(), // 0xA
    (Bit.on, Bit.off, Bit.on, Bit.on): ByteRegister(), // 0xB
    (Bit.on, Bit.on, Bit.off, Bit.off): ByteRegister(), // 0xC
    (Bit.on, Bit.on, Bit.off, Bit.on): ByteRegister(), // 0xD
    (Bit.on, Bit.on, Bit.on, Bit.off): ByteRegister(), // 0xE
    (Bit.on, Bit.on, Bit.on, Bit.on): ByteRegister(), // 0xF
  };

  Byte get readA {
    var readValue = registers[_readAddressA]!.read();
    return andByte(readValue, Byte.all(_isEnabled));
  }

  Byte get readB {
    var readValue = registers[_readAddressB]!.read();
    return andByte(readValue, Byte.all(_isEnabled));
  }

  Nibble _readAddressA = (Bit.off, Bit.off, Bit.off, Bit.off);
  void setReadA(Nibble address) {
    _readAddressA = address.andWithBit(_isEnabled);
  }

  Nibble _readAddressB = (Bit.off, Bit.off, Bit.off, Bit.off);
  void setReadB(Nibble address) {
    _readAddressB = address.andWithBit(_isEnabled);
  }

  Bit _isEnabled = Bit.off;

  void setEnable(Bit enable) {
    _isEnabled = enable;
    _readAddressA = _readAddressA.andWithBit(_isEnabled);
    _readAddressA = _readAddressB.andWithBit(_isEnabled);
  }

  Nibble _writeAddress = (Bit.off, Bit.off, Bit.off, Bit.off);
  void setWrite(Nibble address) {
    _writeAddress = address.andWithBit(_isEnabled);
  }

  void setInput(Byte input) {
    for (var entry in registers.entries) {
      registers[entry.key]?.setIn(input);
    }
  }

  void clock() {
    registers[_writeAddress]!.write();
  }
}
