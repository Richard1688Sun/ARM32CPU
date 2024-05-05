module instruction_queue(
    input clk,
    input rst_n,
    input [31:0] instr_in,
    input is_enqueue,
    output [31:0] instr_out,
    output is_empty
);

// registers
reg [31:0] q1_reg, q2_reg;
reg q1_filled_reg, q2_filled_reg;

// internal signals
wire sel_q1;
assign sel_q1 = q1_filled_reg & ~q2_filled_reg;

// outputs
assign instr_out = (sel_q1 == 1'b1) ? q1_reg : q2_reg;
assign is_empty = ~(q1_filled_reg | q2_filled_reg);

// q1 register
always_ff@(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        q1_reg <= 32'h0;
        q1_filled_reg <= 1'b0;
    end else begin
        q1_reg <= instr_in;
        q1_filled_reg <= 1'b1;
        // otherwise q1_reg keeps its value

        q1_filled_reg <= is_enqueue;
    end
end

// q2 register
always_ff@(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        q2_reg <= 32'h0;
        q2_filled_reg <= 1'b0;
    end else begin
        q2_reg <= q1_reg;
        // otherwise q2_reg keeps its value

        // squash the q1_filled_reg when we are dequeuing and q1 is selected
        q2_filled_reg <= q1_filled_reg & (is_enqueue | ~sel_q1);
    end
end
endmodule: instruction_queue