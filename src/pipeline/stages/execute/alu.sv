

module alu (
  input ex_func operation,
  input signed [31:0] operand_a,
  input signed [31:0] operand_b,
  output logic [31:0] result,
  output logic result_zero
);

  assign result_zero = (result == `ZERO);

  always_comb begin
    result = `ZERO;
    case (operation)
      ALU_ADD: result = operand_a + operand_b;
      ALU_SUB: result = operand_a - operand_b;
      ALU_SRL: result = operand_a >> operand_b[4:0];
      ALU_SRA: result = operand_a >>> operand_b[4:0];
      ALU_SLL: result = operand_a << operand_b[4:0];
      ALU_SLT: result = {31'b0, operand_a < operand_b};
      ALU_SLTU: result = {31'b0, $unsigned(operand_a) < $unsigned(operand_b)};
      ALU_SGT: result = {31'b0, operand_a > operand_b};
      ALU_SGTU: result = {31'b0, $unsigned(operand_a) > $unsigned(operand_b)};
      ALU_SGE: result = {31'b0, operand_a >= operand_b};
      ALU_SGEU: result = {31'b0, $unsigned(operand_a) >= $unsigned(operand_b)};
      ALU_SEQ: result = {31'b0, operand_a == operand_b};
      ALU_SNE: result = {31'b0, operand_a != operand_b};
      ALU_XOR: result = operand_a ^ operand_b;
      ALU_OR: result = operand_a | operand_b;
      ALU_AND: result = operand_a & operand_b;
      ALU_PASS_A: result = operand_a;
      ALU_PASS_B: result = operand_b;
      ALU_NONE: result = `ZERO;
      default: result = `ZERO;
    endcase
   
  end

endmodule
