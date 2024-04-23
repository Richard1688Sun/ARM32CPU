module fetch_pipeline_unit(
    // pipeline signals
    input clk,
    input rst_n,
    input branch_in,
    output branch_value
    // controller signals
    // NOTHING for now
);
// pipeline unit ports
reg branch_value_reg;
assign branch_value = branch_value_reg;

always_ff @( posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        branch_value_reg <= 1'b1; // pass the value of 1 to the first stage load_pc_start to squash the instruction
    end else begin
        branch_value_reg <= branch_in;
    end
end

endmodule: fetch_pipeline_unit