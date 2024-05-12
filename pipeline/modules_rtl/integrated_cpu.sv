module integrated_cpu(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    // cpu inputs
    reg clk;
    reg rst_n;
    reg sel_instr;
    reg [31:0] instr_in;
    assign clk = (SW[9] == 1'd1)? ~KEY[0]: CLOCK_50; //TODO: might be active low
    assign rst_n = KEY[1];

    // cpu outputs
    wire waiting;
    wire mem_w_en;
    wire [6:0] ram_addr2;
    wire [31:0] ram_in2;
    wire [31:0] status;
    wire [6:0] pc;
    wire [6:0] pc_fetch_unit;
    wire [6:0] pc_fetch_wait_unit;
    wire [6:0] pc_decode_unit;
    wire [6:0] pc_execute_unit;
    wire [6:0] pc_memory_unit;
    wire [6:0] pc_memory_wait_unit;
    wire [6:0] pc_writeback_unit;
    wire [6:0] opcode_fetch_unit;
    wire [6:0] opcode_fetch_wait_unit;
    wire [6:0] opcode_decode_unit;
    wire [6:0] opcode_execute_unit;
    wire [6:0] opcode_memory_unit;
    wire [6:0] opcode_memory_wait_unit;
    wire [6:0] opcode_writeback_unit;
    wire [31:0] reg_output;
    wire load_pc;

    // instruction queue inputs
    wire is_enqueue;
    assign is_enqueue = ~load_pc;
    // instruction queue outputs
    wire [31:0] instr_queued;
    wire is_empty;

    // memory outputs
    wire [31:0] ram_data1;
    wire [31:0] ram_data2;

    // FPGA interface
    FPGA_interface FPGA_interface(
        .clk(CLOCK_50),
        .rst_n(rst_n),
        .pc_fetch_unit(pc_fetch_unit),
        .pc_fetch_wait_unit(pc_fetch_wait_unit),
        .pc_decode_unit(pc_decode_unit),
        .pc_execute_unit(pc_execute_unit),
        .pc_memory_unit(pc_memory_unit),
        .pc_memory_wait_unit(pc_memory_wait_unit),
        .pc_writeback_unit(pc_writeback_unit),
        .opcode_fetch_unit(opcode_fetch_unit),
        .opcode_fetch_wait_unit(opcode_fetch_wait_unit),
        .opcode_decode_unit(opcode_decode_unit),
        .opcode_execute_unit(opcode_execute_unit),
        .opcode_memory_unit(opcode_memory_unit),
        .opcode_memory_wait_unit(opcode_memory_wait_unit),
        .opcode_writeback_unit(opcode_writeback_unit),
        .selected_register(reg_output),
        .status_register(status),
        .SW(SW),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3),
        .HEX4(HEX4),
        .HEX5(HEX5),
        .LEDR(LEDR)
    );

    // cpu module
    cpu cpu(
        .clk(clk),
        .rst_n(rst_n),
        .instr(instr_in),
        .ram_data2(ram_data2),
        .start_pc(7'b0),
        .mem_w_en(mem_w_en),
        .ram_addr2(ram_addr2),
        .ram_in2(ram_in2),
        .status(status),
        .pc(pc),
        .load_pc(load_pc),
        .pc_fetch_unit(pc_fetch_unit),
        .pc_fetch_wait_unit(pc_fetch_wait_unit),
        .pc_decode_unit(pc_decode_unit),
        .pc_execute_unit(pc_execute_unit),
        .pc_memory_unit(pc_memory_unit),
        .pc_memory_wait_unit(pc_memory_wait_unit),
        .pc_writeback_unit(pc_writeback_unit),
        .opcode_fetch_unit(opcode_fetch_unit),
        .opcode_fetch_wait_unit(opcode_fetch_wait_unit),
        .opcode_decode_unit(opcode_decode_unit),
        .opcode_execute_unit(opcode_execute_unit),
        .opcode_memory_unit(opcode_memory_unit),
        .opcode_memory_wait_unit(opcode_memory_wait_unit),
        .opcode_writeback_unit(opcode_writeback_unit),
        .reg_output(reg_output), 
        .reg_addr(SW[7:3])
    );

    instruction_queue instruction_queue(
        .clk(clk),
        .rst_n(rst_n),
        .instr_in(ram_data1),
        .is_enqueue(is_enqueue),
        .instr_out(instr_queued),
        .is_empty(is_empty)
    );

    //instruction_memory module
    instr_mem instruction_memory(
        .clock(clk),
        .wren(1'b0),
        .address(pc),        
        .data(32'b0),
        .q(ram_data1)
    );

    // data_memory module
    data_mem data_memory(
        .clock(clk),
        .wren(mem_w_en),
        .address(ram_addr2),
        .data(ram_in2),
        .q(ram_data2)
    );

    // logic for instr_in
    always_comb begin
        instr_in = (is_empty) ? ram_data1 : instr_queued;
    end
endmodule: integrated_cpu