/* verilator lint_off MODDUP */
`include "fetch.sv"
`include "common/ram.sv"

module top #(
  parameter XLEN = 32
)(
  input wire clk_i,
  input wire n_rst,
  input branch_taken_en_i,
  input [XLEN-1:0] next_pc_i,
  input decode_ready
);

  logic [31:0] instruction = 0;
  logic fetch_ready = 0;

  ram_interface ram_if (clk_i, clk_i);

  ram main_memory(
    .ram_if(ram_if.slave)
  );

  fetch #(.XLEN(XLEN)) fetch(
    .clk_i(clk_i),
    .branch_taken_en_i(branch_taken_en_i),
    .next_pc_i(next_pc_i),
    .valid_o(fetch_ready),
    .instruction(instruction),
    .ready_i(decode_ready),
    .ram_if(ram_if.master)
  );

endmodule
