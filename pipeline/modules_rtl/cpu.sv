module cpu (input clk, input rst_n, input [31:0] instr, input [31:0] ram_data2, input [10:0] start_pc,
            output mem_w_en, output [10:0] ram_addr2, output [31:0] ram_in2,
            output [31:0] status, output [31:0] dp_out, output [10:0] pc,
            output [31:0] reg_output, input [3:0] reg_addr); //TODO: status_out may be removed

    // datapath outputs
    wire [31:0] status_out;
    wire [31:0] datapath_out;
    wire [31:0] str_data;
    wire [10:0] pc_out;
    wire [31:0] reg_output_out;
    assign status = status_out;
    assign dp_out = datapath_out;
    assign pc = pc_out;
    assign ram_addr2 = datapath_out[10:0];
    assign ram_in2 = str_data;
    assign reg_output = reg_output_out;

    // controller outputs
    wire [6:0] opcode;
    // execute signals
    wire [3:0] rn, rm, rs;
    wire [4:0] imm5;
    wire [1:0] sel_A_in, sel_B_in, sel_shift_in;
    wire sel_shift, en_A, en_B, en_S;
    // memory signals
    wire [3:0] cond;
    wire [6:0] opcode_memory_unit; //TODO: might not be used
    wire [3:0] rd;
    wire [1:0] shift_op;
    wire [11:0] imm12;
    wire [31:0] imm_branch;
    wire [1:0] sel_pc;
    wire load_pc, sel_branch_imm, sel_A, sel_B;
    wire [2:0] ALU_op;
    wire sel_pre_indexed, en_status;
    wire [1:0] sel_w_addr1;
    wire w_en1, mem_w_en_out;
    // write back signals
    wire w_en_ldr;
    assign mem_w_en = mem_w_en_out;

    // internal signals
    wire [3:0] rt;
    assign rt = rd;

    // datapath module
    datapath datapath(
        .clk(clk),
        .LR_in(ram_data2),
        .sel_w_addr1(sel_w_addr1),
        .w_addr1(rd),
        .w_en1(w_en1),
        .w_addr_ldr(rt),   //for LDR
        .w_en_ldr(w_en_ldr),
        .w_data_ldr(ram_data2),  //for LDR
        .A_addr(rn),
        .B_addr(rm),
        .shift_addr(rs),
        .str_addr(rt),
        .sel_pc(sel_pc),
        .load_pc(load_pc),
        .start_pc(start_pc),
        .sel_A_in(sel_A_in),
        .sel_B_in(sel_B_in),
        .sel_shift_in(sel_shift_in),
        .en_A(en_A),
        .en_B(en_B),
        .shift_imm({27'd0, imm5}),
        .sel_shift(sel_shift),
        .shift_op(shift_op),
        .en_S(en_S),
        .sel_A(sel_A),
        .sel_B(sel_B),
        .sel_branch_imm(sel_branch_imm),
        .sel_pre_indexed(sel_pre_indexed),
        .imm12({20'd0, imm12}),
        .imm_branch(imm_branch),
        .ALU_op(ALU_op),
        .en_status(en_status),
        .status_rdy(1'b0),              // TODO: remove later if not needed to make tests pass -> artifact from normal
        .datapath_out(datapath_out),
        .status_out(status_out),
        .str_data(str_data),
        .PC(pc_out),
        .reg_output(reg_output_out), .reg_addr(reg_addr) //TODO: remove later, this is only for testing
    );

    // controller module
    controller controller(
        .clk(clk),
        .rst_n(rst_n),
        .instr_in(instr),
        .status_reg(status_out),
        .opcode_execute_unit(opcode),
        .rn_execute_unit(rn),
        .rm_execute_unit(rm),
        .rs_execute_unit(rs),
        .imm5_execute_unit(imm5),
        .sel_A_in(sel_A_in),
        .sel_B_in(sel_B_in),
        .sel_shift_in(sel_shift_in),
        .sel_shift(sel_shift),
        .en_A(en_A),
        .en_B(en_B),
        .en_S(en_S),
        .cond_memory_unit(cond),
        .opcode_memory_unit(opcode_memory_unit),
        .rd_memory_unit(rd),
        .shift_op_memory_unit(shift_op),
        .imm12_memory_unit(imm12),
        .imm_branch_memory_unit(imm_branch),
        .sel_pc(sel_pc),
        .load_pc(load_pc),
        .sel_branch_imm(sel_branch_imm),
        .sel_A(sel_A),
        .sel_B(sel_B),
        .ALU_op(ALU_op),
        .sel_pre_indexed(sel_pre_indexed),
        .en_status(en_status),
        .sel_w_addr1(sel_w_addr1),
        .w_en1(w_en1),
        .mem_w_en(mem_w_en_out),
        .w_en_ldr(w_en_ldr)
    );

endmodule: cpu