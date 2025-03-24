`include "common/constants.sv"

module imm_gen (
  input logic [31:0] instruction_i,
  input inst_type instruction_type_i,
  output logic [31:0] immediate_o
);

always_comb begin
  case (instruction_type_i)
    INST_I: immediate_o = { {21{instruction_i[31]}}, instruction_i[30:21], instruction_i[20] };
    INST_S: immediate_o = { {21{instruction_i[31]}}, instruction_i[30:25], instruction_i[11:7] };
    INST_B: immediate_o = { {20{instruction_i[31]}}, instruction_i[7], instruction_i[30:25], instruction_i[11:8], 1'b0 };
    INST_U: immediate_o = { instruction_i[31:12], 12'b0 };
    INST_J: immediate_o = { {12{instruction_i[31]}}, instruction_i[19:12], instruction_i[20], instruction_i[30:21], 1'b0 };
    default: immediate_o = 0;
  endcase
end

endmodule
