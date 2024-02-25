module tb_controller(output err);
  
    // Controller Inputs
    reg clk;
    reg rst_n;
    reg [31:0] instr_in;
    reg [31:0] status_reg;

    // *** Execute Stage Output ***
    // decoded signals
    wire [6:0] opcode_execute_unit;
    wire [3:0] rn_execute_unit;
    wire [3:0] rs_execute_unit;
    wire [3:0] rm_execute_unit;
    wire [4:0] imm5_execute_unit;
    // controller signals
    wire [1:0] sel_A_in;
    wire [1:0] sel_B_in;
    wire [1:0] sel_shift_in;
    wire sel_shift;
    wire en_A;
    wire en_B;
    wire en_S;

    // *** Memory Stage Output ***
    // decoded signals
    wire [3:0] cond_memory_unit;
    wire [6:0] opcode_memory_unit;
    wire [3:0] rd_memory_unit;
    wire [1:0] shift_op_memory_unit;
    wire [11:0] imm12_memory_unit;
    wire [23:0] imm24_memory_unit;
    // controller signals
    wire [1:0] sel_pc;
    wire load_pc;
    wire sel_branch_imm;
    wire sel_A;
    wire sel_B;
    wire [2:0] ALU_op;
    wire sel_post_indexing;
    wire sel_load_LR;
    wire w_en1;
    wire mem_w_en;

    // *** Write Back Stage Output ***
    // controller signals
    wire w_en_ldr;

    // Testbench Signals
    integer error_count = 0;
    integer test_num = 1;
    localparam [31:0] NOP = 32'b1110_00110010_0000_11110000_00000000;

    //DUT
    controller DUT(
        // inputs
        .clk(clk), 
        .rst_n(rst_n),
        .instr_in(instr_in),
        .status_reg(status_reg),
        // *** Execute Stage Output ***
        .opcode_execute_unit(opcode_execute_unit),
        .rn_execute_unit(rn_execute_unit),
        .rs_execute_unit(rs_execute_unit),
        .rm_execute_unit(rm_execute_unit),
        .imm5_execute_unit(imm5_execute_unit),
        .sel_A_in(sel_A_in),
        .sel_B_in(sel_B_in),
        .sel_shift_in(sel_shift_in),
        .sel_shift(sel_shift),
        .en_A(en_A),
        .en_B(en_B),
        .en_S(en_S),
        // *** Memory Stage Output ***
        .cond_memory_unit(cond_memory_unit),
        .opcode_memory_unit(opcode_memory_unit),
        .rd_memory_unit(rd_memory_unit),
        .shift_op_memory_unit(shift_op_memory_unit),
        .imm12_memory_unit(imm12_memory_unit),
        .imm24_memory_unit(imm24_memory_unit),
        .sel_pc(sel_pc),
        .load_pc(load_pc),
        .sel_branch_imm(sel_branch_imm),
        .sel_A(sel_A),
        .sel_B(sel_B),
        .ALU_op(ALU_op),
        .sel_post_indexing(sel_post_indexing),
        .sel_load_LR(sel_load_LR),
        .w_en1(w_en1),
        .mem_w_en(mem_w_en),
        // *** Write Back Stage Output ***
        .w_en_ldr(w_en_ldr)
    );

    //tasks
    task check(input integer expected, input integer actual, integer test_num);
        begin
            if (expected !== actual) begin
                $error("Test %d failed. Expected: %b, Actual: %b", test_num, expected, actual);
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

    task reset;
        begin
            #5;
            clk = 1'b0;
            rst_n = 1'b1;
            #5;
            rst_n = 1'b0;
            #5;
            rst_n = 1'b1;
        end
    endtask: reset

    task  load_pc_start(input integer startTestNum);
        begin
            reset;
            check(1, sel_pc, startTestNum); //first time you load from startpc
            check(1, load_pc, startTestNum + 1);
            test_num = startTestNum + 2;
        end
    endtask: load_pc_start

    task load_pc_normal(input integer startTestNum);
        begin
            check(0, sel_pc, startTestNum);
            check(1, load_pc, startTestNum + 1);
            test_num = startTestNum + 2;
        end
    endtask: load_pc_normal

    task executeCycle_MOV_I(input integer startTestNum);
        begin
            check(0, sel_A_in, startTestNum);
            check(0, sel_B_in, startTestNum + 1);
            check(0, sel_shift_in, startTestNum + 2);
            check(0, en_A, startTestNum + 3);
            check(0, en_B, startTestNum + 4);
            check(0, en_S, startTestNum + 5);
            check(0, sel_shift, startTestNum + 6);
            test_num = startTestNum + 7;
        end
    endtask: executeCycle_MOV_I

    task executeCycle_MOV_R(input integer startTestNum);
        begin
            check(0, sel_A_in, startTestNum);
            check(0, sel_B_in, startTestNum + 1);
            check(0, sel_shift_in, startTestNum + 2);
            check(0, en_A, startTestNum + 3);
            check(1, en_B, startTestNum + 4);
            check(1, en_S, startTestNum + 5);
            check(0, sel_shift, startTestNum + 6);
            test_num = startTestNum + 7;
        end
    endtask: executeCycle_MOV_R

    task executeCycle_MOV_RS(input integer startTestNum);
        begin
            check(0, sel_A_in, startTestNum);
            check(0, sel_B_in, startTestNum + 1);
            check(0, sel_shift_in, startTestNum + 2);
            check(0, en_A, startTestNum + 3);
            check(1, en_B, startTestNum + 4);
            check(1, en_S, startTestNum + 5);
            check(1, sel_shift, startTestNum + 6);
            test_num = startTestNum + 7;
        end
    endtask: executeCycle_MOV_RS

    task executeCycle_I(input integer startTestNum);
        begin
            check(0, sel_A_in, startTestNum);
            check(0, sel_B_in, startTestNum + 1);
            check(0, sel_shift_in, startTestNum + 2);
            check(1, en_A, startTestNum + 3);
            check(0, en_B, startTestNum + 4);
            check(0, en_S, startTestNum + 5);
            check(0, sel_shift, startTestNum + 6);
            test_num = startTestNum + 7;
        end
    endtask: executeCycle_I

    task executeCycle_R(input integer startTestNum);
        begin
            check(0, sel_A_in, startTestNum);
            check(0, sel_B_in, startTestNum + 1);
            check(0, sel_shift_in, startTestNum + 2);
            check(1, en_A, startTestNum + 3);
            check(1, en_B, startTestNum + 4);
            check(1, en_S, startTestNum + 5);
            check(0, sel_shift, startTestNum + 6);
            test_num = startTestNum + 7;
        end
    endtask: executeCycle_R

    task executeCycle_RS(input integer startTestNum);
        begin
            check(0, sel_A_in, startTestNum);
            check(0, sel_B_in, startTestNum + 1);
            check(0, sel_shift_in, startTestNum + 2);
            check(1, en_A, startTestNum + 3);
            check(1, en_B, startTestNum + 4);
            check(1, en_S, startTestNum + 5);
            check(1, sel_shift, startTestNum + 6);
            test_num = startTestNum + 7;
        end
    endtask: executeCycle_RS

    //mode 0 = I, mode 1 = Lit, mode 2 = R
    task executeCycle_LDR_STR(input integer startTestNum, input [2:0] mode);
        begin
            if (mode == 1) begin    //LIT
                check(2'b11, sel_A_in, startTestNum);
            end else begin
                check(0, sel_A_in, startTestNum);
            end

            check(0, sel_B_in, startTestNum + 1);

            check(0, sel_shift_in, startTestNum + 2);

            check(1, en_A, startTestNum + 3);

            if (mode == 2) begin
                check(1, en_B, startTestNum + 4);
            end else begin
                check(0, en_B, startTestNum + 4);
            end

            if (mode == 2) begin
                check(1, en_S, startTestNum + 5);
            end else begin
                check(0, en_S, startTestNum + 5);
            end
            

            if (mode == 2) begin
                check(1, sel_shift, startTestNum + 6);
            end else begin
                check(0, sel_shift, startTestNum + 6);  //dont shift by anything
            end
            test_num = startTestNum + 7;
        end

    endtask: executeCycle_LDR_STR

    task execute_NOP(input integer startTestNum);
        begin
            check(0, sel_A_in, startTestNum);
            check(0, sel_B_in, startTestNum + 1);
            check(0, sel_shift_in, startTestNum + 2);
            check(0, en_A, startTestNum + 3);
            check(0, en_B, startTestNum + 4);
            check(0, en_S, startTestNum + 5);
            check(0, sel_shift, startTestNum + 6);
            test_num = startTestNum + 7;
        end
    endtask: execute_NOP

    task mem_writeback_MOV_I(input integer startTestNum, input [2:0] ALU_op_ans);
        begin
            check(1, sel_A, startTestNum);
            check(1, sel_B, startTestNum + 1);
            check(0, sel_post_shift, startTestNum + 2);
            check(ALU_op_ans, ALU_op, startTestNum + 3);
            check(0, sel_w_data, startTestNum + 4);
            check(1, w_en1, startTestNum + 5);
            test_num = startTestNum + 6;
        end
    endtask: mem_writeback_MOV_I

    task mem_writeback_MOV_R_RS(input integer startTestNum, input [2:0] ALU_op_ans);
        begin
        
            check(1, sel_A, startTestNum);
            check(0, sel_B, startTestNum + 1);
            check(0, sel_post_shift, startTestNum + 2);
            check(ALU_op_ans, ALU_op, startTestNum + 3);
            check(0, sel_w_data, startTestNum + 4);
            check(1, w_en1, startTestNum + 5);
            test_num = startTestNum + 6;
        end
    endtask: mem_writeback_MOV_R_RS

    task mem_writeback_I(input integer startTestNum, input [2:0] ALU_op_ans);
        begin
            
            check(1, sel_A, startTestNum);
            check(0, sel_B, startTestNum + 1);
            check(0, sel_post_shift, startTestNum + 2);
            check(ALU_op_ans, ALU_op, startTestNum + 3);
            check(0, sel_w_data, startTestNum + 4);
            check(1, w_en1, startTestNum + 5);
            test_num = startTestNum + 6;
        end
    endtask: mem_writeback_I

    task mem_writeback_R_RS(input integer startTestNum, input [2:0] ALU_op_ans);
        begin
            check(0, sel_A, startTestNum);
            check(0, sel_B, startTestNum + 1);
            check(0, sel_post_shift, startTestNum + 2);
            check(ALU_op_ans, ALU_op, startTestNum + 3);
            check(0, sel_w_data, startTestNum + 4);
            check(1, w_en1, startTestNum + 5);
            test_nm = startTestNum + 6;
        end
    endtask: mem_writeback_R_RS

    task mem_writeback_STR_LDR(input integer startTestNum, input P, input U, input [1:0] mode, input is_STR);
        begin
            check(0, sel_A, startTestNum);

            if (mode == 2) begin
                check(0, sel_B, startTestNum + 1);
            end else begin
                check(1, sel_B, startTestNum + 1);
            end

            if (P == 1) begin //preindex -> change address first before memory access
                check(0, sel_post_shift, startTestNum + 2);
            end else begin
                check(1, sel_post_shift, startTestNum + 2);
            end

            if (U == 1) begin //UP -> add
                check(3'b000, ALU_op, startTestNum + 3);
            end else begin
                check(3'b001, ALU_op, startTestNum + 3);
            end

            check(0, sel_w_data, startTestNum + 4);
            check(0, w_en1, startTestNum + 5);
            //RAM STUFF
            if (is_STR == 1) begin
                check(1, ram_w_en2, startTestNum + 6);
            end else begin
                check(0, ram_w_en2, startTestNum + 6);
            end
            test_num = startTestNum + 7;
        end
    endtask: mem_writeback_STR_LDR

    task mem_writeback_NOP(input integer startTestNum);
        begin
            check(0, sel_A, startTestNum);
            check(0, sel_B, startTestNum + 1);
            check(0, sel_post_shift, startTestNum + 2);
            check(0, ALU_op, startTestNum + 3);
            check(0, sel_w_data, startTestNum + 4);
            check(0, w_en1, startTestNum + 5);
            test_num = startTestNum + 6;
        end
    endtask: mem_writeback_NOP

    task mem_wait(input integer startTestNum);
    endtask: mem_wait

    task write_back_LDR(input integer startTestNum);
        begin
            check(1, w_en_ldr, startTestNum);
            test_num = startTestNum + 1;
        end
    endtask: write_back_LDR

    task write_back_NOP(input integer startTestNum);
        begin
            check(0, w_en_ldr, startTestNum);
            test_num = startTestNum + 1;
        end
    endtask: write_back_NOP

    initial begin
        // Stage 1 Testing: Normal  + ZERO hazards
        /*
        1. MOV_I R8 #8
        2. NOP
        3. MOV_R R1 R8 >> 3
        4. NOP
        5. MOV_RS R3 R1, R1 << R1
        6. ADD_I R2 R1 #1
        7. ADD_R R9 R8 R1
        8. ADD_RS R10 R8 R1 << R1
        */
        localparam [31:0] MOV_I_R8_8 = 32'b1110_00111010_0000_1000_000000001000;
        localparam [31:0] MOV_R_R1_R8_3 = 32'b1110_00011010_0000_0001_00011_00_0_1000;
        localparam [31:0] MOV_RS_R3_R1_R1_LSL_R1 = 32'b1110_00011010_0000_0011_0001_0_00_1_0001;
        localparam [31:0] ADD_I_R2_R1_1 = 32'b1110_00101000_0001_0010_000000000001;
        localparam [31:0] ADD_R_R9_R8_R1 = 32'b1110_00001000_1000_1001_00000_00_0_0001;
        localparam [31:0] ADD_RS_R10_R8_R1_LSL_R1 = 32'b1110_00001000_1000_1010_0001_0_00_1_0001;
        reset;
        load_pc_start(test_num);
        clk; // load pc
        clk; // fetch
        clk; // fetch_wait

        // EX: 1, MEM: n/a, MEM_WAIT: n/a, WB: n/a
        instr_in = MOV_I_R8_8        // MOV_I r7, #8
        clkR;
        executeCycle_MOV_I(test_num);  //instruction 1


        // EX: NOP, MEM: 1, MEM_WAIT: n/a, WB: n/a  
        instr_in = NOP;
        clkR;
        execute_NOP(test_num);
        mem_writeback_MOV_I(test_num, 3'b000);

        // EX: 3, MEM: NOP, MEM_WAIT: 1, WB: n/a
        instr_in = MOV_R_R1_R8_3        // MOV_R R1 R8 >> 3
        clkR;
        executeCycle_MOV_R(test_num);  //instruction 3
        mem_writeback_NOP(test_num);
        mem_wait(test_num);

        // EX: NOP, MEM: 3, MEM_WAIT: NOP, WB: 1
        instr_in = NOP;
        clkR;
        execute_NOP(test_num);
        mem_writeback_MOV_R_RS(test_num, 3'b000);
        mem_wait(test_num);
        write_back_NOP(test_num);

        // EX: 5, MEM: NOP, MEM_WAIT: 3, WB: NOP
        instr_in = MOV_RS_R3_R1_R1_LSL_R1        // MOV_RS R3 R1, R1 << R1
        clkR;
        executeCycle_MOV_RS(test_num);  //instruction 5
        mem_writeback_NOP(test_num);
        mem_wait(test_num);
        write_back_NOP(test_num);

        // EX: 6, MEM: 5, MEM_WAIT: NOP, WB: 3
        instr_in = ADD_I_R2_R1_1        // ADD_I R2 R1 #1
        clkR;
        executeCycle_I(test_num);  //instruction 6
        mem_writeback_MOV_R_RS(test_num);
        mem_wait(test_num);
        write_back_NOP(test_num);

        // EX: 7, MEM: 6, MEM_WAIT: 5, WB: NOP
        instr_in = ADD_R_R9_R8_R1        // ADD_R R9 R8 R1      
        clkR;
        executeCycle_R(test_num);  //instruction 7\
        mem_writeback_I(test_num);
        mem_wait(test_num);
        write_back_NOP(test_num);

        // EX: 8, MEM: 7, MEM_WAIT: 6, WB: 5
        instr_in = ADD_RS_R10_R8_R1_LSL_R1        // ADD_RS R10 R8 R1 << R1
        clkR;
        executeCycle_RS(test_num);  //instruction 8
        mem_writeback_R_RS(test_num);
        mem_wait(test_num);
        write_back_NOP(test_num);

        // EX: NOP, MEM: 8, MEM_WAIT: 7, WB: 6
        instr_in = NOP;
        clkR;
        execute_NOP(test_num);
        mem_writeback_R_RS(test_num, 1, 1, 2'b00, 1);
        mem_wait(test_num);
        write_back_NOP(test_num);     

        // EX: NOP, MEM: NOP, MEM_WAIT: 8, WB: 7
        instr_in = NOP;
        clkR;
        execute_NOP(test_num);
        mem_writeback_NOP(test_num, 1, 1, 2'b00, 1);   
        mem_wait(test_num);
        write_back_LDR(test_num); // LDR_LIT R8 R1 #1


        // EX: NOP, MEM: 3, MEM_WAIT: NOP, WB: 1



        // Stage 2 Testing: Memory + ZERO hazards
        /*
        1. MOV_I R8 #8
        2. NOP
        3. MOV_R R1 R8 >> 3
        4. NOP
        9. STR_I R8 R1 #1
        10. LDR_LIT R8 R1 #1
        11. NOP
        12. NOP
        13. LDR_I R8 R1 #1
        14. STR_R R8 R1 << R1
        15. LDR_R R8 R1 << R1
        */

        // Stage 3 Testing: Branching + ZERO hazards TODO: TBD
        // Test 1: MOV_I R8 #8

        //print test summary
        if (error_count == 0) begin
            $display("All tests passed!");
        end else begin
            $display("Failed %d tests", error_count);
        end
    end
endmodule: tb_controller