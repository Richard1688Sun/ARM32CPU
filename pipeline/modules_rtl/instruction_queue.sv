module instruction_queue(
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
reg instr_out;
assign instr_out = (sel_q1 == 1'b1) ? q1_reg : q2_reg;
assign is_empty = ~(q1_filled_reg | q2_filled_reg);

// q1 register
always_ff@(posedge clk) begin
    if (is_enqueue == 1'b1) begin
        q1_reg <= instr_in;
        q1_filled_reg <= 1'b1;
    end
    // otherwise q1_reg keeps its value

    q1_filled_reg <= is_enqueue;
end

// q2 register
always_ff@(posedge clk) begin
    if (is_enqueue == 1'b1) begin
        q2_reg <= q1_reg;
    end
    // otherwise q2_reg keeps its value

    // squash the q1_filled_reg when we are dequeuing and q1 is selected
    q2_filled_reg <= q1_filled_reg & (is_enqueue | ~sel_q1);
    // otherwise q2_filled_reg keeps its value
end
endmodule: instruction_queue