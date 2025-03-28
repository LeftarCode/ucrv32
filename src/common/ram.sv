`include "common/interfaces.sv"
/* verilator lint_off MULTIDRIVEN */
module ram #(
  parameter DATA_DEPTH = 8192
)(
  ram_interface.slave ram_if
);
  (* ram_style = "block" *)
  logic [7:0] data [0:DATA_DEPTH-1];

  // NOTE: It's quite possible that R/W are exclusive and read should 
  // be in else block
  always_ff @(posedge ram_if.clk_i_a) begin
    if (ram_if.en_i_a) begin
      if (ram_if.we_i_a[0]) data[ram_if.addr_i_a + 0] <= ram_if.data_i_a[7:0];
      if (ram_if.we_i_a[1]) data[ram_if.addr_i_a + 1] <= ram_if.data_i_a[15:8];
      if (ram_if.we_i_a[2]) data[ram_if.addr_i_a + 2] <= ram_if.data_i_a[23:16];
      if (ram_if.we_i_a[3]) data[ram_if.addr_i_a + 3] <= ram_if.data_i_a[31:24];
      ram_if.data_o_a <= { data[ram_if.addr_i_a + 3], data[ram_if.addr_i_a + 2], data[ram_if.addr_i_a + 1], data[ram_if.addr_i_a + 0] };
    end
  end

  always_ff @(posedge ram_if.clk_i_b) begin
    if (ram_if.en_i_b) begin
      if (ram_if.we_i_b[0]) data[ram_if.addr_i_b + 0] <= ram_if.data_i_b[7:0];
      if (ram_if.we_i_b[1]) data[ram_if.addr_i_b + 1] <= ram_if.data_i_b[15:8];
      if (ram_if.we_i_b[2]) data[ram_if.addr_i_b + 2] <= ram_if.data_i_b[23:16];
      if (ram_if.we_i_b[3]) data[ram_if.addr_i_b + 3] <= ram_if.data_i_b[31:24];
      ram_if.data_o_b <= { data[ram_if.addr_i_b + 3], data[ram_if.addr_i_b + 2], data[ram_if.addr_i_b + 1], data[ram_if.addr_i_b + 0] };
    end
  end

  initial begin
    $readmemh("../../assets/instr.bin", data);
  end

endmodule
/* verilator lint_on MULTIDRIVEN */
