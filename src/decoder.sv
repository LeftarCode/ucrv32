
module decoder (
  input logic [31:0] instruction_i,
  output logic alu_enable_o,
  output logic [3:0] alu_operation_o,
  output logic [31:0] immediate_o,
  output logic [3:0] lsu_operation_o,
  output logic lsu_enable_o
);
  
endmodule
