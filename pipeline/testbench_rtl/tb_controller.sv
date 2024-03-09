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
    wire [31:0] imm_branch_memory_unit;
    // controller signals
    wire [1:0] sel_pc;
    wire load_pc;
    wire sel_branch_imm;
    wire sel_A;
    wire sel_B;
    wire [2:0] ALU_op;
    wire sel_pre_indexed;
    wire en_status;
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
        .imm_branch_memory_unit(imm_branch_memory_unit),
        .sel_pc(sel_pc),
        .load_pc(load_pc),
        .sel_branch_imm(sel_branch_imm),
        .sel_A(sel_A),
        .sel_B(sel_B),
        .ALU_op(ALU_op),
        .sel_pre_indexed(sel_pre_indexed),
        .en_status(en_status),
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
            #5;
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

    task executeCycle_Branch(input integer startTestNum, input is_R);
        begin
            if (is_R == 1'b1) begin
                check(2'b00, sel_A_in, startTestNum);
            end else begin
                check(2'b11, sel_A_in, startTestNum);
            end
            check(2'b00, sel_B_in, startTestNum + 1);
            check(2'b11, sel_shift_in, startTestNum + 2);
            check(1'b0, en_A, startTestNum + 3);

            if (is_R == 1'b1) begin
                check(1'b1, en_B, startTestNum + 4);
            end else begin
                check(1'b0, en_B, startTestNum + 4);
            end

            check(1'b1, en_S, startTestNum + 5);
            check(1'b1, sel_shift, startTestNum + 6);
            test_num = startTestNum + 7;
        end
    endtask: executeCycle_Branch

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

    // TODO: check en_status when doing branch tests

    task mem_writeback_MOV_I(input integer startTestNum, input [2:0] ALU_op_ans);
        begin
            check(1, sel_A, startTestNum);
            check(1, sel_B, startTestNum + 1);
            check(0, sel_pre_indexed, startTestNum + 2);
            check(ALU_op_ans, ALU_op, startTestNum + 3);
            check(0, sel_load_LR, startTestNum + 4);
            check(1, w_en1, startTestNum + 5);
            check(0, mem_w_en, startTestNum + 6);
            check(2'b00, sel_pc, startTestNum + 7);
            check(1, load_pc, startTestNum + 8);
            test_num = startTestNum + 9;
        end
    endtask: mem_writeback_MOV_I

    task mem_writeback_MOV_R_RS(input integer startTestNum, input [2:0] ALU_op_ans);
        begin
        
            check(1, sel_A, startTestNum);
            check(0, sel_B, startTestNum + 1);
            check(0, sel_pre_indexed, startTestNum + 2);
            check(ALU_op_ans, ALU_op, startTestNum + 3);
            check(0, sel_load_LR, startTestNum + 4);
            check(1, w_en1, startTestNum + 5);
            check(0, mem_w_en, startTestNum + 6);
            check(2'b00, sel_pc, startTestNum + 7);
            check(1, load_pc, startTestNum + 8);
            test_num = startTestNum + 9;
        end
    endtask: mem_writeback_MOV_R_RS

    task mem_writeback_I(input integer startTestNum, input [2:0] ALU_op_ans);
        begin
            check(0, sel_A, startTestNum);
            check(1, sel_B, startTestNum + 1);
            check(0, sel_pre_indexed, startTestNum + 2);
            check(ALU_op_ans, ALU_op, startTestNum + 3);
            check(0, sel_load_LR, startTestNum + 4);
            check(1, w_en1, startTestNum + 5);
            check(0, mem_w_en, startTestNum + 6);
            check(2'b00, sel_pc, startTestNum + 7);
            check(1, load_pc, startTestNum + 8);
            test_num = startTestNum + 9;
        end
    endtask: mem_writeback_I

    task mem_writeback_R_RS(input integer startTestNum, input [2:0] ALU_op_ans);
        begin
            check(0, sel_A, startTestNum);
            check(0, sel_B, startTestNum + 1);
            check(0, sel_pre_indexed, startTestNum + 2);
            check(ALU_op_ans, ALU_op, startTestNum + 3);
            check(0, sel_load_LR, startTestNum + 4);
            check(1, w_en1, startTestNum + 5);
            check(0, mem_w_en, startTestNum + 6);
            check(2'b00, sel_pc, startTestNum + 7);
            check(1, load_pc, startTestNum + 8);
            test_num = startTestNum + 9;
        end
    endtask: mem_writeback_R_RS

    task mem_writeback_STR_LDR(input integer startTestNum, input P, input U, input W, input [1:0] mode, input is_STR);
        begin
            check(0, sel_A, startTestNum);

            if (mode == 2) begin
                check(0, sel_B, startTestNum + 1);
            end else begin
                check(1, sel_B, startTestNum + 1);
            end

            if (P == 1) begin //preindex -> change address first before memory access
                check(0, sel_pre_indexed, startTestNum + 2);
            end else begin
                check(1, sel_pre_indexed, startTestNum + 2);
            end

            if (U == 1) begin //UP -> add
                check(3'b000, ALU_op, startTestNum + 3);
            end else begin
                check(3'b001, ALU_op, startTestNum + 3);
            end

            check(0, sel_load_LR, startTestNum + 4);

            if (W == 1 && P == 1) begin
                check(1, w_en1, startTestNum + 5);
            end else begin
                check(0, w_en1, startTestNum + 5);
            end

            //RAM STUFF
            if (is_STR == 1) begin
                check(1, mem_w_en, startTestNum + 6);
            end else begin
                check(0, mem_w_en, startTestNum + 6);
            end

            check(2'b00, sel_pc, startTestNum + 7);
            check(1, load_pc, startTestNum + 8);
            test_num = startTestNum + 9;
        end
    endtask: mem_writeback_STR_LDR

    task mem_writeback_Branch (input integer startTestNum, input load_LR, input is_R, input [3:0] cond, input [3:0] NZCV); 
        begin
            check(0, sel_A, startTestNum);
            if (is_R == 1) begin
                check(1'b0, sel_B, startTestNum + 1);
            end else begin
                check(1'b1, sel_B, startTestNum + 1);
            end
            check(0, sel_pre_indexed, startTestNum + 2);
            check(0, ALU_op, startTestNum + 3);
            check(0, sel_load_LR, startTestNum + 4);
            check(0, w_en1, startTestNum + 5);
            check(0, mem_w_en, startTestNum + 6);
            if ((cond == 4'b0000 && NZCV[1]) || 
                (cond == 4'b0001 && ~NZCV[1]) || 
                (cond == 4'b0010 && NZCV[2]) || 
                (cond == 4'b0011 && ~NZCV[2]) || 
                (cond == 4'b0100 && NZCV[0]) || 
                (cond == 4'b0101 && ~NZCV[0]) || 
                (cond == 4'b0110 && NZCV[3]) || 
                (cond == 4'b0111 && ~NZCV[3]) || 
                (cond == 4'b1000 && NZCV[2] && ~NZCV[1]) || 
                (cond == 4'b1001 && ~NZCV[2] || NZCV[1]) || 
                (cond == 4'b1010 && NZCV[0] == NZCV[3]) || 
                (cond == 4'b1011 && NZCV[0] != NZCV[3]) || 
                (cond == 4'b1100 && (~NZCV[1] && (NZCV[0] == NZCV[3]))) || 
                (cond == 4'b1101 && (NZCV[1] || (NZCV[0] != NZCV[3]))) || 
                (cond == 4'b1110)) begin
            
                // take the new address
                check(2'b11, sel_pc, startTestNum + 7);
                check(1, load_pc, startTestNum + 8);
            end else begin
                check(2'b00, sel_pc, startTestNum + 7);
                check(1, load_pc, startTestNum + 8);
            end
            check(0, en_status, startTestNum + 9);
            test_num = startTestNum + 10;
        end
    endtask: mem_writeback_Branch

    task mem_writeback_NOP(input integer startTestNum);
        begin
            check(0, sel_A, startTestNum);
            check(0, sel_B, startTestNum + 1);
            check(0, sel_pre_indexed, startTestNum + 2);
            check(0, ALU_op, startTestNum + 3);
            check(0, sel_load_LR, startTestNum + 4);
            check(0, w_en1, startTestNum + 5);
            check(0, sel_pc, startTestNum + 6);
            check(0, mem_w_en, startTestNum + 6);
            test_num = startTestNum + 7;
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

    localparam [31:0] MOV_I_R8_8 = 32'b1110_00111010_0000_1000_000000001000;
    localparam [31:0] MOV_R_R1_R8_3 = 32'b1110_00011010_0000_0001_00011_00_0_1000;
    localparam [31:0] MOV_RS_R3_R1_R1_LSL_R1 = 32'b1110_00011010_0000_0011_0001_0_00_1_0001;
    localparam [31:0] ADD_I_R2_R1_1 = 32'b1110_00101000_0001_0010_000000000001;
    localparam [31:0] ADD_R_R9_R8_R1 = 32'b1110_00001000_1000_1001_00000_00_0_0001;
    localparam [31:0] ADD_RS_R10_R8_R1_LSL_R1 = 32'b1110_00001000_1000_1010_0001_0_00_1_0001;

    localparam [31:0] STR_I_R8_R1_1 = 32'b1110_01010000_0001_1000_000000000001;
    localparam [31:0] LDR_LIT_R8_R1_1 = 32'b1110_01011001_1111_1000_000000000001;
    localparam [31:0] LDR_I_R8_R1_1 = 32'b1110_01010011_0001_1000_000000000001;
    localparam [31:0] STR_R_R8_R1_LSL_R1 = 32'b1110_01100000_0001_1000_00001_00_0_0001;
    localparam [31:0] LDR_R_R8_R1_LSL_R1 = 32'b1110_01101001_0001_1000_00001_00_0_0001;

    localparam [31:0] B_1 = 32'b0000_1010_000000000000000000000001;
    localparam [31:0] BL_2 = 32'b0001_1011_000000000000000000000010;  
    localparam [31:0] BX_R1 = 32'b1100_00010010_111111111111_0001_0001;
    localparam [31:0] BLX_R2 = 32'b1011_00010010_111111111111_0011_0010;

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
        reset;
        $display("Starting Normal Tests");
        load_pc_start(test_num);
        clkR; // load pc
        clkR; // fetch
        clkR; // fetch_wait

        // EX: 1, MEM: n/a, MEM_WAIT: n/a, WB: n/a
        $display("1: Test Number %d", test_num);
        instr_in = MOV_I_R8_8;        // MOV_I r7, #8
        clkR;
        executeCycle_MOV_I(test_num);  //instruction 1


        // EX: NOP, MEM: 1, MEM_WAIT: n/a, WB: n/a  
        $display("2: Test Number %d", test_num);
        instr_in = NOP;
        clkR;
        execute_NOP(test_num);
        mem_writeback_MOV_I(test_num, 3'b000);

        // EX: 3, MEM: NOP, MEM_WAIT: 1, WB: n/a
        $display("3: Test Number %d", test_num);
        instr_in = MOV_R_R1_R8_3;        // MOV_R R1 R8 >> 3
        clkR;
        executeCycle_MOV_R(test_num);  //instruction 3
        mem_writeback_NOP(test_num);
        mem_wait(test_num);

        // EX: NOP, MEM: 3, MEM_WAIT: NOP, WB: 1
        $display("4: Test Number %d", test_num);
        instr_in = NOP;
        clkR;
        execute_NOP(test_num);
        mem_writeback_MOV_R_RS(test_num, 3'b000);
        mem_wait(test_num);
        write_back_NOP(test_num);

        // EX: 5, MEM: NOP, MEM_WAIT: 3, WB: NOP
        $display("5: Test Number %d", test_num);
        instr_in = MOV_RS_R3_R1_R1_LSL_R1;        // MOV_RS R3 R1, R1 << R1
        clkR;
        executeCycle_MOV_RS(test_num);  //instruction 5
        mem_writeback_NOP(test_num);
        mem_wait(test_num);
        write_back_NOP(test_num);

        // EX: 6, MEM: 5, MEM_WAIT: NOP, WB: 3
        $display("6: Test Number %d", test_num);
        instr_in = ADD_I_R2_R1_1;        // ADD_I R2 R1 #1
        clkR;
        executeCycle_I(test_num);  //instruction 6
        mem_writeback_MOV_R_RS(test_num, 3'b000);
        mem_wait(test_num);
        write_back_NOP(test_num);

        // EX: 7, MEM: 6, MEM_WAIT: 5, WB: NOP
        $display("7: Test Number %d", test_num);
        instr_in = ADD_R_R9_R8_R1;        // ADD_R R9 R8 R1      
        clkR;
        executeCycle_R(test_num);  //instruction 7\
        mem_writeback_I(test_num, 3'b000);
        mem_wait(test_num);
        write_back_NOP(test_num);
        // EX: 8, MEM: 7, MEM_WAIT: 6, WB: 5
        $display("8: Test Number %d", test_num);
        instr_in = ADD_RS_R10_R8_R1_LSL_R1;        // ADD_RS R10 R8 R1 << R1
        clkR;
        executeCycle_RS(test_num);  //instruction 8
        mem_writeback_R_RS(test_num, 3'b000);
        mem_wait(test_num);
        write_back_NOP(test_num);

        // EX: NOP, MEM: 8, MEM_WAIT: 7, WB: 6
        $display("9: Test Number %d", test_num);
        instr_in = NOP;
        clkR;
        execute_NOP(test_num);
        mem_writeback_R_RS(test_num, 2'b00);
        mem_wait(test_num);
        write_back_NOP(test_num);     

        // EX: NOP, MEM: NOP, MEM_WAIT: 8, WB: 7
        $display("10: Test Number %d", test_num);
        instr_in = NOP;
        clkR;
        execute_NOP(test_num);
        mem_writeback_NOP(test_num);   
        mem_wait(test_num);
        write_back_NOP(test_num); // LDR_LIT R8 R1 #1

        // EX: NOP, MEM: NOP, MEM_WAIT: NOP, WB: 8
        $display("11: Test Number %d", test_num);
        instr_in = NOP;
        clkR;
        execute_NOP(test_num);
        mem_writeback_NOP(test_num);
        mem_wait(test_num);
        write_back_NOP(test_num); // LDR_LIT R8 R1 #1



        // Stage 2 Testing: Memory + ZERO hazards
        /*
        1. STR_I R8 R1 #1 - PUW = 100
        2. LDR_LIT R8 #1 - PUW = 110
        3. NOP
        4. NOP
        5. LDR_I R8 R1 #1 - PUW = 101
        6. STR_R R8 R1 << R1 - PUW = 000
        7. LDR_R R8 R1 << R1 - PUW = 010
        */
        reset;
        $display("Starting Memory Tests");
        load_pc_start(test_num);
        clkR; // load pc
        clkR; // fetch
        clkR; // fetch_wait

        // EX: 1, MEM: n/a, MEM_WAIT: n/a, WB: n/a
        $display("12: Test Number %d", test_num);
        instr_in = STR_I_R8_R1_1;        // STR_I R8 R1 #1
        clkR;
        executeCycle_LDR_STR(test_num, 2'b00);  //instruction 1

        // EX: 2, MEM: 1, MEM_WAIT: n/a, WB: n/a
        $display("13: Test Number %d", test_num);
        instr_in = LDR_LIT_R8_R1_1;        // LDR_LIT R8 #1
        clkR;
        executeCycle_LDR_STR(test_num, 2'b01);  //instruction 2
        mem_writeback_STR_LDR(test_num, 1, 0, 0, 2'b00, 1);

        // EX: NOP, MEM: 2, MEM_WAIT: 1, WB: n/a
        $display("14: Test Number %d", test_num);
        instr_in = NOP;
        clkR;
        execute_NOP(test_num);
        mem_writeback_STR_LDR(test_num, 1, 1, 0, 2'b01, 0);
        mem_wait(test_num);

        // EX: NOP, MEM: NOP, MEM_WAIT: 2, WB: 1
        $display("15: Test Number %d", test_num);
        instr_in = NOP;
        clkR;
        execute_NOP(test_num);
        mem_writeback_NOP(test_num);
        mem_wait(test_num);
        write_back_NOP(test_num);

        // EX: 5, MEM: NOP, MEM_WAIT: NOP, WB: 2
        $display("16: Test Number %d", test_num);
        instr_in = LDR_I_R8_R1_1;        // LDR_I R8 R1 #1
        clkR;
        executeCycle_LDR_STR(test_num, 2'b00);  //instruction 5
        mem_writeback_NOP(test_num);
        mem_wait(test_num);
        write_back_LDR(test_num);

        // EX: 6, MEM: 5, MEM_WAIT: NOP, WB: NOP
        $display("17: Test Number %d", test_num);
        instr_in = STR_R_R8_R1_LSL_R1;        // STR_R R8 R1 << R1
        clkR;
        executeCycle_LDR_STR(test_num, 2'b10);  //instruction 6
        mem_writeback_STR_LDR(test_num, 1, 0, 1, 2'b00, 0);
        mem_wait(test_num);
        write_back_NOP(test_num);

        // EX: 7, MEM: 6, MEM_WAIT: 5, WB: NOP
        $display("18: Test Number %d", test_num);
        instr_in = LDR_R_R8_R1_LSL_R1;        // LDR_R R8 R1 << R1
        clkR;
        executeCycle_LDR_STR(test_num, 2'b10);  //instruction 7
        mem_writeback_STR_LDR(test_num, 0, 0, 0, 2'b10, 1);
        mem_wait(test_num);
        write_back_NOP(test_num);

        // EX: NOP, MEM: 7, MEM_WAIT: 6, WB: 5
        $display("19: Test Number %d", test_num);
        instr_in = NOP;
        clkR;
        execute_NOP(test_num);
        mem_writeback_STR_LDR(test_num, 0, 1, 0, 2'b10, 0);
        mem_wait(test_num);
        write_back_LDR(test_num);

        // EX: NOP, MEM: NOP, MEM_WAIT: 7, WB: 6
        $display("20: Test Number %d", test_num);
        instr_in = NOP;
        clkR;
        execute_NOP(test_num);
        mem_writeback_NOP(test_num);
        mem_wait(test_num);
        write_back_NOP(test_num);

        // EX: NOP, MEM: NOP, MEM_WAIT: NOP, WB: 7
        $display("21: Test Number %d", test_num);
        instr_in = NOP;
        clkR;
        execute_NOP(test_num);
        mem_writeback_NOP(test_num);
        mem_wait(test_num);
        write_back_LDR(test_num);

        // Stage 3 Testing: Branching + ZERO hazards TODO: TBD
        /*
        1. B #1 -> equals 0000
        2. BL #2 -> not equal 0001
        3. BX R1 -> greater than 1100
        4. BLX R2 -> less than 1011
        5. B #1 -> equals 0000 BUT FAILS
        */
        reset;
        $display("Starting Branch Tests");
        load_pc_start(test_num);
        clkR; // load pc
        clkR; // fetch
        clkR; // fetch_wait

        // EX: 1, MEM: n/a, MEM_WAIT: n/a, WB: n/a
        $display("22: Test Number %d", test_num);
        instr_in = B_1;        // B #1
        clkR;
        executeCycle_Branch(test_num, 0);  //instruction 1
        clkR;
        clkR;

        // EX: 2, MEM: 1, MEM_WAIT: n/a, WB: n/a
        $display("23: Test Number %d", test_num);
        instr_in = BL_2;        // BL #2
        status_reg = 32'b1000_0000000000000000000000000000;
        clkR;
        executeCycle_Branch(test_num, 0);  //instruction 2
        mem_writeback_Branch(test_num, 0, 0, 4'b0000, status_reg[31:28]);

        // EX: 3, MEM: 2, MEM_WAIT: 1, WB: n/a
        $display("24: Test Number %d", test_num);
        instr_in = BX_R1;        // BX R1
        status_reg = 32'b0111_0000000000000000000000000000;
        clkR;
        executeCycle_Branch(test_num, 1);  //instruction 3
        mem_writeback_Branch(test_num, 1, 0, 4'b0001, status_reg[31:28]);
        mem_wait(test_num);

        // EX: 4, MEM: 3, MEM_WAIT: 2, WB: 1
        $display("25: Test Number %d", test_num);
        instr_in = BLX_R2;        // BLX R2
        status_reg = 32'b0010_0000000000000000000000000000;
        clkR;
        executeCycle_Branch(test_num, 1);  //instruction 4
        mem_writeback_Branch(test_num, 0, 1, 4'b1100, status_reg[31:28]);
        mem_wait(test_num);
        write_back_NOP(test_num);

        // EX: 5, MEM: 4, MEM_WAIT: 3, WB: 2
        $display("26: Test Number %d", test_num);
        instr_in = B_1;        // B #1
        status_reg = 32'b1000_0000000000000000000000000000;
        clkR;
        executeCycle_Branch(test_num, 0);  //instruction 5
        mem_writeback_Branch(test_num, 1, 1, 4'b1011, status_reg[31:28]);
        mem_wait(test_num);
        write_back_NOP(test_num);

        // EX: NOP, MEM: 5, MEM_WAIT: 4, WB: 3
        $display("27: Test Number %d", test_num);
        instr_in = NOP;
        status_reg = 32'b0001_0000000000000000000000000000;
        clkR;
        execute_NOP(test_num);
        mem_writeback_Branch(test_num, 0, 0, 4'b0000, status_reg[31:28]);    //this one should fail
        mem_wait(test_num);
        write_back_NOP(test_num);

        // EX: NOP, MEM: NOP, MEM_WAIT: 5, WB: 4
        $display("28: Test Number %d", test_num);
        instr_in = NOP;
        clkR;
        execute_NOP(test_num);
        mem_writeback_NOP(test_num);
        mem_wait(test_num);
        write_back_NOP(test_num);

        // EX: NOP, MEM: NOP, MEM_WAIT: NOP, WB: 5
        $display("29: Test Number %d", test_num);
        instr_in = NOP;
        clkR;
        execute_NOP(test_num);
        mem_writeback_NOP(test_num);
        mem_wait(test_num);
        write_back_NOP(test_num);

        //print test summary
        if (error_count == 0) begin
            $display("All tests passed!");
        end else begin
            $display("Failed %d tests", error_count);
        end
    end
endmodule: tb_controller