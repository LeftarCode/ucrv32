`include "interfaces.sv"
/* verilator lint_off MULTIDRIVEN */
module ram #(
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 32,
  parameter DATA_DEPTH = 8192
)(
  ram_interface.slave ram_if
);

  logic [DATA_WIDTH-1:0] data [0:$clog2(DATA_DEPTH)-1];

  // NOTE: It's quite possible that R/W are exclusive and read should 
  // be in else block
  always_ff @(posedge ram_if.clk_i_a) begin
    if (ram_if.en_i_a) begin
      if (ram_if.we_i_a) begin
        data[ram_if.addr_i_a] <= ram_if.data_i_a;
      end
      ram_if.data_o_a <= data[ram_if.addr_i_a];
    end
  end

  always_ff @(posedge ram_if.clk_i_b) begin
    if (ram_if.en_i_b) begin
      if (ram_if.we_i_b) begin
        data[ram_if.addr_i_b] <= ram_if.data_i_b;
      end
      ram_if.data_o_b <= data[ram_if.addr_i_b];
    end
  end

  initial begin
    $readmemh("../../assets/instructions.bin", data);
  end

endmodule
/* verilator lint_on MULTIDRIVEN */
