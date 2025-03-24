/* verilator lint_off MODDUP */
/* verilator lint_off REDEFMACRO */
`include "common/enums.sv"
`include "pipeline/stages/fetch/fetch.sv"
`include "pipeline/stages/decode/decode.sv"
`include "pipeline/stages/execute/execute.sv"
`include "pipeline/registers/if_id_stage.sv"
`include "pipeline/registers/id_ex_stage.sv"
`include "common/ram.sv"
`include "common/multiplexers/mux2to1.sv"

module top (
  input wire clk_i,
  input wire n_rst,

  // FIXME: TEMP input
  input logic alu_next_pc_en,
  input logic [31:0] alu_next_pc,
  
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

  // =============================
  // PC handling
  // =============================
  logic [31:0] pc = 32'b0;
  logic [31:0] next_pc;
  mux2to1 pc_mux(
    .sel(alu_next_pc_en),
    .a(pc + 32'd4),
    .b(alu_next_pc),
    .y(next_pc)
  );

  always_ff @(posedge clk_i)
  begin
      pc <= next_pc;
  end

  // =============================
  // BRAM instatiation
  // =============================
  ram_interface ram_if (clk_i, clk_i);
  ram main_memory(
    .ram_if(ram_if.slave)
  );
  
  // =============================
  // IF_ID signals
  // =============================
  logic [31:0] if_id_instruction_i;
  logic [31:0] if_id_pc_i;
  logic if_id_valid_i;
  logic [31:0] if_id_instruction_o;
  logic [31:0] if_id_pc_o;
  
  // =============================
  // ID_EX signals
  // =============================
  logic [31:0] id_ex_pc_i;
  ex_func id_ex_func_i;
  rs1_sel id_ex_rs1_sel_i;
  rs2_sel id_ex_rs2_sel_i;
  logic id_ex_memwrite_en_i;
  logic id_ex_memread_en_i;
  logic id_ex_wb_en_i;
  wb_source_type id_ex_wb_src_i;
  wb_pc_source_type id_ex_wb_pc_src_i;
  logic [31:0] id_ex_rs1_data_i;
  logic [31:0] id_ex_rs2_data_i;
  logic [31:0] id_ex_immediate_i;

  logic [31:0] id_ex_pc_o;
  ex_func id_ex_func_o;
  rs1_sel id_ex_rs1_sel_o;
  rs2_sel id_ex_rs2_sel_o;
  logic id_ex_memwrite_en_o;
  logic id_ex_memread_en_o;
  logic id_ex_wb_en_o;
  wb_source_type id_ex_wb_src_o;
  wb_pc_source_type id_ex_wb_pc_src_o;
  logic [31:0] id_ex_rs1_data_o;
  logic [31:0] id_ex_rs2_data_o;
  logic [31:0] id_ex_immediate_o;


  // =============================
  // FIXME: const signals
  // =============================
  logic if_id_flush = 1'b0;
  logic if_id_stall = 1'b0;
  logic id_ex_flush = 1'b0;
  logic id_ex_stall = 1'b0;

  // =============================
  // Fetch stage
  // =============================
  fetch fetch(
    .clk_i(clk_i),
    .pc_i(pc),
    .instruction_o(if_id_instruction_i),
    .pc_o (if_id_pc_i),
    .ram_if(ram_if.master),
    .valid_o(if_id_valid_i)
  );

  // =============================
  // IF_ID pipeline registers
  // =============================
  if_id_stage if_id_stage (
    .clk_i    (clk_i),
    .n_rst    (n_rst),
    .flush    (if_id_flush),
    .stall    (if_id_stall),
    .if_inst  (if_id_instruction_i),
    .if_pc    (if_id_pc_i),
    .if_valid (if_id_valid_i),
    .id_inst  (if_id_instruction_o),
    .id_pc    (if_id_pc_o)
  );

  // =============================
  // Decode stage
  // =============================
  decode decode(
    .clk_i(clk_i),
    .n_rst(n_rst),
    .instruction_i(if_id_instruction_o),
    .pc_i(if_id_pc_o),
    
    .pc_o(id_ex_pc_i),
    .ex_func_o(id_ex_func_i),
    .rs1_sel_o(id_ex_rs1_sel_i),
    .rs2_sel_o(id_ex_rs2_sel_i),
    .memwrite_en_o(id_ex_memwrite_en_i),
    .memread_en_o(id_ex_memread_en_i),
    .wb_en_o(id_ex_wb_en_i),
    .wb_src_o(id_ex_wb_src_i),
    .wb_pc_src_o(id_ex_wb_pc_src_i),
    .rs1_data_o(id_ex_rs1_data_i),
    .rs2_data_o(id_ex_rs2_data_i),
    .immediate_o(id_ex_immediate_i)
  );

  // =============================
  // ID_EX pipeline registers
  // =============================
  id_ex_stage id_ex_stage(
    .clk_i(clk_i),
    .n_rst(n_rst),
    .flush(id_ex_flush),
    .stall(id_ex_stall),
    
    .id_pc_i(id_ex_pc_i),
    .id_ex_func_i(id_ex_func_i),
    .id_rs1_sel_i(id_ex_rs1_sel_i),
    .id_rs2_sel_i(id_ex_rs2_sel_i),
    .id_memwrite_en_i(id_ex_memwrite_en_i),
    .id_memread_en_i(id_ex_memread_en_i),
    .id_wb_en_i(id_ex_wb_en_i),
    .id_wb_src_i(id_ex_wb_src_i),
    .id_wb_pc_src_i(id_ex_wb_pc_src_i),
    .id_rs1_data_i(id_ex_rs1_data_i),
    .id_rs2_data_i(id_ex_rs2_data_i),
    .id_immediate_i(id_ex_immediate_i),

    .ex_pc_o(id_ex_pc_o),
    .ex_func_o(id_ex_func_o),
    .ex_rs1_sel_o(id_ex_rs1_sel_o),
    .ex_rs2_sel_o(id_ex_rs2_sel_o),
    .ex_memwrite_en_o(id_ex_memwrite_en_o),
    .ex_memread_en_o(id_ex_memread_en_o),
    .ex_wb_en_o(id_ex_wb_en_o),
    .ex_wb_src_o(id_ex_wb_src_o),
    .ex_wb_pc_src_o(id_ex_wb_pc_src_o),
    .ex_rs1_data_o(id_ex_rs1_data_o),
    .ex_rs2_data_o(id_ex_rs2_data_o),
    .ex_immediate_o(id_ex_immediate_o)
  );

  // =============================
  // Execute stage
  // =============================
  execute execute(
    .clk_i(clk_i),
    .n_rst(n_rst),
    
    .pc_i(id_ex_pc_o),
    .ex_func_i(id_ex_func_o),
    .rs1_sel_i(id_ex_rs1_sel_o),
    .rs2_sel_i(id_ex_rs2_sel_o),
    .memwrite_en_i(id_ex_memwrite_en_o),
    .memread_en_i(id_ex_memread_en_o),
    .wb_en_i(id_ex_wb_en_o),
    .wb_src_i(id_ex_wb_src_o),
    .wb_pc_src_i(id_ex_wb_pc_src_o),
    .rs1_data_i(id_ex_rs1_data_o),
    .rs2_data_i(id_ex_rs2_data_o),
    .immediate_i(id_ex_immediate_o),
    
    .alu_zero_o(alu_zero_o),
    .alu_result_o(alu_result_o),
    .pc_o(pc_o),
    .pc_4_o(pc_4_o),
    .pc_imm_o(pc_imm_o),
    .memwrite_en_o(memwrite_en_o),
    .memread_en_o(memread_en_o),
    .wb_en_o(wb_en_o),
    .wb_src_o(wb_src_o),
    .wb_pc_src_o(wb_pc_src_o)
  );

endmodule
