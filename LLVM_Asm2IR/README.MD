# Asm to IR
Generating IR for SDL graphical sample from own assembly

## Usage:
```
clang++ `llvm-config --cppflags --ldflags --libs` app_asm_IRgen_<type>.cpp -lSDL2
```

Where `<type>` represents building and execution type:
- **cpu**

    Interpreting every instruction by custom CPU (no IR)

- **1**

    Building IR from assembly using emulating functions such as do_ADD(...) and running it using Execution Engine

- **2**

    Building IR from assembly using IR equivalent for every instruction except graphics instructions and running it using Execution Engine

## Again, if the compiler does not see `begin_code.h` file (as it was for me), you can try:
```
clang++ `llvm-config --cppflags --ldflags --libs` app_asm_IRgen_<type>.cpp -lSDL2 -I/usr/include/SDL2
```

## After compilation you can run:
```
./a.out app.s
```


## Instruction Set Architecture (ISA)
### Here is description of all instructions.


- RET

    Return from function

    `pc` &larr; `call_stack.top()`

    `call_stack.pop()`

- PUT_PIXELS_14

    Put 14 pixels on screen texture in a horizontal strip. X and Y coordinates of screen and color obtained via particular registers: `x0`, `x1`, `x2`

- FLUSH

    Update framebuffer and draw the texture to screen

- JMP

    Unconditional jump to provided basic block

    `pc` &larr; `bb_pc`

- CALL

    `call_stack.push(pc + 1)`

    `pc` &larr; `func_pc`


- RAND

    Generate random number and store it into register `rs1`

    `rs1` &larr; `rand()`

- MV

    Copy value from `rs2` to `rs1`

    `rs1` &larr; `rs2`

- MVI

    Copy value of `imm` to `rs1`

    `rs1` &larr; `imm`

- ALLOCA

    Allocate array of type `RegVal_t` with size `imm` and store pointer to `rs1`

    `rs1` &larr; `new RegVal_t[imm]`

- ADD

    Add value of `rs2` to value of `rs3` and store result into `rs1`

    `rs1` &larr; `rs2 + rs3`

- SUB

    Subtract value of `rs3` from value of `rs2` and store result into `rs1`

    `rs1` &larr; `rs2 - rs3`

- DIV

    Divide value of `rs2` by value of `rs3` and store result into `rs1`

    `rs1` &larr; `rs2 / rs3`

- OR

    Bitwise `OR` of value of `rs2` and value of `rs3` and store result into `rs1`

    `rs1` &larr; `rs2 | rs3`

- ADDI

    Add `imm` to `rs2` and store result into `rs1`

    `rs1` &larr; `rs2 + imm`

- MULI

    Multiply `imm` with `rs2` and store result into `rs1`

    `rs1` &larr; `rs2 * imm`

- REMI

    Obtain remainder of division `rs2` by `imm` and store result into `rs1`

    `rs1` &larr; `rs2 % imm`

- ANDI

    Bitwise `AND` of value of `rs2` and value of `imm` and store result into `rs1`

    `rs1` &larr; `rs2 | imm`

- SLI

    Shift left value of `rs2` by value of `imm` and store result into `rs1`

    `rs1` &larr; `rs2 << imm`

- LOAD

    Load value of memory at position `rs2[rs3]` into `rs1`

    `rs1` &larr; `rs2[rs3]`

- STORE

    Store value of `rs1` into memory at position `rs2[rs3]`

    `rs2[rs3]` &larr; `rs1`

- ICMPGE

    Compare values of `rs2` and `rs3` and check if `rs2` greater or equal than `rs3` and store bool result into `rs1`

    `rs1` &larr; `rs2 >= rs3 ? 1 : 0`

- ICMPNE

    Compare values of `rs2` and `rs3` and check if `rs2` not equal to `rs3` and store bool result into `rs1`

    `rs1` &larr; `rs2 != rs3 ? 1 : 0`

- CONDBR

    Conditional branch to one of two provided basic blocks based on the value of `rs1`

    `pc` &larr; `rs1 == true ? true_bb_pc : false_bb_pc`
