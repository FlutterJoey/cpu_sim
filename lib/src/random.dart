import 'dart:math';

import 'package:cpu_sim/src/byte.dart';
import 'package:cpu_sim/src/data_memory.dart';

class RandomAttachment extends MemoryAttachment {
  final Random random = Random.secure();

  @override
  Byte read() {
    return Byte.fromValue(random.nextInt(256));
  }

  @override
  void write(Byte write) {}
}
