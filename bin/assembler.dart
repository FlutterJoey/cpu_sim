import 'dart:developer';
import 'dart:io';

import 'package:cpu_sim/cpu_sim.dart';
import 'package:cpu_sim/src/byte.dart';
import 'package:cpu_sim/src/control_rom.dart';
import 'package:cpu_sim/src/instruction_memory.dart';

void main(List<String> args) {
  var relativeFile = args[0];
  var file = File(relativeFile);

  var outFileName = args.elementAtOrNull(1) ?? "program";

  var outFile = File("build/$outFileName.dart");

  var build = Directory("build");
  if (!build.existsSync()) {
    build.createSync();
  }

  if (!file.existsSync()) {
    exit(1);
  }

  var locs = file.readAsLinesSync();
  locs = locs
      .map((String loc) => loc.replaceAll(RegExp("//.*"), "").trim())
      .map((loc) => loc.isEmpty ? "NOP" : loc)
      .toList();
  try {
    var mappedLocs = extractLabels(locs);

    var instructions = mappedLocs.indexed
        .map((indexed) => Instruction.parse(indexed.$2, indexed.$1 + 1))
        .toList();

    var binaryInstructions = instructions
        .map((instruction) => instruction.getInstructionBits())
        .toList();

    StringBuffer buffer = StringBuffer();
    buffer.writeln("import 'package:cpu_sim/cpu_sim.dart' show Bit;");
    buffer.writeln("");
    buffer.writeln("const programInstructions = [");
    for (var binaryInstruction in binaryInstructions) {
      buffer.write("    [");
      buffer.write(binaryInstruction.map((bit) => bit.generate()).join(", "));
      buffer.writeln("],");
    }
    buffer.writeln("];");

    if (!outFile.existsSync()) {
      outFile.createSync();
    }

    outFile.writeAsStringSync(buffer.toString());
    print(instructionsToHex(binaryInstructions));
  } on InvalidInstructionException catch (e) {
    log("Unexpected instruction received.");
    print("Received: ${e.input} at ${e.lineNumber}");
    print("What was wrong: ${e.reason}");
  }
}

String instructionsToHex(List<List<Bit>> binaryInstructions) {
  StringBuffer buffer = StringBuffer();
  for (var (index, instruction) in binaryInstructions.indexed) {
    buffer.write("${index + 1}:\t");
    var byteString = Byte.fromList(
      instruction.sublist(0, 8),
    ).value.toRadixString(16).padLeft(2, '0');
    buffer.write("0x$byteString\t");
    var byteString2 = Byte.fromList(
      instruction.sublist(8, 16),
    ).value.toRadixString(16).padLeft(2, '0');
    buffer.write("0x$byteString2");
    buffer.writeln("");
  }

  return buffer.toString();
}

List<String> extractLabels(List<String> locs) {
  var labels = locs.indexed
      .where((loc) => loc.$2.startsWith(RegExp(r"\.\w*")))
      .fold(<String, int>{}, (labels, loc) {
        var (number, line) = loc;
        number++;
        var label = line.trim().split(RegExp(r"[\s\t ]+")).first;
        if (labels.containsKey(label)) {
          throw InvalidInstructionException(
            number,
            line,
            "Label $label was already defined",
          );
        }
        labels[label] = number;
        return labels;
      });

  return locs.indexed.map((loc) {
    var (number, line) = loc;
    number++;
    String result = line;
    if (result.startsWith(RegExp(r"\.\w*"))) {
      result = result.replaceFirst(RegExp(r"\.\w*[\s\t ]+"), "");
    }

    var foundLabels = RegExp(r"\.\w*")
        .allMatches(result)
        .map((match) => result.substring(match.start, match.end))
        .toList();
    for (var label in foundLabels) {
      var labelValue = labels[label];
      if (labelValue == null) {
        throw InvalidInstructionException(
          number,
          result,
          "Label referenced but never defined",
        );
      }

      result = result.replaceAll(label, "$labelValue");
    }
    return result;
  }).toList();
}

