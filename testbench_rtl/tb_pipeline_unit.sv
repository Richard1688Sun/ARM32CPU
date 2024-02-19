module tb_pipeline_unit();

// DUT inputs
reg clk;
reg [31:0] instr_in;
reg branch_ref;
reg branch_in;
reg sel_stall;

// DUT outputs
wire [3:0] cond;
wire [6:0] opcode;
wire en_status;
wire [3:0] rn;
wire [3:0] rd;
wire [3:0] rs;
wire [3:0] rm;
wire [1:0] shift_op;
wire [4:0] imm5;
wire [11:0] imm12;
wire [23:0] imm24;
wire P;
wire U;
wire W;
wire branch_value;

// DUT instance:
pipeline_unit DUT(
    .clk(clk),
    .instr_in(instr_in),
    .branch_ref(branch_ref),
    .branch_in(branch_in),
    .sel_stall(sel_stall),
    .cond(cond),
    .opcode(opcode),
    .en_status(en_status),
    .rn(rn),
    .rd(rd),
    .rs(rs),
    .rm(rm),
    .shift_op(shift_op),
    .imm5(imm5),
    .imm12(imm12),
    .imm24(imm24),
    .P(P),
    .U(U),
    .W(W),
    .branch_value(branch_value)
);

// test regs
integer error_count = 0;

// Tasks
task check(input [31:0] expected, input [31:0] actual, integer test_num);
    begin
        if (expected !== actual) begin
            $error("Test %d failed. Expected: %b(%d), Actual: %b(%d)", test_num, expected, expected, actual, actual);
            error_count = error_count + 1;
        end
    end
endtask: check

task clkR;
    begin
        clk = 1'b0;
        #5;
        clk = 1'b1;
        #5;
    end
endtask: clkR

initial begin
    // Make sure memory is stored and decoded correctly
    instr_in = 32'b0101_00010101_0101_01010101_01010101;
    branch_ref = 1'b0;
    branch_in = 1'b0;
    sel_stall = 1'b0;
    clkR;

    check(4'b0101, cond, 1);
    check(7'b0111010, opcode, 2);
    check(1'b1, en_status, 3);
    check(4'b0101, rn, 4);
    check(4'b0101, rd, 5);
    check(4'b0101, rs, 6);
    check(4'b0101, rm, 7);
    check(2'b10, shift_op, 8);
    check(5'b01010, imm5, 9);
    check(12'b010101010101, imm12, 10);
    check(24'b010101010101010101010101, imm24, 11);
    check(P, 1'b1, 12);
    check(U, 1'b0, 13);
    check(W, 1'b0, 14);
    #5;

    // Check stalling doesn't change anything
    instr_in = 32'b1010_11101010_1010_10101010_10101010;
    branch_ref = 1'b0;
    branch_in = 1'b1;
    sel_stall = 1'b1;
    clkR;

    check(32'b0101_00010101_0101_01010101_01010101, DUT.instr_reg, -15);
    check(1'b0, DUT.branch_value_reg, -16);     //branch_value_reg doesnt change when sel_stall is 1
    check(4'b0101, cond, 15);
    check(7'b0111010, opcode, 16);
    check(1'b1, en_status, 17);
    check(4'b0101, rn, 18);
    check(4'b0101, rd, 19);
    check(4'b0101, rs, 20);
    check(4'b0101, rm, 21);
    check(2'b10, shift_op, 22);
    check(5'b01010, imm5, 23);
    check(12'b010101010101, imm12, 24);
    check(24'b010101010101010101010101, imm24, 25);
    check(P, 1'b1, 26);
    check(U, 1'b0, 27);
    check(W, 1'b0, 28);
    #5;

    // Check branch value no equal to branch ref decoder output equal to that of NOP
    branch_ref = 1'b0;
    branch_in = 1'b1;
    sel_stall = 1'b0;
    clkR;

    check(32'b1110_00110010_0000_11110000_00000000, DUT.instr_decoder_in, 29);
    check(32'b1010_11101010_1010_10101010_10101010, DUT.instr_reg, 30);
    check(4'b1110, cond, 31);
    check(7'b0100000, opcode, 32);
    check(1'b0, en_status, 33);
    check(4'b0000, rn, 34);
    check(4'b1111, rd, 35);
    check(4'b0000, rs, 36);
    check(4'b0000, rm, 37);
    check(2'b00, shift_op, 38);
    check(5'b00000, imm5, 39);
    check(12'b000000000000, imm12, 40);
    check(24'b0010_0000_11110000_00000000, imm24, 41);
    check(P, 1'b1, 42);
    check(U, 1'b0, 43);
    check(W, 1'b1, 44);
    #5;

    // print results
    if (error_count == 0) begin
        $display("All tests passed");
    end else begin
        $display("%d tests failed", error_count);
    end
end
endmodule: tb_pipeline_unit