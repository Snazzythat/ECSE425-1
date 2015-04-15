
To Run the processor
Instructions:
1- Generate machine code using the assemblers
2- Create a new project in ModelSim and add all .vhd files as exisiting files
3- Compile all files and start simulation on the "Sandbox.vhd"

*****************************************************************************
Optimisation were implemented but not integrated to the processor because of time issue
Bellow are the instructions you need to follow to run each optimizatiion technique testbanch

Run the Branch Predictor
Instructions
1.Create a new project in ModelSim and add .vhd files that the branch-predictor folder 2.contains i.e.
	1. tb_branch_predictor.vhdl
	2. branchPredictor.vhdl

3.Compile all files and start simulation on the “tb_branch_perdictor.vhdl”

*****************************************************************************
How to run the Python Assembler:
1st deliverable:
  Run "python assembler.py"

2nd deliverable (replace assembly.asm with the assembly file name):
  Run "python AssemblerFinal.py" then enter the file name "assembly.asm"
  or
  Run "python AssemblerFinal.py assembly.asm"
  
*****************************************************************************
How to run the windows .exe Assembler (replace assembly.asm with the assembly file name):
  In the "Test compiler" folder use "425_Assembler.exe" the same way as the python assembler
    "425_Assembler.exe assembly.asm"
    or
    "425_Assembler.exe" then enter the file name

*****************************************************************************
All assemblers create the "Init.dat" file to be used in the VHDL project.

The windows assembler also creates the "Init.opt" file, which is the experimental
scheduled machine code. Feature not working properly.
