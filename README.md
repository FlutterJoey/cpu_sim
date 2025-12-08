# CPU simulator

This is a simple CPU simulator based on my own defined instructionset.

This is a learning project and a puzzle for an internal development project.

## Running the simulator

To run any program on the simulator, you first need to write a program in assembly.

Then run the following command:
`dart run bin/assembler.dart path/to/assembly_file.a`

This will create a program in the build folder.

Then, run your program by running:
`dart run bin/cpu_sim.dart`

The output will give you the current state of the registers.