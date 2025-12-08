import 'dart:convert';

import 'package:cpu_sim/src/byte.dart';
import 'package:cpu_sim/src/data_memory.dart';

class Printer {
  Printer({
    required this.memory,
  }) {
    _instructions = PrinterInstructions(printer: this);
    _printerData = PrinterData(printer: this);
    memory.attach(instructionAddress, _instructions);
    memory.attach(dataAddress, _printerData);
  }

  late final PrinterInstructions _instructions;
  late final PrinterData _printerData;
  final DataMemory memory;

  static final instructionAddress = Byte.fromValue(254);
  static final dataAddress = Byte.fromValue(255);

  List<Byte> charBuffer = [];

  void addCharacter(Byte byte) {
    charBuffer.add(byte);
  }

  void clearBuffer() {
    charBuffer.clear();
  }

  void writeOut() {
    var decoder = AsciiDecoder(allowInvalid: true);
    print(decoder.convert(charBuffer.map((byte) => byte.value).toList()));
    charBuffer.clear();
  }

  void popLast() {
    if (charBuffer.isNotEmpty) {
      charBuffer.removeLast();
    }
  }
}

class PrinterData implements MemoryAttachment {
  PrinterData({required this.printer});

  final Printer printer;

  @override
  Byte read() {
    return Byte.fromValue(0);
  }

  @override
  void write(Byte write) {
    printer.addCharacter(write);
  }
}

class PrinterInstructions implements MemoryAttachment {
  PrinterInstructions({required this.printer});
  
  final Printer printer;
  
  @override
  Byte read() {
    return Byte.fromValue(0);
  }

  @override
  void write(Byte write) {
    switch(write) {
      case Byte(value: 0x01):
        printer.clearBuffer();
      case Byte(value: 0x02):
        printer.writeOut();
      case Byte(value: 0x03):
        printer.popLast();
    }
  }
}
