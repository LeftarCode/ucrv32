module mem_wb_stage (
  input wire clk_i,
  input wire n_rst,
  input logic flush,
  input logic stall,
  
  input logic [4:0] mem_rd_i,
  input logic mem_wb_en_i,
  input logic [31:0] mem_wb_value_i,

  output logic [4:0] wb_rd_o,
  output logic wb_en_o,
  output logic [31:0] wb_value_o
);

always_ff @(posedge clk_i or negedge n_rst) begin
  if (!n_rst) begin
    wb_rd_o <= 5'b0;
    wb_en_o <= `DISABLE;
    wb_value_o <= `ZERO;
  end 
  else begin
    if (flush) begin
      wb_rd_o <= 5'b0;
      wb_en_o <= `DISABLE;
      wb_value_o <= `ZERO;
    end 
    else if (!stall) begin
      wb_rd_o <= mem_rd_i;
      wb_en_o <= mem_wb_en_i;
      wb_value_o <= mem_wb_value_i;
    end
  end
end

endmodule