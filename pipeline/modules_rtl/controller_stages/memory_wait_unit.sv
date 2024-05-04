module memory_wait_unit(
    // pipeline signals
    input clk,
    input rst_n,
    input [31:0] instr_in,
    input [6:0] pc_in,
    output [3:0] rt,
    output [6:0] opcode,
    output [31:0] instr_output,
    output [6:0] pc_out
    // controller signals
    // NOTHING for now
);

// pipeline unit ports
wire [31:0] instr_out;
wire [3:0] rt_out;
wire [6:0] opcode_out;
assign instr_output = instr_out;
assign rt = rt_out;
assign opcode = opcode_out;

// controller ports
wire status_rdy_out;
assign status_rdy = status_rdy_out;

// pipeline unit module
memory_wait_pipeline_unit memory_wait_pipeline_unit(
    .clk(clk),
    .rst_n(rst_n),
    .instr_in(instr_in),
    .pc_in(pc_in),
    .rt(rt_out),
    .opcode(opcode_out),
    .instr_output(instr_out),
    .pc_out(pc_out)
);

// controller module
// NOTHING for now

endmodule: memory_wait_unit