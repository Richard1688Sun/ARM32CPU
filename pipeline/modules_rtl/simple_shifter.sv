module simple_shifter(
  input clk,
  input rst_n,
  input [3:0] shift_in,
  output [3:0] shift_out
);

// internal signals
reg [3:0] shift_reg;
assign shift_out = shift_reg;

// shifter module
always @(posedge clk or negedge rst_n) begin
  if (~rst_n) begin
    shift_reg <= 4'd0;
  end else begin
    shift_reg <= shift_in >> 1;
  end
end
endmodule : simple_shifter