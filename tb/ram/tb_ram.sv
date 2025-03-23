`include "../../src/common/ram.sv"

/// Verilator doesn't support interfaces in top module
/// So it was required to create that wrapper
module ram_wrapper(
  input  logic         clk_i,
  input  logic         en_i_a,
  input  logic [31:0]  addr_i_a,
  input  logic [3:0]   we_i_a,
  input  logic [31:0]  data_i_a,
  output logic [31:0]  data_o_a,
  input  logic         en_i_b,
  input  logic [31:0]  addr_i_b,
  input  logic [3:0]   we_i_b,
  input  logic [31:0]  data_i_b,
  output logic [31:0]  data_o_b
);

  ram_interface ram_if_inst(clk_i, clk_i);

  assign ram_if_inst.en_i_a   = en_i_a;
  assign ram_if_inst.addr_i_a = addr_i_a;
  assign ram_if_inst.we_i_a   = we_i_a;
  assign ram_if_inst.data_i_a = data_i_a;
  assign data_o_a             = ram_if_inst.data_o_a;

  assign ram_if_inst.en_i_b   = en_i_b;
  assign ram_if_inst.addr_i_b = addr_i_b;
  assign ram_if_inst.we_i_b   = we_i_b;
  assign ram_if_inst.data_i_b = data_i_b;
  assign data_o_b             = ram_if_inst.data_o_b;

  ram #(
    .DATA_DEPTH(8192)
  ) u_ram (
    .ram_if( ram_if_inst.slave )
  );

endmodule
