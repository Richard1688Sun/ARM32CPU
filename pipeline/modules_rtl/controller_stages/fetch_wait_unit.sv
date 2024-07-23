module fetch_wait_unit(
    input clk,
    input rst_n,
    input branch_in,
    input [6:0] pc_in,
    output branch_value,
    output [6:0] pc_out
);

// pipeline module
fetch_pipeline_unit fetch_pipeline_unit(
    .clk(clk),
    .rst_n(rst_n),
    .branch_in(branch_in),
    .pc_in(pc_in),
    .branch_value(branch_value),
    .pc_out(pc_out)
);

endmodule: fetch_wait_unit