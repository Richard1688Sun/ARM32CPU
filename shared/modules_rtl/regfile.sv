module regfile(input clk, input [31:0] w_data1, input [3:0] w_addr1, input w_en1,
            input [31:0] w_data_ldr, input [3:0] w_addr_ldr, input w_en_ldr,
            input [3:0] A_addr, input [3:0] B_addr, input [3:0] shift_addr, input [3:0] str_addr,
            input [1:0] sel_pc, input load_pc, input [10:0] start_pc, input [10:0] dp_pc,
            output [31:0] A_data, output [31:0] B_data, output [31:0] shift_data, output [31:0] str_data, output [6:0] pc_out,
            output [31:0] reg_output, input [3:0] reg_addr);

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

    reg [31:0] registeres[0:14];
    reg [6:0] pc_register;
    wire [10:0] pc_in;

    // read is combinational
    assign A_data = registeres[A_addr];
    assign B_data = registeres[B_addr];
    assign shift_data = registeres[shift_addr];
    assign str_data = registeres[str_addr];
    assign pc_out = pc_register;
    assign pc_in = pc_out + 1;
    assign reg_output = (reg_addr == 4'd15)? pc_register : registeres[reg_addr]; //TODO: remove later, this is only for testing

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
endmodule: regfile