class InvalidInstructionException implements Exception {
  final String input;
  final String reason;
  final int lineNumber;

  InvalidInstructionException(this.lineNumber, this.input, this.reason);
}

class Alias {
  final String mnemonic;

  final (OpCode, List<String> args) Function(List<String> parameters)
  toOperation;

  const Alias({required this.mnemonic, required this.toOperation});
}

final List<Alias> aliases = [
  Alias(
    mnemonic: "INC",
    toOperation: (parameters) {
      return (OpCode.adi, [parameters.first, "1"]);
    },
  ),
  Alias(
    mnemonic: "DEC",
    toOperation: (parameters) {
      return (OpCode.adi, [parameters.first, "255"]);
    },
  ),
  Alias(
    mnemonic: "LOD",
    toOperation: (parameters) {
      return (
        OpCode.lod,
        [parameters[0], parameters[1], parameters.elementAtOrNull(2) ?? "0"],
      );
    },
  ),
  Alias(
    mnemonic: "STR",
    toOperation: (parameters) {
      return (
        OpCode.str,
        [parameters[0], parameters[1], parameters.elementAtOrNull(2) ?? "0"],
      );
    },
  ),
  Alias(
    mnemonic: "MOV",
    toOperation: (parameters) {
      return (
        OpCode.add,
        [parameters[0], "r0", parameters[1]],
      );
    },
  ),
];

Alias? getAlias(String opCode) {
  return aliases.where((alias) => alias.mnemonic == opCode).firstOrNull;
}

class RegisterInstruction extends Instruction {
  final int register1Address;
  final int register2Address;
  final int outputRegisterAddress;
  final int inputValue;

  RegisterInstruction({
    required super.opCode,
    required super.instructionNumber,
    required this.register1Address,
    required this.register2Address,
    required this.outputRegisterAddress,
    required this.inputValue,
  });

  @override
  List<Bit> getInstructionBits() {
    var (firstBit, secondBit, thirdBit, fourthBit) = opCode.binary;
    return [
      ...[firstBit, secondBit, thirdBit, fourthBit],
      ...registerToBytes(register1Address),
      if (!opCode.hasAbsoluteValue) ...[
        ...registerToBytes(register2Address),
        ...registerToBytes(outputRegisterAddress),
      ] else ...[
        ...Byte.fromValue(inputValue).bits,
      ],
    ];
  }
}

enum JumpFlag {
  zero([Bit.off, Bit.off]),
  notzero([Bit.off, Bit.off]),
  carry([Bit.on, Bit.on]),
  notcarry([Bit.on, Bit.off]),
  none([Bit.off, Bit.off]);

  const JumpFlag(this.bits);

  final List<Bit> bits;

  static String get names =>
      [zero.name, notzero.name, carry.name, notcarry.name].join(", ");
}

class DataInstruction extends Instruction {
  final int register1Address;
  final int register2Address;
  final int offset;

  DataInstruction({
    required super.opCode,
    required super.instructionNumber,
    required this.register1Address,
    required this.register2Address,
    required this.offset,
  });

  @override
  List<Bit> getInstructionBits() {
    var (firstBit, secondBit, thirdBit, fourthBit) = opCode.binary;
    return [
      ...[firstBit, secondBit, thirdBit, fourthBit],
      ...registerToBytes(register1Address),
      ...registerToBytes(register2Address),
      ...registerToBytes(offset),
    ];
  }
}

class JumpInstruction extends Instruction {
  final JumpFlag flag;
  final int target;

  JumpInstruction({
    required super.opCode,
    required super.instructionNumber,
    required this.flag,
    required this.target,
  });

