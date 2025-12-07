import 'package:cpu_sim/src/alu.dart';
import 'package:cpu_sim/src/bit.dart';
import 'package:cpu_sim/src/bit_operators.dart';
import 'package:cpu_sim/src/byte.dart';
import 'package:cpu_sim/src/call_stack.dart';
import 'package:cpu_sim/src/clock.dart';
import 'package:cpu_sim/src/control_rom.dart';
import 'package:cpu_sim/src/data_memory.dart';
import 'package:cpu_sim/src/instruction_memory.dart';
import 'package:cpu_sim/src/mux.dart';
import 'package:cpu_sim/src/program_counter.dart';
import 'package:cpu_sim/src/registers.dart';

export 'src/bit.dart';

class CPUSim {
  final Alu alu = Alu();
  final Registers registers = Registers();
  final ControlRom controlRom = ControlRom();
  final InstructionMemory instructionMemory = InstructionMemory();
  final CallStack callStack = CallStack();
  final ProgramCounter programCounter = ProgramCounter();
  final DataMemory dataMemory = DataMemory();
  late final Clock clock = Clock(tick);

  Future<void> start() async {
    instructionMemory.setCurrentAddress(addressFromInt(0));
    clock.setActive(Bit.on);
    await clock.completionFuture;
  }

  void loadProgram(List<Instruction> instructions) {
    instructionMemory.insertProgram(instructions);
  }

  void tick() {
    instructionMemory.setCurrentAddress(programCounter.currentAddress);
    runInstruction(instructionMemory.currentInstruction);
  }

  void runInstruction(Instruction input) {
    var (partA, partB) = input;
    var opCode = partA.leftNibble;

    var thirdParamAsByte = partB.rightNibble.asByte();

    var branchCondition = (partA.bits[4], partA.bits[5]);

    var jumpAddress = (
      partA.bits[6],
      partA.bits[7],
      partB.bits[0],
      partB.bits[1],
      partB.bits[2],
      partB.bits[3],
      partB.bits[4],
      partB.bits[5],
      partB.bits[6],
      partB.bits[7],
    );

    var controlRomOutput = controlRom.getOutput(opCode);

    registers.setEnable(controlRomOutput.enableRegisters);
    dataMemory.setEnabled(controlRomOutput.dataMemoryEnabled);
    dataMemory.setMode(controlRomOutput.dataMemoryReadMode);

    registers.setReadA(partA.rightNibble);

    registers.setReadB(partB.leftNibble);

    Bit loadFromData = and(
      controlRomOutput.dataMemoryEnabled,
      controlRomOutput.dataMemoryReadMode,
    );

    registers.setWrite(
      muxNibble(
        muxNibble(
          partB.rightNibble,
          partA.rightNibble,
          controlRomOutput.destMux,
        ),
        partB.leftNibble,
        loadFromData,
      ),
    );

    alu.setByteA(registers.readA);

    alu.setByteB(
      muxByte(
        muxByte(registers.readB, partB, controlRomOutput.immediateBMux),
        thirdParamAsByte,
        controlRomOutput.dataMemoryEnabled,
      ),
    );

    dataMemory.setData(registers.readB);

    alu.setOperation(controlRomOutput.aluOperation);

    var aluOutput = alu.getOutput(controlRomOutput.shouldSetFlags);

    dataMemory.setAddress(aluOutput);

    var byteToWrite = muxByte(
      muxByte(aluOutput, partB, controlRomOutput.dataMux),
      dataMemory.read(),
      loadFromData,
    );

    registers.setInput(byteToWrite);

    var flags = alu.flags;

    var relatedFlag = muxBit(flags.$1, flags.$2, branchCondition.$1);
    var branchTriggered = and(
      xor(relatedFlag, branchCondition.$1),
      controlRomOutput.shouldBranch,
    );

    var shouldJump = controlRomOutput.shouldJump.or(branchTriggered);

    programCounter.setIn(
      muxInstructionAddress(
        muxInstructionAddress(
          programCounter.incrementAddress,
          jumpAddress,
          shouldJump,
        ),
        callStack.getOutput(),
        and(controlRomOutput.stackPopMode, controlRomOutput.useStack),
      ),
    );

    callStack.setEnabled(controlRomOutput.useStack);
    callStack.setMode(controlRomOutput.stackPopMode);
    callStack.setInput(programCounter.incrementAddress);

    clock.setActive(controlRomOutput.shouldHaltClock.not());
    dataMemory.clock();
    registers.clock();
    programCounter.clock();
    callStack.clock();
  }
}

extension on Nibble {
  Byte asByte() {
    return Byte.fromList([
      Bit.off, Bit.off, Bit.off, Bit.off, //
      $1, $2, $3, $4, //
    ]);
  }
}
