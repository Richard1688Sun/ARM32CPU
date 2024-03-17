module fetch_wait_unit(
    input clk,
    input rst_n,
    input branch_in,
    output branch_value
);

// pipeline module
fetch_pipeline_unit fetch_pipeline_unit(
    .clk(clk),
    .rst_n(rst_n),
    .branch_in(branch_in),
    .branch_value(branch_value)
);

endmodule: fetch_wait_unit