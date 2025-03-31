module regfile (
    input  logic clk_i,
    input  logic n_rst,
    input  logic [4:0] rs1_addr_i,
    input  logic [4:0] rs2_addr_i,
    input  logic [4:0] rd_addr_i,
    input  logic [31:0] wd_i,
    input  logic we_i,
    output logic [31:0] rs1_data_o,
    output logic [31:0] rs2_data_o
);
  logic [31:0] reg_array [31:0];

  always_ff @(posedge clk_i or negedge n_rst) begin
    if (!n_rst) begin
      integer i;
      for (i = 0; i < 32; i = i + 1) begin
        reg_array[i] <= 32'd0;
      end
    end else begin
      if (we_i && (rd_addr_i != 5'd0)) begin
        reg_array[rd_addr_i] <= wd_i;
      end
    end
  end

  assign rs1_data_o = (rs1_addr_i == 5'd0) ? 32'd0 : reg_array[rs1_addr_i];
  assign rs2_data_o = (rs2_addr_i == 5'd0) ? 32'd0 : reg_array[rs2_addr_i];

endmodule
