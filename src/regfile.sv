module regfile (
    input  logic clk,
    input  logic n_rst,
    input  logic [4:0] rs1,
    input  logic [4:0] rs2,
    input  logic [4:0] rd,
    input  logic [31:0] wd,
    input  logic we,
    output logic [31:0] rd1,
    output logic [31:0] rd2
);
  logic [31:0] reg_array [31:0];

  always_ff @(posedge clk or negedge n_rst) begin
    if (reset) begin
      integer i;
      for (i = 0; i < 32; i = i + 1) begin
        reg_array[i] <= 32'd0;
      end
    end else begin
      if (we && (rd != 5'd0)) begin
        reg_array[rd] <= wd;
      end
    end
  end

  assign rd1 = (rs1 == 5'd0) ? 32'd0 : reg_array[rs1];
  assign rd2 = (rs2 == 5'd0) ? 32'd0 : reg_array[rs2];

endmodule
