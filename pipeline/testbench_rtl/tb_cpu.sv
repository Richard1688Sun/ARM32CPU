module tb_cpu(output err);

    reg clk, rst_n;
    reg [31:0] instr;
    reg [31:0] ram_data2;
    reg [10:0] start_pc;
    wire mem_w_en;
    wire [10:0] ram_addr2;
    wire [31:0] ram_in2;
    wire [31:0] status;
    wire [31:0] dp_out;
    wire [10:0] pc;
    wire [31:0] reg_output;         //TODO: remove later
    wire [3:0] reg_addr;            //TODO: remove later
    integer error_count = 0;

    // tasks
    task check(input [31:0] expected, input [31:0] actual, input [3:0] addr, integer test_num);
        begin
            if (expected !== actual) begin
            $error("Test %d failed. Expected: %d, Actual: %d", test_num, expected, actual);
            error_count = error_count + 1;
            end else begin
            $display("Test %d passed.", test_num);
            end
        end
    endtask: check

    // clk task
    task clkR;
        begin
            clk = 1'b0;
            #5;
            clk = 1'b1;
            #5;
        end
    endtask: clkR

    // reset task
    task reset;
        begin
            rst_n = 1'b1;
            #5;
            rst_n = 1'b0;
            #5;
            rst_n = 1'b1;
        end
    endtask: reset

    task restart_pc;
        reset; // load pc
        clkR; // fetch
        clkR; // fetch_wait
    endtask: restart_pc

    task clkStart;
        begin
            restart_pc;
            clkR;
            clkR;
        end
    endtask: clkStart

    task clkEnd;
        begin
            clkR;
        end
    endtask: clkEnd
    
    // Instantiate the CPU module
    cpu DUT (
        .clk(clk),
        .rst_n(rst_n),
        .instr(instr),
        .ram_data2(ram_data2),
        .start_pc(start_pc),
        .mem_w_en(mem_w_en),
        .ram_addr2(ram_addr2),
        .ram_in2(ram_in2),
        .status(status),
        .dp_out(dp_out),
        .pc(pc),
        .reg_output(reg_output),
        .reg_addr(reg_addr)
    );
    
    integer i = 0;
    localparam [31:0] NOP = 32'b1110_00110010_0000_11110000_00000000;
    initial begin
        restart_pc;
        //load every register with value of register number
        instr = 32'b1110_00111010_0000_0000_000000000001; // MOV R0, #0

        for (i = 0; i < 16; i = i + 1) begin
            clkR;
            instr = instr + (32'd1 << 12); //increment the register addr
            instr = instr + 32'd1;       //increment the register value
        end
        // finish off the last instruction
        instr = NOP;
        clkR;
        clkR;
        clkR;
        clkR;

        // Test 1: ADD_R R0, R0, R0
        //ADD R0, R0, R0
        instr = 32'b0000_00001001_0000_00000000_00000000;
        clkStart;
        check(32'd2, dp_out, 0, 1);
        clkEnd;
        check(32'b00000000_00000000_00000000_00000000, status, 0, 1);


        // Test 2: ADD_R R1, R1, R0
        //ADD R0, R0, R0
        instr = 32'b0000_00_0_0100_1_0001_0001_0000_00000000; //b0000_00101001_0001_0001_0000_00001000
        clkStart;
        check(32'd4, dp_out, 0, 2);
        clkEnd;
        check(32'b00000000_00000000_00000000_00000000, status, 0, 2);


        // Test 3: ADD_I R1, R1, #8
        instr = 32'b0000_00_1_0100_1_0001_0001_000000001000;
        clkStart;
        check(32'd12, dp_out, 0, 3);
        clkEnd;
        check(32'b00000000_00000000_00000000_00000000, status, 0, 3);

        // Test 4: ADD_RS R2, R2, R0 << R2
        instr = 32'b1110_00_0_0100_0_0010_0010_0010_0_00_1_0000;
        clkStart;
        check(32'd19, dp_out, 0, 4);
        clkEnd;
        check(32'b00000000_00000000_00000000_00000000, status, 0, 4);

        // Test 5: ADD_R R0, R0, R1
        instr = 32'b1110_00_0_0100_1_0000_0000_00000_00_0_0001; // ADD_R R0, R0, R1
        clkStart;
        check(32'd14, dp_out, 0, 5);
        clkEnd;
        check(32'b00000000_00000000_00000000_00000000, status, 0, 5);

        // Test 6: CMP_R R0, R1, (R0 = 14, R1 = 12)
        instr = 32'b1110_00010101_0000_0000_000000000001; // CMP R0, R1
        clkStart;
        check(32'd2, dp_out, 0, 6);
        clkEnd;
        check(32'b00000000_00000000_00000000_00000000, status, 0, 6);
        
        // Test 7: SUB_R R0, R0, R0 (0 flag)
        instr = 32'b1110_00000101_0000_0000_000000000000; // SUB R0, R1, R0
        clkStart;
        check(32'd0, dp_out, 0, 7);
        clkEnd;
        check(32'b01000000_00000000_00000000_00000000, status, 0, 7);

        // Test 8: SUB_RS R5, R5, R1 >> R3 (R5 = 6, R1 = 12 -> 0, R3 = 4)
        instr = 32'b1110_00000100_0101_0101_0011_0011_0001; // cond_op_Rn_Rd_Rs_shift_rm
        clkStart;
        check(32'd6, dp_out, 0, 8);
        clkEnd;
        check(32'b01000000_00000000_00000000_00000000, status, 0, 8);
    end
endmodule
