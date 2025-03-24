`include "common/multiplexers/mux2to1.sv"
`include "pipeline/stages/execute/alu.sv"

module execute (
  input logic clk_i,
  input logic n_rst,

  input logic [31:0] pc_i,
  input ex_func ex_func_i,
  input rs1_sel rs1_sel_i,
  input rs2_sel rs2_sel_i,
  input logic memwrite_en_i,
  input logic memread_en_i,
  input logic wb_en_i,
  input wb_source_type wb_src_i,
  input wb_pc_source_type wb_pc_src_i,
  input logic [31:0] rs1_data_i,
  input logic [31:0] rs2_data_i,
  input logic [31:0] immediate_i,

  output logic alu_zero_o,
  output logic [31:0] alu_result_o,
  output logic [31:0] pc_o,
  output logic [31:0] pc_4_o,
  output logic [31:0] pc_imm_o,
  output logic memwrite_en_o,
  output logic memread_en_o,
  output logic wb_en_o,
  output wb_source_type wb_src_o,
  output wb_pc_source_type wb_pc_src_o
);

assign pc_o = pc_i;
assign pc_4_o = pc_i + 4;
assign pc_imm_o = pc_i + immediate_i;
assign memwrite_en_o = memwrite_en_i;
assign memread_en_o = memread_en_i;
assign wb_en_o = wb_en_i;
assign wb_src_o = wb_src_i;
assign wb_pc_src_o = wb_pc_src_i;

logic [31:0] alu_operand_a;
logic [31:0] alu_operand_b;

// if sel == 1 then b otherwise a
mux2to1 alu_operand_a_mux (
    .a(pc_i),
    .b(rs1_data_i),
    .sel(rs1_sel_i),
    .y(alu_operand_a)
);

mux2to1 alu_operand_n_mux (
    .a(immediate_i),
    .b(rs2_data_i),
    .sel(rs2_sel_i),
    .y(alu_operand_b)
);

alu alu (
    .operation(ex_func_i),
    .operand_a(alu_operand_a),
    .operand_b(alu_operand_b),
    .result(alu_result_o),
    .result_zero(alu_zero_o)
);

endmodule
