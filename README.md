# RISC MIPS32 Pipelined Processor
This project is a Verilog implementation of a **RISC MIPS32 pipelined processor** with a testbench that demonstrates execution of basic arithmetic, load/store, and branch instructions. The design follows the classic **5-stage pipeline** (IF, ID, EX, MEM, WB).

**Features**
- **5-Stage Pipeline**: Instruction Fetch, Decode, Execute, Memory, Write-back  
- **Instruction Support**:
  - Arithmetic: `ADD`, `ADDI`  
  - Memory: `LW`, `SW`  
  - Branch: `BNEQZ` (used for factorial computation)  
  - `NOP` and `HLT` for synchronization and halting execution  
- **Memory & Register File**:  
  - `memory[0:1023]` for instructions + data  
  - `reg_bank[0:31]` for 32 general-purpose registers  

 **Testbench Programs**
The testbench (`MIPS32tb.v`) includes **three example programs**:

### Add Program
- Loads constants into registers and performs addition.  
- Example:  
  - `10 + 20 = 30`  
  - `30 + 25 = 55`  

### Load/Store Program
- Loads a value from memory, modifies it, and stores back.  
- Example:  
  - Initial `memory[120] = 85`  
  - `LW → R2 = 85`  
  - `ADDI R2, R2, 45 → R2 = 130`  
  - `SW R2 → memory[121] = 130`  

### Branch Program (Factorial)
- Computes factorial of a number using loop and multiplication.  
- Example:  
  - Input: `memory[200] = 7`  
  - Output: `7! = 5040` stored in `memory[198]`  


