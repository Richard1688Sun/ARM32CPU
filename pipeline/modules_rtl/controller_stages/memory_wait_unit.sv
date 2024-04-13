module memory_wait_unit(
    // pipeline signals
    input clk,
    input rst_n,
    input [31:0] instr_in,
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
memory_wait_pipeline_unit memory_wait_pipeline_unit(
    .clk(clk),
    .rst_n(rst_n),
    .instr_in(instr_in),
    .instr_output(instr_out)
);

// controller module
// NOTHING for now

endmodule: memory_wait_unit