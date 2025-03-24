`include "common/constants.sv"

module controller (
  input logic [6:0] opcode_i,
  input logic [6:0] funct7_i,
  input logic [2:0] funct3_i,


  output ex_func ex_func_o,
  output rs1_sel rs1_sel_o,
  output rs2_sel rs2_sel_o,
  output logic memwrite_en_o,
  output logic memread_en_o,
  output logic wb_en_o,
  output wb_source_type wb_src_o,
  output wb_pc_source_type wb_pc_src_o
);

always_comb begin
  case (opcode_i)
    `OPCODE_LUI: begin
      /// Load Upper Instruction
      {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} = 
        {ALU_PASS_B, PC_VALUE, IMM_VALUE, `DISABLE, `DISABLE, `ENABLE, WB_SRC_ALU, PC_SRC_NONE};
    end
    `OPCODE_AUIPC: begin
      /// pc = pc + imm;
      /// Effect: flush pipeline!
      {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
        {ALU_NONE, PC_VALUE, IMM_VALUE, `DISABLE, `DISABLE, `DISABLE, WB_SRC_NONE, PC_SRC_PC_IMM};
    end
    `OPCODE_JAL: begin
      /// rd = pc + 4; pc = pc + imm;
      /// Effect: flush pipeline!
      {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
        {ALU_NONE, PC_VALUE, IMM_VALUE, `DISABLE, `DISABLE, `ENABLE, WB_SRC_PC_4, PC_SRC_PC_IMM};
    end
    `OPCODE_JALR: begin
      /// rd = pc + 4; pc = rs1 + imm;
      /// Effect: flush pipeline!
      {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
        {ALU_NONE, PC_VALUE, IMM_VALUE, `DISABLE, `DISABLE, `ENABLE, WB_SRC_PC_4, PC_SRC_PC_IMM};
    end
    `OPCODE_BRANCH: begin
      case (funct3_i)
        // if rs1 == rs2 then pc = pc + imm
        `FUNCT3_BEQ:
          {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
            {ALU_SEQ, RS1_VALUE, RS2_VALUE, `DISABLE, `DISABLE, `DISABLE, WB_SRC_NONE, PC_SRC_PC_IMM};
        `FUNCT3_BNE:
          {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
            {ALU_SNE, RS1_VALUE, RS2_VALUE, `DISABLE, `DISABLE, `DISABLE, WB_SRC_NONE, PC_SRC_PC_IMM};
        `FUNCT3_BLT: 
          {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
            {ALU_SLT, RS1_VALUE, RS2_VALUE, `DISABLE, `DISABLE, `DISABLE, WB_SRC_NONE, PC_SRC_PC_IMM};
        `FUNCT3_BGE: 
          {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
            {ALU_SGE, RS1_VALUE, RS2_VALUE, `DISABLE, `DISABLE, `DISABLE, WB_SRC_NONE, PC_SRC_PC_IMM};
        `FUNCT3_BLTU:
          {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
            {ALU_SLTU, RS1_VALUE, RS2_VALUE, `DISABLE, `DISABLE, `DISABLE, WB_SRC_NONE, PC_SRC_PC_IMM};
        `FUNCT3_BGEU:
          {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
            {ALU_SGEU, RS1_VALUE, RS2_VALUE, `DISABLE, `DISABLE, `DISABLE, WB_SRC_NONE, PC_SRC_PC_IMM};
        default: begin
        end
      endcase
    end
    `OPCODE_LOAD: begin
      case (funct3_i)
        `FUNCT3_LB: 
          {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
            {ALU_NONE, RS1_VALUE, RS2_VALUE, `DISABLE, `ENABLE, `ENABLE, WB_SRC_MEM, PC_SRC_NONE};
        `FUNCT3_LH: 
          {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
            {ALU_NONE, RS1_VALUE, RS2_VALUE, `DISABLE, `ENABLE, `ENABLE, WB_SRC_MEM, PC_SRC_NONE};
        `FUNCT3_LW: 
          {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
            {ALU_NONE, RS1_VALUE, RS2_VALUE, `DISABLE, `ENABLE, `ENABLE, WB_SRC_MEM, PC_SRC_NONE};
        `FUNCT3_LBU:
          {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
            {ALU_NONE, RS1_VALUE, RS2_VALUE, `DISABLE, `ENABLE, `ENABLE, WB_SRC_MEM, PC_SRC_NONE};
        `FUNCT3_LHU:
          {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
            {ALU_NONE, RS1_VALUE, RS2_VALUE, `DISABLE, `ENABLE, `ENABLE, WB_SRC_MEM, PC_SRC_NONE};
        default: begin
        end
      endcase
    end
    `OPCODE_STORE: begin
      case (funct3_i)
        `FUNCT3_SB:
          {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
            {ALU_NONE, RS1_VALUE, RS2_VALUE, `ENABLE, `DISABLE, `DISABLE, WB_SRC_NONE, PC_SRC_NONE};
        `FUNCT3_SH:
          {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
            {ALU_NONE, RS1_VALUE, RS2_VALUE, `ENABLE, `DISABLE, `DISABLE, WB_SRC_NONE, PC_SRC_NONE};
        `FUNCT3_SW:
          {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
            {ALU_NONE, RS1_VALUE, RS2_VALUE, `ENABLE, `DISABLE, `DISABLE, WB_SRC_NONE, PC_SRC_NONE};
        default: begin
        end
      endcase
    end
    `OPCODE_ALUIMM: begin
      case (funct3_i)
        `FUNCT3_ADD_SUB:
          case (funct7_i)
            `FUNCT7_ADD:
              {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
                {ALU_ADD, RS1_VALUE, IMM_VALUE, `DISABLE, `DISABLE, `DISABLE, WB_SRC_ALU, PC_SRC_NONE};
            `FUNCT7_SUB:
              {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
                {ALU_SUB, RS1_VALUE, IMM_VALUE, `DISABLE, `DISABLE, `DISABLE, WB_SRC_ALU, PC_SRC_NONE};
            default: begin
            end
          endcase
        `FUNCT3_SLL:
            {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
              {ALU_SLL, RS1_VALUE, IMM_VALUE, `DISABLE, `DISABLE, `DISABLE, WB_SRC_ALU, PC_SRC_NONE};
        `FUNCT3_SLT:
            {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
              {ALU_SLT, RS1_VALUE, IMM_VALUE, `DISABLE, `DISABLE, `DISABLE, WB_SRC_ALU, PC_SRC_NONE};
        `FUNCT3_SLTU:
            {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
              {ALU_SLTU, RS1_VALUE, IMM_VALUE, `DISABLE, `DISABLE, `DISABLE, WB_SRC_ALU, PC_SRC_NONE};
        `FUNCT3_XOR:
            {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
              {ALU_XOR, RS1_VALUE, IMM_VALUE, `DISABLE, `DISABLE, `DISABLE, WB_SRC_ALU, PC_SRC_NONE};
        `FUNCT3_SRL_SRA:
          case (funct7_i)
            `FUNCT7_SRL:
              {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
                {ALU_SRL, RS1_VALUE, IMM_VALUE, `DISABLE, `DISABLE, `DISABLE, WB_SRC_ALU, PC_SRC_NONE};
            `FUNCT7_SRA:
              {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
                {ALU_SRA, RS1_VALUE, IMM_VALUE, `DISABLE, `DISABLE, `DISABLE, WB_SRC_ALU, PC_SRC_NONE};
            default: begin
            end
          endcase
        `FUNCT3_OR:
          {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
            {ALU_OR, RS1_VALUE, IMM_VALUE, `DISABLE, `DISABLE, `DISABLE, WB_SRC_ALU, PC_SRC_NONE};
        `FUNCT3_AND:
          {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
            {ALU_AND, RS1_VALUE, IMM_VALUE, `DISABLE, `DISABLE, `DISABLE, WB_SRC_ALU, PC_SRC_NONE};
          default: begin
          end
      endcase
    end
    `OPCODE_ALUREG: begin
      case (funct3_i)
        `FUNCT3_ADD_SUB:
          case (funct7_i)
            `FUNCT7_ADD:
              {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
                {ALU_ADD, RS1_VALUE, RS2_VALUE, `DISABLE, `DISABLE, `DISABLE, WB_SRC_ALU, PC_SRC_NONE};
            `FUNCT7_SUB:
              {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
                {ALU_SUB, RS1_VALUE, RS2_VALUE, `DISABLE, `DISABLE, `DISABLE, WB_SRC_ALU, PC_SRC_NONE};
            default: begin
            end
          endcase
        `FUNCT3_SLL:
            {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
              {ALU_SLL, RS1_VALUE, RS2_VALUE, `DISABLE, `DISABLE, `DISABLE, WB_SRC_ALU, PC_SRC_NONE};
        `FUNCT3_SLT:
            {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
              {ALU_SLT, RS1_VALUE, RS2_VALUE, `DISABLE, `DISABLE, `DISABLE, WB_SRC_ALU, PC_SRC_NONE};
        `FUNCT3_SLTU:
            {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
              {ALU_SLTU, RS1_VALUE, RS2_VALUE, `DISABLE, `DISABLE, `DISABLE, WB_SRC_ALU, PC_SRC_NONE};
        `FUNCT3_XOR:
            {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
              {ALU_XOR, RS1_VALUE, RS2_VALUE, `DISABLE, `DISABLE, `DISABLE, WB_SRC_ALU, PC_SRC_NONE};
        `FUNCT3_SRL_SRA:
          case (funct7_i)
            `FUNCT7_SRL:
              {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
                {ALU_SRL, RS1_VALUE, RS2_VALUE, `DISABLE, `DISABLE, `DISABLE, WB_SRC_ALU, PC_SRC_NONE};
            `FUNCT7_SRA:
              {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
                {ALU_SRA, RS1_VALUE, RS2_VALUE, `DISABLE, `DISABLE, `DISABLE, WB_SRC_ALU, PC_SRC_NONE};
            default: begin
            end
          endcase
        `FUNCT3_OR:
          {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
            {ALU_OR, RS1_VALUE, RS2_VALUE, `DISABLE, `DISABLE, `DISABLE, WB_SRC_ALU, PC_SRC_NONE};
        `FUNCT3_AND:
          {ex_func_o, rs1_sel_o, rs2_sel_o, memwrite_en_o, memread_en_o, wb_en_o, wb_src_o, wb_pc_src_o} =
            {ALU_AND, RS1_VALUE, RS2_VALUE, `DISABLE, `DISABLE, `DISABLE, WB_SRC_ALU, PC_SRC_NONE};
        default: begin
        end
      endcase
    end
    `OPCODE_FENCE_PAUSE: begin
      // FENCE/PAUSE instruction, unsupported, NOP
    end
    `OPCODE_SYSTEM: begin
      // SYSTEM instruction, unsupported, NOP
    end
    default: begin
    end
  endcase
end

endmodule
