`timescale 1ps / 1ps
module tb_integrated_cpu();
    // constants for HEX
    reg [6:0] display [16] = '{
        7'b1000000, // 0
        7'b1111001, // 1
        7'b0100100, // 2
        7'b0110000, // 3
        7'b0011001, // 4
        7'b0010010, // 5
        7'b0000010, // 6
        7'b1111000, // 7
        7'b0000000, // 8
        7'b0010000, // 9
        7'b1111111, // blank
        7'b1111111, // blank
        7'b1111111, // blank
        7'b1111111, // blank
        7'b1111111, // blank
        7'b1111111 // blank
    };

    //test regs
    integer error_count = 0;

    //cpu inputs
    reg clk, rst_n, manual_clk;
    wire CLOCK_50;
    wire [3:0] KEY;
    wire [9:0] SW;
    wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    wire [9:0] LEDR;

    // internal signals
    reg [4:0] reg_addr;

    //cpu module
    integrated_cpu DUT(
        .CLOCK_50(CLOCK_50),
        .KEY(KEY),
        .SW(SW),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3),
        .HEX4(HEX4),
        .HEX5(HEX5),
        .LEDR(LEDR)
    );

    assign CLOCK_50 = clk;
    assign KEY[0] = ~manual_clk;
    assign KEY[1] = rst_n;
    assign SW = { 2'b11, reg_addr, 3'b000};

    function [3:0] reverse_display (input [6:0] value);
        case (value)
            display[0]: return 4'b0000;
            display[1]: return 4'b0001;
            display[2]: return 4'b0010;
            display[3]: return 4'b0011;
            display[4]: return 4'b0100;
            display[5]: return 4'b0101;
            display[6]: return 4'b0110;
            display[7]: return 4'b0111;
            display[8]: return 4'b1000;
            display[9]: return 4'b1001;
            display[10]: return 4'b1010;
            display[11]: return 4'b1011;
            display[12]: return 4'b1100;
            display[13]: return 4'b1101;
            display[14]: return 4'b1110;
            display[15]: return 4'b1111;
            default: return 4'b1111; // Return a default value if no match is found
        endcase
    endfunction

    // Tasks
    task check(input [31:0] expected, input [31:0] actual, integer test_num);
        begin
            if (expected !== actual) begin
                $error("Test %d failed. Expected: %b(%d), Actual: %b(%d)", test_num, expected, expected, actual, actual);
                error_count = error_count + 1;
            end
        end
    endtask: check

    
    task autoClkTimes (input integer times);
        for (int i = 0; i < times; i = i + 1) begin
            clk = 1'b0;
            #1;
            clk = 1'b1;
            #1;
        end
    endtask;

    // TODO: fix this
    int has_error;
    int og_expected;
    task displayCheck (input int expected, integer test_num);
        begin
            has_error = 0;
            og_expected = expected;
            autoClkTimes(6);
            if (reg_addr == 16) begin
                if (HEX0 !== display[expected[28]]) has_error = 1;
                if (HEX1 !== display[expected[29]]) has_error = 1;
                if (HEX2 !== display[expected[30]]) has_error = 1;
                if (HEX3 !== display[expected[31]]) has_error = 1;
                if (HEX4 !== display[0]) has_error = 1;
                if (HEX5 !== display[0]) has_error = 1;

                if (has_error) begin
                    $error("Test %d failed. Expected: %b, Actual: %d%d%d%d%d%d", test_num, og_expected, reverse_display(HEX5), reverse_display(HEX4), reverse_display(HEX3), reverse_display(HEX2), reverse_display(HEX1), reverse_display(HEX0));
                    error_count = error_count + 1;
                end else begin
                    $display("Test %d: Expected: %b, Actual: %b", test_num, og_expected, og_expected);
                end
            end else begin
                if (HEX0 !== display[expected % 10]) has_error = 1;
                expected = expected / 10;
                if (HEX1 !== display[expected % 10]) has_error = 1;
                expected = expected / 10;
                if (HEX2 !== display[expected % 10]) has_error = 1;
                expected = expected / 10;
                if (HEX3 !== display[expected % 10]) has_error = 1;
                expected = expected / 10;
                if (HEX4 !== display[expected % 10]) has_error = 1;
                expected = expected / 10;
                if (HEX5 !== display[expected % 10]) has_error = 1;

                if (has_error) begin
                    $error("Test %d failed. Expected: %d, Actual: %d%d%d%d%d%d", test_num, og_expected, reverse_display(HEX5), reverse_display(HEX4), reverse_display(HEX3), reverse_display(HEX2), reverse_display(HEX1), reverse_display(HEX0));
                    error_count = error_count + 1;
                end else begin
                    $display("Test %d: Expected: %d, Actual: %d", test_num, og_expected, og_expected);
                end
            end
        end
    endtask : displayCheck

    task setRegAddr(input [4:0] addr);
        begin
            reg_addr = addr;
            #5;
        end
    endtask: setRegAddr

    task clkR;
        begin
            manual_clk = 1'b0;
            #5;
            manual_clk = 1'b1;
            #5;
        end
    endtask: clkR

    task reset;
        begin
            #5;
            manual_clk = 1'b0;
            setRegAddr(18);      // some random default number
            rst_n = 1'b1;
            #5;
            rst_n = 1'b0;
            #5;
            rst_n = 1'b1;
        end
    endtask: reset

    // ALL THE TASKS MEAN WE START THE STAGE NOT COMPLETE
    task restart_pc;
        reset; // load pc
        clkR; // fetch
        clkR; // fetch_wait
        clkR; // decode stage -> preapre to load execute register
    endtask: restart_pc

    task clkEnterMemory;
        begin
            clkR;   //execute
            clkR;   //memory
        end
    endtask: clkEnterMemory

    task clkEnterMemWait;
        begin
            clkR;   // memory_wait
        end
    endtask: clkEnterMemWait

    task clkDone;
        begin
            clkR;   // ldr_writeback
        end
    endtask: clkDone

    integer i = 0;
    integer pc_before = 0;
    initial begin
        //fill the duel memory with instructions: with the mov instructions
        $readmemb("C:/Users/richa/OneDrive - UBC/Documents/Personal_Projects/Winter_CPU_Project/ARM32CPU/memory_data/rtl_data/remakeCPUTests.memb",
            DUT.instruction_memory.altsyncram_component.m_default.altsyncram_inst.mem_data);
        
        restart_pc;
        clkEnterMemory;


        // Fill each register with default values
        for (i = 0; i < 15; i = i + 1) begin
            clkR;
            setRegAddr(i);
            displayCheck(i + 1, i);
        end
        
        // ADD_R r0, r0, r0
        clkR;
        setRegAddr(0);
        displayCheck(2, 16);

        // ADD_I r1, r1, #8
        clkR;
        // check status reg
        setRegAddr(16);
        displayCheck(0, 17);   // from previous test
        setRegAddr(1);
        displayCheck(10, 18);

        // ADD_RS r2, r2, r0, LSL r0
        clkR;
        // check status reg
        setRegAddr(16);
        displayCheck(0, 19);

        // CMP_R r2, r1, LSL #1 (r2 = 11, r1 = 10 -> 20)
        clkR;
        // check status reg
        setRegAddr(16);
        displayCheck(32'b10000000_00000000_00000000_00000000, 23);

        // CMP_I r2, #11
        clkR;
        // check status reg
        setRegAddr(16);
        displayCheck(32'b01000000_00000000_00000000_00000000, 25);

        // ### LDR and STR tests ###
        $readmemb("C:/Users/richa/OneDrive - UBC/Documents/Personal_Projects/Winter_CPU_Project/ARM32CPU/memory_data/rtl_data/str_ldr_instr_CPUTests.memb",
            DUT.instruction_memory.altsyncram_component.m_default.altsyncram_inst.mem_data);
        $readmemb("C:/Users/richa/OneDrive - UBC/Documents/Personal_Projects/Winter_CPU_Project/ARM32CPU/memory_data/rtl_data/str_ldr_data_CPUTests.memb",
            DUT.data_memory.altsyncram_component.m_default.altsyncram_inst.mem_data);
        
        restart_pc;
        clkEnterMemory;

        // Fill each register with default values
        for (i = 0; i < 15; i = i + 1) begin
            clkR;
            setRegAddr(i);
            displayCheck(i, i + 26);
        end

        // LDR_I r0, r9, #19
        clkR; // memory
        clkR; // memory_wait
        clkR; // ldr_writeback
        clkR; // complete ldr_writeback
        setRegAddr(0);
        displayCheck(38, 42);

        // STR_I r8, r0, #9 -> store 8 in address 29 -> 38 - 9 = 29 -> store 29 in r0
        // NOTE: There was stallin done for this instruction
        clkR; // complete memory
        setRegAddr(0);
        displayCheck(29, 43);

        //LDR_R r14, r0, r1 -> address = 29 -> write 28 to r0
        clkR; // complete memory
        setRegAddr(0);
        displayCheck(28, 44);

        clkR; // complete memory_wait for LDR_R && complete memory for STR_R
        //STR_R r9, r12, r2 LSL 3 -> address = 12 + 2 * 8 = 28 -> write 28 address 12
        setRegAddr(12);
        displayCheck(28, 46);
        clkR; // complete ldr_writeback for LDR_R && complete memory_wait STR_R
        setRegAddr(14);             // check again LDR_R r14, r0, r1
        displayCheck(8, 45);

        
        // LDR_Lit r1, #8 -> PC == 20
        clkR; // complete memory_wait for LDR_Lit
        clkR; // was stalled for 1 cycle -> complete memory for LDR_Lit
        // checking final register value
        setRegAddr(1);
        displayCheck(888, 47);

        // ### Branch tests ###
        $readmemb("C:/Users/richa/OneDrive - UBC/Documents/Personal_Projects/Winter_CPU_Project/ARM32CPU/memory_data/rtl_data/branchCPUTests.memb",
            DUT.instruction_memory.altsyncram_component.m_default.altsyncram_inst.mem_data);
        
        restart_pc;
        clkEnterMemory;

        //MOV_I r0, #1
        clkR;
        setRegAddr(0);
        displayCheck(1, 48);

        //MOV_I r1, #10
        clkR;
        setRegAddr(1);
        displayCheck(10, 49);

        //ADD r0, r0, #1
        //CMP r0, r1
        //BLE #2
        for (i = 0; i < 8; i = i + 1) begin
            clkR;
            setRegAddr(0);
            displayCheck(2 + i, i * 3 + 50);
            clkR;
            // check status reg
            setRegAddr(16);
            displayCheck(32'b10000000_00000000_00000000_00000000, (i * 3) + 51);
            clkR;
            setRegAddr(15);
            displayCheck(2, (i * 3) + 52);
            // branch was taken so need to squash the next 3 instructions
            clkR; // load_pc register 
            clkR; // finish fetch
            clkR; // finish fetch_wait
            clkR; // finish decode
        end
        clkR;
        setRegAddr(0);
        displayCheck(10, 77);
        clkR;   //r0 == r1
        // check status reg
        setRegAddr(16);
        displayCheck(32'b01000000_00000000_00000000_00000000, 78);
        clkR;
        setRegAddr(15);
        displayCheck(2, 79);
        clkR; // load_pc register 
        clkR; // finish fetch
        clkR; // finish fetch_wait
        clkR; // finish decode
        // last loop iteration, branch not taken
        clkR;
        setRegAddr(0);
        displayCheck(11, 80);
        clkR;   //r0 > r1
        // check status reg
        setRegAddr(16);
        displayCheck(32'b00000000_00000000_00000000_00000000, 81);
        setRegAddr(15);
        // pc_before = reg_output; //  caching the previous PC value //TODO: fix this
        clkR;
        // displayCheck(pc_before + 1, 82);   // checking that the PC was incremented by 1
        
        //STR r0, r0, #1
        clkR;
        check(11, DUT.data_memory.altsyncram_component.m_default.altsyncram_inst.mem_data[10], 83);

        //print final test results
        if (error_count == 0) begin
            $display("All tests passed!");
        end else begin
            $display("%d tests failed.", error_count);
        end
    end
endmodule: tb_integrated_cpu