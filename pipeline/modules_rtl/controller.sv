module controller(
    // inputs
    input clk, 
    input rst_n,
    input [31:0] instr_in,
    input [31:0] status_reg,
    input [6:0] pc_in,

    // *** Fetch Stage Output ***
    // decoded signals
    output [6:0] pc_fetch_unit,
    output [6:0] opcode_fetch_unit,

    // *** Fetch Wait Stage Output ***\
    // decoded signals
    output [6:0] pc_fetch_wait_unit,
    output [6:0] opcode_fetch_wait_unit,

    // *** Decode Stage Output ***
    // decoded signals
    output [6:0] pc_decode_unit,
    output [6:0] opcode_decode_unit,


    // *** Execute Stage Output ***
    // decoded signals
    output [6:0] pc_execute_unit,
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
    output load_pc,

    // *** Memory Stage Output ***
    // decoded signals
    output [3:0] cond_memory_unit,                      // TODO: might not be used
    output [6:0] pc_memory_unit,
    output [6:0] opcode_memory_unit,
    output [3:0] rn_memory_unit,
    output [3:0] rd_memory_unit,
    output [1:0] shift_op_memory_unit,
    output [11:0] imm12_memory_unit,
    output [31:0] imm_branch_memory_unit,
    // controller signals
    output [1:0] sel_pc,
    output sel_branch_imm,
    output sel_A,
    output sel_B,
    output [2:0] ALU_op,
    output sel_pre_indexed,
    output en_status,
    output [1:0] sel_w_addr1,
    output w_en1,
    output mem_w_en,
    output [6:0] start_pc,

    // *** Memory Wait Stage Output ***
    // decoded signals
    output [6:0] pc_memory_wait_unit,
    output [6:0] opcode_memory_wait_unit,

    // *** Write Back Stage Output ***
    // decoded signals
    output [6:0] pc_writeback_unit,
    output [6:0] opcode_writeback_unit,
    // controller signals
    output w_en_ldr,
    output [3:0] rt_writeback_unit
);

    // *** Non-Stage Specific Signals ***
    reg cpu_stopped;

    // *** Fetch Stage Unit ***
    wire [6:0] pc_fetch_unit_out;
    // decoded signals
    assign pc_fetch_unit = pc_fetch_unit_out;
    assign opcode_fetch_unit = 7'b0100000;
    // branch value signals
    wire branch_value_fetch_unit;

    // *** Fetch Wait Stage Unit ***
    wire [6:0] pc_fetch_wait_unit_out;
    // decoded signals
    assign pc_fetch_wait_unit = pc_fetch_wait_unit_out;
    assign opcode_fetch_wait_unit = 7'b0100000;
    // branch value signals
    wire branch_value_fetch_wait_unit;

    // *** Decode Stage Unit ***
    // decoded signals
    wire [6:0] pc_decode_unit_out;
    wire [31:0] instr_decode_unit;
    wire [6:0] opcode_decode_unit_out;
    assign pc_decode_unit = pc_decode_unit_out;
    assign opcode_decode_unit = opcode_decode_unit_out;     // TODO: optimize the pipeline + have opcode here
    // controller signals

    // *** Execute Stage Unit ***
    // decoded signals
    wire [6:0] opcode_execute_unit_out;
    wire [3:0] rn_execute_unit_out;
    wire [3:0] rs_execute_unit_out;
    wire [3:0] rm_execute_unit_out;
    wire [4:0] imm5_execute_unit_out;
    wire branch_value_execute_unit;
    wire [31:0] instr_execute_unit;
    wire [6:0] pc_execute_unit_out;
    assign opcode_execute_unit = opcode_execute_unit_out;
    assign rn_execute_unit = rn_execute_unit_out;
    assign rs_execute_unit = rs_execute_unit_out;
    assign rm_execute_unit = rm_execute_unit_out;
    assign imm5_execute_unit = imm5_execute_unit_out;
    assign pc_execute_unit = pc_execute_unit_out;
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
    assign load_pc = (cpu_stopped == 1'b1) ? 1'b0 : ~stall_pc;

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
    wire [6:0] pc_memory_unit_out;
    assign cond_memory_unit = cond_memory_unit_out;
    assign opcode_memory_unit = opcode_memory_unit_out;
    assign rn_memory_unit = rn_memory_unit_out;
    assign rd_memory_unit = rd_memory_unit_out;
    assign shift_op_memory_unit = shift_op_memory_unit_out;
    assign imm12_memory_unit = imm12_memory_unit_out;
    assign imm_branch_memory_unit = imm_branch_memory_unit_out;
    assign pc_memory_unit = pc_memory_unit_out;
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
    wire is_halt;
    reg [6:0] start_pc_out;
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
    assign start_pc_out = (is_halt == 1'b1) ? pc_memory_unit_out : 7'd0;
    assign start_pc = start_pc_out;
    // global branch reference
    reg branch_ref_global;

    // *** Memory Wait Stage Unit ***
    // decoded signals
    wire [3:0] rt_memory_wait_unit;
    wire [6:0] opcode_memory_wait_unit_out;
    wire [31:0] instr_memory_wait_unit;
    wire [6:0] pc_memory_wait_unit_out;
    assign opcode_memory_wait_unit = opcode_memory_wait_unit_out;
    assign pc_memory_wait_unit = pc_memory_wait_unit_out;
    // controller signals
    // NOTHING


    // *** LDR Write Back Stage Unit ***
    // decoded signals
    wire [3:0] rt_writeback_unit_out;
    wire [6:0] opcode_writeback_unit_out;
    wire [6:0] pc_writeback_unit_out;
    assign rt_writeback_unit = rt_writeback_unit_out;
    assign opcode_writeback_unit = opcode_writeback_unit_out;
    assign pc_writeback_unit = pc_writeback_unit_out;
    // controller signals
    wire w_en_ldr_out;
    assign w_en_ldr = w_en_ldr_out;

    fetch_unit fetch_unit(
        // pipeline_unit signals
        .clk(clk),
        .rst_n(rst_n),
        .pc_in(pc_in),
        .branch_in(branch_ref_global),
        .branch_value(branch_value_fetch_unit),
        .pc_out(pc_fetch_unit_out)
        // controller signals
    );

    fetch_wait_unit fetch_wait_unit(
        // pipeline_unit signals
        .clk(clk),
        .rst_n(rst_n),
        .branch_in(branch_value_fetch_unit),
        .pc_in(pc_fetch_unit_out),
        .branch_value(branch_value_fetch_wait_unit),
        .pc_out(pc_fetch_wait_unit_out)
    );

    decoder_unit decoder_unit(
        // pipeline_unit signals
        .clk(clk),
        .rst_n(rst_n),
        .instr_in(instr_in),
        .pc_in(pc_fetch_wait_unit_out),
        .instr_out(instr_decode_unit),
        .pc_out(pc_decode_unit_out),
        .opcode_decode_unit(opcode_decode_unit_out)
        // controller signals
    );

    execute_unit execute_unit(
        // pipeline_unit signals
        .clk(clk),
        .rst_n(rst_n),
        .instr_in(instr_decode_unit),
        .pc_in(pc_decode_unit_out),              
        .branch_in(branch_value_fetch_wait_unit),
        .opcode(opcode_execute_unit_out),
        .rn(rn_execute_unit_out),
        .rs(rs_execute_unit_out),
        .rm(rm_execute_unit_out),
        .imm5(imm5_execute_unit_out),
        .branch_value(branch_value_execute_unit),
        .instr_output(instr_execute_unit),
        .pc_out(pc_execute_unit_out),
        // controller signals
        .rn_memory(rn_memory_unit_out),
        .rd_memory(rd_memory_unit_out),
        .opcode_memory(opcode_memory_unit_out),
        .sel_w_addr1_memory(sel_w_addr1_out),
        .rt_memory_wait(rt_memory_wait_unit),
        .opcode_memory_wait(opcode_memory_wait_unit_out),
        .rt_writeback(rt_writeback_unit_out),
        .opcode_writeback(opcode_writeback_unit_out),
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
        .pc_in(pc_execute_unit_out),
        .cond(cond_memory_unit_out),
        .opcode(opcode_memory_unit_out),
        .rn(rn_memory_unit_out),
        .rd(rd_memory_unit_out),
        .shift_op(shift_op_memory_unit_out),
        .imm12(imm12_memory_unit_out),
        .imm_branch(imm_branch_memory_unit_out),
        .instr_output(instr_memory_unit),
        .pc_out(pc_memory_unit_out),
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
        .is_halt(is_halt),
        // global branch reference
        .branch_ref_global(branch_ref_global)
    );

    // memory_wait stage
    memory_wait_unit memory_wait_unit(
        // pipeline_unit signals
        .clk(clk),
        .rst_n(rst_n),
        .instr_in(instr_memory_unit),
        .pc_in(pc_memory_unit_out),
        .rt(rt_memory_wait_unit),
        .opcode(opcode_memory_wait_unit_out),
        .instr_output(instr_memory_wait_unit),
        .pc_out(pc_memory_wait_unit_out)
        // controller signals
    );

    // ldr_write stage
    ldr_writeback_unit ldr_writeback_unit(
        // pipeline_unit signals
        .clk(clk),
        .rst_n(rst_n),
        .instr_in(instr_memory_wait_unit),
        .pc_in(pc_memory_wait_unit_out),
        .rt(rt_writeback_unit_out),
        .opcode(opcode_writeback_unit_out),
        // controller signals
        .w_en_ldr(w_en_ldr_out),
        .pc_out(pc_writeback_unit_out)
    );


    // internal signals
    reg [1:0] state;
    reg [1:0] next_state;
    localparam load_pc_start = 2'b00;
    localparam run_cpu = 2'b01;
    localparam stop_cpu = 2'b10;

    // state machine
    always_ff @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            state <= load_pc_start;
        end else begin
            state <= next_state;
        end
    end

    // next state logic
    always_comb begin
        if (is_halt == 1'b1) begin
            next_state <= stop_cpu;
        end else begin
            case (state)
                load_pc_start: begin
                    next_state <= run_cpu;
                end
                run_cpu: begin
                    next_state <= run_cpu;
                end
                stop_cpu: begin
                    next_state <= stop_cpu;
                end
                default: begin
                    next_state <= stop_cpu;
                end
            endcase
        end
    end

    // controller logic
    always_comb begin
        case (state)
            load_pc_start: begin
                sel_pc_out <= 2'b01;
                cpu_stopped <= 1'b0;
            end
            stop_cpu: begin
                sel_pc_out <= sel_pc_memory_unit_out;
                cpu_stopped <= 1'b1;
            end
            default: begin
                sel_pc_out <= sel_pc_memory_unit_out;
                cpu_stopped <= 1'b0;
            end
        endcase
    end

endmodule: controller