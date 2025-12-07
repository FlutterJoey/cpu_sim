import 'package:cpu_sim/src/alu.dart';
import 'package:cpu_sim/src/bit.dart';

class ControlRomOutput {
  final Bit enableRegisters;
  final Nibble aluOperation;
  final Bit dataMux;
  final Bit destMux;
  final Bit immediateBMux;
  final Bit shouldHaltClock;
  final Bit shouldSetFlags;
  final Bit shouldJump;
  final Bit shouldBranch;
  final Bit useStack;
  final Bit stackPopMode;
  final Bit dataMemoryEnabled;
  final Bit dataMemoryReadMode;

  const ControlRomOutput({
    required this.enableRegisters,
    required this.aluOperation,
    this.dataMux = Bit.off,
    this.destMux = Bit.off,
    this.immediateBMux = Bit.off,
    this.shouldHaltClock = Bit.off,
    this.shouldSetFlags = Bit.off,
    this.shouldJump = Bit.off,
    this.shouldBranch = Bit.off,
    this.useStack = Bit.off,
    this.stackPopMode = Bit.off,
    this.dataMemoryReadMode = Bit.off,
    this.dataMemoryEnabled = Bit.off,
  });

  const ControlRomOutput.noOp()
    : enableRegisters = Bit.off,
      aluOperation = const (Bit.off, Bit.off, Bit.off, Bit.off),
      dataMux = Bit.off,
      destMux = Bit.off,
      immediateBMux = Bit.off,
      shouldHaltClock = Bit.off,
      shouldSetFlags = Bit.off,
      shouldJump = Bit.off,
      shouldBranch = Bit.off,
      useStack = Bit.off,
      stackPopMode = Bit.off,
      dataMemoryEnabled = Bit.off,
      dataMemoryReadMode = Bit.off;
}

enum OpCode {
  nop("NOP", 0, (Bit.off, Bit.off, Bit.off, Bit.off)),
  hlt("HLT", 0, (Bit.off, Bit.off, Bit.off, Bit.on)),
  add("ADD", 3, (Bit.off, Bit.off, Bit.on, Bit.off)),
  sub("SUB", 3, (Bit.off, Bit.off, Bit.on, Bit.on)),
  nor("NOR", 3, (Bit.off, Bit.on, Bit.off, Bit.off)),
  and("AND", 3, (Bit.off, Bit.on, Bit.off, Bit.on)),
  xor("XOR", 3, (Bit.off, Bit.on, Bit.on, Bit.off)),
  rsh("RSH", 3, (Bit.off, Bit.on, Bit.on, Bit.on)),
  ldi("LDI", 2, (Bit.on, Bit.off, Bit.off, Bit.off), hasAbsoluteValue: true),
  adi("ADI", 2, (Bit.on, Bit.off, Bit.off, Bit.on), hasAbsoluteValue: true),
  jmp("JMP", 1, (Bit.on, Bit.off, Bit.on, Bit.off)),
  brh("BRH", 2, (Bit.on, Bit.off, Bit.on, Bit.on)),
  cal("CAL", 1, (Bit.on, Bit.on, Bit.off, Bit.off)),
  ret("RET", 0, (Bit.on, Bit.on, Bit.off, Bit.on)),
  lod("LOD", 3, (Bit.on, Bit.on, Bit.on, Bit.off)),
  str("STR", 3, (Bit.on, Bit.on, Bit.on, Bit.on));

  const OpCode(
    this.mnemonic,
    this.minArgLength,
    this.binary, {
    this.hasAbsoluteValue = false,
  });

  final String mnemonic;
  final Nibble binary;
  final int minArgLength;
  final bool hasAbsoluteValue;
}

