`include "interfaces.sv"
/* verilator lint_off MULTIDRIVEN */
module ram #(
  parameter DATA_DEPTH = 8192
)(
  ram_interface.slave ram_if
);
  (* ram_style = "block" *)
  logic [7:0] data0 [0:DATA_DEPTH-1];
  logic [7:0] data1 [0:DATA_DEPTH-1];
  logic [7:0] data2 [0:DATA_DEPTH-1];
  logic [7:0] data3 [0:DATA_DEPTH-1];

  // NOTE: It's quite possible that R/W are exclusive and read should 
  // be in else block
  always_ff @(posedge ram_if.clk_i_a) begin
    if (ram_if.en_i_a) begin
      if (ram_if.we_i_a[0]) data3[ram_if.addr_i_a >> 2] <= ram_if.data_i_a[31:24];
      if (ram_if.we_i_a[1]) data2[ram_if.addr_i_a >> 2] <= ram_if.data_i_a[23:16];
      if (ram_if.we_i_a[2]) data1[ram_if.addr_i_a >> 2] <= ram_if.data_i_a[15:8];
      if (ram_if.we_i_a[3]) data0[ram_if.addr_i_a >> 2] <= ram_if.data_i_a[7:0];
      ram_if.data_o_a <= { data3[ram_if.addr_i_a >> 2], data2[ram_if.addr_i_a >> 2], data1[ram_if.addr_i_a >> 2], data0[ram_if.addr_i_a >> 2] };
    end
  end

  always_ff @(posedge ram_if.clk_i_b) begin
    if (ram_if.en_i_b) begin
      if (ram_if.we_i_b[0]) data3[ram_if.addr_i_b >> 2] <= ram_if.data_i_b[31:24];
      if (ram_if.we_i_b[1]) data2[ram_if.addr_i_b >> 2] <= ram_if.data_i_b[23:16];
      if (ram_if.we_i_b[2]) data1[ram_if.addr_i_b >> 2] <= ram_if.data_i_b[15:8];
      if (ram_if.we_i_b[3]) data0[ram_if.addr_i_b >> 2] <= ram_if.data_i_b[7:0];
      ram_if.data_o_b <= { data3[ram_if.addr_i_b >> 2], data2[ram_if.addr_i_b >> 2], data1[ram_if.addr_i_b >> 2], data0[ram_if.addr_i_b >> 2] };
    end
  end

  initial begin
    $readmemh("../../assets/rand0.bin", data0);
    $readmemh("../../assets/rand1.bin", data1);
    $readmemh("../../assets/rand2.bin", data2);
    $readmemh("../../assets/rand3.bin", data3);
  end

endmodule
/* verilator lint_on MULTIDRIVEN */
