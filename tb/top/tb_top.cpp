#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vtop.h"
#include <iostream>
#include <cstdint>

#define MAX_TIME 500

#define ENABLE 1
#define DISABLE 0
#define WB_SRC_NONE 0
#define WB_SRC_ALU 1
#define WB_SRC_PC_4 2
#define WB_SRC_MEM 3
#define PC_SRC_NONE 0
#define PC_SRC_ALU 1
#define PC_SRC_PC_4 2
#define PC_SRC_PC_IMM 3

struct ExpectedSignals
{
  int cycle;
  bool alu_zero;
  uint32_t alu_result;
  uint32_t pc;
  uint32_t pc_4;
  uint32_t pc_imm;
  bool memwrite_en;
  bool memread_en;
  bool wb_en;
  int wb_src;
  int wb_pc_src;
};

int main(int argc, char **argv)
{
  Verilated::commandArgs(argc, argv);
  Verilated::traceEverOn(true);
  Vtop *dut = new Vtop;
  VerilatedVcdC *m_trace = new VerilatedVcdC;
  dut->trace(m_trace, 5);
  m_trace->open("waveform.vcd");

  // Reset sequence (active low)
  int sim_time = 0;
  dut->n_rst = 1;

  ExpectedSignals expected[] = {
    //cycle,alu_z alu_result,   pc,       pc_4,      pc_imm,   memwr_en,memd_en,wb_en, wb_src,   wb_pc_src
    {3, false, 0x12345000, 0x00000000, 0x00000004, 0x12345000, false, false, true,  WB_SRC_ALU,   PC_SRC_NONE},     // LUI   x1, 0x12345
    {4, true,  0x00000000, 0x00000004, 0x00000008, 0x1004,      false, false, false, WB_SRC_NONE,  PC_SRC_PC_IMM},   // AUIPC x2, 0x1
    {5, true,  0x00000000, 0x00000008, 0x0000000C, 0x10,        false, false, true,  WB_SRC_PC_4,  PC_SRC_PC_IMM},   // JAL   x3, label_jal
    {6, true,  0x00000000, 0x0000000C, 0x00000010, 0x0000000C, false, false, true,  WB_SRC_PC_4,  PC_SRC_ALU}    // JALR  x4, x1, 0
  };
  const int num_tests = sizeof(expected) / sizeof(expected[0]);

  for (int i = 0; i < 30; i++) {
    dut->clk_i = 0;
    dut->eval();
    m_trace->dump(sim_time++);
    dut->clk_i = 1;
    dut->eval();
    m_trace->dump(sim_time++);
  }

  m_trace->close();
  dut->final();
  delete dut;
  return 0;
}
