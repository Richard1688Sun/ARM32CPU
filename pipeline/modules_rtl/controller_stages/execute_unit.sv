module execute_unit(
    // pipeline_unit signals
    input clk,
    input rst_n,
    input [31:0] instr_in,
    input branch_in,
    input sel_stall,
    output [6:0] opcode,    // Opcode for the instruction TODO: remove later if needed
    output [3:0] rn,        // Rn
    output [3:0] rs,        // Rs
    output [3:0] rm,        // Rm 
    output [4:0] imm5,      // Immediate value
    output branch_value,
    output [31:0] instr_output,
    // controller signals
    input [3:0] rn_memory,                  // from memory stage for forwarding for writeback
    input [3:0] rd_memory,                  // from memory stage for forwarding & stalling
    input [6:0] opcode_memory,              // from memory stage for forwarding & stalling
    input [1:0] sel_w_addr1_memory,               // from memory stage for forwarding replaces the need for P & W
    input [3:0] rt_memory_wait,             // from wait stage for stalling
    input [6:0] opcode_memory_wait,         // from wait stage for stalling
    input [3:0] rt_writeback,               // from writeback stage for forwarding from ldr instructions
    input [6:0] opcode_writeback,           // from writeback stage for forwarding from ldr instructions
    output [1:0] sel_A_in,
    output [1:0] sel_B_in,
    output [1:0] sel_shift_in,
    output sel_shift,
    output en_A,
    output en_B,
    output en_S,
    output stall_pc         // TODO: implment later
);

// pipeline unit ports
wire [3:0] cond_out;
wire [6:0] opcode_out;
wire [3:0] rn_out;
wire [3:0] rs_out;
wire [3:0] rm_out;
wire [4:0] imm5_out;
wire branch_value_out;
wire [31:0] instr_out;
assign opcode = opcode_out;
assign rn = rn_out;
assign rs = rs_out;
assign rm = rm_out;
assign imm5 = imm5_out;
assign branch_value = branch_value_out;
assign instr_output = instr_out;

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

// constants
localparam [31:0] opcode_NOP = 7'b0100000;

// pipeline unit module
execute_pipeline_unit execute_pipeline_unit(
    .clk(clk),
    .rst_n(rst_n),
    .instr_in(instr_in),
    .branch_in(branch_in),
    .sel_stall(sel_stall),
    .cond(cond_out),
    .opcode(opcode_out),
    .rn(rn_out),
    .rs(rs_out),
    .rm(rm_out),
    .imm5(imm5_out),
    .branch_value(branch_value_out),
    .instr_output(instr_out)
);

