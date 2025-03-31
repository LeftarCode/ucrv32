#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vtop.h"
#include <iostream>
#include <cstdint>

int main(int argc, char **argv) {
  Verilated::commandArgs(argc, argv);
  Verilated::traceEverOn(true);
  Vtop *dut = new Vtop;
  VerilatedVcdC *m_trace = new VerilatedVcdC;
  dut->trace(m_trace, 5);
  m_trace->open("waveform.vcd");

  int sim_time = 0;
  dut->n_rst = 1;
  
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
