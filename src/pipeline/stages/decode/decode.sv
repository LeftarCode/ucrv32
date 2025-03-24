`include "pipeline/stages/decode/decoder.sv"
`include "pipeline/stages/decode/imm_gen.sv"
`include "pipeline/stages/decode/regfile.sv"
`include "pipeline/stages/decode/controller.sv"

module decode (
  input logic clk_i,
  input logic n_rst,
  input logic [31:0] instruction_i,
  input logic [31:0] pc_i,

  output logic [31:0] pc_o,
  output ex_func ex_func_o,
  output rs1_sel rs1_sel_o,
  output rs2_sel rs2_sel_o,
  output logic memwrite_en_o,
  output logic memread_en_o,
  output logic wb_en_o,
  output wb_source_type wb_src_o,
  output wb_pc_source_type wb_pc_src_o,
  output logic [31:0] rs1_data_o,
  output logic [31:0] rs2_data_o,
  output logic [31:0] immediate_o
);

assign pc_o = pc_i;
// =============================
// Decoder signals
// =============================
logic [4:0] decoder_rs1_o;
logic [4:0] decoder_rs2_o;
logic [4:0] decoder_rd_o;
inst_type decoder_instruction_type_o;
logic [6:0] decoder_opcode_o;
logic [2:0] decoder_funct3_o;
logic [6:0] decoder_funct7_o;
// =============================
// Regfile signals
// =============================
logic [4:0] TEMP_rd_addr_i;
logic [31:0] TEMP_wd_i;
logic TEMP_we_i;

decoder decoder(
  .instruction_i(instruction_i),
  .rs1_o(decoder_rs1_o),
  .rs2_o(decoder_rs2_o),
  .rd_o(decoder_rd_o),
  .opcode_o(decoder_opcode_o),
  .instruction_type_o(decoder_instruction_type_o),
  .funct3_o(decoder_funct3_o),
  .funct7_o(decoder_funct7_o)
);

imm_gen imm_gen(
  .instruction_i(instruction_i),
  .instruction_type_i(decoder_instruction_type_o),
  .immediate_o(immediate_o)
);

regfile regfile(
  .clk_i(clk_i),
  .n_rst(n_rst),
  .rs1_addr_i(decoder_rs1_o),
  .rs2_addr_i(decoder_rs2_o),
  .rd_addr_i(TEMP_rd_addr_i),
  .wd_i(TEMP_wd_i),
  .we_i(TEMP_we_i),
  .rs1_data_o(rs1_data_o),
  .rs2_data_o(rs2_data_o)
);

controller controller(
  .opcode_i(decoder_opcode_o),
  .funct7_i(decoder_funct7_o),
  .funct3_i(decoder_funct3_o),

  .ex_func_o(ex_func_o),
  .rs1_sel_o(rs1_sel_o),
  .rs2_sel_o(rs2_sel_o),
  .memwrite_en_o(memwrite_en_o),
  .memread_en_o(memread_en_o),
  .wb_en_o(wb_en_o),
  .wb_src_o(wb_src_o),
  .wb_pc_src_o(wb_pc_src_o)
);

endmodule
