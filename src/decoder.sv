`include "common/constants.sv"
`include "common/functions.sv"

module decoder (
  input logic [31:0] instruction_i,

  output logic [31:0] immediate_o,
  output logic [4:0] rs1_o,
  output logic rs1_en_o,
  output logic [4:0] rs2_o,
  output logic rs2_en_o,
  output logic [4:0] rd_o,
  output logic [6:0] opcode_o,
  output logic [3:0] funct3,
  output logic [6:0] funct7,

  output logic valid_o,
  output logic jal_o,
  output logic reg2mem_o,
  output logic mem2reg_o,
  output logic alu_writeback_o,
  output logic syscall_o,
  output logic branch_o
);

inst_type inst_type_local;

assign jal_o = (opcode_o == `OPCODE_JAL);
assign reg2mem_o = (opcode_o == `OPCODE_STORE);
assign mem2reg_o = (opcode_o == `OPCODE_LOAD);
assign alu_writeback_o = (opcode == `OPCODE_JAL || opcode == `OPCODE_JALR ||
                          opcode == `OPCODE_LUI || opcode == `OPCODE_AUIPC ||
                          opcode == `OPCODE_ALUIMM || opcode == `OPCODE_ALUREG);
assign syscall_o = (opcode == `OPCODE_SYSTEM);
assign branch_o = (opcode == `OPCODE_BRANCH);

assign opcode_o = instruction_i[6:0];
assign rd_o = instruction_i[11:7];
assign rs1_o = instruction_i[19:15];
assign rs2_o = instruction_i[24:20];
assign funct3_o = instruction_i[14:12];
assign funct7_o = instruction_i[31:25];

always_comb begin
   case (opcode)
    `OPCODE_LUI: inst_type_local <= INST_U;
    `OPCODE_AUIPC: inst_type_local <= INST_U;
    `OPCODE_JAL: inst_type_local <= INST_J;
    `OPCODE_JALR: inst_type_local <= INST_I;
    `OPCODE_BRANCH: inst_type_local <= INST_B;
    `OPCODE_LOAD: inst_type_local <= INST_I;
    `OPCODE_STORE: inst_type_local <= INST_S;
    `OPCODE_ALUIMM: inst_type_local <= INST_I;
    `OPCODE_ALUREG: inst_type_local <= INST_R;
    `OPCODE_SYSTEM: inst_type_local <= INST_I;
    default: valid_o <= 0; 
  endcase  
end

always_comb begin
  case (inst_type_local)
    `INST_I: imm_o <= { {21{instruction_i[31]}}, instruction_i[30:21], instruction_i[20] };
    `INST_S: imm_o <= { {21{instruction_i[31]}}, instruction_i[30:25], instruction_i[11:7] };
    `INST_B: imm_o <= { {20{instruction_i[31]}}, instruction_i[7], instruction_i[30:25], instruction_i[11:8], 1'b0 };
    `INST_U: imm_o <= { instruction_i[31:12], 12'b0 };
    `INST_J: imm_o <= { {12{instruction_i[31]}}, instruction_i[19:12], instruction_i[20], instruction_i[30:21], 1'b0 };
    default: imm_o <= 0;
  endcase
end

always_comb begin
  case (inst_type_local)
    `INST_R: {rs1_en_o, rs2_en_o} <= 2'b11;
    `INST_I: {rs1_en_o, rs2_en_o} <= 2'b01;
    `INST_S: {rs1_en_o, rs2_en_o} <= 2'b11;
    `INST_B: {rs1_en_o, rs2_en_o} <= 2'b11;
    default: {rs1_en_o, rs2_en_o} <= 2'b00; 
  endcase
end

endmodule
