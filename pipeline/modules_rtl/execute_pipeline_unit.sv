module execute_pipeline_unit(
    // inputs
    input clk,
    input rst_n,
    input [31:0] instr_in,
    input branch_in,
    input sel_stall,
    // outputs
    output branch_value,
    output [31:0] instr_output,
    output [3:0] cond,      // Condition code
    output [6:0] opcode,    // Opcode for the instruction
    output [3:0] rn,        // Rn
    output [3:0] rs,        // Rs
    output [3:0] rm,        // Rm 
    output [4:0] imm5      // Immediate value
);
// internal signals
localparam [31:0] NOP = 32'b1110_00110010_0000_11110000_00000000;
reg [31:0] instr_reg;
reg branch_value_reg;

// module outputs
wire [3:0] cond_out, rn_out, rs_out, rm_out;
wire [4:0] imm5_out;
wire [6:0] opcode_out;
wire [31:0] instr_decoder_in;
assign cond = cond_out;
assign opcode = opcode_out;
assign rn = rn_out; 
assign rs = rs_out;
assign rm = rm_out;
assign imm5 = imm5_out;
assign branch_value = branch_value_reg;
assign instr_output = instr_decoder_in;

// module instances
idecoder decoder(
    .instr(instr_decoder_in),
    .cond(cond_out),
    .opcode(opcode_out),
    .en_status(),
    .rn(rn_out),
    .rd(),
    .rs(rs_out),
    .rm(rm_out),
    .shift_op(),
    .imm5(imm5_out),
    .imm12(),
    .imm_branch(),
    .P(),
    .U(),
    .W()
);

// mux
assign instr_decoder_in = (sel_stall == 1'b1)? NOP : instr_reg;

// instruction register
always_ff @( posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        instr_reg <= NOP;
    end else begin
        if (sel_stall == 1'b0) begin
            instr_reg <= instr_in;
        end
    end
end

// branch register
always_ff @( posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        branch_value_reg <= 0;
    end else begin
        if (sel_stall == 1'b1) begin
            branch_value_reg <= branch_value_reg;
        end else begin
            branch_value_reg <= branch_in;
        end
    end
end
endmodule: execute_pipeline_unit