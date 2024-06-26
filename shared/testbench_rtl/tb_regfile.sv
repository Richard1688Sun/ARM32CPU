module tb_regfile(output err);

    //regs for testbench
    reg [31:0] w_data1, w_data2, A_data, B_data, shift_data;
    reg [3:0] A_addr, B_addr, shift_addr, w_addr1, w_addr2;
    reg w_en1, w_en2, clk;
    integer error_count = 0;

    // tasks
    task check(input [31:0] expected, input [31:0] actual, input [3:0] addr, integer test_num);
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
            clk = 1'b0;
            #5;
            clk = 1'b1;
            #5;
        end
    endtask: clkR

    // DUT
    regfile regfile(
        .w_data1(w_data1),
        .w_addr1(w_addr1),
        .w_en1(w_en1),
        .clk(clk),
        .w_data2(w_data2),
        .w_addr2(w_addr2),
        .w_en2(w_en2),
        .A_addr(A_addr),
        .B_addr(B_addr),
        .shift_addr(shift_addr),
        .A_data(A_data),
        .B_data(B_data),
        .shift_data(shift_data)
    );

    integer i = 0;
    initial begin
        // test every register write and read on A_data
        for (i = 0; i < 8; i = i + 1) begin
            w_data1 = i;
            w_addr1 = i;
            w_en1 = 1'b1;
            w_data2 = i + 8;
            w_addr2 = i + 8;
            w_en2 = 1'b1;
            A_addr = i;
            clkR;
            check(i, A_data, A_addr, i);
        end

        // test every register read again
        for (i = 0; i < 16 - 2; i = i + 1) begin
            w_en1 = 1'b0;
            A_addr = i;
            B_addr = i + 1;
            shift_addr = i + 2;
            #10;
            check(i, A_data, A_addr, i);
            check(i + 1, B_data, B_addr, i);
            check(i + 2, shift_data, shift_addr, i);
        end

        // print test summary
        if (error_count == 0) begin
            $display("All tests passed!");
        end else begin
            $display("Failed %d tests", error_count);
        end
    end
endmodule: tb_regfile
