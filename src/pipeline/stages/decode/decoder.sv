`include "common/constants.sv"

module decoder (
  input logic [31:0] instruction_i,

  output inst_type instruction_type_o,

  output logic [4:0] rs1_o,
  output logic [4:0] rs2_o,
  output logic [4:0] rd_o,
  output logic [6:0] opcode_o,
  output logic [2:0] funct3_o,
  output logic [6:0] funct7_o
);

assign opcode_o = instruction_i[6:0];
assign rd_o = instruction_i[11:7];
assign rs1_o = instruction_i[19:15];
assign rs2_o = instruction_i[24:20];
assign funct3_o = instruction_i[14:12];
assign funct7_o = instruction_i[31:25];

always_comb begin
  case (opcode_o)
    `OPCODE_LUI: instruction_type_o = INST_U;
    `OPCODE_AUIPC: instruction_type_o = INST_U;
    `OPCODE_JAL: instruction_type_o = INST_J;
    `OPCODE_JALR: instruction_type_o = INST_I;
    `OPCODE_BRANCH: instruction_type_o = INST_B;
    `OPCODE_LOAD: instruction_type_o = INST_I;
    `OPCODE_STORE: instruction_type_o = INST_S;
    `OPCODE_ALUIMM: instruction_type_o = INST_I;
    `OPCODE_ALUREG: instruction_type_o = INST_R;
    `OPCODE_SYSTEM: instruction_type_o = INST_I;
    default: instruction_type_o = INST_UNKNOWN;
  endcase  
end

endmodule
