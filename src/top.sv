module top (
  input wire clk_i,
  input wire n_rst,
  output reg [7:0] counter_o
);
  always @(clk_i) begin
    counter_o <= counter_o + 1;
  end

endmodule
