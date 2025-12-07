import 'dart:async';

import 'package:cpu_sim/cpu_sim.dart';

class Clock {
  late Timer timer;
  Completer completer = Completer();
  Clock(this.onTick) {
    timer = Timer.periodic(Duration(milliseconds: 100), (clock) {
      if (_isActive == Bit.off) return;
      onTick();
    });
  }

  Bit _isActive = Bit.off;

  void setActive(Bit bit) {
    _isActive = bit;
    if (bit == Bit.off) {
      timer.cancel();
      completer.complete();
    }
  }

  Future<void> get completionFuture => completer.future;

  void Function() onTick;
}
