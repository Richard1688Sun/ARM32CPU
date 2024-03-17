module memory_wait_unit(
    // pipeline signals
    input clk,
    input rst_n,
    input [31:0] instr_in,
    input sel_stall,
    output [31:0] instr_output
    // controller signals
    // NOTHING for now
);

// pipeline unit ports
wire [31:0] instr_out;
assign instr_output = instr_out;

// controller ports
wire status_rdy_out;
assign status_rdy = status_rdy_out;

// pipeline unit module
pipeline_unit pipeline_unit(
    .clk(clk),
    .rst_n(rst_n),
    .instr_in(instr_in),
    .branch_in(),
    .sel_stall(sel_stall),
    .cond(),
    .opcode(),
    .en_status(),
    .rn(),
    .rd(),
    .rs(),
    .rm(),
    .shift_op(),
    .imm5(),
    .imm12(),
    .imm_branch(),
    .P(),
    .U(),
    .W(),
    .branch_value(),
    .instr_output(instr_out)
);

// controller module
// NOTHING for now

endmodule: memory_wait_unit