class ControlRom {
  ControlRomOutput getOutput(Nibble opCode) {
    return switch (opCode) {
      (Bit(value: 0), Bit(value: 0), Bit(value: 0), Bit(value: 1)) =>
        ControlRomOutput(
          aluOperation: AluOperations.noop.operation,
          enableRegisters: Bit.off,
          shouldHaltClock: Bit.on,
        ), // 0x1 HLT Halt the clock
      // ADD
      (Bit(value: 0), Bit(value: 0), Bit(value: 1), Bit(value: 0)) =>
        ControlRomOutput(
          enableRegisters: Bit.on,
          aluOperation: AluOperations.add.operation,
          shouldSetFlags: Bit.on,
        ),
      // SUB subtract
      (Bit(value: 0), Bit(value: 0), Bit(value: 1), Bit(value: 1)) =>
        ControlRomOutput(
          enableRegisters: Bit.on,
          aluOperation: AluOperations.subtract.operation,
          shouldSetFlags: Bit.on,
        ),
      // NOR neither or
      (Bit(value: 0), Bit(value: 1), Bit(value: 0), Bit(value: 0)) =>
        ControlRomOutput(
          enableRegisters: Bit.on,
          aluOperation: AluOperations.nor.operation,
          shouldSetFlags: Bit.on,
        ),
      // AND
      (Bit(value: 0), Bit(value: 1), Bit(value: 0), Bit(value: 1)) =>
        ControlRomOutput(
          enableRegisters: Bit.on,
          aluOperation: AluOperations.and.operation,
          shouldSetFlags: Bit.on,
        ),
      // XOR
      (Bit(value: 0), Bit(value: 1), Bit(value: 1), Bit(value: 0)) =>
        ControlRomOutput(
          enableRegisters: Bit.on,
          aluOperation: AluOperations.xor.operation,
          shouldSetFlags: Bit.on,
        ),
      // RSH right shift
      (Bit(value: 0), Bit(value: 1), Bit(value: 1), Bit(value: 1)) =>
        ControlRomOutput(
          enableRegisters: Bit.on,
          aluOperation: AluOperations.shiftRight.operation,
        ),
      // LDI Load immediate
      (Bit(value: 1), Bit(value: 0), Bit(value: 0), Bit(value: 0)) =>
        ControlRomOutput(
          enableRegisters: Bit.on,
          dataMux: Bit.on,
          destMux: Bit.on,
          aluOperation: AluOperations.noop.operation,
        ),
      // ADI Add immediate
      (Bit(value: 1), Bit(value: 0), Bit(value: 0), Bit(value: 1)) =>
        ControlRomOutput(
          enableRegisters: Bit.on,
          aluOperation: AluOperations.add.operation,
          destMux: Bit.on,
          immediateBMux: Bit.on,
          shouldSetFlags: Bit.on,
        ),
      // JMP Jump
      (Bit(value: 1), Bit(value: 0), Bit(value: 1), Bit(value: 0)) =>
        ControlRomOutput(
          enableRegisters: Bit.off,
          aluOperation: AluOperations.noop.operation,
          shouldJump: Bit.on,
        ),
      // BRH Branch
      (Bit(value: 1), Bit(value: 0), Bit(value: 1), Bit(value: 1)) =>
        ControlRomOutput(
          enableRegisters: Bit.off,
          aluOperation: AluOperations.noop.operation,
          shouldBranch: Bit.on,
        ),
      // CAL Call and add to stack
      (Bit(value: 1), Bit(value: 1), Bit(value: 0), Bit(value: 0)) =>
        ControlRomOutput(
          enableRegisters: Bit.off,
          aluOperation: AluOperations.noop.operation,
          shouldJump: Bit.on,
          useStack: Bit.on,
          stackPopMode: Bit.off,
        ),
      // RET Return to previous point of call
      (Bit(value: 1), Bit(value: 1), Bit(value: 0), Bit(value: 1)) =>
        ControlRomOutput(
          enableRegisters: Bit.off,
          aluOperation: AluOperations.noop.operation,
          useStack: Bit.on,
          stackPopMode: Bit.on,
        ),
      // LOD Load from data memory
      (Bit(value: 1), Bit(value: 1), Bit(value: 1), Bit(value: 0)) =>
        ControlRomOutput(
          enableRegisters: Bit.on,
          aluOperation: AluOperations.add.operation,
          dataMemoryEnabled: Bit.on,
          dataMemoryReadMode: Bit.on,
        ),
      // STR Store into data memory
      (Bit(value: 1), Bit(value: 1), Bit(value: 1), Bit(value: 1)) =>
        ControlRomOutput(
          enableRegisters: Bit.on,
          aluOperation: AluOperations.add.operation,
          dataMemoryEnabled: Bit.on,
          dataMemoryReadMode: Bit.off,
        ),
      // NOP
      (Bit(value: 0), Bit(value: 0), Bit(value: 0), Bit(value: 0)) ||
      _ => ControlRomOutput.noOp(),
    };
  }
}
