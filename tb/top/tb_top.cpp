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

int main(int argc, char** argv, char** env) {
    Vtop *dut = new Vtop;
    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    int fails = 0;
    uint64_t sim_time = 0;
    dut->decode_ready = 1;
    // NORMAL RUN
    while (sim_time < MAX_TIME/5) {
      dut->clk_i ^= 1;
      dut->eval();
      m_trace->dump(sim_time++);
    }
   
    // NEW BRANCH
    dut->clk_i ^= 1;
    dut->branch_taken_en_i = 1;
    dut->next_pc_i = 0x00000000;
    dut->eval();
    m_trace->dump(sim_time++);

    dut->clk_i ^= 1;
    dut->eval();
    m_trace->dump(sim_time++);
    dut->branch_taken_en_i = 0;

    // CONTINUE WITH NEW PC
    while (sim_time < 2*MAX_TIME/5) {
      dut->clk_i ^= 1;
      dut->eval();
      m_trace->dump(sim_time++);
    }
   
    dut->decode_ready = 0;
    // CONTINUE WITHOUT READY
    while (sim_time < 3*MAX_TIME/5) {
      dut->clk_i ^= 1;
      dut->eval();
      m_trace->dump(sim_time++);
    }

    dut->decode_ready = 1;
    // RESUME
    while (sim_time < 4*MAX_TIME/5) {
      dut->clk_i ^= 1;
      dut->eval();
      m_trace->dump(sim_time++);
    }

    // NEW BRANCH BUT DECODER NOT READY
    dut->clk_i ^= 1;
    dut->decode_ready = 0;
    dut->branch_taken_en_i = 1;
    dut->next_pc_i = 0x00000000;
    dut->eval();
    m_trace->dump(sim_time++);

    dut->clk_i ^= 1;
    dut->eval();
    m_trace->dump(sim_time++);
    dut->branch_taken_en_i = 0;
    // RESUME
    while (sim_time < MAX_TIME) {
      dut->clk_i ^= 1;
      dut->eval();
      m_trace->dump(sim_time++);
    }

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}
