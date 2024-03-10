module memory_unit(
    // pipeline signals
    input clk,
    input rst_n,
    input [31:0] instr_in,
    input branch_ref,
    input branch_in,
    input sel_stall,
    output [3:0] cond,      // Condition code               TODO: remove later if needed
    output [6:0] opcode,    // Opcode for the instruction   TODO: remove later if needed
    output [3:0] rd,        // Rd (destination)
    output [1:0] shift_op,  // Shift operation
    output [11:0] imm12,    // Immediate value or second operand
    output [31:0] imm_branch,    // Address for branching
    output branch_value,
    output [31:0] instr_output,
    // controller signals
    input [31:0] status_reg,
    output [1:0] sel_pc,
    output load_pc,
    output sel_branch_imm,
    output sel_A,
    output sel_B,
    output [2:0] ALU_op,
    output sel_pre_indexed,
    output en_status,
    output sel_load_LR,
    output w_en1,
    output mem_w_en,
    // global branch reference
    output branch_ref_global,
);

// pipeline unit ports
wire [3:0] cond_decoded;
wire [6:0] opcode_decoded;
wire en_status_decoded;
wire [3:0] rd_out;
wire [1:0] shift_op_out;
wire [11:0] imm12_out;
wire [31:0] imm_branch_out;
wire P;
wire U;
wire W;
wire [31:0] instr_out;
assign cond = cond_decoded;
assign opcode = opcode_decoded;
assign rd = rd_out;
assign shift_op = shift_op_out;
assign imm12 = imm12_out;
assign imm_branch = imm_branch_out;
assign instr_output = instr_out;

// brnach reference MUX
reg branch_ref_value;   // output from pipeline unit used to select next branch_ref
reg branch_value_out;
assign branch_value = branch_value_out; //TODO: within controller logic we change branch_ref_reg to either branch_value or ~branch_value

// controller ports
reg [1:0] sel_pc_reg;
reg load_pc_reg;
reg sel_branch_imm_reg;
reg sel_A_reg;
reg sel_B_reg;
reg [2:0] ALU_op_reg;
reg en_status_reg;
reg sel_pre_indexed_reg;
reg sel_load_LR_reg;
reg w_en1_reg;
reg mem_w_en_reg;
assign sel_pc = sel_pc_reg;
assign load_pc = load_pc_reg;
assign sel_branch_imm = sel_branch_imm_reg;
assign sel_A = sel_A_reg;
assign sel_B = sel_B_reg;
assign ALU_op = ALU_op_reg;
assign en_status = en_status_reg;
assign sel_pre_indexed = sel_pre_indexed_reg;
assign sel_load_LR = sel_load_LR_reg;
assign w_en1 = w_en1_reg;
assign mem_w_en = mem_w_en_reg;

// branch reference global
reg branch_ref_global_reg;
assign branch_ref_global = branch_ref_global_reg;

// status bits
wire N;
wire Z;
wire C;
wire V;
assign N = status_reg[31];
assign Z = status_reg[30];
assign C = status_reg[29];
assign V = status_reg[28];

// localparam for ALU_op
localparam [2:0] ADD = 3'b000;
localparam [2:0] SUB = 3'b001;
localparam [2:0] AND = 3'b010;
localparam [2:0] ORR = 3'b011;
localparam [2:0] XOR = 3'b111;

// localparam for CMP
localparam [3:0] CMP = 4'b1010; //some overlap with none but should be fine

// pipeline unit module
pipeline_unit pipeline_unit(
    .clk(clk),
    .rst_n(rst_n),
    .instr_in(instr_in),
    .branch_ref(branch_ref),
    .branch_in(branch_in),
    .sel_stall(sel_stall),
    .cond(cond_decoded),
    .opcode(opcode_decoded),
    .en_status(en_status_decoded),
    .rn(),
    .rd(rd_out),
    .rs(),
    .rm(),
    .shift_op(shift_op_out),
    .imm5(),
    .imm12(imm12_out),
    .imm_branch(imm_branch_out),
    .P(P),
    .U(U),
    .W(W),
    .branch_value(branch_ref_value),
    .instr_output(instr_out)
);

always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        branch_ref_global_reg <= 1'b0;
    end else begin
        branch_ref_global_reg <= branch_ref;
    end
end

