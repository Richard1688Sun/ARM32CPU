module decoder_pipeline_unit(
    input clk,
    input rst_n,
    input [6:0] pc_in,
    input [31:0] instr_in,
    output [31:0] instr_out,
    output [6:0] pc_out,
    output [6:0] opcode_decode_unit
);

// outputs
assign instr_out = instr_in;
assign pc_out = pc_in;

// module instances
idecoder decoder(
    .instr(instr_in),
    .cond(),
    .opcode(opcode_decode_unit),
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
    .W()
);

endmodule: decoder_pipeline_unit