/* verilator lint_off MODDUP */
/* verilator lint_off REDEFMACRO */
`include "common/enums.sv"
`include "pipeline/stages/fetch/fetch.sv"
`include "pipeline/stages/decode/decode.sv"
`include "pipeline/stages/execute/execute.sv"
`include "pipeline/stages/memory/memory.sv"
`include "pipeline/stages/write_back/write_back.sv"
`include "pipeline/registers/if_id_stage.sv"
`include "pipeline/registers/id_ex_stage.sv"
`include "pipeline/registers/ex_mem_stage.sv"
`include "pipeline/registers/mem_wb_stage.sv"
`include "common/ram.sv"
`include "common/multiplexers/mux2to1.sv"

module top (
  input wire clk_i,
  input wire n_rst
);
  logic fetch_stall_o;
  logic mem_stall_o;
  logic pc_stall;

  assign pc_stall = fetch_stall_o | mem_stall_o;

  // =============================
  // PC handling
  // =============================
  logic branch_taken;
  logic [31:0] branch_pc;
  logic [31:0] pc = 32'b0;
  logic [31:0] next_pc;
  mux2to1 pc_mux(
    .sel(branch_taken),
    .a(pc_stall == 1'b0 ? (pc + 32'd4) : pc),
    .b(branch_pc),
    .y(next_pc)
  );

  always_ff @(posedge clk_i)
  begin
    pc <= next_pc;
  end

  // =============================
  // BRAM instatiation
  // =============================
  ram_interface iram_if (clk_i, clk_i);
  ram instruction_memory(
    .ram_if(iram_if.slave)
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
  logic [4:0] id_ex_rd_i;
  ex_func id_ex_func_i;
  rs1_sel id_ex_rs1_sel_i;
  rs2_sel id_ex_rs2_sel_i;
  logic id_ex_memwrite_en_i;
  logic id_ex_memread_en_i;
  logic id_ex_branch_i;
  logic id_ex_jmp_i;
  logic id_ex_wb_en_i;
  wb_source_type id_ex_wb_src_i;
  wb_pc_source_type id_ex_wb_pc_src_i;
  logic [31:0] id_ex_rs1_data_i;
  logic [31:0] id_ex_rs2_data_i;
  logic [31:0] id_ex_immediate_i;

  logic [31:0] id_ex_pc_o;
  logic [4:0] id_ex_rd_o;
  ex_func id_ex_func_o;
  rs1_sel id_ex_rs1_sel_o;
  rs2_sel id_ex_rs2_sel_o;
  logic id_ex_memwrite_en_o;
  logic id_ex_memread_en_o;
  logic id_ex_branch_o;
  logic id_ex_jmp_o;
  logic id_ex_wb_en_o;
  wb_source_type id_ex_wb_src_o;
  wb_pc_source_type id_ex_wb_pc_src_o;
  logic [31:0] id_ex_rs1_data_o;
  logic [31:0] id_ex_rs2_data_o;
  logic [31:0] id_ex_immediate_o;

  // =============================
  // EX_MEM signals
  // =============================
  logic [4:0] ex_mem_rd_i;
  logic ex_mem_alu_zero_i;
  logic [31:0] ex_mem_alu_result_i;
  logic [31:0] ex_mem_rs2_data_i;
  logic [31:0] ex_mem_pc_i;
  logic [31:0] ex_mem_pc_4_i;
  logic [31:0] ex_mem_pc_imm_i;
  logic ex_mem_memwrite_en_i;
  logic ex_mem_memread_en_i;
  logic ex_mem_branch_i;
  logic ex_mem_jmp_i;
  logic ex_mem_wb_en_i;
  wb_source_type ex_mem_wb_src_i;
  wb_pc_source_type ex_mem_wb_pc_src_i;

  logic [4:0] ex_mem_rd_o;
  logic ex_mem_alu_zero_o;
  logic [31:0] ex_mem_alu_result_o;
  logic [31:0] ex_mem_rs2_data_o;
  logic [31:0] ex_mem_pc_o;
  logic [31:0] ex_mem_pc_4_o;
  logic [31:0] ex_mem_pc_omm_o;
  logic ex_mem_memwrite_en_o;
  logic ex_mem_memread_en_o;
  logic ex_mem_branch_o;
  logic ex_mem_jmp_o;
  logic ex_mem_wb_en_o;
  wb_source_type ex_mem_wb_src_o;
  wb_pc_source_type ex_mem_wb_pc_src_o;

  // =============================
  // MEM_WB signals
  // =============================
  logic [4:0] mem_wb_rd_i;
  logic mem_wb_en_i;
  logic [31:0] mem_wb_value_i;

  logic [4:0] mem_wb_rd_o;
  logic mem_wb_en_o;
  logic [31:0] mem_wb_value_o;
  // =============================
  // WB signals
  // =============================
  logic [4:0] wb_id_rd_o;
  logic wb_id_en_o;
  logic [31:0] wb_id_value_o;

  // =============================
  // FIXME: const signals
  // =============================
  logic if_id_flush = 1'b0;
  logic if_id_stall = 1'b0;
  logic id_ex_flush = 1'b0;
  logic id_ex_stall = 1'b0;
  logic ex_mem_flush = 1'b0;
  logic ex_mem_stall = 1'b0;
  logic mem_wb_flush = 1'b0;
  logic mem_wb_stall = 1'b0;

  assign if_id_stall = mem_stall_o;
  assign id_ex_stall = mem_stall_o;
  assign ex_mem_stall = mem_stall_o;

  assign if_id_flush = branch_taken;
  assign id_ex_flush = branch_taken;
  assign ex_mem_flush = branch_taken;

  // =============================
  // Fetch stage
  // =============================
  fetch fetch(
    .clk_i(clk_i),
    .flush_i(branch_taken),
    .pc_i(pc),
    .instruction_o(if_id_instruction_i),
    .pc_o (if_id_pc_i),
    .ram_if(iram_if.master),
    .valid_o(if_id_valid_i),
    .stall_o(fetch_stall_o)
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
    .regfile_rd_i(wb_id_rd_o),
    .regfile_we_i(wb_id_en_o),
    .regfile_rd_value_i(wb_id_value_o),
    
    .pc_o(id_ex_pc_i),
    .rd_o(id_ex_rd_i),
    .ex_func_o(id_ex_func_i),
    .rs1_sel_o(id_ex_rs1_sel_i),
    .rs2_sel_o(id_ex_rs2_sel_i),
    .memwrite_en_o(id_ex_memwrite_en_i),
    .memread_en_o(id_ex_memread_en_i),
    .branch_o(id_ex_branch_i),
    .jmp_o(id_ex_jmp_i),
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
    .id_rd_i(id_ex_rd_i),
    .id_ex_func_i(id_ex_func_i),
    .id_rs1_sel_i(id_ex_rs1_sel_i),
    .id_rs2_sel_i(id_ex_rs2_sel_i),
    .id_memwrite_en_i(id_ex_memwrite_en_i),
    .id_memread_en_i(id_ex_memread_en_i),
    .id_branch_i(id_ex_branch_i),
    .id_jmp_i(id_ex_jmp_i),
    .id_wb_en_i(id_ex_wb_en_i),
    .id_wb_src_i(id_ex_wb_src_i),
    .id_wb_pc_src_i(id_ex_wb_pc_src_i),
    .id_rs1_data_i(id_ex_rs1_data_i),
    .id_rs2_data_i(id_ex_rs2_data_i),
    .id_immediate_i(id_ex_immediate_i),

    .ex_pc_o(id_ex_pc_o),
    .ex_rd_o(id_ex_rd_o),
    .ex_func_o(id_ex_func_o),
    .ex_rs1_sel_o(id_ex_rs1_sel_o),
    .ex_rs2_sel_o(id_ex_rs2_sel_o),
    .ex_memwrite_en_o(id_ex_memwrite_en_o),
    .ex_memread_en_o(id_ex_memread_en_o),
    .ex_branch_o(id_ex_branch_o),
    .ex_jmp_o(id_ex_jmp_o),
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
    .rd_i(id_ex_rd_o),
    .ex_func_i(id_ex_func_o),
    .rs1_sel_i(id_ex_rs1_sel_o),
    .rs2_sel_i(id_ex_rs2_sel_o),
    .memwrite_en_i(id_ex_memwrite_en_o),
    .memread_en_i(id_ex_memread_en_o),
    .branch_i(id_ex_branch_o),
    .jmp_i(id_ex_jmp_o),
    .wb_en_i(id_ex_wb_en_o),
    .wb_src_i(id_ex_wb_src_o),
    .wb_pc_src_i(id_ex_wb_pc_src_o),
    .rs1_data_i(id_ex_rs1_data_o),
    .rs2_data_i(id_ex_rs2_data_o),
    .immediate_i(id_ex_immediate_o),
    
    .rd_o(ex_mem_rd_i),
    .alu_zero_o(ex_mem_alu_zero_i),
    .alu_result_o(ex_mem_alu_result_i),
    .rs2_data_o(ex_mem_rs2_data_i),
    .pc_o(ex_mem_pc_i),
    .pc_4_o(ex_mem_pc_4_i),
    .pc_imm_o(ex_mem_pc_imm_i),
    .memwrite_en_o(ex_mem_memwrite_en_i),
    .memread_en_o(ex_mem_memread_en_i),
    .branch_o(ex_mem_branch_i),
    .jmp_o(ex_mem_jmp_i),
    .wb_en_o(ex_mem_wb_en_i),
    .wb_src_o(ex_mem_wb_src_i),
    .wb_pc_src_o(ex_mem_wb_pc_src_i)
  );

  // =============================
  // EX_MEM pipeline registers
  // =============================
  ex_mem_stage ex_mem_stage (
    .clk_i(clk_i),
    .n_rst(n_rst),
    .stall(ex_mem_stall),
    .flush(ex_mem_flush),

    .ex_rd_i(ex_mem_rd_i),
    .ex_alu_zero_i(ex_mem_alu_zero_i),
    .ex_alu_result_i(ex_mem_alu_result_i),
    .ex_rs2_data_i(ex_mem_rs2_data_i),
    .ex_pc_i(ex_mem_pc_i),
    .ex_pc_4_i(ex_mem_pc_4_i),
    .ex_pc_imm_i(ex_mem_pc_imm_i),
    .ex_memwrite_en_i(ex_mem_memwrite_en_i),
    .ex_memread_en_i(ex_mem_memread_en_i),
    .ex_branch_i(ex_mem_branch_i),
    .ex_jmp_i(ex_mem_jmp_i),
    .ex_wb_en_i(ex_mem_wb_en_i),
    .ex_wb_src_i(ex_mem_wb_src_i),
    .ex_wb_pc_src_i(ex_mem_wb_pc_src_i),

    .mem_rd_o(ex_mem_rd_o),
    .mem_alu_zero_o(ex_mem_alu_zero_o),
    .mem_alu_result_o(ex_mem_alu_result_o),
    .mem_rs2_data_o(ex_mem_rs2_data_o),
    .mem_pc_o(ex_mem_pc_o),
    .mem_pc_4_o(ex_mem_pc_4_o),
    .mem_pc_imm_o(ex_mem_pc_omm_o),
    .mem_memwrite_en_o(ex_mem_memwrite_en_o),
    .mem_memread_en_o(ex_mem_memread_en_o),
    .mem_branch_o(ex_mem_branch_o),
    .mem_jmp_o(ex_mem_jmp_o),
    .mem_wb_en_o(ex_mem_wb_en_o),
    .mem_wb_src_o(ex_mem_wb_src_o),
    .mem_wb_pc_src_o(ex_mem_wb_pc_src_o)
  );

  memory memory (
    .clk_i(clk_i),
    .n_rst(n_rst),

    .rd_i(ex_mem_rd_o),
    .alu_zero_i(ex_mem_alu_zero_o),
    .alu_result_i(ex_mem_alu_result_o),
    .rs2_data_i(ex_mem_rs2_data_o),
    .pc_i(ex_mem_pc_o),
    .pc_4_i(ex_mem_pc_4_o),
    .pc_imm_i(ex_mem_pc_omm_o),
    .memwrite_en_i(ex_mem_memwrite_en_o),
    .memread_en_i(ex_mem_memread_en_o),
    .branch_i(ex_mem_branch_o),
    .jmp_i(ex_mem_jmp_o),
    .wb_en_i(ex_mem_wb_en_o),
    .wb_src_i(ex_mem_wb_src_o),
    .wb_pc_src_i(ex_mem_wb_pc_src_o),

    .rd_o(mem_wb_rd_i),
    .wb_en_o(mem_wb_en_i),
    .wb_value_o(mem_wb_value_i),
    .next_pc_o(branch_pc),
    .branch_taken_o(branch_taken),
    .stall_o(mem_stall_o),
    .ram_if(iram_if.master)
  );

  mem_wb_stage mem_wb_stage (
    .clk_i(clk_i),
    .n_rst(n_rst),
    .flush(mem_wb_flush),
    .stall(mem_wb_stall),

    .mem_rd_i(mem_wb_rd_i),
    .mem_wb_en_i(mem_wb_en_i),
    .mem_wb_value_i(mem_wb_value_i),

    .wb_rd_o(mem_wb_rd_o),
    .wb_en_o(mem_wb_en_o),
    .wb_value_o(mem_wb_value_o)
  );

  write_back write_back (
    .clk_i(clk_i),
    .n_rst(n_rst),

    .rd_i(mem_wb_rd_o),
    .wb_en_i(mem_wb_en_o),
    .wb_value_i(mem_wb_value_o),

    .rd_o(wb_id_rd_o),
    .rd_we_en_o(wb_id_en_o),
    .rd_value_o(wb_id_value_o)
  );

endmodule
