module controller(
    // inputs
    input clk, 
    input rst_n,
    input [31:0] instr_in,
    input [31:0] status_reg,

    // *** Execute Stage Output ***
    // decoded signals
    output [6:0] opcode_execute_unit,
    output [3:0] rn_execute_unit,
    output [3:0] rm_execute_unit,
    output [3:0] rs_execute_unit,
    output [4:0] imm5_execute_unit,
    // controller signals
    output [1:0] sel_A_in,
    output [1:0] sel_B_in,
    output [1:0] sel_shift_in,
    output sel_shift,
    output en_A,
    output en_B,
    output en_S,

    // *** Memory Stage Output ***
    // decoded signals
    output [3:0] cond_memory_unit,                      // TODO: might not be used
    output [6:0] opcode_memory_unit,
    output [3:0] rn_memory_unit,
    output [3:0] rd_memory_unit,
    output [1:0] shift_op_memory_unit,
    output [11:0] imm12_memory_unit,
    output [31:0] imm_branch_memory_unit,
    // controller signals
    output [1:0] sel_pc,
    output load_pc,
    output sel_branch_imm,
    output sel_A,
    output sel_B,
    output [2:0] ALU_op,
    output sel_pre_indexed,
    output en_status,
    output [1:0] sel_w_addr1,
    output w_en1,
    output mem_w_en,

    // *** Write Back Stage Output ***
    // controller signals
    output w_en_ldr,
    output [3:0] rt_writeback_unit
);
    // *** Fetch Stage Unit ***
    // branch value signals
    wire branch_value_fetch_unit;

    // *** Fetch Wait Stage Unit ***
    // branch value signals
    wire branch_value_fetch_wait_unit;

    // *** Execute Stage Unit ***
    // decoded signals
    wire [6:0] opcode_execute_unit_out;
    wire [3:0] rn_execute_unit_out;
    wire [3:0] rs_execute_unit_out;
    wire [3:0] rm_execute_unit_out;
    wire [4:0] imm5_execute_unit_out;
    wire branch_value_execute_unit;
    wire [31:0] instr_execute_unit;
    assign opcode_execute_unit = opcode_execute_unit_out;
    assign rn_execute_unit = rn_execute_unit_out;
    assign rs_execute_unit = rs_execute_unit_out;
    assign rm_execute_unit = rm_execute_unit_out;
    assign imm5_execute_unit = imm5_execute_unit_out;
    // controller signals
    wire [1:0] sel_A_in_out;
    wire [1:0] sel_B_in_out;
    wire [1:0] sel_shift_in_out;
    wire sel_shift_out;
    wire en_A_out;
    wire en_B_out;
    wire en_S_out;
    wire stall_pc;
    assign sel_A_in = sel_A_in_out;
    assign sel_B_in = sel_B_in_out;
    assign sel_shift_in = sel_shift_in_out;
    assign sel_shift = sel_shift_out;
    assign en_A = en_A_out;
    assign en_B = en_B_out;
    assign en_S = en_S_out;
    assign load_pc = ~stall_pc;

    // *** Memory Stage Unit ***
    // decoded signals
    wire [3:0] cond_memory_unit_out;
    wire [6:0] opcode_memory_unit_out;
    wire [3:0] rn_memory_unit_out;
    wire [3:0] rd_memory_unit_out;
    wire [1:0] shift_op_memory_unit_out;
    wire [11:0] imm12_memory_unit_out;
    wire [31:0] imm_branch_memory_unit_out;
    wire branch_value_memory_unit;
    wire [31:0] instr_memory_unit;
    assign cond_memory_unit = cond_memory_unit_out;
    assign opcode_memory_unit = opcode_memory_unit_out;
    assign rn_memory_unit = rn_memory_unit_out;
    assign rd_memory_unit = rd_memory_unit_out;
    assign shift_op_memory_unit = shift_op_memory_unit_out;
    assign imm12_memory_unit = imm12_memory_unit_out;
    assign imm_branch_memory_unit = imm_branch_memory_unit_out;
    // controller signals
    reg [1:0] sel_pc_out;
    wire [1:0] sel_pc_memory_unit_out;  // special case for memory stage
    wire sel_branch_imm_out;
    wire sel_A_out;
    wire sel_B_out;
    wire [2:0] ALU_op_out;
    wire sel_pre_indexed_out;
    wire en_status_out;
    wire [1:0] sel_w_addr1_out;
    wire w_en1_out;
    wire mem_w_en_out;
    assign sel_pc = sel_pc_out;
    assign sel_branch_imm = sel_branch_imm_out;
    assign sel_A = sel_A_out;
    assign sel_B = sel_B_out;
    assign ALU_op = ALU_op_out;
    assign sel_pre_indexed = sel_pre_indexed_out;
    assign en_status = en_status_out;
    assign sel_w_addr1 = sel_w_addr1_out;
    assign w_en1 = w_en1_out;
    assign mem_w_en = mem_w_en_out;
    // global branch reference
    reg branch_ref_global;

    // *** Memory Wait Stage Unit ***
    // decoded signals
    wire [3:0] rt_memory_wait_unit;
    wire [6:0] opcode_memory_wait_unit;
    wire [31:0] instr_memory_wait_unit;
    // controller signals
    // NOTHING


    // *** LDR Write Back Stage Unit ***
    // decoded signals
    wire [3:0] rt_writeback_unit_out;
    wire [6:0] opcode_writeback_unit;
    assign rt_writeback_unit = rt_writeback_unit_out;
    // controller signals
    wire w_en_ldr_out;
    assign w_en_ldr = w_en_ldr_out;

    fetch_unit fetch_unit(
        // pipeline_unit signals
        .clk(clk),
        .rst_n(rst_n),
        .branch_in(branch_ref_global),
        .branch_value(branch_value_fetch_unit)
        // controller signals
    );

    fetch_wait_unit fetch_wait_unit(
        // pipeline_unit signals
        .clk(clk),
        .rst_n(rst_n),
        .branch_in(branch_value_fetch_unit),
        .branch_value(branch_value_fetch_wait_unit)
    );
    execute_unit execute_unit(
        // pipeline_unit signals
        .clk(clk),
        .rst_n(rst_n),
        .instr_in(instr_in),
        .branch_in(branch_value_fetch_wait_unit),
        .opcode(opcode_execute_unit_out),
        .rn(rn_execute_unit_out),
        .rs(rs_execute_unit_out),
        .rm(rm_execute_unit_out),
        .imm5(imm5_execute_unit_out),
        .branch_value(branch_value_execute_unit),
        .instr_output(instr_execute_unit),
        // controller signals
        .rn_memory(rn_memory_unit_out),
        .rd_memory(rd_memory_unit_out),
        .opcode_memory(opcode_memory_unit_out),
        .sel_w_addr1_memory(sel_w_addr1_out),
        .rt_memory_wait(rt_memory_wait_unit),
        .opcode_memory_wait(opcode_memory_wait_unit),
        .rt_writeback(rt_writeback_unit_out),
        .opcode_writeback(opcode_writeback_unit),
        .sel_A_in(sel_A_in_out),
        .sel_B_in(sel_B_in_out),
        .sel_shift_in(sel_shift_in_out),
        .sel_shift(sel_shift_out),
        .en_A(en_A_out),
        .en_B(en_B_out),
        .en_S(en_S_out),
        .stall_pc(stall_pc)
    );

    // memory stage
    memory_unit memory_unit(
        // pipeline_unit signals
        .clk(clk),
        .rst_n(rst_n),
        .instr_in(instr_execute_unit),
        .branch_in(branch_value_execute_unit),
        .cond(cond_memory_unit_out),
        .opcode(opcode_memory_unit_out),
        .rn(rn_memory_unit_out),
        .rd(rd_memory_unit_out),
        .shift_op(shift_op_memory_unit_out),
        .imm12(imm12_memory_unit_out),
        .imm_branch(imm_branch_memory_unit_out),
        .instr_output(instr_memory_unit),
        // controller signals
        .status_reg(status_reg),
        .sel_pc(sel_pc_memory_unit_out),
        .sel_branch_imm(sel_branch_imm_out),
        .sel_A(sel_A_out),
        .sel_B(sel_B_out),
        .ALU_op(ALU_op_out),
        .sel_pre_indexed(sel_pre_indexed_out),
        .en_status(en_status_out),
        .sel_w_addr1(sel_w_addr1_out),
        .w_en1(w_en1_out),
        .mem_w_en(mem_w_en_out),
        // global branch reference
        .branch_ref_global(branch_ref_global)
    );

    // memory_wait stage
    memory_wait_unit memory_wait_unit(
        // pipeline_unit signals
        .clk(clk),
        .rst_n(rst_n),
        .instr_in(instr_memory_unit),
        .rt(rt_memory_wait_unit),
        .opcode(opcode_memory_wait_unit),
        .instr_output(instr_memory_wait_unit)
        // controller signals
    );

    // ldr_write stage
    ldr_writeback_unit ldr_writeback_unit(
        // pipeline_unit signals
        .clk(clk),
        .rst_n(rst_n),
        .instr_in(instr_memory_wait_unit),
        .rt(rt_writeback_unit_out),
        .opcode(opcode_writeback_unit),
        // controller signals
        .w_en_ldr(w_en_ldr_out)
    );


    // internal signals
    reg [2:0] state;
    localparam load_pc_start = 3'b000;
    localparam start_cpu = 3'b001;
    localparam fetch = 3'b010;
    localparam fetch_wait = 3'b011;
    localparam execute = 3'b100;
    localparam memory = 3'b101;
    localparam memory_wait = 3'b110;
    localparam write_back = 3'b111;

    // state machine
    always_ff @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            state <= load_pc_start;
        end else begin
            case (state)
                load_pc_start: begin
                    state <= fetch;
                end
                fetch: begin
                    state <= fetch_wait;
                end
                fetch_wait: begin
                    state <= execute;
                end
                execute: begin
                    state <= memory;
                end
                memory: begin
                    state <= memory_wait;
                end
                memory_wait: begin
                    state <= write_back;
                end
                write_back: begin
                    state <= start_cpu;
                end
                default: begin
                    state <= start_cpu;
                end
            endcase
        end
    end

    // controller logic
    always_comb begin
        case (state)
            load_pc_start: begin
                sel_pc_out <= 2'b01;
            end
            default: begin
                sel_pc_out <= sel_pc_memory_unit_out;
            end
        endcase
    end

endmodule: controller