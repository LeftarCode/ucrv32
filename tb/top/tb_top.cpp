#include <stdlib.h>
#include <iostream>
#include <cstdlib>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vtop.h"
#include <vector>
#include <stdint.h>
#include <random>
#include <exception>
#include <limits.h>

#define MAX_TIME 500
int sim_time = 0;

int main(int argc, char** argv, char** env) {
    Vtop *dut = new Vtop;
    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    dut->n_rst = 1;

    while (sim_time < MAX_TIME/2) {
      dut->clk_i ^= 1;
      dut->eval();
      m_trace->dump(sim_time++);
    }

    dut->clk_i ^= 1;
    dut->eval();
    m_trace->dump(sim_time++);
    
    dut->clk_i ^= 1;
    dut->alu_next_pc_en = 1;
    dut->alu_next_pc = 0;
    dut->eval();
    m_trace->dump(sim_time++);

    dut->alu_next_pc_en = 0;

    while (sim_time < MAX_TIME) {
      dut->clk_i ^= 1;
      dut->eval();
      m_trace->dump(sim_time++);
    }

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}
