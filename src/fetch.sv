`include "common/interfaces.sv"

typedef enum logic[1:0] {STATE_INIT=0, STATE_NEW_PC=1, STATE_READY=2} fetch_state;

module fetch #(
  parameter XLEN = 32
)(
  input logic clk_i,
  // Branch 
  input logic branch_taken_en_i,
  input logic [XLEN-1:0] next_pc_i,
  // Skid buffer
  output logic valid_o,
  output logic [XLEN-1:0] instruction,
  input logic ready_i,
  // BRAM Interface
  ram_interface.master ram_if
);
  logic [XLEN-1:0] pc = 0;
  fetch_state state = STATE_INIT;

  assign ram_if.en_i_a = 1;
  assign ram_if.addr_i_a = pc;
  assign instruction = ram_if.data_o_a;
  assign valid_o = state == STATE_READY;

  // NOTE: Not handled case: NEW_PC + !READY_I it may lost one instruction
  always_ff @(posedge clk_i) begin
    case (state)
      STATE_INIT: begin
        state <= STATE_READY;
      end
      STATE_READY: begin
        if (branch_taken_en_i) begin
          state <= STATE_NEW_PC;
        end
      end
      STATE_NEW_PC: begin
        state <= STATE_READY;
      end
      default: state <= STATE_INIT;
    endcase
  end

  always_ff @(posedge clk_i) begin
    if (branch_taken_en_i) begin
      pc <= next_pc_i;
    end else if (ready_i) begin
      pc <= pc + 4;
    end
  end 

endmodule
