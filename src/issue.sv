`include "common/constants.sv"
`include "common/functions.sv"

module decoder #(
  XLEN = 32
)(
  // NOTE: Maybe registers bits should also be dependant on XLEN?
  input logic clk_i,
  input logic [XLEN-1:0] instruction_i,
 
  output unit_type unit_type_o;
  output logic [3:0] alu_op_o,
  output logic [3:0] lsu_op_o,
  output logic [3:0] bru_op_o,
  output logic [3:0] system_op_o,
  
  output inst_type inst_type_o
  output logic [XLEN-1:0] immediate_o,
  output logic [4:0] rs1_o,
  output logic [4:0] rs2_o,
  output logic [4:0] rd_o,
);

logic [6:0] opcode;
logic [4:0] rd;
logic [3:0] funct3;
logic [4:0] rs1;
logic [4:0] rs2;
logic [31:0] imm_i;
logic [31:0] imm_s;
logic [31:0] imm_b;
logic [31:0] imm_u;
logic [31:0] imm_j;

assign opcode = instruction_i[6:0];
assign rd = instruction_i[11:7];
assign funct3 = instruction_i[14:12];
assign rs1 = instruction_i[19:15];
assign rs2 = instruction_i[24:20];
assign funct7 = instruction_i[31:25];

assign imm_i = { {21{instruction_i[31]}}, instruction_i[30:21], instruction_i[20] };
assign imm_s = { {21{instruction_i[31]}}, instruction_i[30:25], instruction_i[11:7] };
assign imm_b = { {20{instruction_i[31]}}, instruction_i[7], instruction_i[30:25], instruction_i[11:8], 1'b0 };
assign imm_u = { instruction_i[31:12], 12'b0 };
assign imm_j = { {12{instruction_i[31]}}, instruction_i[19:12], instruction_i[20], instruction_i[30:21], 1'b0 };

always_ff @(clk_i) begin
  alu_en_o <= 0;
  lsu_en_o <= 0;
  bu_en_o <= 0;
  system_en_o <= 0;
  case (opcode)
    `OPCODE_LUI: begin
      inst_type_o <= INST_U;
      unit_type_o <= ALU;
      rd_o <= rd;
      rs1_o <= 0;
      imm_o <= imm_u;
    end
    `OPCODE_AUIPC: begin
      inst_type_o <= INST_U;
      unit_type_o <= ALU;
      rd_o <= rd;
      rs1_o <= pc;
      imm_o <= imm_u;
    end
    `OPCODE_JAL: begin
      // J-Type
      // rd = pc + 4
      // pc = pc + offset
      inst_type_o <= INST_J;
      unit_type_o <= BRU;
    end
    `OPCODE_JALR: begin
      // I-Type
      // rd = pc + 4
      // pc = (rs1 + offset) ^ -2
      inst_type_o <= INST_I;
      unit_type_o <= BRU;
    end 
    `OPCODE_BRANCH: begin
      // B-Type
      inst_type_o <= INST_B;
      unit_type_o <= BRU;
    end
    `OPCODE_LOAD: begin
      // I-Type
      inst_type_o <= INST_I;
      unit_type_o <= LSU;
    end
    `OPCODE_STORE: begin
      // S-Type
      inst_type_o <= INST_S;
      unit_type_o <= LSU;
    end
    `OPCODE_ALUIMM: begin
      // I-Type
      inst_type_o <= INST_I;
      unit_type_o <= ALU;
    end
    `OPCODE_ALUREG: begin
      // R-Type
      inst_type_o <= INST_R;
      unit_type_o <= ALU;
    end
    `OPCODE_FENCE_PAUSE: begin
      // Custom-type?
      // NOTE: Change inst_type_o!!
      inst_type_o <= INST_U;
      unit_type_o <= SYSTEM;
    end
    `OPCODE_SYSTEM: begin
      // Custom-type?
      // NOTE: Change inst_type_o!!
      inst_type_o <= INST_U;
      unit_type_o <= SYSTEM;
    end
  endcase
end
  
endmodule
