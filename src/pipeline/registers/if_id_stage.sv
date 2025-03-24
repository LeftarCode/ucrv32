module if_id_stage (
  input wire clk_i,
  input wire n_rst,
  input logic flush,
  input logic stall,

  input logic if_valid,
  input logic [31:0] if_inst,
  input logic [31:0] if_pc,

  output logic [31:0] id_inst,
  output logic [31:0] id_pc
);

always_ff @(posedge clk_i or negedge n_rst) begin
  if (!n_rst) begin
    id_inst <= 32'h00000013;
    id_pc   <= 32'h0;
  end 
  else begin
    if (flush) begin
      id_inst <= 32'h00000013;
      id_pc   <= 32'h0;
    end 
    else if (!stall) begin
      id_inst <= (if_valid) ? if_inst : 32'h00000013;
      id_pc   <= if_pc;
    end
  end
end

endmodule