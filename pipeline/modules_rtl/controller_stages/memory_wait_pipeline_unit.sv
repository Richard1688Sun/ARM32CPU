module memory_wait_pipeline_unit(
    // inputs
    input clk,
    input rst_n,
    input [31:0] instr_in,
    input [6:0] pc_in,
    // outputs
    output [3:0] rt,
    output [6:0] opcode,
    output [31:0] instr_output,
    output [6:0] pc_out
);
// internal signals
localparam [31:0] NOP = 32'b1110_00110010_0000_11110000_00000000;

// module outputs
reg [31:0] instr_reg;
wire [3:0] rt_out;
wire [6:0] opcode_out;
reg [6:0] pc_reg;
assign instr_output = instr_reg;
assign rt = rt_out;
assign opcode = opcode_out;
assign pc_out = pc_reg;

// module instances
idecoder decoder(
    .instr(instr_reg),
    .cond(),
    .opcode(opcode_out),
    .en_status(),
    .rn(),
    .rd(rt_out),
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

// instruction register
always_ff @( posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        instr_reg <= NOP;
    end else begin
        instr_reg <= instr_in;
    end
end

// pc register
always_ff @( posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        pc_reg <= 7'd0
    end else begin
        pc_reg <= pc_in;
    end
end
endmodule: memory_wait_pipeline_unit