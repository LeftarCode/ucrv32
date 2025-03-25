`include "common/multiplexers/mux4to1.sv"

module memory (
  input logic clk_i,
  input logic n_rst,

  input logic [4:0] rd_i,
  input logic alu_zero_i,
  input logic [31:0] alu_result_i,
  input logic [31:0] pc_i,
  input logic [31:0] pc_4_i,
  input logic [31:0] pc_imm_i,
  input logic memwrite_en_i,
  input logic memread_en_i,
  input logic branch_i,
  input logic jmp_i,
  input logic wb_en_i,
  input wb_source_type wb_src_i,
  input wb_pc_source_type wb_pc_src_i,

  output logic [4:0] rd_o,
  output logic memwrite_en_o,
  output logic wb_en_o,
  output logic [31:0] wb_value_o,
  output logic [31:0] next_pc_o,
  output logic branch_taken_o,

  ram_interface.master ram_if
);

assign rd_o = rd_i;
assign memwrite_en_o = memwrite_en_i;
assign wb_en_o = wb_en_i;
// IF it's branch and alu_result isn't zero (condition is true) then branch is taken. Or when it's simple jmp.
assign branch_taken_o = jmp_i | (branch_i & ~alu_zero_i);

assign ram_if.en_i_a = memread_en_i;
assign ram_if.addr_i_a = alu_result_i;

mux4to1 next_pc_mux (
  .in0(`ZERO),
  .in1(alu_result_i),
  .in2(pc_4_i),
  .in3(pc_imm_i),
  .out(next_pc_o),
  .sel(wb_pc_src_i)
);

mux4to1 wb_value_mux (
  .in0(`ZERO),
  .in1(alu_result_i),
  .in2(pc_4_i),
  .in3(ram_if.data_o_a),
  .out(wb_value_o),
  .sel(wb_src_i)
);

endmodule
