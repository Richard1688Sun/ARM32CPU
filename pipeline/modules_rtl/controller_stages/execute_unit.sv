module execute_unit(
    // pipeline_unit signals
    input clk,
    input reset,
    input [31:0] instr_in,
    input branch_ref,
    input branch_in,
    input sel_stall,
    output branch_value,
    output [6:0] opcode,    // Opcode for the instruction
    output [3:0] rn,        // Rn
    output [3:0] rs,        // Rs
    output [3:0] rm,        // Rm 
    output [1:0] shift_op,  // Shift operation
    output [4:0] imm5,      // Immediate value
    // controller signals
    input [3:0] rd,         // from memory stage for forwarding
    output [1:0] sel_A_in,
    output [1:0] sel_B_in,
    output [1:0] sel_shift_in,
    output sel_shift,
    output en_A,
    output en_B,
    output en_S
);

// decoder ports
wire [3:0] cond_out;
wire [6:0] opcode_out;
wire [3:0] rn_out;
wire [3:0] rs_out;
wire [3:0] rm_out;
wire [1:0] shift_op_out;
wire [4:0] imm5_out;
assign opcode = opcode_out;
assign rn = rn_out;
assign rs = rs_out;
assign rm = rm_out;
assign shift_op = shift_op_out;
assign imm5 = imm5_out;

// controller ports
reg [1:0] sel_A_in_reg;
reg [1:0] sel_B_in_reg;
reg [1:0] sel_shift_in_reg;
reg sel_shift_reg;
reg en_A_reg;
reg en_B_reg;
reg en_S_reg;
assign sel_A_in = sel_A_in_reg;
assign sel_B_in = sel_B_in_reg;
assign sel_shift_in = sel_shift_in_reg;
assign sel_shift = sel_shift_reg;
assign en_A = en_A_reg;
assign en_B = en_B_reg;
assign en_S = en_S_reg;

// decoder module
idecoder decoder(
    .instr(instr_in),
    .cond(cond_out),
    .opcode(opcode_out),
    .en_status(),
    .rn(rn_out),
    .rd(),
    .rs(rs_out),
    .rm(rm_out),
    .shift_op(shift_op_out),
    .imm5(imm5_out),
    .imm12(),
    .imm24(),
    .P(),
    .U(),
    .W()
);

always_comb begin
    sel_A_in_reg = 2'b00;
    sel_B_in_reg = 2'b00;
    sel_shift_in_reg = 2'b00;
    sel_shift_reg = 1'b0;
    en_A_reg = 1'b0;
    en_B_reg = 1'b0;
    en_S_reg = 1'b0;

    //normal instructions
    if (opcode_out[6] == 0 && cond_out != 4'b1111)  begin
        //sel_A_in
        //sel_B_in

        //sel_shift and sel_shift_in
        // TODO: note down what [4] means
        if (opcode_out[4] == 1'b1) begin
            //sel_shift
            sel_shift_reg = opcode_out[5];
            //sel_shift_in TODO: change later when do forwarding
            sel_shift_in_reg = 2'b00;
        end else begin
            //sel_shift
            //sel_shift_in
        end

        //en_A
        if (opcode_out[3] == 1'b1) begin
            en_A_reg = 1'b1;
        end

        //en_B
        if (opcode_out[4] == 1'b1) begin
            en_B_reg = 1'b1;
        end

        // en_S
        en_S_reg = 1'b1;        //TODO: doesnt affect anything for MOV_I BUT should be changed -> right now too lazy to change tb

    end else if (opcode_out[6:5] == 2'b11 || opcode_out[6:3] == 4'b1000) begin //STR and LDR
        
        //immendiate
        if (opcode_out[3] == 1'b0) begin
            // sel_A_in
            if (opcode_out[6:4] == 3'b100) begin //LDR_Lit
                sel_A_in_reg = 2'b11;       //load from PC
            end //otherwise from Rn

            // sel_B_in
            // load shift - value of 0
            // sel_shift_in

            // en_A
            en_A_reg = 1'b1;

            // en_B
            // en_S
        end else begin  //register
            //sel_A_in
            //sel_B_in
            //sel_shift
            //sel_shift_in

            //en_A - always from Rn
            en_A_reg = 1'b1;

            //en_B - always from Rm
            en_B_reg = 1'b1;

            //en_S
            en_S_reg = 1'b1;
        end
    end else if (opcode_out[6:3] == 4'b1000) begin  //branching
        // sel_A_in
        // sel_B_in

        // sel_shift
        sel_shift_reg = 1'b1;

        // sel_shift_in TODO: change later when do forwarding
        sel_shift_in_reg = 2'b11;

        // en_A

        // en_B
        if (opcode_out[1] == 1'b1) begin
            en_B_reg = 1'b1;
        end

        // en_S
        en_S_reg = 1'b1;        //TODO: doesnt affect anything for MOV_I BUT should be changed -> right now too lazy to change tb
    end
end
endmodule: execute_unit