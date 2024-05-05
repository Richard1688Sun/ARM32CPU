module datapath(input clk, input [31:0] LR_in, input [1:0] sel_w_addr1,
                input [3:0] rd_memory_unit, input [3:0] rn_memory_unit, input w_en1, input [3:0] w_addr_ldr, input w_en_ldr,                           //regfile write inputs
                input [31:0] w_data_ldr, input [3:0] A_addr, input [3:0] B_addr, input [3:0] shift_addr, input [3:0] str_addr,                     //end of regfile inputs
                input [1:0] sel_pc, input load_pc, input [10:0] start_pc, input [6:0] pc_execute_unit,                                                                      //pc inputs
                input [1:0] sel_A_in, input [1:0] sel_B_in, input [1:0] sel_shift_in,                                   //inputs for forwarding muxes
                input en_A, input en_B, input [31:0] shift_imm, input sel_shift,
                input [1:0] shift_op, input en_S,
                input sel_A, input sel_B, input sel_branch_imm, input sel_pre_indexed, input [31:0] imm12, input [31:0] imm_branch,
                input [2:0] ALU_op, input en_status, input status_rdy,                                                  //datapath inputs
                output [31:0] datapath_out, output [31:0] status_out, output [31:0] str_data, output [6:0] PC,         //datapath outputs
                output [31:0] reg_output, input [3:0] reg_addr);    //TODO: remove later, this is only for testing  
  
    // --- internal wires ---
    //regfile
    wire [31:0] A_data, B_data, shift_data;
    reg [31:0] w_data1;
    reg [3:0] w_addr1;
    wire [10:0] pc_out;
    wire [31:0] reg_output_rf;
    assign PC = pc_out;
    assign reg_output = reg_output_rf;

    //shifter
    wire [31:0] shift_out;
    //register ALU
    wire [31:0] val_A, val_B, ALU_out, shift_amt, status_in, imm_data;
    //forwarding muxes
    reg [31:0] A_in, B_in, shift_in;

    // --- internal regs ---
    reg [31:0] A_reg, B_reg, S_reg, status_out_reg;

    // internal connections
    assign status_out = status_out_reg;

    //internal modules
    regfile regfile(.clk(clk), .w_data1(w_data1), .w_addr1(w_addr1), .w_en1(w_en1),
                    .w_data_ldr(w_data_ldr), .w_addr_ldr(w_addr_ldr), .w_en_ldr(w_en_ldr), 
                    .sel_pc(sel_pc), .load_pc(load_pc), .start_pc(start_pc), .dp_pc(ALU_out[10:0]),
                    .A_addr(A_addr), .B_addr(B_addr), .shift_addr(shift_addr), .str_addr(str_addr),
                    .A_data(A_data), .B_data(B_data), .shift_data(shift_data), .str_data(str_data), .pc_out(pc_out),
                    .reg_output(reg_output_rf), .reg_addr(reg_addr));   //TODO: remove later
    shifter shifter(.shift_in(B_reg), .shift_op(shift_op), .shift_amt(S_reg), .shift_out(shift_out));
    ALU alu(.val_A(val_A), .val_B(val_B), .ALU_op(ALU_op), .ALU_out(ALU_out), .flags(status_in));
    status_reg_block status_reg(.clk(clk), .en_status(en_status), .status_rdy(status_rdy), .status_in(status_in), .status_out(status_out_reg));

    //muxes
    assign datapath_out = (sel_pre_indexed == 1'b1) ? val_A : ALU_out;
    assign val_A = (sel_A == 1'b1) ? 31'b0 : A_reg;
    assign val_B = (sel_B == 1'b1) ? imm_data : shift_out; 
    assign imm_data = (sel_branch_imm == 1'b1) ? imm_branch : imm12;
    assign shift_amt = (sel_shift == 1'b1) ? shift_in: shift_imm;

    // w_data1
    always_comb begin
        case (sel_w_addr1)
        2'b01: w_data1 = LR_in;
        default: w_data1 = ALU_out;
        endcase
    end

    // w_addr1_in
    always_comb begin
        case (sel_w_addr1)
        2'b00: w_addr1 = rd_memory_unit;
        2'b01: w_addr1 = 4'd14;
        2'b10: w_addr1 = rn_memory_unit;
        default: w_addr1 = rd_memory_unit;
        endcase
    end
    
    //A_in mux
    always_comb begin
        case (sel_A_in)
            2'b00: A_in = A_data;
            2'b01: A_in = ALU_out;
            2'b10: A_in = w_data_ldr;
            2'b11: A_in = {25'd0, pc_execute_unit};
            default: A_in = A_data;
        endcase
    end
    // B_in mux
    always_comb begin
        case (sel_B_in)
            2'b00: B_in = B_data;
            2'b01: B_in = ALU_out;
            2'b10: B_in = w_data_ldr;
            2'b11: B_in = val_B;
            default: B_in = B_data;
        endcase
    end
    //shift_in mux
    always_comb begin
        case (sel_shift_in)
            2'b00: shift_in = shift_data;
            2'b01: shift_in = ALU_out;
            2'b10: shift_in = w_data_ldr;
            2'b11: shift_in = 32'b0;
            default: shift_in = shift_data;
        endcase
    end

    //register A
    always_ff @(posedge clk) begin
        if (en_A == 1'b1) begin
            A_reg <= A_in;
        end
    end

    //register B
    always_ff @(posedge clk) begin
        if (en_B == 1'b1) begin
            B_reg <= B_in;
        end
    end

    //register S
    always_ff @(posedge clk) begin
        if (en_S == 1'b1) begin
            S_reg <= shift_amt;
        end
    end
endmodule: datapath
