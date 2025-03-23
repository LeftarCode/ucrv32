`include "common/interfaces.sv"

typedef enum logic {STATE_INIT=0, STATE_READY=1} fetch_state;

module fetch(
  input logic clk_i,
  // Branch
  input logic [31:0] pc_i,
  // Skid buffer
  output logic valid_o,
  output logic [31:0] instruction_o,
  output logic [31:0] pc_o,
  // BRAM Interface
  ram_interface.master ram_if
);
  fetch_state state = STATE_INIT;
  logic [1:0] init_counter = 0;
  logic [31:0] fetched_pc;

  assign ram_if.en_i_a = 1;
  assign ram_if.addr_i_a = pc_i;
  assign instruction_o = ram_if.data_o_a;
  assign pc_o = fetched_pc;
  assign valid_o = state == STATE_READY;

  always_ff @(posedge clk_i) begin
    case (state)
      STATE_INIT: begin
        state <= STATE_READY;
        fetched_pc   <= pc_i;
      end
      STATE_READY: begin
        fetched_pc   <= pc_i;
      end
      default: state <= STATE_INIT;
    endcase
  end

endmodule
