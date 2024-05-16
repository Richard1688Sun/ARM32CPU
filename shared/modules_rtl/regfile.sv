module regfile(
    input clk, 

    // normal registers
    input [31:0] w_data1, 
    input [3:0] w_addr1, 
    input w_en1,
    input [31:0] w_data_ldr, 
    input [3:0] w_addr_ldr, 
    input w_en_ldr,
    input [3:0] A_addr, 
    input [3:0] B_addr, 
    input [3:0] shift_addr, 
    input [3:0] str_addr,
    output [31:0] A_data, 
    output [31:0] B_data, 
    output [31:0] shift_data, 
    output [31:0] str_data,

    // pc signals
    input [1:0] sel_pc, 
    input load_pc, 
    input [6:0] start_pc, 
    input [6:0] dp_pc,
    output [6:0] pc_out,

    // status register signals
    input en_status,
    input [31:0] status_in,
    output [31:0] status_out,

    // FPGA interface
    output [31:0] reg_output, 
    input [4:0] reg_addr
);

    /*
    *** About ***
    - 16 regsiteres 32 bits each
    - 4 bits for address
    - 32 bits for data
    - read is combinational
    - write is sequential

    *** Registers ***
    R0 - General Purpose
    R1 - General Purpose
    R2 - General Purpose
    R3 - General Purpose
    R4 - General Purpose
    R5 - General Purpose
    R6 - General Purpose
    R7 - Holds System Call Number
    R8 - General Purpose
    R9 - General Purpose
    R10 - General Purpose
    R11 - Frame Pointer (FP)
    R12 - Intra Procedural Call (IP)
    R13 - Stack Pointer (SP)
    R14 - Link Register (LR)
    R15 - Program Counter (PC)

    --- Removed to be direct output of datapath ---
    R16 - Status Register (SR)
    */

    // registers
    reg [31:0] registeres[0:14];
    reg [6:0] pc_register;
    reg [31:0] status_reg;
    assign status_out = status_reg;

    // internal connections
    reg [31:0] selected_register;
    wire [6:0] pc_in;

    // read is combinational
    assign A_data = registeres[A_addr];
    assign B_data = registeres[B_addr];
    assign shift_data = registeres[shift_addr];
    assign str_data = registeres[str_addr];
    assign pc_out = pc_register;
    assign pc_in = pc_out + 7'd1;
    assign reg_output = (reg_addr == 4'd15)? pc_register : registeres[reg_addr]; //TODO: remove later, this is only for testing

    // selected register MUX
    always_comb begin
        case (reg_addr)
            5'd0: selected_register = registeres[0];
            5'd1: selected_register = registeres[1];
            5'd2: selected_register = registeres[2];
            5'd3: selected_register = registeres[3];
            5'd4: selected_register = registeres[4];
            5'd5: selected_register = registeres[5];
            5'd6: selected_register = registeres[6];
            5'd7: selected_register = registeres[7];
            5'd8: selected_register = registeres[8];
            5'd9: selected_register = registeres[9];
            5'd10: selected_register = registeres[10];
            5'd11: selected_register = registeres[11];
            5'd12: selected_register = registeres[12];
            5'd13: selected_register = registeres[13];
            5'd14: selected_register = registeres[14];
            5'd15: selected_register = pc_register;
            5'd16: selected_register = status_reg;
            default: selected_register = 32'd0; // register DNE
        endcase
    end

    // write is sequential
    always_ff @(posedge clk) begin
        if (w_en1 == 1'b1 && w_addr1 != 4'd15) begin
            registeres[w_addr1] = w_data1;
        end

        if (w_en_ldr == 1'b1 && w_addr_ldr != 4'd15) begin
            registeres[w_addr_ldr] = w_data_ldr;
        end
    end

    // PC register
    always_ff @(posedge clk) begin
        if (load_pc == 1'b1) begin
            case (sel_pc)
                2'b01: begin
                    pc_register <= start_pc;
                end
                2'b11: begin
                    pc_register <= dp_pc;
                end
                default: pc_register <= pc_in;
            endcase
        end
        // otherwise keep the original value
    end

    // status register
    always_ff @(posedge clk) begin
        if (en_status == 1'b1) begin
            status_reg <= status_in;
        end
    end
endmodule: regfile
