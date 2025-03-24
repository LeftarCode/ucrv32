
typedef enum logic[2:0] {INST_I, INST_S, INST_B, INST_U, INST_J, INST_R, INST_UNKNOWN} inst_type;
typedef enum logic[3:0] {ALU=1, LSU=2, BRU=4, SYSTEM=8} unit_type;

typedef enum logic {PC_VALUE=0, RS1_VALUE=1} rs1_sel;
typedef enum logic {IMM_VALUE=0, RS2_VALUE=1} rs2_sel;

typedef enum logic[4:0] {
    ALU_ADD,
    ALU_SUB,
    ALU_SRL,
    ALU_SRA,
    ALU_SLL,
    ALU_SLT,
    ALU_SLTU,
    ALU_SGT,
    ALU_SGTU,
    ALU_SGE,
    ALU_SGEU,
    ALU_SEQ,
    ALU_SNE,
    ALU_XOR,
    ALU_OR,
    ALU_AND,
    ALU_PASS_A,
    ALU_PASS_B,
    ALU_NONE
} ex_func;

typedef enum logic[1:0] {
    WB_SRC_NONE, WB_SRC_ALU, WB_SRC_PC_4, WB_SRC_MEM
} wb_source_type;

typedef enum logic[1:0] {
    PC_SRC_NONE, PC_SRC_ALU, PC_SRC_PC_4, PC_SRC_PC_IMM
} wb_pc_source_type;