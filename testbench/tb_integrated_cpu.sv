`timescale 1ps / 1ps
module tb_integrated_cpu();

    //test regs
    integer error_count = 0;

    //cpu inputs
    reg clk, rst_n;
    reg [10:0] start_pc;

    //cpu module
    integrated_cpu DUT(
        .clk(clk),
        .rst_n(rst_n),
        .start_pc(start_pc)
    );

    // Tasks
    task check(input integer expected, input integer actual, integer test_num);
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

    task clkCycle;
        begin
            clkR;
            clkR;
            clkR;
            clkR;
            clkR;
            clkR;
            clkR;
            clkR;
        end
    endtask: clkCycle

    integer i = 0;
    initial begin
        //fill the duel memory with instructions: with the mov instructions
        $readmemb("C:/Users/richa/OneDrive - UBC/Documents/Personal_Projects/Winter_CPU_Project/ARM32CPU/memory_data/remakeCPUTests.memh",
            DUT.duel_mem.altsyncram_component.m_default.altsyncram_inst.mem_data);
        
        reset;
        start_pc = 32'd0;

        // Fill each register with default values
        for (i = 0; i < 16; i = i + 1) begin
            clkCycle;
            check(i + 1, DUT.cpu.datapath.regfile.registeres[i], i);
        end
        
        // ADD_R r0, r0, r0
        clkCycle;
        check(2, DUT.cpu.datapath.regfile.registeres[0], 16);
        check(0, DUT.cpu.status_out, 17);

        // ADD_I r1, r1, #8
        clkCycle;
        check(10, DUT.cpu.datapath.regfile.registeres[1], 18);
        check(0, DUT.cpu.status_out, 19);

        // ADD_RS r2, r2, r0, LSL r0
        clkCycle;
        check(11, DUT.cpu.datapath.regfile.registeres[2], 20);
        check(0, DUT.cpu.status_out, 21);

        // CMP_R r2, r1, LSL #1 (r2 = 11, r1 = 10 -> 20)
        clkCycle;
        check(10, DUT.cpu.datapath.regfile.registeres[1], 22);
        check(32'b10000000_00000000_00000000_00000000, DUT.cpu.status_out, 23);

        // CMP_I r2, #11
        clkCycle;
        check(11, DUT.cpu.datapath.regfile.registeres[2], 24);
        check(32'b01000000_00000000_00000000_00000000, DUT.cpu.status_out, 25);

        // ### LDR and STR tests ###
        $readmemb("C:/Users/richa/OneDrive - UBC/Documents/Personal_Projects/Winter_CPU_Project/ARM32CPU/memory_data/str_ldr_CPUTests.memh",
            DUT.duel_mem.altsyncram_component.m_default.altsyncram_inst.mem_data);
        $readmemb("C:/Users/richa/OneDrive - UBC/Documents/Personal_Projects/Winter_CPU_Project/ARM32CPU/memory_data/str_ldr_CPUTests.memh",
            DUT.duel_mem.altsyncram_component.m_default.altsyncram_inst.mem_data_b);
        reset;
        start_pc = 32'd0;

        // Fill each register with default values
        for (i = 0; i < 16; i = i + 1) begin
            clkCycle;
            check(i, DUT.cpu.datapath.regfile.registeres[i], i + 26);
        end

        // LDR_I r0, r9, #19
        clkCycle;
        clkR;   //because the actual LDR writeback is done on the very very last clk edge
        check(38, DUT.cpu.datapath.regfile.registeres[0], 42);

        // STR_I r8, r0, #9 -> store 8 in address 29 -> 38 - 9 = 29 -> store 29 in r0
        clkCycle;
        check(29, DUT.cpu.datapath.regfile.registeres[0], 43);

        //LDR_R r15, r0, r1 -> address = 29 -> write 28 to r0
        clkCycle;
        check(28, DUT.cpu.datapath.regfile.registeres[0], 44);
        check(8, DUT.cpu.datapath.regfile.registeres[15], 45);

        //STR_R r9, r12, r2 LSL 3 -> address = 12 + 2 * 8 = 28 -> write 28 address 12
        clkCycle;
        check(28, DUT.cpu.datapath.regfile.registeres[12], 46);
        
        // LDR_Lit r1, #8 -> PC == 20, write 10 to r1
        clkCycle;
        check(10, DUT.cpu.datapath.regfile.registeres[1], 47);

        //print final test results
        if (error_count == 0) begin
            $display("All tests passed!");
        end else begin
            $display("%d tests failed.", error_count);
        end
    end
endmodule: tb_integrated_cpu