import 'package:cpu_sim/src/bit.dart';

Bit and(Bit a, Bit b) {
  return nand(a, b).not();
}

Bit nand(Bit a, Bit b) {
  return a.not().or(b.not());
}

Bit nor(Bit a, Bit b) {
  return a.or(b).not();
}

Bit xor(Bit a, Bit b) {
  var aAndB = and(a, b);
  return and(aAndB.not(), a.or(b));
}

Bit xnor(Bit a, Bit b) {
  return xor(a, b).not();
}

(Bit result, Bit overflow) halfAdd(Bit a, Bit b) {
  return (xor(a, b), and(a, b));
}

(Bit result, Bit overflow) add(Bit a, Bit b, [Bit overflowIn = Bit.off]) {
  var (result, overflow) = halfAdd(a, b);
  return (xor(result, overflowIn), overflow.or(and(result, overflowIn)));
}
