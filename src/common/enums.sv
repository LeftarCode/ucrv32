
typedef enum logic[3:0] {INST_I, INST_S, INST_B, INST_U, INST_J, INST_R} inst_type;
typedef enum logic[3:0] {ALU=1, LSU=2, BRU=4, SYSTEM=8} unit_type;
typedef enum logic[3:0] {INVALID_INSTRUCTION, NOT_ALIGNED_PC} exception_type;