module ldr_writeback_unit(
    // pipeline unit ports
    input clk,
    input rst_n,
    input [31:0] instr_in,
    input branch_ref,
    input branch_in,
    input sel_stall,
    output branch_value,
    output [31:0] instr_output,
    // controller signals
    output w_en_ldr
);

// pipeline unit ports
wire [6:0] opcode_decoded;
wire branch_value_out;
wire [31:0] instr_out;
assign branch_value = branch_value_out;
assign instr_output = instr_out;

// controller ports
reg w_en_ldr_reg;
assign w_en_ldr = w_en_ldr_reg;

// pipeline unit module
pipeline_unit pipeline_unit(
    .clk(clk),
    .rst_n(rst_n),
    .instr_in(instr_in),
    .branch_ref(branch_ref),
    .branch_in(branch_in),
    .sel_stall(sel_stall),
    .cond(),
    .opcode(opcode_decoded),
    .en_status(),
    .rn(),
    .rd(),
    .rs(),
    .rm(),
    .shift_op(),
    .imm5(),
    .imm12(),
    .imm24(),
    .P(),
    .U(),
    .W(),
    .branch_value(branch_value_out),
    .instr_output(instr_out)
);

// controller module
always_comb begin
    // default values
    w_en_ldr_reg = 1'b0;

    if (opcode_decoded[6:4] == 3'b110 || opcode_decoded[6:3] == 4'b1000) begin
        //w_en2
        w_en_ldr_reg = 1'b1;
    end
end
endmodule: ldr_writeback_unit