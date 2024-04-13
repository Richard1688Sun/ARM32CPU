module writeback_pipeline_unit(
    // inputs
    input clk,
    input rst_n,
    input [31:0] instr_in,
    // outputs
    output [6:0] opcode    // Opcode for the instruction
);
// internal signals
localparam [31:0] NOP = 32'b1110_00110010_0000_11110000_00000000;
reg [31:0] instr_reg;

// module outputs
wire [6:0] opcode_out;
wire [31:0] instr_decoder_in;
assign opcode = opcode_out;

// module instances
idecoder decoder(
    .instr(instr_decoder_in),
    .cond(),
    .opcode(opcode_out),
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

// mux
assign instr_decoder_in = instr_reg;

// instruction register
always_ff @( posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        instr_reg <= NOP;
    end else begin
        instr_reg <= instr_in;
    end
end
endmodule: writeback_pipeline_unit