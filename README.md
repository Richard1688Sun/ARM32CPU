# Table of Contents

- [Table of Contents](#table-of-contents)
- [Modules](#modules)
  - [Datapath](#datapath)
    - [Datapath Ports](#datapath-ports)
  - [Controller](#controller)
    - [Controller Ports](#controller-ports)
  - [Instruction Queue](#instruction-queue)
  - [Stages](#stages)
    - [Pipeline Unit:](#pipeline-unit)
    - [Memory Stage:](#memory-stage)
  - [IDecoder](#idecoder)
    - [IDecoder Ports](#idecoder-ports)
    - [Opcode Table](#opcode-table)
    - [Notes](#notes)
  - [Branching](#branching)

# Modules

## Datapath

### Datapath Ports
Where all the actual computation happens within the CPU. Operational registers are A, B, and Shift. Those operational registers are then fed into the ALU for computation. This module is controlled by the `controller` module
**Inputs**

|         Name         | Origin     | Purpose                                                                                                        |
|:--------------------:|:-----------|:---------------------------------------------------------------------------------------------------------------|
|        `clk`         | hardware   | clock for hardware                                                                                             |
|    `[31:0] LR_in`    | ram        | Link Register value for branch & link instruction                                                              |
|    `sel_load_LR`     | controller | select writing to Link Register                                                                                |
|   `[3:0] w_addr1`    | controller | writeback address for normal and memory instructions                                                           |
|       `w_en1`        | controller | enable writeback to regfile at port 1                                                                          |
|  `[3:0] w_addr_ldr`  | idecoder   | writeback address for LDR instruction during `LDR_writeback`                                                   |
|      `w_en_ldr`      | controller | enable writeback to regfile for LDR port                                                                       |
| `[31:0] w_data_ldr`  | ram        | data to be written back to regfile for LDR port                                                                |
|    `[3:0] A_addr`    | idecoder   | address of rn                                                                                                  |
|    `[3:0] B_addr`    | idecoder   | address of rm                                                                                                  |
|  `[3:0] shift_addr`  | idecoder   | address for shift input to ALU or shift amount                                                                 |
|   `[3:0] str_addr`   | idecoder   | address for accessing STR data                                                                                 |
|    `[1:0] sel_pc`    | controller | select PC source within regfile                                                                                |
|      `load_pc`       | controller | load PC within regfile                                                                                         |
|  `[10:0] start_pc`   | controller | start PC value on startup                                                                                      |
|   `[1:0] sel_A_in`   | controller | select input to register A                                                                                     |
|   `[1:0] sel_B_in`   | controller | select input to register B                                                                                     |
| `[1:0] sel_shift_in` | controller | select input to shift unit                                                                                     |
|        `en_A`        | controller | enable input to register A                                                                                     |
|        `en_B`        | controller | enable input to register B                                                                                     |
| `[31:0] shift_imme`  | idecoder   | immediate shift value                                                                                          |
|     `sel_shift`      | controller | select shift type                                                                                              |
|   `[1:0] shift_op`   | idecoder   | shift operation                                                                                                |
|        `en_S`        | controller | enable input to shift unit                                                                                     |
|       `sel_A`        | controller | select input 1 to ALU                                                                                          |
|       `sel_B`        | controller | select input 2 to ALU                                                                                          |
|  `sel_branch_imme`   | controller | select immediate value for input 2 to ALU                                                                      |
|  `sel_pre_indexed`   | controller | select pre-indexed addressing mode for memory instructions(value dp_out is indexed prior to memory op == `~P`) |
|    `[31:0] imm12`    | idecoder   | immediate value for normal and memory instructions                                                             |
| `[31:0] imm_branch`  | idecoder   | immediate value for branch instructions                                                                        |
|    `[2:0] ALU_op`    | idecoder   | ALU operation                                                                                                  |
|     `en_status`      | controller | enable status register                                                                                         |
|     `status_rdy`     | controller | **[Maybe deprecated]** status register ready                                                                   |

**Outputs**
|         Name          |   Destination   |                          Purpose                          |
|:---------------------:|:---------------:|:---------------------------------------------------------:|
| `[31:0] datapath_out` | controller, ram |                  output of the datapath                   |
|  `[31:0] status_out`  |   controller    |               output of the status register               |
|   `[31:0] str_data`   |       ram       |        data read from regfile for STR instructions        |
|      `[10:0] PC`      |   controller    |                     output of the PC                      |
|  `[31:0] reg_output`  |    interface    | **[Maybe deprecated]** output of the regfile for testing  |
|   `[3:0] reg_addr`    |    interface    | **[Maybe deprecated]** address of the regfile for testing |


## Controller

### Controller Ports
The mastermind behind this CPU. Controls datapath and how it operates through signals. This module is fed the decoded instruction from the `IDecoder` module and then outputs the necessary control signals to the `Datapath` module as well as the memory unit. 

**Inputs**
|        Name         |  Origin  |         Purpose         |
|:-------------------:|:--------:|:-----------------------:|
|        `clk`        | hardware |   clock for hardware    |
|       `rst_n`       | hardware | active low reset signal |
|  `[31:0] instr_in`  |   ram    |    input instruction    |
| `[31:0] status_reg` | datapath |  status register value  |

**Outputs**
|              Name               |     Stage     | Destination |                          Purpose                           |
|:-------------------------------:|:-------------:|:-----------:|:----------------------------------------------------------:|
|   `[6:0] opcode_execute_unit`   |    execute    |  datapath   |                       decoded opcode                       |
|     `[3:0] rn_execute_unit`     |    execute    |  datapath   |                         decoded rn                         |
|     `[3:0] rs_execute_unit`     |    execute    |  datapath   |                         decoded rs                         |
|     `[3:0] rm_execute_unit`     |    execute    |  datapath   |                         decoded rm                         |
|    `[4:0] imm5_execute_unit`    |    execute    |  datapath   |                        decoded imm5                        |
|        `[1:0] sel_A_in`         |    execute    |  datapath   |                 select input to register A                 |
|        `[1:0] sel_B_in`         |    execute    |  datapath   |                 select input to register B                 |
|      `[1:0] sel_shift_in`       |    execute    |  datapath   |                 select input to shift unit                 |
|           `sel_shift`           |    execute    |  datapath   |                     select shift type                      |
|             `en_A`              |    execute    |  datapath   |                 enable input to register A                 |
|             `en_B`              |    execute    |  datapath   |                 enable input to register B                 |
|             `en_S`              |    execute    |  datapath   |                 enable input to shift unit                 |
|    `[3:0] cond_memory_unit`     |    memory     |  datapath   |                     decoded condition                      |
|   `[6:0] opcode_memory_unit`    |    memory     |  datapath   |                       decoded opcode                       |
|     `[3:0] rd_memory_unit`      |    memory     |  datapath   |                         decoded rd                         |
|  `[1:0] shift_op_memory_unit`   |    memory     |  datapath   |                  decoded shift operation                   |
|   `[11:0] imm12_memory_unit`    |    memory     |  datapath   |                       decoded imm12                        |
| `[31:0] imm_branch_memory_unit` |    memory     |  datapath   |                  decoded branch immediate                  |
|         `[1:0] sel_pc`          |    memory     |   regfile   |          select source to load PC within regfile           |
|            `load_pc`            |    memory     |   regfile   |                   load PC within regfile                   |
|        `sel_branch_imm`         |    memory     |  datapath   |         select immediate value for input 2 to ALU          |
|             `sel_A`             |    memory     |  datapath   |                   select input 1 to ALU                    |
|             `sel_B`             |    memory     |  datapath   |                   select input 2 to ALU                    |
|         `[2:0] ALU_op`          |    memory     |  datapath   |                       ALU operation                        |
|        `sel_pre_indexed`        |    memory     |  datapath   | select pre-indexed addressing mode for memory instructions |
|           `en_status`           |    memory     |  datapath   |                   enable status register                   |
|          `sel_load_LR`          |    memory     |  datapath   |              select writing to Link Register               |
|             `w_en1`             |    memory     |   regfile   |           enable writeback to regfile at port 1            |
|           `mem_w_en`            |    memory     |     ram     |                    enable memory write                     |
|           `w_en_ldr`            | ldr_writeback |   regfile   |          enable writeback to regfile for LDR port          |

## Instruction Queue:
Used to queue fetched instructions while the CPU is stalling. Necessary since the fetching process cannot be stalled, hence we will loose fetched instruction when the CPU is stalling.

**Diagram**
![image](https://github.com/Richard1688Sun/ARM32CPU/assets/112845533/333fb425-40f0-4857-8f84-4118e272354b)

**Attributes**
- 2 stage queue
- always moves instructions along the queue
  - overflowing the queue will loose the first instruction
- `is_empty` indicates that the queue is empty can we can begin taking instructions from the `fetch_wait` stage again

## Stages

### Fetch Stages:
Stages that fetches instructions from memory. Is in 2 parts since on-board memory takes `2` clock cycles to read

**fetch_pipeline_unit**: holds `branch_value` for squashing
  - Contains the following signals: 
    - Branch Register
  - Stalling:
    - Doesn't exist. Since at this stage there is no instruction yet. Technically the stalling is controlled by the `PC`. As long as the `PC` doesn't change this stage is effectively stalled

### Execute Stage:
Stage that loads execution registers(eg. `rn`, `rm`, and `rs`) and completes the ALU operations as well as shifting
When stalling, `instr_out` is NOP to load a blank instruction to the next stage. This is not done within `execute_pipeline_unit` because we need to correctly decoded data within `execute_unit`

**execute_pipeline_unit**:
  - Contains the following signals: 
    - Instruction Register
    - Branch Register
  - Stalling: triggered using `sel_stall` 
    - outputs `NOP` instead of stored instruction
    - does not replace the current `instr_reg` on next cycle

### Memory Stage:
Stage that deal with writebacks and memory operations. Is in 2 parts since reading from on-board memory(LDR) takes 2 clocks
Stage that does the following:
- Normal Instructions: Writeback to register file && loads `status_reg`
- Memory Instructions: 
  - STR: write to memory at `rt`
  - LDR: initiates read from memory at `rt`
  - Both: if `W == P == 1`(writeback and post-index) writes to `rn`
- Branch Instructions:
  - branches the PC if necessary 
  - writes to `LR` if necessary
- All:
  - increments PC value to begin fetching next instruction (different for Branch Instructions)

**memory_pipeline_unit**: 
  - Contains the following signals: 
    - Instruction Register
    - Branch Register
  - Stalling PC: triggered using `stall_pc`
    - turns `load_pc` to `0`, so fetch stages will not move pull subsequent instructions
  - Squashing: compares the `branch_value` with `branch_ref`
    - if squash: outputs `NOP` 
      - NOTE: `instr_reg` will replaced with new instruction the following clock so no need to squash that value
    - else: outputs `instr_reg` as normal

### Write Back Unit:
Stage deals with writeback for LDR instructions only. This is off-sync with others since reading from on-board memory takes 2 clock cycles + 1 for writeback to regfile(This stage)

Uses **writeback_pipeline_unit**:
  - Contains the following signals:
    - Instruction Register

> `Note:` Below is outdated, will be removed later

### Pipeline Unit:
The basic building for each stage of the pipeline. This modules holds the instructions for each stage and also decodes it as output. Also can be used to stall the pipeline if necessary through `sel_stall` signal. It also holds a designated `branch_val` for when the instruction was created.

For **fetch stage**, this has not instruction register portion

For **memory stage**, it has an extra part used for squashing instructions if `branch_val != branch_ref`. In such case, the instruction fed into the decoder will be NOP effectively squashing the instruction.

For **memory_wait stage and ldr_writeback stage**, it has no branch register portion. NOTE: this uses `pipeline unit`, just doesn't use the ports

### Memory Stage:
**Control Hazards**: Handles control hazards by squashing instructions when `branch_val != branch_ref`. In such case, the instruction fed into the decoder will be NOP effectively squashing the instruction. `branch_ref_global` is stored within this unit. It's next value(`branch_ref_next`) with either be `~branch_ref_global` if the current instruction is a branch and that branch is taken or `branch_ref_global` otherwise. `branch_ref_next` will be loaded into `branch_ref_global` the following clock cycle.

## IDecoder
Combinational logic that decodes the 32-bit ARM instruction into their respective fields. Also translates instructions into custom 7-bit opcode
### IDecoder Ports
**Inputs**
|      Name      | Origin |      Purpose      |
|:--------------:|:------:|:-----------------:|
| `[31:0] instr` |  ram   | input instruction |

**Outputs**
|        Name         |                          Purpose                          |
|:-------------------:|:---------------------------------------------------------:|
|    `[3:0] cond`     |                      Condition code                       |
|   `[6:0] opcode`    |                Opcode for the instruction                 |
|     `en_status`     |                  Enable status register                   |
|     `[3:0] rn`      |                            Rn                             |
|     `[3:0] rd`      |                     Rd (destination)                      |
|     `[3:0] rs`      |                            Rs                             |
|     `[3:0] rm`      |                            Rm                             |
|  `[1:0] shift_op`   |                      Shift operation                      |
|    `[4:0] imm5`     |                      Immediate value                      |
|   `[11:0] imm12`    | Immediate value or second operand for data processing ins |
| `[32:0] imm_branch` |                   Address for branching                   |
|         `P`         |                             P                             |
|         `U`         |                             U                             |
|         `W`         |                             W                             |

### Opcode Table
**Normal Instructions**
<table style="text-align: center;">
  <thead>
    <tr>
      <th></th>
      <th colspan=7>Opcode</th>
    </tr>
  </thead>
  <thead>
    <tr>
      <th>Instruction Type</th>
      <th>6</th>
      <th>5 (<code>sel_shift</code>)</th>
      <th>4 (<code>en_B == ~sel_B</code>)</th>
      <th>3</th>
      <th>2</th>
      <th>1</th>
      <th>0</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center">Immediate (2nd operand is a immediate value)</td>
      <td align="center">0</td>
      <td align="center">0</td>
      <td align="center">0</td>
      <td align="center"colspan=4> Instruction Dependant</td>
    </tr>
    <tr>
      <td align="center">Register (2nd operand is a rm, shift is immeidate value)</td>
      <td align="center">0</td>
      <td align="center">0</td>
      <td align="center">1</td>
      <td align="center"colspan=4> Instruction Dependant</td>
    </tr>
    <tr>
      <td align="center">Immediate (2nd operand is a immediate value)</td>
      <td align="center">0</td>
      <td align="center">1</td>
      <td align="center">1</td>
      <td align="center"colspan=4> Instruction Dependant</td>
    </tr>
  </tbody>
</table>
<table style="text-align: center;">
  <thead>
    <tr>
      <th></th>
      <th colspan=7>Opcode</th>
    </tr>
  </thead>
  <thead>
    <tr>
      <th>Instruction</th>
      <th>6</th>
      <th>5</th>
      <th>4</th>
      <th>3 (<code>en_A == ~sel_A</code>)</th>
      <th>2</th>
      <th>1</th>
      <th>0</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center">ADD</td>
      <td align="center"colspan=3>Type Dependant</td>
      <td align="center">1</td>
      <td align="center">0</td>
      <td align="center">0</td>
      <td align="center">0</td>
    </tr>
    <tr>
      <td align="center">SUB</td>
      <td align="center"colspan=3>Type Dependant</td>
      <td align="center">1</td>
      <td align="center">0</td>
      <td align="center">0</td>
      <td align="center">1</td>
    </tr>
    <tr>
      <td align="center">CMP</td>
      <td align="center"colspan=3>Type Dependant</td>
      <td align="center">1</td>
      <td align="center">0</td>
      <td align="center">1</td>
      <td align="center">0</td>
    </tr>
    <tr>
      <td align="center">AND</td>
      <td colspan=3>type Dependant</td>
      <td align="center">1</td>
      <td align="center">0</td>
      <td align="center">1</td>
      <td align="center">1</td>
    </tr>
    <tr>
      <td align="center">ORR</td>
      <td align="center"colspan=3>Type Dependant</td>
      <td align="center">1</td>
      <td align="center">1</td>
      <td align="center">0</td>
      <td align="center">0</td>
    </tr>
    <tr>
      <td align="center">EOR</td>
      <td align="center" colspan=3>Type Dependant</td>
      <td align="center">1</td>
      <td align="center">1</td>
      <td align="center">0</td>
      <td align="center">1</td>
    </tr>
    <tr>
      <td align="center">MOV, LSL, LSR, ASR, ROR</td>
      <td align="center" colspan=3>Type Dependant</td>
      <td align="center">0</td>
      <td align="center">0</td>
      <td align="center">0</td>
      <td align="center">0</td>
    </tr>
  </tbody>
</table>

> Note: `opcode[6] == 0` means this instruction is a normal instruction  

<br/>

**Memory Instructions**
<table style="text-align: center;">
  <thead>
    <tr>
      <th></th>
      <th colspan=7>Opcode</th>
    </tr>
  </thead>
  <thead>
    <tr>
      <th>Instruction</th>
      <th>6</th>
      <th>5</th>
      <th>4 (<code>0/1 == STR/LDR</code>)</th>
      <th>3 (<code>0/1 == imm/reg</code>)</th>
      <th>2 (<code>pre-indexed or P</code>)</th>
      <th>1 (<code>upward or U</code>)</th>
      <th>0 (<code>writeback or W</code>)</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center">LDR_I</td>
      <td align="center">1</td>
      <td align="center">1</td>
      <td align="center">0</td>
      <td align="center">0</td>
      <td align="center" colspan=3>Instruction Dependant</td>
    </tr>
    <tr>
      <td align="center">LDR_R</td>
      <td align="center">1</td>
      <td align="center">1</td>
      <td align="center">0</td>
      <td align="center">1</td>
      <td align="center" colspan=3>Instruction Dependant</td>
    </tr>
    <tr>
      <td align="center">LDR_Literal</td>
      <td align="center">1</td>
      <td align="center">0</td>
      <td align="center">0</td>
      <td align="center">0</td>
      <td align="center" colspan=3>Instruction Dependant</td>
    </tr>
    <tr>
      <td align="center">STR_I</td>
      <td align="center">1</td>
      <td align="center">1</td>
      <td align="center">1</td>
      <td align="center">0</td>
      <td align="center" colspan=3>Instruction Dependant</td>
    </tr>
    <tr>
      <td align="center">STR_R</td>
      <td align="center">1</td>
      <td align="center">1</td>
      <td align="center">1</td>
      <td align="center">1</td>
      <td align="center" colspan=3>Instruction Dependant</td>
    </tr>
  </tbody>
</table>

> Note: `opcode[6:5] == 11` means this instruction is a memory instruction with exception of `LDR_Literal` which has `opcode[6:3] == 1000`

> Note: `P == 0` means post-index addressing(use the post-ALU value for addr), `P == 1` means pre-index addressing **0 is the most basic instruction operation**

> Note: `U == 0` means ALU subtraction operation, `U == 1` means ALU addition operation

> Note: `W == 0` means no writeback to base register, `W == 1` means yes writeback to base register

<br/>

**Branch Instructions**

<table style="text-align: center;">
  <thead>
    <tr>
      <th></th>
      <th colspan=7>Opcode</th>
    </tr>
    <tr>
      <th>Instruction</th>
      <th>6</th>
      <th>5</th>
      <th>4</th>
      <th>3</th>
      <th>2</th>
      <th>1 (indicates load LR)</th>
      <th>0 (<code>~sel_B</code>)</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center">B</td>
      <td align="center">1</td>
      <td align="center">0</td>
      <td align="center">0</td>
      <td align="center">1</td>
      <td align="center">0</td>
      <td align="center">0</td>
      <td align="center">0</td>
    </tr>
    <tr>
      <td align="center">BL</td>
      <td align="center">1</td>
      <td align="center">0</td>
      <td align="center">0</td>
      <td align="center">1</td>
      <td align="center">0</td>
      <td align="center">1</td>
      <td align="center">0</td>
    </tr>
    <tr>
      <td align="center">BX</td>
      <td align="center">1</td>
      <td align="center">0</td>
      <td align="center">0</td>
      <td align="center">1</td>
      <td align="center">0</td>
      <td align="center">0</td>
      <td align="center">1</td>
    </tr>    
    <tr>
      <td align="center">BLX</td>
      <td align="center">1</td>
      <td align="center">0</td>
      <td align="center">0</td>
      <td align="center">1</td>
      <td align="center">0</td>
      <td align="center">1</td>
      <td align="center">1</td>
    </tr>
  </tbody>
</table>

> Note: `opcode[6:3] == 1001` means this instruction is a branch instruction

<br/>

**Special Instructions**

<table style="text-align: center;">
  <thead>
    <tr>
      <th></th>
      <th colspan=7>Opcode</th>
    </tr>
    <tr>
      <th>Instruction</th>
      <th>6</th>
      <th>5</th>
      <th>4</th>
      <th>3</th>
      <th>2</th>
      <th>1</th>
      <th>0</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center">NOP</td>
      <td align="center">0</td>
      <td align="center">1</td>
      <td align="center">0</td>
      <td align="center">0</td>
      <td align="center">0</td>
      <td align="center">0</td>
      <td align="center">0</td>
    </tr>
  </tbody>
</table>

### Notes

- Memory is by index -> each index is 4 bytes
- All memory operations thus are also divided by 4 to match new memory access protocol

## Branching

- `type X` are absolute address
- `type immediate` are PC relative
