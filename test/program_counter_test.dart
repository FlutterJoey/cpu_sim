import 'package:cpu_sim/src/instruction_memory.dart';
import 'package:cpu_sim/src/program_counter.dart';
import 'package:test/test.dart';

void main() {
  group("Program counter", () {
    
    test("should increment the current address by one", () {
      var sut = ProgramCounter();
      
      
      sut.setIn(sut.incrementAddress);
      sut.clock();
      sut.setIn(sut.incrementAddress);
      sut.clock();
      sut.setIn(sut.incrementAddress);
      sut.clock();
      sut.setIn(sut.incrementAddress);
      sut.clock();
      sut.setIn(sut.incrementAddress);
      sut.clock();

      expect(sut.currentAddress, equals(addressFromInt(5)));
    });
  });
}