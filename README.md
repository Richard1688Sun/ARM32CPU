# Table of Contents

- [Modules](#modules)
  - [Datapath](#datapath)
    - [Ports](#datapath-ports)
  - [Controller](#controller)
    - [Ports](#controller-ports)
    - [Stages](#stages)
  - [IDecoder](#idecoder)
    - [Ports](#idecoder-ports)
    - [Opcode Table](#opcode-table)
    - [Notes](#notes)

# Modules

## Datapath

### Datapath Ports
**Inputs**

|         Name         | Origin     | Purpose                                                      |
|:--------------------:|:-----------|:-------------------------------------------------------------|
|        `clk`         | hardware   | clock for hardware                                           |
|    `[31:0] LR_in`    | ram        | Link Register value for branch & link instruction            |
|    `sel_load_LR`     | controller | select writing to Link Register                              |
|   `[3:0] w_addr1`    | controller | writeback address for normal and memory instructions         |
|       `w_en1`        | controller | enable writeback to regfile at port 1                        |
|  `[3:0] w_addr_ldr`  | idecoder   | writeback address for LDR instruction during `LDR_writeback` |
|      `w_en_ldr`      | controller | enable writeback to regfile for LDR port                     |
| `[31:0] w_data_ldr`  | ram        | data to be written back to regfile for LDR port              |
|    `[3:0] A_addr`    | idecoder   | address of rn                                                |
|    `[3:0] B_addr`    | idecoder   | address of rm                                                |
|  `[3:0] shift_addr`  | idecoder   | address for shift input to ALU or shift amount               |
|   `[3:0] str_addr`   | idecoder   | address for accessing STR data                               |
|    `[1:0] sel_pc`    | controller | select PC source within regfile                              |
|      `load_pc`       | controller | load PC within regfile                                       |
|  `[10:0] start_pc`   | controller | start PC value on startup                                    |
|   `[1:0] sel_A_in`   | controller | select input to register A                                   |
|   `[1:0] sel_B_in`   | controller | select input to register B                                   |
| `[1:0] sel_shift_in` | controller | select input to shift unit                                   |
|        `en_A`        | controller | enable input to register A                                   |
|        `en_B`        | controller | enable input to register B                                   |
| `[31:0] shift_imme`  | idecoder   | immediate shift value                                        |
|     `sel_shift`      | controller | select shift type                                            |
|   `[1:0] shift_op`   | idecoder   | shift operation                                              |
|        `en_S`        | controller | enable input to shift unit                                   |
|       `sel_A`        | controller | select input 1 to ALU                                        |
|       `sel_B`        | controller | select input 2 to ALU                                        |
|  `sel_branch_imme`   | controller | select immediate value for input 2 to ALU                    |
|  `sel_pre_indexed`   | controller | select pre-indexed addressing mode for memory instructions   |
|    `[31:0] imm12`    | idecoder   | immediate value for normal and memory instructions           |
| `[31:0] imm_branch`  | idecoder   | immediate value for branch instructions                      |
|    `[2:0] ALU_op`    | idecoder   | ALU operation                                                |
|     `en_status`      | controller | enable status register                                       |
|     `status_rdy`     | controller | **[Maybe deprecated]** status register ready                 |

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

### Stages

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

> Note: `opcode[6:5] == 11` means this instruction is a memory instruction with exception of `LDR_Literal` which has `opcode[6:5] == 10`

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
      <th>2 (<code>sel_load_LR</code>)</th>
      <th>1 (<code>~sel_B</code>)</th>
      <th>0</th>
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
      <td align="center">1</td>
      <td align="center">0</td>
      <td align="center">0</td>
    </tr>
    <tr>
      <td align="center">BX</td>
      <td align="center">1</td>
      <td align="center">0</td>
      <td align="center">0</td>
      <td align="center">1</td>
      <td align="center">0</td>
      <td align="center">1</td>
      <td align="center">0</td>
    </tr>    
    <tr>
      <td align="center">BLX</td>
      <td align="center">1</td>
      <td align="center">0</td>
      <td align="center">0</td>
      <td align="center">1</td>
      <td align="center">1</td>
      <td align="center">1</td>
      <td align="center">0</td>
    </tr>
  </tbody>
</table>

> Note: `opcode[6:3] == 1001` means this instruction is a branch instruction

### Notes

- Memory is by index -> each index is 4 bytes
- All memory operations thus are also divided by 4 to match new memory access protocol

## Branching

- `type X` are absolute address
- `type immediate` are PC relative