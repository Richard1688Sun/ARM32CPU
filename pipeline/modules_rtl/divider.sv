module divider (
  input clk,
  input rst_n,
  input [19:0] divider_in,
  output [19:0] divider_out
);

// internal signals
reg [19:0] divider_reg;
assign divider_out = divider_reg;

// divider module
always @(posedge clk or negedge rst_n) begin
  if (~rst_n) begin
    divider_reg <= 20'd0;
  end else begin
    divider_reg <= divider_in / 10;
  end
end
endmodule : divider