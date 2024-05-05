module decoder_pipeline_unit(
    input clk,
    input rst_n,
    input [6:0] pc_in,
    input [31:0] instr_in,
    output [31:0] instr_out,
    output [6:0] pc_out
);

// internal signals
reg [6:0] pc_reg;
assign pc_out = pc_reg;

// outputs
assign instr_out = instr_in;

always_ff @( posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        pc_reg <= 7'd0;
    end else begin
        pc_reg <= pc_in;
    end
end
endmodule: decoder_pipeline_unit