module memory_wait_pipeline_unit(
    // inputs
    input clk,
    input rst_n,
    input [31:0] instr_in,
    // outputs
    output [31:0] instr_output
);
// internal signals
localparam [31:0] NOP = 32'b1110_00110010_0000_11110000_00000000;
reg [31:0] instr_reg;

// module outputs
assign instr_output = instr_reg;

// mux
assign instr_decoder_in = instr_reg;

// instruction register
always_ff @( posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        instr_reg <= NOP;
    end else begin
        instr_reg <= instr_in;
    end
end
endmodule: memory_wait_pipeline_unit