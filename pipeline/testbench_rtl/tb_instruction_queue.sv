module tb_instruction_queue(output err);
    //regs for testbench
    reg clk;
    reg rst_n;
    reg [31:0] instr_in;
    reg is_enqueue;
    reg [31:0] instr_out;
    reg is_empty;
    integer error_count = 0;
    integer test_num = 0;

    // tasks
    task check(input [31:0] expected, input [31:0] actual, integer test_num);
        begin
            if (expected !== actual) begin
            $error("Test %d failed. Expected: %d, Actual: %d", test_num, expected, actual);
            error_count = error_count + 1;
            end
        end
    endtask: check

    // clk task
    task clkR;
        begin
            clk = 1'd0;
            #5;
            clk = 1'd1;
            #5;
        end
    endtask: clkR

    task reset;
        begin
            instr_in = 32'd0;
            is_enqueue = 1'd1;
            test_num = 0;
            rst_n = 1'b1;
            #5;
            rst_n = 1'b0;
            #5;
            rst_n = 1'b1;
        end
    endtask: reset

    // DUT
    instruction_queue instr_queue(
        .clk(clk),
        .rst_n(rst_n),
        .instr_in(instr_in),
        .is_enqueue(is_enqueue),
        .instr_out(instr_out),
        .is_empty(is_empty)
    );

    integer i = 0;
    initial begin
        // Test 1: reset the module will clear the queue
        $display("##### Test 1 ##### : Time: %t", $time);
        reset;
        check(32'd0, instr_out, test_num);
        check(1'd1, is_empty, test_num + 1);

        // Test 2: enqueue an instruction then dequeue it
        $display("##### Test 2 ##### : Time: %t", $time);
        reset;
        instr_in = 32'h12345678;
        clkR;
        // can peek the next instruciton to dequeue
        instr_in = 32'd0;
        check(32'h12345678, instr_out, test_num + 2);
        check(1'd0, is_empty, test_num + 3);
        is_enqueue = 1'd0;
        clkR;
        // queue is now empty
        check(1'd1, is_empty, test_num + 4);

        // Test 3: enqueue two instructions then dequeue them
        $display("##### Test 3 ##### : Time: %t", $time);
        reset;
        instr_in = 32'd1;
        clkR;
        instr_in = 32'd2;
        clkR;
        // peeks the first instruction
        instr_in = 32'd0;
        check(32'd1, instr_out, test_num);
        check(1'd0, is_empty, test_num + 1);
        is_enqueue = 1'd0;
        clkR;
        // peeks the second instruction
        instr_in = 32'd0;
        check(32'd2, instr_out, test_num + 2);
        check(1'd0, is_empty, test_num + 3);
        clkR;
        // queue is now empty
        check(1'd1, is_empty, test_num + 4);

        // Test 4: enqueue three instructions would overflow the queue
        $display("##### Test 4 ##### : Time: %t", $time);
        reset;
        instr_in = 32'd1;
        clkR;
        instr_in = 32'd2;
        clkR;
        instr_in = 32'd3;
        clkR;
        // peeks the second instruction -> first got overflowed
        instr_in = 32'd0;
        check(32'd2, instr_out, test_num);
        check(1'd0, is_empty, test_num + 1);
        is_enqueue = 1'd0;
        clkR;
        // peeks the third instruction
        instr_in = 32'd0;
        check(32'd3, instr_out, test_num + 2);
        check(1'd0, is_empty, test_num + 3);
        clkR;
        // queue is now empty
        check(1'd1, is_empty, test_num + 4);


        // print test summary
        if (error_count == 0) begin
            $display("All tests passed");
        end else begin
            $display("There were %d errors", error_count);
        end
    end
endmodule: tb_instruction_queue