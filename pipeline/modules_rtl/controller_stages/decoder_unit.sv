module decoder_unit(
    input clk,
    input rst_n,
    input [6:0] pc_in,
    input [31:0] instr_in,
    output [31:0] instr_out,
    output [6:0] pc_out,
    output [6:0] opcode_decode_unit
);

// pipeline module
decoder_pipeline_unit decoder_pipeline_unit(
    .clk(clk),
    .rst_n(rst_n),
    .pc_in(pc_in),
    .instr_in(instr_in),
    .instr_out(instr_out),
    .pc_out(pc_out),
    .opcode_decode_unit(opcode_decode_unit)
);

endmodule: decoder_unit