always_comb begin
    // default values
    sel_pc_reg = 2'b00;
    load_pc_reg = 1'b0;
    sel_branch_imm_reg = 1'b0;
    sel_A_reg = 1'b0;
    sel_B_reg = 1'b0;
    ALU_op_reg = 3'b000;
    sel_pre_indexed_reg = 1'b0;
    en_status_reg = 1'b0;
    sel_load_LR_reg = 1'b0;
    w_en1_reg = 1'b0;
    mem_w_en_reg = 1'b0;
    branch_value_out = branch_ref_value;

    //normal instructions
    if (opcode[6] == 0 && opcode[5:4] != 2'b10 && cond_decoded != 4'b1111)  begin

        // sel_pc_reg

        // load_pc_reg
        load_pc_reg = 1'b1;

        // sel_branch_imm

        // sel_A -> opposite of load A
        if (opcode[3] == 1'b0) begin
            sel_A_reg = 1'b1;
        end // else default from A_reg

        // sel_B -> opposite of load B
        if (opcode[4] == 1'b0) begin
            sel_B_reg = 1'b1;
        end // else default from B_reg

        // ALU_op
        case (opcode[2:0])
            3'b000: ALU_op_reg = ADD;
            3'b001: ALU_op_reg = SUB;
            3'b010: ALU_op_reg = SUB;
            3'b011: ALU_op_reg = AND;
            3'b100: ALU_op_reg = ORR;
            3'b101: ALU_op_reg = XOR;
            default: ALU_op_reg = ADD;
        endcase

        // sel_pre_indexed

        // en_status -> in branching decodded result doesnt this work
        en_status_reg = en_status_decoded;
        
        // sel_load_LR

        // w_en1
        if (opcode[3:0] != CMP) begin
            w_en1_reg = 1'b1;
        end

        // mem_w_en
        mem_w_en_reg = 1'b0;
    end else if (opcode[6:5] == 2'b11 || opcode[6:3] == 4'b1000) begin //STR and LDR

        // sel_pc_reg

        // load_pc_reg
        load_pc_reg = 1'b1;

        // sel_A - always from Rn
        sel_A_reg = 1'b0;

        // sel_B & sel_pre_indexed
        sel_pre_indexed_reg = ~P;
        if (opcode[3] == 1'b1) begin
            // register - load from regB
            sel_B_reg = 1'b0;
        end else begin
            // immediate
            sel_B_reg = 1'b1;
        end

        // ALU_op
        case (U)
        1'b0: ALU_op_reg = SUB;
        default: ALU_op_reg = ADD;
        endcase

        // sel_pre_indexed

        //en_status
        en_status_reg = en_status_decoded;

        // sel_load_LR

        // w_en1
        w_en1_reg = P && W;

        // mem_w_en
        if (opcode[4] == 1'b1) begin    //STR
            mem_w_en_reg = 1'b1;
        end // else default for LDR

    end else if (opcode[6:3] == 4'b1001) begin  //branching

        // sel_pc_reg
        // load_pc_reg
        if ((cond_decoded == 4'b0000 && Z) || 
            (cond_decoded == 4'b0001 && ~Z) || 
            (cond_decoded == 4'b0010 && C) || 
            (cond_decoded == 4'b0011 && ~C) || 
            (cond_decoded == 4'b0100 && N) || 
            (cond_decoded == 4'b0101 && ~N) || 
            (cond_decoded == 4'b0110 && V) || 
            (cond_decoded == 4'b0111 && ~V) || 
            (cond_decoded == 4'b1000 && C && ~Z) || 
            (cond_decoded == 4'b1001 && ~C || Z) || 
            (cond_decoded == 4'b1010 && N == V) || 
            (cond_decoded == 4'b1011 && N != V) || 
            (cond_decoded == 4'b1100 && (~Z && (N == V))) || 
            (cond_decoded == 4'b1101 && (Z || (N != V))) || 
            (cond_decoded == 4'b1110)) begin
            
            // take the new address
            sel_pc_reg = 2'b11;
            load_pc_reg = 1'b1;
            branch_value_out = ~branch_ref_value;
        end else begin
            sel_pc_reg = 2'b00;
            load_pc_reg = 1'b1;
        end

        //sel_A
        if (opcode[1] == 1'b1) begin
            // type X is direct laod PC from register
            sel_A_reg = 1'b1;
        end

        //sel_B
        if (opcode[1] == 1'b1) begin
            sel_B_reg = 1'b0;
        end else begin
            sel_B_reg = 1'b1;
            sel_branch_imm_reg = 1'b1;
        end

        // ALU_op
        // sel_pre_indexed
        // en_status

        // sel_load_LR
        // w_en1
        if (opcode[2] == 1'b1) begin
            sel_load_LR_reg = 1'b0;
            w_en1_reg = 1'b1;
        end

        // mem_w_en
    end
end
endmodule: memory_unit