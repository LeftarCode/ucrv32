`include "common/multiplexers/mux4to1.sv"

module memory (
  input logic clk_i,
  input logic n_rst,

  input logic [4:0] rd_i,
  input logic alu_zero_i,
  input logic [31:0] alu_result_i,
  input logic [31:0] rs2_data_i,
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
  output logic wb_en_o,
  output logic [31:0] wb_value_o,
  output logic [31:0] next_pc_o,
  output logic branch_taken_o,
  output logic stall_o,

  ram_interface.master ram_if
);
logic memory_op;
logic stall;
logic memory_delay;

assign memory_op = memread_en_i | memwrite_en_i;
assign stall = (memory_op && (memory_delay == 1'b0));

assign rd_o = rd_i;
assign stall_o = stall;
assign wb_en_o = (stall == `ENABLE) ? 1'b0 : wb_en_i;

// If it's branch AND alu_result isn't zero (condition is true) OR when it's simple jmp then branch is taken.
assign branch_taken_o = jmp_i | (branch_i & ~alu_zero_i);

assign ram_if.en_i_b = `ENABLE;
assign ram_if.we_i_b = {4{memwrite_en_i}};
assign ram_if.addr_i_b = alu_result_i;
assign ram_if.data_i_b = rs2_data_i;

always_ff @(posedge clk_i or negedge n_rst) begin
  if (!n_rst) begin
    memory_delay <= 1'b0;
  end else if (memory_op && (memory_delay == 1'b0)) begin
    memory_delay <= 1'b1;
  end else if (memory_delay > 0) begin
    memory_delay <= memory_delay + 1;
  end
end

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
  .in3(ram_if.data_o_b),
  .out(wb_value_o),
  .sel(wb_src_i)
);

endmodule
