/* verilator lint_off MODDUP */
`include "fetch.sv"
`include "controller.sv"
`include "pipeline/if_id_stage.sv"
`include "common/ram.sv"
`include "common/multiplexers/mux2to1.sv"

module top (
  input wire clk_i,
  input wire n_rst,

  // FIXME: TEMP input
  input logic alu_next_pc_en,
  input logic [31:0] alu_next_pc,

  // Decoder output signals
  output logic [31:0] dec_imm,
  output logic [4:0] dec_rs1,
  output logic [4:0] dec_rs2,
  output logic [4:0] dec_rd,
  output logic [6:0] dec_opcode,
  output logic [2:0] dec_funct3,
  output logic [6:0] dec_funct7,
  output logic dec_exception_en,
  output exception_type dec_exception,
  output logic dec_jal,
  output logic dec_reg2mem,
  output logic dec_mem2reg,
  output logic dec_alu_wb,
  output logic dec_syscall,
  output logic dec_branch,
  output logic dec_rs1_en,
  output logic dec_rs2_en
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
  // FIXME: const signals
  // =============================
  logic if_id_flush = 1'b0;
  logic if_id_stall = 1'b0;

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
  controller controller (
    .instruction_i  (if_id_instruction_o),
    .immediate_o    (dec_imm),
    .rs1_o          (dec_rs1),
    .rs1_en_o       (dec_rs1_en),
    .rs2_o          (dec_rs2),
    .rs2_en_o       (dec_rs2_en),
    .rd_o           (dec_rd),
    .opcode_o       (dec_opcode),
    .funct3_o       (dec_funct3),
    .funct7_o       (dec_funct7),
    .exception_en_o (dec_exception_en),
    .exception_o    (dec_exception),
    .jal_o          (dec_jal),
    .reg2mem_o      (dec_reg2mem),
    .mem2reg_o      (dec_mem2reg),
    .alu_writeback_o(dec_alu_wb),
    .syscall_o      (dec_syscall),
    .branch_o       (dec_branch)
  );

endmodule
