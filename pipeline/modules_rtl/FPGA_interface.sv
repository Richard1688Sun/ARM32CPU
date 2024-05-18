module FPGA_interface(
  input clk,
  input rst_n,
  input [6:0] pc_fetch_unit,
  input [6:0] pc_fetch_wait_unit,
  input [6:0] pc_decode_unit,
  input [6:0] pc_execute_unit,
  input [6:0] pc_memory_unit,
  input [6:0] pc_memory_wait_unit,
  input [6:0] pc_writeback_unit,
  input [6:0] opcode_fetch_unit,
  input [6:0] opcode_fetch_wait_unit,
  input [6:0] opcode_decode_unit,
  input [6:0] opcode_execute_unit,
  input [6:0] opcode_memory_unit,
  input [6:0] opcode_memory_wait_unit,
  input [6:0] opcode_writeback_unit,
  input [31:0] selected_register,
  input [31:0] status_register,
  input [9:0] SW,
  output [6:0] HEX0,
  output [6:0] HEX1,
  output [6:0] HEX2,
  output [6:0] HEX3,
  output [6:0] HEX4,
  output [6:0] HEX5,
  output [9:0] LEDR
);

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

  // state registers
  reg is_show_reg_mode;
  assign is_show_reg_mode = SW[8];    // might be active low
  reg is_manual_clk_mode;
  assign is_manual_clk_mode = SW[9];  // might be active low
  reg [2:0] state;
  reg [9:0] prev_SW;
  reg rst_n_sw;

  // output registers
  reg [6:0] HEX0_out;
  reg [6:0] HEX1_out;
  reg [6:0] HEX2_out;
  reg [6:0] HEX3_out;
  reg [6:0] HEX4_out;
  reg [6:0] HEX5_out;
  reg [9:0] LEDR_out;
  assign HEX0 = (is_manual_clk_mode == 1'd1) ? HEX0_out : 7'b1111111;
  assign HEX1 = (is_manual_clk_mode == 1'd1) ? HEX1_out : 7'b1111111;
  assign HEX2 = (is_manual_clk_mode == 1'd1) ? HEX2_out : 7'b1111111;
  assign HEX3 = (is_manual_clk_mode == 1'd1) ? HEX3_out : 7'b1111111;
  assign HEX4 = (is_manual_clk_mode == 1'd1) ? HEX4_out : 7'b1111111;
  assign HEX5 = (is_manual_clk_mode == 1'd1) ? HEX5_out : 7'b1111111;
  assign LEDR = (is_manual_clk_mode == 1'd1) ? LEDR_out : 10'b1111111111;

  // internal signals
  reg [19:0] target_value;
  reg [6:0] selected_pc;
  reg [19:0] combined_register;
  assign combined_register = selected_register[19:0];
  assign target_value = (is_show_reg_mode == 1'b1) ? combined_register : {13'd0, selected_pc};

  // divider module
  reg [19:0] divider_in;
  wire [19:0] divider_out;
  assign divider_in = (state == 3'd0) ? target_value : divider_out;

  // simple shifter module
  reg [3:0] shift_in;
  wire [3:0] shift_out;
  assign shift_in = (state == 3'd0) ? status_register[31:28] : shift_out;

  // inverter module
  reg [6:0] selected_opcode;

  // remainder singals
  wire [3:0] remainder;
  assign remainder = (SW[7:3] == 5'b10000) ? shift_out & 4'b0001: divider_out % 10;

  // divider module
  divider divider (
    .clk(clk),
    .rst_n(rst_n),
    .divider_in(divider_in),
    .divider_out(divider_out)
  );

  // simple shifter module -> for status register showing
  simple_shifter simple_shifter (
    .clk(clk),
    .rst_n(rst_n),
    .shift_in(shift_in),
    .shift_out(shift_out)
  );

  // selected_pc mux
  always_comb begin
    case (SW[2:0])
      3'b000: selected_pc = pc_fetch_unit;
      3'b001: selected_pc = pc_fetch_wait_unit;
      3'b010: selected_pc = pc_decode_unit;
      3'b011: selected_pc = pc_execute_unit;
      3'b100: selected_pc = pc_memory_unit;
      3'b101: selected_pc = pc_memory_wait_unit;
      3'b110: selected_pc = pc_writeback_unit;
      default: selected_pc = 7'b0100000;
    endcase
  end

  // selected_opcode mux
  always_comb begin
    case (SW[2:0])
      3'b000: selected_opcode = opcode_fetch_unit;
      3'b001: selected_opcode = opcode_fetch_wait_unit;
      3'b010: selected_opcode = opcode_decode_unit;
      3'b011: selected_opcode = opcode_execute_unit;
      3'b100: selected_opcode = opcode_memory_unit;
      3'b101: selected_opcode = opcode_memory_wait_unit;
      3'b110: selected_opcode = opcode_writeback_unit;
      default: selected_opcode = 7'b0;
    endcase
  end

  // logic for reseting the state when switch changes
  always_comb begin
    rst_n_sw = (SW == prev_SW || state == 3'b000) ? 1'b1 : 1'b0;
  end

  // logic for HEX display
  always_ff @(posedge clk or negedge rst_n or negedge rst_n_sw) begin
    if (~rst_n || ~rst_n_sw) begin
      state <= 3'b000;
      prev_SW <= 10'd0;
      // set everything to blank
      HEX0_out = 7'b1111111;
      HEX1_out = 7'b1111111;
      HEX2_out = 7'b1111111;
      HEX3_out = 7'b1111111;
      HEX4_out = 7'b1111111;
      HEX5_out = 7'b1111111;
    end else begin
      case (state)
        3'b000: begin
          state <= 3'b001;
          prev_SW <= SW;
          HEX0_out = (SW[7:3] == 5'b10000) ? display[shift_in & 4'b0001] : display[divider_in % 10];
        end
        3'b001: begin
          state <= 3'b010;
          HEX1_out = display[remainder];
        end
        3'b010: begin
          state <= 3'b011;
          HEX2_out = display[remainder];
        end
        3'b011: begin
          state <= 3'b100;
          HEX3_out = display[remainder];
        end
        3'b100: begin
          state <= 3'b101;
          HEX4_out = display[remainder];
        end
        3'b101: begin
          state <= 3'b000;
          HEX5_out = display[remainder];
        end
        default: state <= state;
      endcase
    end
  end

  always_comb begin
    if (is_show_reg_mode == 1'b1) begin
      LEDR_out = 10'b0000000000;
    end else begin
      // need to inver the signal
      LEDR_out = {3'b000, selected_opcode};
    end
  end
endmodule : FPGA_interface