always_comb begin
    // default values
    sel_A_in_reg = 2'b00;
    sel_B_in_reg = 2'b00;
    sel_shift_in_reg = 2'b00;
    sel_shift_reg = 1'b0;
    en_A_reg = 1'b0;
    en_B_reg = 1'b0;
    en_S_reg = 1'b0;    // always 1 anyway

    // forwarding logic for reg A
    if (opcode_out != opcode_NOP && ((!opcode_out[6] && opcode_out[3:0] != 4'b0000) || opcode_out[6:5] == 2'b11)) begin     // current instruction uses the rn register
        if (opcode_memory != opcode_NOP                                                                                     // memory stage is not NOP and can be checked for forwarding
            && ((sel_w_addr1_memory == 2'b10 && rn_out == rn_memory)                                                        // memory stage is doing pre-indexed writeback
            || (!opcode_memory[6] && rn_out == rd_memory))) begin                                                           // memory stage is doing normal writeback
            sel_A_in_reg = 2'b01;    // forward from result of ALU
        end else if (opcode_writeback != opcode_NOP                                                                        // writeback stage is not NOP and can be checked for forwarding
            && (opcode_writeback[6:4] == 3'b110 || opcode_writeback[6:3] == 4'b1000)                                        // writeback stage is doing LDR or LDR_Lit
            && (rt_writeback == rn_out)) begin                                                                             // writeback stage is writing back to rn
            sel_A_in_reg = 2'b10;    // forward from memory     
        end
    end
    // otherwise default from Rn

    // forwarding logic for reg B
    if ((!opcode_out[6] && opcode_out[4]) || (opcode_out[6:5] == 2'b11 && opcode_out[3]) || (opcode_out[6:2] == 5'b10010 && opcode_out[0])) begin   // current instruction uses the rm reg
        if (opcode_memory != opcode_NOP 
            && ((sel_w_addr1_memory == 2'b10 && rm_out == rn_memory)
            || (!opcode_memory[6] && rm_out == rd_memory))) begin
            sel_B_in_reg = 2'b01;    // forward from result of ALU
        end else if (opcode_writeback != opcode_NOP                                                                   // writeback stage is not NOP and can be checked for forwarding
            && (opcode_writeback[6:4] == 3'b110 || opcode_writeback[6:3] == 4'b1000)                                  // writeback stage is doing LDR or LDR_Lit
            && (rt_writeback == rm_out)) begin                                                                        // writeback stage is writing back to rm
            sel_B_in_reg = 2'b10;    // forward from memory
        end
    end
    // otherwise default from Rm

    // forwarding logic for shift reg
    if (opcode_out[6:4] == 3'b011) begin
        if (opcode_memory != opcode_NOP
            && ((sel_w_addr1_memory == 2'b10 && rs_out == rn_memory) 
            || (!opcode_memory[6] && rs_out == rd_memory))) begin
            sel_shift_in_reg = 2'b01;   // forward from result of ALU
        end else if (opcode_writeback != opcode_NOP                                                                   // writeback stage is not NOP and can be checked for forwarding
            && (opcode_writeback[6:4] == 3'b110 || opcode_writeback[6:3] == 4'b1000)                                  // writeback stage is doing LDR or LDR_Lit
            && (rt_writeback == rs_out)) begin                                                                        // writeback stage is writing back to rs
            sel_shift_in_reg = 2'b10;    // forward from memory
        end
    end
    // otherwise default to Rs

    //normal instructions
    if (opcode_out[6] == 0 && opcode_out[5:4] != 2'b10 && cond_out != 4'b1111)  begin
        //sel_A_in
        //sel_B_in
        //sel_shift and sel_shift_in
        if (opcode_out[4] == 1'b1) begin
            //sel_shift
            sel_shift_reg = opcode_out[5];

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
        if (opcode_out[4] == 1'b1) begin
            en_S_reg = 1'b1;
        end

    end else if (opcode_out[6:5] == 2'b11 || opcode_out[6:3] == 4'b1000) begin //STR and LDR
        
        //immendiate
        if (opcode_out[3] == 1'b0) begin
            // sel_A_in
            if (opcode_out[6:4] == 3'b100) begin //LDR_Lit
                sel_A_in_reg = 2'b11;       //load from PC
            end //otherwise from Rn

            // sel_B_in
            // sel_shift
            // sel_shift_in

            // en_A
            en_A_reg = 1'b1;

            // en_B
            // en_S
        end else begin  //register
            //sel_A_in
            //sel_B_in
            //sel_shift
            sel_shift_reg = 1'b1;

            //sel_shift_in

            //en_A - always from Rn
            en_A_reg = 1'b1;

            //en_B - always from Rm
            en_B_reg = 1'b1;

            //en_S
            en_S_reg = 1'b1;
        end
    end else if (opcode_out[6:3] == 4'b1001) begin  //branching
        // sel_A_in
        if (opcode[0] == 1'b0) begin
            // pc realtive for imm branch
            sel_A_in_reg = 2'b11;
        end

        // sel_shift
        sel_shift_reg = 1'b1;

        // sel_shift_in
        sel_shift_in_reg = 2'b11;

        // en_A

        // en_B
        if (opcode_out[0] == 1'b1) begin
            en_B_reg = 1'b1;
        end

        // en_S
        en_S_reg = 1'b1;
    end
end
endmodule: execute_unit