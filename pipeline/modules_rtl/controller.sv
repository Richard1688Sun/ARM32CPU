module controller(
    // inputs
    input clk, 
    input rst_n,
    input [31:0] status_reg,
    // execute stage output
    output [1:0] sel_A_in,
    output [1:0] sel_B_in,
    output [1:0] sel_shift_in,
    output sel_shift,
    output en_A,
    output en_B,
    output en_S
    // memory_pc_increment stage output
    output [1:0] sel_pc,
    output load_pc,
    output sel_branch_imm,
    output sel_A,
    output sel_B,
    output [2:0] ALU_op,
    output sel_post_indexing,
    output sel_load_LR,
    output w_en1,
    output mem_w_en
    // write_back stage output
    output w_en_ldr;
);

    /*

    Load/Store Instructions - TBA
    - P = 1 -> Pre-Indexing
    - P = 0 -> Post-Indexing
    - U = 1 -> Offset is positive
    - U = 0 -> Offset is negative
    - W = 1 -> Write back to base register
    - W = 0 -> Do not write back to base register
    */

    // controller outputs
    // execute stage output
    wire [1:0] sel_A_in_out;
    wire [1:0] sel_B_in_out;
    wire [1:0] sel_shift_in_out;
    wire sel_shift_out;
    wire en_A_out;
    wire en_B_out;
    wire en_S_out;
    // memory_pc_increment stage output
    wire [1:0] sel_pc_out;
    wire load_pc_out;
    wire sel_branch_imm_out;
    wire sel_A_out;
    wire sel_B_out;
    wire [2:0] ALU_op_out;
    wire sel_post_indexing_out;
    wire sel_load_LR_out;
    wire w_en1_out;
    wire mem_w_en_out;
    // write_back stage output
    wire w_en_ldr_out;

    // assign outputs
    // execute stage output
    assign sel_A_in = sel_A_in_out;
    assign sel_B_in = sel_B_in_out;
    assign sel_shift_in = sel_shift_in_out;
    assign sel_shift = sel_shift_out;
    assign en_A = en_A_out;
    assign en_B = en_B_out;
    assign en_S = en_S_out;
    // memory_pc_increment stage output
    assign sel_pc = sel_pc_out;
    assign load_pc = load_pc_out;
    assign sel_branch_imm = sel_branch_imm_out;
    assign sel_A = sel_A_out;
    assign sel_B = sel_B_out;
    assign ALU_op = ALU_op_out;
    assign sel_post_indexing = sel_post_indexing_out;
    assign sel_load_LR = sel_load_LR_out;
    assign w_en1 = w_en1_out;
    assign mem_w_en = mem_w_en_out;
    // write_back stage output
    assign w_en_ldr = w_en_ldr_out;

    
    always_ff @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            state <= reset;
        end else begin
            case (state)
                reset: begin
                    state <= load_pc_start;
                end
                load_pc_start: begin
                    state <= fetch;
                end
                fetch: begin
                    state <= fetch_wait;
                end
                fetch_wait: begin
                    state <= decode;
                end
                decode: begin
                    state <= execute;
                end
                execute: begin
                    state <= memory_increment_pc;
                end
                memory_increment_pc: begin
                    state <= memory_wait;
                end
                memory_wait: begin
                    state <= write_back;
                end
                write_back: begin
                    state <= fetch;
                    start <= 1'b0; //end of cycle
                end
                default: begin
                    state <= reset;
                    start <= 1'b0;
                end
            endcase
        end
    end

endmodule: controller