import 'dart:async';
import 'dart:io' as io;

import 'package:cpu_sim/cpu_sim.dart';
import 'package:cpu_sim/src/bit_operators.dart';
import 'package:cpu_sim/src/byte.dart';
import 'package:cpu_sim/src/data_memory.dart';
import 'package:cpu_sim/src/mux.dart';

class KeyboardInput {
  KeyboardInput({required this.memory}) {
    _keyboardIntructionControl = KeyboardInstructionControl(this);
    _keyboardPressData = KeyboardPressData(this);
    memory.attach(
      _keyboardIntructionControlAddress,
      _keyboardIntructionControl,
    );
    memory.attach(_keyboardPressDataAddress, _keyboardPressData);
    _subscription = io.stdin.listen((data) {
      lastPressedKey = muxByte(
        lastPressedKey,
        Byte.fromValue(data.first),
        collectBit,
      );
      collectBit = Bit.off;
    });
  }

  final _keyboardPressDataAddress = Byte.fromValue(0xFB);
  final _keyboardIntructionControlAddress = Byte.fromValue(0xFC);

  late final StreamSubscription _subscription;
  late final KeyboardInstructionControl _keyboardIntructionControl;
  late final KeyboardPressData _keyboardPressData;

  final DataMemory memory;

  Byte lastPressedKey = Byte.fromValue(0);

  Bit collectBit = Bit.off;
  void setCollectKeyBit(Bit bit) {
    collectBit = bit.or(collectBit);
  }

  void clearCollectKeyBit(Bit bit) {
    collectBit = and(collectBit, bit.not());
  }

  Bit collectLatest = Bit.off;
  void setCollectLatestMode(Bit bit) {
    collectLatest = bit;
  }

  void dispose() {
    _subscription.cancel();
  }
}

class KeyboardPressData extends MemoryAttachment {
  final KeyboardInput keyboardInput;

  KeyboardPressData(this.keyboardInput);

  @override
  Byte read() {
    return keyboardInput.lastPressedKey;
  }

  @override
  void write(Byte write) {}
}

class KeyboardInstructionControl extends MemoryAttachment {
  final KeyboardInput keyboardInput;

  KeyboardInstructionControl(this.keyboardInput);

  @override
  Byte read() {
    return Byte.fromList([
      Bit.off,
      Bit.off,
      Bit.off,
      Bit.off,
      Bit.off,
      Bit.off,
      keyboardInput.collectLatest,
      keyboardInput.collectBit,
    ]);
  }

  @override
  void write(Byte write) {
    keyboardInput.setCollectKeyBit(write.bits[7]);
    keyboardInput.clearCollectKeyBit(write.bits[6]);
    keyboardInput.setCollectLatestMode(write.bits[5]);
  }
}