  factory JumpInstruction.fromArgs(
    int instructionNumber,
    OpCode opCode,
    List<String> args,
  ) {
    var flag = JumpFlag.none;
    if (opCode == OpCode.brh) {
      flag = JumpFlag.values.firstWhere(
        (flag) => flag.name == args[0],
        orElse: () {
          throw InvalidInstructionException(
            instructionNumber,
            args[1],
            "Expected any of (${JumpFlag.names})",
          );
        },
      );
    }

    return JumpInstruction(
      opCode: opCode,
      instructionNumber: instructionNumber,
      flag: flag,
      target: args._parseArgumentAsInt(opCode == OpCode.brh ? 1 : 0),
    );
  }

  @override
  List<Bit> getInstructionBits() {
    var (firstBit, secondBit, thirdBit, fourthBit) = opCode.binary;
    var address = addressFromInt(target);
    return [
      ...[firstBit, secondBit, thirdBit, fourthBit],
      ...flag.bits,
      ...address.asList(),
    ];
  }
}

abstract class Instruction {
  final OpCode opCode;

  final int instructionNumber;

  Instruction({required this.instructionNumber, required this.opCode});

  static Instruction _getInstructionForOpCode(
    int instructionNumber,
    OpCode opCode,
    List<String> args,
  ) {
    switch (opCode) {
      case OpCode.nop:
      case OpCode.hlt:
      case OpCode.add:
      case OpCode.sub:
      case OpCode.nor:
      case OpCode.and:
      case OpCode.xor:
      case OpCode.rsh:
      case OpCode.ldi:
      case OpCode.adi:
        return RegisterInstruction(
          instructionNumber: instructionNumber,
          opCode: opCode,
          register1Address: args._parseArgumentAsInt(0),
          register2Address: args._parseArgumentAsInt(1),
          outputRegisterAddress: args._parseArgumentAsInt(2),
          inputValue: args._parseArgumentAsInt(1),
        );
      case OpCode.jmp:
      case OpCode.brh:
      case OpCode.cal:
      case OpCode.ret:
        return JumpInstruction.fromArgs(instructionNumber, opCode, args);
      case OpCode.lod:
      case OpCode.str:
        return DataInstruction(
          instructionNumber: instructionNumber,
          opCode: opCode,
          register1Address: args._parseArgumentAsInt(0),
          register2Address: args._parseArgumentAsInt(1),
          offset: args._parseArgumentAsInt(2),
        );
    }
  }

  factory Instruction.parse(String loc, int lineNumber) {
    var elements = loc
        .split(RegExp(r"[\s\t ]+"))
        .map((entry) => entry.trim())
        .toList();

    var args = elements.sublist(1);
    var alias = getAlias(elements.first);
    OpCode opCode;

    if (alias != null) {
      (opCode, args) = alias.toOperation(args);
    } else {
      opCode = OpCode.values.firstWhere(
        (code) => code.mnemonic == elements.first,
        orElse: () => throw InvalidInstructionException(
          lineNumber,
          elements.first,
          "Unexpected opcode received: ${elements.first}",
        ),
      );
    }

    if (args.length != opCode.minArgLength) {
      print(args);
      throw InvalidInstructionException(
        lineNumber,
        loc,
        "Unexpected length ${args.length}, expected ${opCode.minArgLength}",
      );
    }

    return _getInstructionForOpCode(lineNumber, opCode, args);
  }

  /// Returns a list of 16 bits
  List<Bit> getInstructionBits();

  List<Bit> registerToBytes(int registerAddress) {
    if (registerAddress > 15) {
      throw InvalidInstructionException(
        instructionNumber,
        "r$registerAddress",
        "Register can only have a maximum address of 15",
      );
    }
    var nibble = Byte.fromValue(registerAddress).rightNibble;
    return [nibble.$1, nibble.$2, nibble.$3, nibble.$4];
  }
}

extension on List<String> {
  int _parseArgumentAsInt(int index) {
    var arg = elementAtOrNull(index);
    if (arg == null) return 0;
    var pureNumber = arg.replaceAll(RegExp(r"[^\d]"), "");
    var number = int.tryParse(pureNumber);

    return number ?? 0;
  }
}

extension on Bit {
  String generate() => switch (value) {
    1 => "Bit.on",
    _ => "Bit.off",
  };
}
