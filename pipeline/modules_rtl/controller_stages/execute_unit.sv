module execute_unit(
    // pipeline_unit signals
    input clk,
    input reset,
    input [31:0] instr_in,
    input branch_ref,
    input branch_in,
    input sel_stall,
    output [3:0] cond,      // Condition code
    output [6:0] opcode,    // Opcode for the instruction
    output en_status,       // Enable status register
    output [3:0] rn,        // Rn
    output [3:0] rd,        // Rd (destination)
    output [3:0] rs,        // Rs
    output [3:0] rm,        // Rm 
    output [1:0] shift_op,  // Shift operation
    output [4:0] imm5,      // Immediate value
    output [11:0] imm12,    // Immediate value or second operand
    output [23:0] imm24,    // Address for branching
    output P,
    output U,
    output W,
    output branch_value
    // controller signals
    output [1:0] sel_A_in,
    output [1:0] sel_B_in,
    output [1:0] sel_shift_in,
    output sel_shift,
    output en_A,
    output en_B,
    output en_S
endmodule: execute_unit