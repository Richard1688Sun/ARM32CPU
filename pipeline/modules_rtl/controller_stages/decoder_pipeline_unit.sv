module decoder_pipeline_unit(
    input clk,
    input rst_n,
    input [6:0] pc_in,
    input [31:0] instr_in,
    output [31:0] instr_out,
    output [6:0] pc_out
);

// outputs
assign instr_out = instr_in;
assign pc_out = pc_in;

endmodule: decoder_pipeline_unit