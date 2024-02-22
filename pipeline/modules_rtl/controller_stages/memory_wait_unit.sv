module memory_wait_unit(
    // pipeline signals
    input clk,
    input rst_n,
    input [31:0] instr_in,
    input branch_ref,
    input branch_in,
    input sel_stall,
    output branch_value
    output [31:0] instr_output,
    // controller signals
    // NOTHING for now
);

// pipeline unit ports
wire branch_value_out;
wire [31:0] instr_out;
assign branch_value = branch_value_out;
assign instr_output = instr_out;

// controller ports
wire status_rdy_out;
assign status_rdy = status_rdy_out;

// pipeline unit module
pipeline_unit pipeline_unit(
    .clk(clk),
    .rst_n(rst_n),
    .instr_in(instr_in),
    .branch_ref(branch_ref),
    .branch_in(branch_in),
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
    .imm24(),
    .P(),
    .U(),
    .W(),
    .branch_value(branch_value_out)
    .instr_output(instr_out)
);

// controller module
// NOTHING for now

endmodule: memory_wait_unit