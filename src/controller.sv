`include "common/constants.sv"
`include "common/enums.sv"

module controller (
  input logic [31:0] instruction_i,

  output logic [31:0] immediate_o,
  output logic rs1_en_o,
  output logic [4:0] rs1_o,
  output logic rs2_en_o,
  output logic [4:0] rs2_o,
  output logic [4:0] rd_o,
  output logic [6:0] opcode_o,
  output logic [2:0] funct3_o,
  output logic [6:0] funct7_o,

  output logic exception_en_o,
  output exception_type exception_o,
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
assign alu_writeback_o = (opcode_o == `OPCODE_JAL || opcode_o == `OPCODE_JALR ||
                          opcode_o == `OPCODE_LUI || opcode_o == `OPCODE_AUIPC ||
                          opcode_o == `OPCODE_ALUIMM || opcode_o == `OPCODE_ALUREG);
assign syscall_o = (opcode_o == `OPCODE_SYSTEM);
assign branch_o = (opcode_o == `OPCODE_BRANCH);

assign opcode_o = instruction_i[6:0];
assign rd_o = instruction_i[11:7];
assign rs1_o = instruction_i[19:15];
assign rs2_o = instruction_i[24:20];
assign funct3_o = instruction_i[14:12];
assign funct7_o = instruction_i[31:25];

always_comb begin
   case (opcode_o)
    `OPCODE_LUI: inst_type_local = INST_U;
    `OPCODE_AUIPC: inst_type_local = INST_U;
    `OPCODE_JAL: inst_type_local = INST_J;
    `OPCODE_JALR: inst_type_local = INST_I;
    `OPCODE_BRANCH: inst_type_local = INST_B;
    `OPCODE_LOAD: inst_type_local = INST_I;
    `OPCODE_STORE: inst_type_local = INST_S;
    `OPCODE_ALUIMM: inst_type_local = INST_I;
    `OPCODE_ALUREG: inst_type_local = INST_R;
    `OPCODE_SYSTEM: inst_type_local = INST_I;
    default:
    begin
      exception_en_o = 1;
      exception_o = INVALID_INSTRUCTION;
    end
  endcase  
end

always_comb begin
  case (inst_type_local)
    INST_I: immediate_o = { {21{instruction_i[31]}}, instruction_i[30:21], instruction_i[20] };
    INST_S: immediate_o = { {21{instruction_i[31]}}, instruction_i[30:25], instruction_i[11:7] };
    INST_B: immediate_o = { {20{instruction_i[31]}}, instruction_i[7], instruction_i[30:25], instruction_i[11:8], 1'b0 };
    INST_U: immediate_o = { instruction_i[31:12], 12'b0 };
    INST_J: immediate_o = { {12{instruction_i[31]}}, instruction_i[19:12], instruction_i[20], instruction_i[30:21], 1'b0 };
    default: immediate_o = 0;
  endcase
end

always_comb begin
  case (inst_type_local)
    INST_R: {rs1_en_o, rs2_en_o} = 2'b11;
    INST_I: {rs1_en_o, rs2_en_o} = 2'b01;
    INST_S: {rs1_en_o, rs2_en_o} = 2'b11;
    INST_B: {rs1_en_o, rs2_en_o} = 2'b11;
    default: {rs1_en_o, rs2_en_o} = 2'b00; 
  endcase
end

endmodule
