module cpu (
    input clk, 
    input rst_n, 
    input [31:0] instr, 
    input [31:0] ram_data2, 
    input [6:0] start_pc,
    output mem_w_en, 
    output [6:0] ram_addr2, 
    output [31:0] ram_in2,
    output [31:0] status, 
    output [6:0] pc, 
    output load_pc,
    output [6:0] pc_fetch_unit,
    output [6:0] pc_fetch_wait_unit,
    output [6:0] pc_decode_unit,
    output [6:0] pc_execute_unit,
    output [6:0] pc_memory_unit,
    output [6:0] pc_memory_wait_unit,
    output [6:0] pc_writeback_unit,
    output [6:0] opcode_fetch_unit,
    output [6:0] opcode_fetch_wait_unit,
    output [6:0] opcode_decode_unit,
    output [6:0] opcode_execute_unit,
    output [6:0] opcode_memory_unit,
    output [6:0] opcode_memory_wait_unit,
    output [6:0] opcode_writeback_unit,
    output [31:0] reg_output, 
    input [4:0] reg_addr
);

    // datapath outputs
    wire [31:0] status_out;
    wire [31:0] datapath_out;
    wire [31:0] str_data;
    wire [6:0] pc_out;
    wire [31:0] reg_output_out;
    assign status = status_out;
    assign pc = pc_out;
    assign ram_addr2 = datapath_out[6:0];
    assign ram_in2 = str_data;
    assign reg_output = reg_output_out;

    // controller outputs
    // fetch signals
    wire [6:0] pc_fetch_unit_out;
    wire [6:0] opcode_fetch_unit_out;
    assign pc_fetch_unit = pc_fetch_unit_out;
    assign opcode_fetch_unit = opcode_fetch_unit_out;
    // fetch wait signals
    wire [6:0] pc_fetch_wait_unit_out;
    wire [6:0] opcode_fetch_wait_unit_out;
    assign pc_fetch_wait_unit = pc_fetch_wait_unit_out;
    assign opcode_fetch_wait_unit = opcode_fetch_wait_unit_out;
    // decode signals
    wire [6:0] pc_decode_unit_out;
    wire [6:0] opcode_decode_unit_out;
    assign pc_decode_unit = pc_decode_unit_out;
    assign opcode_decode_unit = opcode_decode_unit_out;
    // execute signals
    wire [3:0] rn, rm, rs;
    wire [4:0] imm5;
    wire [1:0] sel_A_in, sel_B_in, sel_shift_in;
    wire sel_shift, en_A, en_B, en_S;
    wire [6:0] pc_execute_unit_out;
    wire [6:0] opcode_execute_unit_out;
    assign pc_execute_unit = pc_execute_unit_out;
    assign opcode_execute_unit = opcode_execute_unit_out;
    // memory signals
    wire [3:0] cond;
    wire [6:0] pc_memory_unit_out;
    wire [6:0] opcode_memory_unit_out;
    wire [3:0] rd;
    wire [3:0] rn_memory_unit;
    wire [1:0] shift_op;
    wire [11:0] imm12;
    wire [31:0] imm_branch;
    wire [1:0] sel_pc;
    wire load_pc_out, sel_branch_imm, sel_A, sel_B;
    wire [2:0] ALU_op;
    wire sel_pre_indexed, en_status;
    wire [1:0] sel_w_addr1;
    wire w_en1, mem_w_en_out;
    assign load_pc = load_pc_out;
    assign pc_memory_unit = pc_memory_unit_out;
    assign opcode_memory_unit = opcode_memory_unit_out;
    // memory wait signals
    wire [6:0] pc_memory_wait_unit_out;
    wire [6:0] opcode_memory_wait_unit_out;
    assign pc_memory_wait_unit = pc_memory_wait_unit_out;
    assign opcode_memory_wait_unit = opcode_memory_wait_unit_out;
    // write back signals
    wire w_en_ldr;
    wire [6:0] pc_writeback_unit_out;
    wire [6:0] opcode_writeback_unit_out;
    assign pc_writeback_unit = pc_writeback_unit_out;
    assign opcode_writeback_unit = opcode_writeback_unit_out;
    assign mem_w_en = mem_w_en_out;

    // internal signals
    wire [3:0] rt;
    wire [3:0] rt_writeback_unit;
    assign rt = rd;

    // datapath module
    datapath datapath(
        .clk(clk),
        .LR_in(ram_data2),
        .sel_w_addr1(sel_w_addr1),
        .rd_memory_unit(rd),
        .rn_memory_unit(rn_memory_unit),
        .w_en1(w_en1),
        .w_addr_ldr(rt_writeback_unit),   //for LDR
        .w_en_ldr(w_en_ldr),
        .w_data_ldr(ram_data2),  //for LDR
        .A_addr(rn),
        .B_addr(rm),
        .shift_addr(rs),
        .str_addr(rt),
        .sel_pc(sel_pc),
        .load_pc(load_pc_out),
        .start_pc(start_pc),
        .pc_execute_unit(pc_execute_unit_out),
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
        .datapath_out(datapath_out),
        .status_out(status_out),
        .str_data(str_data),
        .PC(pc_out),
        .reg_output(reg_output_out), 
        .reg_addr(reg_addr)
    );

    // controller module
    controller controller(
        .clk(clk),
        .rst_n(rst_n),
        .instr_in(instr),
        .status_reg(status_out),
        .pc_in(pc_out),
        .pc_fetch_unit(pc_fetch_unit_out),
        .opcode_fetch_unit(opcode_fetch_unit_out),
        .pc_fetch_wait_unit(pc_fetch_wait_unit_out),
        .opcode_fetch_wait_unit(opcode_fetch_wait_unit_out),
        .pc_decode_unit(pc_decode_unit_out),
        .opcode_decode_unit(opcode_decode_unit_out),
        .pc_execute_unit(pc_execute_unit_out),
        .opcode_execute_unit(opcode_execute_unit_out),
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
        .load_pc(load_pc_out),
        .cond_memory_unit(cond),
        .pc_memory_unit(pc_memory_unit_out),
        .opcode_memory_unit(opcode_memory_unit_out),
        .rn_memory_unit(rn_memory_unit),
        .rd_memory_unit(rd),
        .shift_op_memory_unit(shift_op),
        .imm12_memory_unit(imm12),
        .imm_branch_memory_unit(imm_branch),
        .sel_pc(sel_pc),
        .sel_branch_imm(sel_branch_imm),
        .sel_A(sel_A),
        .sel_B(sel_B),
        .ALU_op(ALU_op),
        .sel_pre_indexed(sel_pre_indexed),
        .en_status(en_status),
        .sel_w_addr1(sel_w_addr1),
        .w_en1(w_en1),
        .mem_w_en(mem_w_en_out),
        .pc_memory_wait_unit(pc_memory_wait_unit_out),
        .opcode_memory_wait_unit(opcode_memory_wait_unit_out),
        .pc_writeback_unit(pc_writeback_unit_out),
        .opcode_writeback_unit(opcode_writeback_unit_out),
        .w_en_ldr(w_en_ldr),
        .rt_writeback_unit(rt_writeback_unit)
    );

endmodule: cpu