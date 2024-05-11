module tb_FPGA_interface();
  //test regs
  integer error_count = 0;

  // constants
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

  // DUT inputs
  reg clk, rst_n;
  reg [6:0] pc_fetch_unit;
  reg [6:0] pc_fetch_wait_unit;
  reg [6:0] pc_decode_unit;
  reg [6:0] pc_execute_unit;
  reg [6:0] pc_memory_unit;
  reg [6:0] pc_memory_wait_unit;
  reg [6:0] pc_writeback_unit;
  reg [6:0] opcode_fetch_unit;
  reg [6:0] opcode_fetch_wait_unit;
  reg [6:0] opcode_decode_unit;
  reg [6:0] opcode_execute_unit;
  reg [6:0] opcode_memory_unit;
  reg [6:0] opcode_memory_wait_unit;
  reg [6:0] opcode_writeback_unit;
  reg [19:0] selected_reg_value;
  reg [9:0] SW;

  // DUT outputs
  wire [6:0] HEX0;
  wire [6:0] HEX1;
  wire [6:0] HEX2;
  wire [6:0] HEX3;
  wire [6:0] HEX4;
  wire [6:0] HEX5;
  wire [9:0] LEDR;

  // internal control signals
  reg is_show_reg_mode;
  assign SW[8] = is_show_reg_mode;
  reg is_manual_clk_mode;
  assign SW[9] = is_manual_clk_mode;
  reg [2:0] stage_select;
  assign SW[2:0] = stage_select;
  reg [3:0] reg_select;
  assign SW[7:4] = reg_select;

  FPGA_interface FPGA_interface(
    .clk(clk),
    .rst_n(rst_n),
    .pc_fetch_unit(pc_fetch_unit),
    .pc_fetch_wait_unit(pc_fetch_wait_unit),
    .pc_decode_unit(pc_decode_unit),
    .pc_execute_unit(pc_execute_unit),
    .pc_memory_unit(pc_memory_unit),
    .pc_memory_wait_unit(pc_memory_wait_unit),
    .pc_writeback_unit(pc_writeback_unit),
    .opcode_fetch_unit(opcode_fetch_unit),
    .opcode_fetch_wait_unit(opcode_fetch_wait_unit),
    .opcode_decode_unit(opcode_decode_unit),
    .opcode_execute_unit(opcode_execute_unit),
    .opcode_memory_unit(opcode_memory_unit),
    .opcode_memory_wait_unit(opcode_memory_wait_unit),
    .opcode_writeback_unit(opcode_writeback_unit),
    .selected_reg_value(selected_reg_value),
    .SW(SW),
    .HEX0(HEX0),
    .HEX1(HEX1),
    .HEX2(HEX2),
    .HEX3(HEX3),
    .HEX4(HEX4),
    .HEX5(HEX5),
    .LEDR(LEDR)
  );

  // Tasks
  task check(input [6:0] expected, input [6:0] actual, integer test_num);
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
      is_show_reg_mode = 0;
      is_manual_clk_mode = 1;
      reg_select = 4'b0000;
      stage_select = 3'b000;
      opcode_fetch_unit = 7'b0000001;
      opcode_fetch_wait_unit = 7'b0000010;
      opcode_decode_unit = 7'b0000011;
      opcode_execute_unit = 7'b0000100;
      opcode_memory_unit = 7'b0000101;
      opcode_memory_wait_unit = 7'b0000110;
      opcode_writeback_unit = 7'b0000111;
      selected_reg_value = 20'b0000000000000000;
      pc_fetch_unit = 7'b0000000;
      pc_fetch_wait_unit = 7'b0001000;
      pc_decode_unit = 7'b0001001;
      pc_execute_unit = 7'd88;
      pc_memory_unit = 7'd88;
      pc_memory_wait_unit = 7'd123;
      pc_writeback_unit = 7'd66;
      #5;
      clk = 1'b0;
      rst_n = 1'b1;
      #5;
      rst_n = 1'b0;
      #5;
      rst_n = 1'b1;
    end
  endtask: reset

  initial begin

    // Test 1: reg mode and displays the register value correctly in HEX
    reset;
    is_show_reg_mode = 1;
    reg_select = 4'b0000;
    selected_reg_value = 20'd123456;

    clkR;
    // HEX0 should display 6
    check(display[6], HEX0, 1);
    clkR;
    // HEX1 should display 5
    check(display[5], HEX1, 2);
    clkR;
    // HEX2 should display 4
    check(display[4], HEX2, 3);
    clkR;
    // HEX3 should display 3
    check(display[3], HEX3, 4);
    clkR;
    // HEX4 should display 2
    check(display[2], HEX4, 5);
    clkR;
    // HEX5 should display 1
    check(display[1], HEX5, 6);

    // Test 2: changing the reg_select should reset the display
    reset;
    is_show_reg_mode = 1;
    reg_select = 4'b0001;
    selected_reg_value = 20'd654321;

    for (int i = 0; i < 6; i = i + 1) begin
      clkR;
    end
    // should have something displayed in all 6 HEX
    check(display[1], HEX0, 7);
    check(display[2], HEX1, 8);
    check(display[3], HEX2, 9);
    check(display[4], HEX3, 10);
    check(display[5], HEX4, 11);
    check(display[6], HEX5, 12);
    #5;
    reg_select = 4'b0000;
    #5;
    // should have reset the display
    check(display[10], HEX0, 13);
    check(display[10], HEX1, 14);
    check(display[10], HEX2, 15);
    check(display[10], HEX3, 16);
    check(display[10], HEX4, 17);
    check(display[10], HEX5, 18);

    // Test 3: stage select should display the correct pc
    reset;
    is_show_reg_mode = 0;

    stage_select = 3'b000;
    clkR;
    // HEX0 should display 0
    check(display[0], HEX0, 19);
    clkR;
    // HEX1 should display 0
    check(display[0], HEX1, 20);
    clkR;
    // HEX2 should display 0
    check(display[0], HEX2, 21);
    clkR;
    // HEX3 should display 0
    check(display[0], HEX3, 22);
    clkR;
    // HEX4 should display 0
    check(display[0], HEX4, 23);
    clkR;
    // HEX5 should display 0
    check(display[0], HEX5, 24);

    stage_select = 3'd4;  // mnemory_stage
    #5;
    // should reset the display
    check(display[10], HEX0, 13);
    check(display[10], HEX1, 14);
    check(display[10], HEX2, 15);
    check(display[10], HEX3, 16);
    check(display[10], HEX4, 17);
    check(display[10], HEX5, 18);
    clkR;
    // HEX0 should display 8
    check(display[8], HEX0, 25);
    clkR;
    // HEX1 should display 8
    check(display[8], HEX1, 26);
    clkR;
    // HEX2 should display 0
    check(display[0], HEX2, 27);
    clkR;
    // HEX3 should display 0
    check(display[0], HEX3, 28);
    clkR;
    // HEX4 should display 0
    check(display[0], HEX4, 29);
    clkR;
    // HEX5 should display 0
    check(display[0], HEX5, 30);

    // Test 4: stage select should display the inverted opcode
    reset;
    is_show_reg_mode = 0;

    stage_select = 3'b000; // fetch_stage
    #5;
    check(~opcode_fetch_unit, LEDR, 31);
    stage_select = 3'b001;  // fetch_wait_stage
    #5;
    check(~opcode_fetch_wait_unit, LEDR, 32);
    #5;
    stage_select = 3'b010;  // decode_stage
    #5;
    check(~opcode_decode_unit, LEDR, 33);
    #5;
    stage_select = 3'b011;  // execute_stage
    #5;
    check(~opcode_execute_unit, LEDR, 34);
    #5;
    stage_select = 3'b100;  // memory_stage
    #5;
    check(~opcode_memory_unit, LEDR, 35);
    #5;
    stage_select = 3'b101;  // memory_wait_stage
    #5;
    check(~opcode_memory_wait_unit, LEDR, 36);
    #5;
    stage_select = 3'b110;  // writeback_stage
    #5;
    check(~opcode_writeback_unit, LEDR, 37);

    // Test 4: is not manual clock mode so everythign should be blank
    reset;
    is_show_reg_mode = 0;
    is_manual_clk_mode = 0;
    for (int i = 0; i < 6; i = i + 1) begin
      clkR;
    end
    // HEX display should be blank
    check(display[10], HEX0, 38);
    check(display[10], HEX1, 39);
    check(display[10], HEX2, 40);
    check(display[10], HEX3, 41);
    check(display[10], HEX4, 42);
    check(display[10], HEX5, 43);
    // LEDR should be blank
    check(10'b1111111111, LEDR, 44);

    // show test summary
    if (error_count == 0) begin
        $display("All tests passed!");
    end else begin
        $display("%d tests failed.", error_count);
    end
  end
endmodule : tb_FPGA_interface