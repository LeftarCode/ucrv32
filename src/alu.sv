`include "common/constants.sv"

module alu (
  input logic enable,
  input logic [3:0] operation,
  input signed [31:0] operand_a,
  input signed [31:0] operand_b,
  output logic [31:0] result,
  output logic result_zero
);

  assign result_zero = (result == 32'b0);

  always_comb begin
    result = `ZERO;
    case (operation)
      `ALU_ADD: result = operand_a + operand_b;
      `ALU_SUB: result = operand_a - operand_b;
      `ALU_SRL: result = operand_a >> operand_b[4:0];
      `ALU_SRA: result = operand_a >>> operand_b[4:0];
      `ALU_SLL: result = operand_a << operand_b[4:0];
      `ALU_SLT: result = {31'b0, operand_a < operand_b};
      `ALU_SLTU: result = {31'b0, $unsigned(operand_a) < $unsigned(operand_b)};
      `ALU_SEQ: result = {31'b0, operand_a == operand_b};
      `ALU_XOR: result = operand_a ^ operand_b;
      `ALU_OR: result = operand_a | operand_b;
      `ALU_AND: result = operand_a & operand_b;
      default: result = `ZERO;
    endcase
  end
  
endmodule
