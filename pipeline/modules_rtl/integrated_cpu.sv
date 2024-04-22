module integrated_cpu(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    // cpu inputs
    reg clk;
    reg rst_n;
    reg sel_instr;
    assign clk = CLOCK_50;
    assign rst_n = KEY[0];
    assign sel_instr = KEY[1];
    assign start_pc = {1'b0, SW};

    // cpu outputs
    wire waiting;
    wire mem_w_en;
    wire [10:0] ram_addr2;
    wire [31:0] ram_in2;
    wire [31:0] status;
    wire [31:0] dp_out;

    // pc outputs
    wire [10:0] pc;

    // duel_ram outputs
    wire [31:0] ram_data1;
    wire [31:0] ram_data2;

    //TODO: remove later
    wire [31:0] reg_output;
    assign LEDR = reg_output[9:0];
    assign HEX0 = (sel_instr == 1'b1) ? ram_data1[6:0] : status[6:0];
    assign HEX1 = (sel_instr == 1'b1) ? ram_data1[13:7] : status[13:7];
    assign HEX2 = (sel_instr == 1'b1) ? ram_data1[20:14] : status[20:14];
    assign HEX3 = (sel_instr == 1'b1) ? ram_data1[27:21] : status[27:21];
    assign HEX4 = (sel_instr == 1'b1) ? ram_data1[31:28] : status[31:28];

    // cpu module
    cpu cpu(
        .clk(clk),
        .rst_n(rst_n),
        .instr(ram_data1),
        .ram_data2(ram_data2),
        .start_pc(11'b0),
        .mem_w_en(mem_w_en),
        .ram_addr2(ram_addr2),
        .ram_in2(ram_in2),
        .status(status),
        .dp_out(dp_out),
        .pc(pc),
        .reg_output(reg_output), .reg_addr(SW[3:0]) //TODO: remove later
    );

    //instruction_memory module
    instr_mem instruction_memory(
        .clock(clk),
        .wren(1'b0),
        .address(pc[6:0]),
        .data(32'b0),
        .q(ram_data1)
    );

    // data_memory module
    data_mem data_memory(
        .clock(clk),
        .wren(mem_w_en),
        .address(ram_addr2[6:0]),
        .data(ram_in2),
        .q(ram_data2)
    );
endmodule: integrated_cpu