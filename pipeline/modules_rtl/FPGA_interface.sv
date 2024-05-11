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
  input [19:0] selected_reg_value,
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

  // output registers
  reg [6:0] HEX0_out;
  reg [6:0] HEX1_out;
  reg [6:0] HEX2_out;
  reg [6:0] HEX3_out;
  reg [6:0] HEX4_out;
  reg [6:0] HEX5_out;
  reg [9:0] LEDR_out;
  assign HEX0 = HEX0_out;
  assign HEX1 = HEX1_out;
  assign HEX2 = HEX2_out;
  assign HEX3 = HEX3_out;
  assign HEX4 = HEX4_out;
  assign HEX5 = HEX5_out;
  assign LEDR = LEDR_out;

  // state registers
  reg is_show_reg_mode;
  assign is_show_reg_mode = SW[9];
  reg [2:0] state;
  reg [9:0] prev_SW;

  // internal signals
  reg [19:0] target_value;
  reg [6:0] selected_pc;
  assign target_value = (is_show_reg_mode == 1'b1) ? selected_reg_value : {13'd0, selected_pc};

  // divider module
  reg [19:0] divider_in;
  wire [19:0] divider_out;
  assign divider_in = (state == 3'd0) ? target_value : divider_out;

  // inverter module
  reg [6:0] inverter_in;
  wire [6:0] selected_opcode;

  // remainder singals
  wire [3:0] remainder;
  assign remainder = divider_out % 10;

  // divider module
  divider divider (
    .clk(clk),
    .rst_n(rst_n),
    .divider_in(divider_in),
    .divider_out(divider_out)
  );

  // inverter module
  inverter inverter (
    .in(inverter_in),
    .out(selected_opcode)
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
      default: selected_pc = 7'b0;
    endcase
  end

  // selected_opcode mux
  always_comb begin
    case (SW[2:0])
      3'b000: inverter_in = opcode_fetch_unit;
      3'b001: inverter_in = opcode_fetch_wait_unit;
      3'b010: inverter_in = opcode_decode_unit;
      3'b011: inverter_in = opcode_execute_unit;
      3'b100: inverter_in = opcode_memory_unit;
      3'b101: inverter_in = opcode_memory_wait_unit;
      3'b110: inverter_in = opcode_writeback_unit;
      default: inverter_in = 7'b0;
    endcase
  end

  // logic for HEX display
  always_ff @(posedge clk or negedge rst_n or SW) begin
    if (~rst_n) begin
      state <= 3'b000;
      prev_SW <= SW;
      // set everything to blank
      HEX0_out = 7'b1111111;
      HEX1_out = 7'b1111111;
      HEX2_out = 7'b1111111;
      HEX3_out = 7'b1111111;
      HEX4_out = 7'b1111111;
      HEX5_out = 7'b1111111;
    end else if (SW != prev_SW) begin
      // when something resets we want to recompute the values
      state <= 3'b000;
      prev_SW <= SW;
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
          HEX0_out = display[target_value % 10];
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
          state <= 3'b110;
          HEX5_out = display[remainder];
        end
        default: state <= state;
      endcase
    end
  end

  always_comb begin
    if (is_show_reg_mode == 1'b1) begin
      LEDR_out = 10'b1111111111;
    end else begin
      // need to inver the signal
      LEDR_out = selected_opcode;
    end
  end
endmodule : FPGA_interface
