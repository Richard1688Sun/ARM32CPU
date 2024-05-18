module inverter (
  input [6:0] in,
  output [6:0] out
);

reg [7:0] out_reg;
assign out = out_reg;

always_comb begin
  out_reg = ~in;
end

endmodule : inverter