CPU FILES LAST UPDATED FROM SOURCE: 4:40 PM, 3/07/2023
COMPILER LAST UPDATED: 3/07/2023

DIRECTORIES and FILES:
- CPU_Files    -- .vhd files that handle the actual design of the CPU.
- output       -- .vhd test bench files output by the assembler that test the CPU.
- programs     -- text files that can be compiled by the assembler; generally use
                  the .nok file format but that isn't needed.
- text_files   -- text files that are interacted with by the assembler.
- assembler.py -- simple assembler to compile assembly text files into VHDL test
                  benches for the CPU.
- example.nok  -- A basic set of assembly instructions to demonstrate functionality.
- README.txt   -- this
