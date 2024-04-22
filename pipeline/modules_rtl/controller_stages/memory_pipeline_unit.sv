module memory_pipeline_unit(
    // inputs
    input clk,
    input rst_n,
    input [31:0] instr_in,
    input branch_ref,
    input branch_in,
    // outputs
    output [31:0] instr_output,
    output [3:0] cond,      // Condition code
    output [6:0] opcode,    // Opcode for the instruction
    output en_status,       // Enable status register
    output [3:0] rn,        // Rn
    output [3:0] rd,        // Rd (destination)
    output [1:0] shift_op,  // Shift operation
    output [11:0] imm12,    // Immediate value or second operand
    output [31:0] imm_branch,    // Address for branching
    output P,
    output U,
    output W
);
// internal signals
localparam [31:0] NOP = 32'b1110_00110010_0000_11110000_00000000;
reg [31:0] instr_reg;
reg branch_value_reg;

// module outputs
wire [3:0] cond_out, rn_out, rd_out, rs_out, rm_out;
wire [1:0] shift_op_out;
wire [4:0] imm5_out;
wire [11:0] imm12_out;
wire [31:0] imm_branch_out;
wire P_out, U_out, W_out;
wire en_status_out;
wire [6:0] opcode_out;
wire [31:0] instr_decoder_in;
assign cond = cond_out;
assign opcode = opcode_out;
assign en_status = en_status_out;
assign rn = rn_out; 
assign rd = rd_out;
assign shift_op = shift_op_out;
assign imm12 = imm12_out;
assign imm_branch = imm_branch_out;
assign P = P_out;
assign U = U_out;
assign W = W_out;
assign instr_output = instr_decoder_in;

// module instances
idecoder decoder(
    .instr(instr_decoder_in),
    .cond(cond_out),
    .opcode(opcode_out),
    .en_status(en_status_out),
    .rn(rn_out),
    .rd(rd_out),
    .rs(),
    .rm(),
    .shift_op(shift_op_out),
    .imm5(),
    .imm12(imm12_out),
    .imm_branch(imm_branch_out),
    .P(P_out),
    .U(U_out),
    .W(W_out)
);

// mux
assign instr_decoder_in = (branch_ref == branch_value_reg) ? instr_reg : NOP;

// instruction register
always_ff @( posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        instr_reg <= NOP;
    end else begin
        instr_reg <= instr_in;
    end
end

// branch register
always_ff @( posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        branch_value_reg <= 0;
    end else begin
        branch_value_reg <= branch_in;
    end
end
endmodule: memory_pipeline_unit