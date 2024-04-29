module tb_instruction_queue(output err);
    //regs for testbench
    reg [31:0] instr_in;
    reg is_enqueue;
    reg [31:0] instr_out;
    reg is_empty;
    integer error_count = 0;

    // tasks
    task check(input [31:0] expected, input [31:0] actual, integer test_num);
        begin
            if (expected !== actual) begin
            $display("Test %d failed. Expected: %d, Actual: %d", test_num, expected, actual);
            error_count = error_count + 1;
            end
        end
    endtask: check

    // clk task
    task clkR;
        begin
            is_enqueue = 1'b0;
            #5;
            is_enqueue = 1'b1;
            #5;
        end
    endtask: clkR

    // DUT
    instruction_queue instr_queue(
        .instr_in(instr_in),
        .is_enqueue(is_enqueue),
        .instr_out(instr_out),
        .is_empty(is_empty)
    );

    integer i = 0;
    initial begin
        // test every register write and read on instr_in
        for (i = 1; i < 3; i = i + 1) begin
            instr_in = i;
            is_enqueue = 1'b1;
            clkR;
            check(i, instr_out, i);
        end

        // test is_empty
        is_enqueue = 1'b0;
        clkR;
        check(1, is_empty, 8);
    end

    // check if there are any errors
    initial begin
        if (error_count == 0) begin
            $display("All tests passed");
            err = 0;
        end else begin
            $display("There were %d errors", error_count);
            err = 1;
        end
    end
endmodule: tb_instruction_queue