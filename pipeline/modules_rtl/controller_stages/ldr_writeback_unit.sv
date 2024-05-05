module ldr_writeback_unit(
    // pipeline unit ports
    input clk,
    input rst_n,
    input [31:0] instr_in,
    input [6:0] pc_in,
    // controller signals
    output [3:0] rt,
    output [6:0] opcode,
    output w_en_ldr,
    output [6:0] pc_out
);

// pipeline unit ports
wire [3:0] rt_out;
wire [6:0] opcode_out;
assign rt = rt_out;
assign opcode = opcode_out;

// controller ports
reg w_en_ldr_reg;
assign w_en_ldr = w_en_ldr_reg;

// pipeline unit module
writeback_pipeline_unit writeback_pipeline_unit(
    .clk(clk),
    .rst_n(rst_n),
    .instr_in(instr_in),
    .pc_in(pc_in),
    .rt(rt_out),
    .opcode(opcode_out),
    .pc_out(pc_out)
);

// controller module
always_comb begin
    // default values
    w_en_ldr_reg = 1'b0;

    if (opcode_out[6:4] == 3'b110 || opcode_out[6:3] == 4'b1000) begin
        //w_en_ldr_reg
        w_en_ldr_reg = 1'b1;
    end
end
endmodule: ldr_writeback_unit