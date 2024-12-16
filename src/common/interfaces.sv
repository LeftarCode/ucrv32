/* verilator lint_off DECLFILENAME */
interface ram_interface #(
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 32
)(
  input logic clk_i_a,
  input logic clk_i_b
);
  // PORT A
  logic we_i_a;
  logic en_i_a;
  logic [DATA_WIDTH-1:0] data_i_a;
  logic [DATA_WIDTH-1:0] data_o_a;
  logic [ADDR_WIDTH-1:0] addr_i_a;
  // PORT B
  logic we_i_b;
  logic en_i_b;
  logic [DATA_WIDTH-1:0] data_i_b;
  logic [DATA_WIDTH-1:0] data_o_b;
  logic [ADDR_WIDTH-1:0] addr_i_b;

  modport master (
    // PORT A
    input clk_i_a,
    output we_i_a,
    output en_i_a,
    output data_i_a,
    input data_o_a,
    output addr_i_a,
    // PORT B
    input clk_i_b,
    output we_i_b,
    output en_i_b,
    output data_i_b,
    input data_o_b,
    output addr_i_b
  );

  modport slave (
    // PORT A
    input clk_i_a,
    input we_i_a,
    input en_i_a,
    input data_i_a,
    output data_o_a,
    input addr_i_a,
    // PORT B
    input clk_i_b,
    input we_i_b,
    input en_i_b,
    input data_i_b,
    output data_o_b,
    input addr_i_b
  );
endinterface
