module pipeline_unit(
    // inputs
    input clk,
    input [31:0] instr_in,
    input branch_ref,
    input branch_in,
    input sel_stall,
    // outputs
    output [3:0] cond,      // Condition code
    output [6:0] opcode,    // Opcode for the instruction
    output en_status,       // Enable status register
    output [3:0] rn,        // Rn
    output [3:0] rd,        // Rd (destination)
    output [3:0] rs,        // Rs
    output [3:0] rm,        // Rm 
    output [1:0] shift_op,  // Shift operation
    output [4:0] imm5,      // Immediate value
    output [11:0] imm12,    // Immediate value or second operand
    output [23:0] imm24,    // Address for branching
    output P,
    output U,
    output W,
    output branch_value
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
wire [23:0] imm24_out;
wire P_out, U_out, W_out, branch_value_out;
wire en_status_out;
wire [6:0] opcode_out;
wire [31:0] instr_decoder_in;
assign cond = cond_out;
assign opcode = opcode_out;
assign en_status = en_status_out;
assign rn = rn_out; 
assign rd = rd_out;
assign rs = rs_out;
assign rm = rm_out;
assign shift_op = shift_op_out;
assign imm5 = imm5_out;
assign imm12 = imm12_out;
assign imm24 = imm24_out;
assign P = P_out;
assign U = U_out;
assign W = W_out;
assign branch_value = branch_value_reg;

// module instances
idecoder decoder(
    .instr(instr_decoder_in),
    .cond(cond_out),
    .opcode(opcode_out),
    .en_status(en_status_out),
    .rn(rn_out),
    .rd(rd_out),
    .rs(rs_out),
    .rm(rm_out),
    .shift_op(shift_op_out),
    .imm5(imm5_out),
    .imm12(imm12_out),
    .imm24(imm24_out),
    .P(P_out),
    .U(U_out),
    .W(W_out)
);

// mux
assign instr_decoder_in = (branch_ref == branch_value_reg) ? instr_reg : NOP;

// instruction register
always_ff @( posedge clk) begin
    if (sel_stall == 1'b1) begin
        instr_reg <= instr_reg;
    end else begin
        instr_reg <= instr_in;
    end
end

// branch register
always_ff @( posedge clk) begin
    if (sel_stall == 1'b1) begin
        branch_value_reg <= branch_value_reg;
    end else begin
        branch_value_reg <= branch_in;
    end
end
endmodule: pipeline_unit