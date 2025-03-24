module id_ex_stage (
  input wire clk_i,
  input wire n_rst,
  input logic flush,
  input logic stall,

  input logic [31:0] id_pc_i,
  input ex_func id_ex_func_i,
  input rs1_sel id_rs1_sel_i,
  input rs2_sel id_rs2_sel_i,
  input logic id_memwrite_en_i,
  input logic id_memread_en_i,
  input logic id_wb_en_i,
  input wb_source_type id_wb_src_i,
  input wb_pc_source_type id_wb_pc_src_i,
  input logic [31:0] id_rs1_data_i,
  input logic [31:0] id_rs2_data_i,
  input logic [31:0] id_immediate_i,

  output logic [31:0] ex_pc_o,
  output ex_func ex_func_o,
  output rs1_sel ex_rs1_sel_o,
  output rs2_sel ex_rs2_sel_o,
  output logic ex_memwrite_en_o,
  output logic ex_memread_en_o,
  output logic ex_wb_en_o,
  output wb_source_type ex_wb_src_o,
  output wb_pc_source_type ex_wb_pc_src_o,
  output logic [31:0] ex_rs1_data_o,
  output logic [31:0] ex_rs2_data_o,
  output logic [31:0] ex_immediate_o
);

always_ff @(posedge clk_i or negedge n_rst) begin
  if (!n_rst) begin
    ex_pc_o <= `ZERO;
    ex_func_o <= ALU_NONE;
    ex_rs1_sel_o <= RS1_VALUE;
    ex_rs2_sel_o <= RS2_VALUE;
    ex_memwrite_en_o <= `DISABLE;
    ex_memread_en_o <= `DISABLE;
    ex_wb_en_o <= `DISABLE;
    ex_wb_src_o <= WB_SRC_NONE;
    ex_wb_pc_src_o <= PC_SRC_NONE;
    ex_rs1_data_o <= `ZERO;
    ex_rs2_data_o <= `ZERO;
    ex_immediate_o <= `ZERO;
  end 
  else begin
    if (flush) begin
      ex_pc_o <= `ZERO;
      ex_func_o <= ALU_NONE;
      ex_rs1_sel_o <= RS1_VALUE;
      ex_rs2_sel_o <= RS2_VALUE;
      ex_memwrite_en_o <= `DISABLE;
      ex_memread_en_o <= `DISABLE;
      ex_wb_en_o <= `DISABLE;
      ex_wb_src_o <= WB_SRC_NONE;
      ex_wb_pc_src_o <= PC_SRC_NONE;
      ex_rs1_data_o <= `ZERO;
      ex_rs2_data_o <= `ZERO;
      ex_immediate_o <= `ZERO;
    end 
    else if (!stall) begin
      ex_pc_o <= id_pc_i;
      ex_func_o <= id_ex_func_i;
      ex_rs1_sel_o <= id_rs1_sel_i;
      ex_rs2_sel_o <= id_rs2_sel_i;
      ex_memwrite_en_o <= id_memwrite_en_i;
      ex_memread_en_o <= id_memread_en_i;
      ex_wb_en_o <= id_wb_en_i;
      ex_wb_src_o <= id_wb_src_i;
      ex_wb_pc_src_o <= id_wb_pc_src_i;
      ex_rs1_data_o <= id_rs1_data_i;
      ex_rs2_data_o <= id_rs2_data_i;
      ex_immediate_o <= id_immediate_i;
    end
  end
end

endmodule