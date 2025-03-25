module ex_mem_stage (
  input wire clk_i,
  input wire n_rst,
  input logic flush,
  input logic stall,

  input logic [4:0] ex_rd_i,
  input logic ex_alu_zero_i,
  input logic [31:0] ex_alu_result_i,
  input logic [31:0] ex_pc_i,
  input logic [31:0] ex_pc_4_i,
  input logic [31:0] ex_pc_imm_i,
  input logic ex_memwrite_en_i,
  input logic ex_memread_en_i,
  input logic ex_branch_i,
  input logic ex_jmp_i,
  input logic ex_wb_en_i,
  input wb_source_type ex_wb_src_i,
  input wb_pc_source_type ex_wb_pc_src_i,

  output logic [4:0] mem_rd_o,
  output logic mem_alu_zero_o,
  output logic [31:0] mem_alu_result_o,
  output logic [31:0] mem_pc_o,
  output logic [31:0] mem_pc_4_o,
  output logic [31:0] mem_pc_imm_o,
  output logic mem_memwrite_en_o,
  output logic mem_memread_en_o,
  output logic mem_branch_o,
  output logic mem_jmp_o,
  output logic mem_wb_en_o,
  output wb_source_type mem_wb_src_o,
  output wb_pc_source_type mem_wb_pc_src_o
);

always_ff @(posedge clk_i or negedge n_rst) begin
  if (!n_rst) begin
    mem_rd_o <= 5'b0;
    mem_alu_zero_o <= `DISABLE;
    mem_alu_result_o <= `ZERO;
    mem_pc_o <= `ZERO;
    mem_pc_4_o <= `ZERO;
    mem_pc_imm_o <= `ZERO;
    mem_memwrite_en_o <= `DISABLE;
    mem_memread_en_o <= `DISABLE;
    mem_wb_en_o <= `DISABLE;
    mem_branch_o <= `DISABLE;
    mem_jmp_o <= `DISABLE;
    mem_wb_src_o <= WB_SRC_NONE;
    mem_wb_pc_src_o <= PC_SRC_NONE;
  end 
  else begin
    if (flush) begin
      mem_rd_o <= 5'b0;
      mem_alu_zero_o <= `DISABLE;
      mem_alu_result_o <= `ZERO;
      mem_pc_o <= `ZERO;
      mem_pc_4_o <= `ZERO;
      mem_pc_imm_o <= `ZERO;
      mem_memwrite_en_o <= `DISABLE;
      mem_memread_en_o <= `DISABLE;
      mem_wb_en_o <= `DISABLE;
      mem_branch_o <= `DISABLE;
      mem_jmp_o <= `DISABLE;
      mem_wb_src_o <= WB_SRC_NONE;
      mem_wb_pc_src_o <= PC_SRC_NONE;
    end 
    else if (!stall) begin
      mem_rd_o <= ex_rd_i;
      mem_alu_zero_o <= ex_alu_zero_i;
      mem_alu_result_o <= ex_alu_result_i;
      mem_pc_o <= ex_pc_i;
      mem_pc_4_o <= ex_pc_4_i;
      mem_pc_imm_o <= ex_pc_imm_i;
      mem_memwrite_en_o <= ex_memwrite_en_i;
      mem_memread_en_o <= ex_memread_en_i;
      mem_wb_en_o <= ex_wb_en_i;
      mem_branch_o <= ex_branch_i;
      mem_jmp_o <= ex_jmp_i;
      mem_wb_src_o <= ex_wb_src_i;
      mem_wb_pc_src_o <= ex_wb_pc_src_i;
    end
  end
end

endmodule