`include "common/multiplexers/mux4to1.sv"

module write_back (
  input logic clk_i,
  input logic n_rst,

  input logic [4:0] rd_i,
  input logic wb_en_i,
  input logic [31:0] wb_value_i,

  output logic [4:0] rd_o,
  output logic rd_we_en_o,
  output logic [31:0] rd_value_o
);

assign rd_o = rd_i;
assign rd_we_en_o = wb_en_i;
assign rd_value_o = wb_value_i;

endmodule
