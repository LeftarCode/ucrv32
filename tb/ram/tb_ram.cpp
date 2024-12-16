#include <stdlib.h>
#include <iostream>
#include <cstdlib>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vram.h"
#include <vector>
#include <stdint.h>
#include <random>
#include <exception>
#include <limits.h>

int32_t read_a(Vram* dut, int32_t addr) {
  dut->en_i_a = 1;
  dut->addr_i_a = addr;

  std::cout << "[READ_A] Address: 0x" << std::hex << addr << ", data: 0x" << std::hex << dut->data_o_a << std::endl;
  return dut->data_o_a;
}

int32_t read_b(Vram* dut, int32_t addr) {
  dut->en_i_b = 1;
  dut->addr_i_b = addr;

  std::cout << "[READ_B] Address: 0x" << std::hex << addr << ", data: 0x" << std::hex << dut->data_o_b << std::endl;
  return dut->data_o_b;
}

void write_a(Vram* dut, int32_t addr, int32_t value) {
  dut->en_i_a = 1;
  dut->we_i_a = 1;
  dut->addr_i_a = addr;
  dut->data_i_a = value;
  std::cout << "[WRITE_A] Address: 0x" << std::hex << addr << ", data: 0x" << std::hex << value << std::endl;
}

void write_b(Vram* dut, int32_t addr, int32_t value) {
  dut->en_i_b = 1;
  dut->we_i_b = 1;
  dut->addr_i_b = addr;
  dut->data_i_b = value;
  std::cout << "[WRITE_B] Address: 0x" << std::hex << addr << ", data: 0x" << std::hex << value << std::endl;
}

void reset_inputs(Vram* dut) {
  dut->en_i_a = 0;
  dut->en_i_b = 0;
  dut->we_i_a = 0;
  dut->we_i_b = 0;
  dut->data_i_a = 0x00000000;
  dut->data_i_b = 0x00000000;
  dut->addr_i_a = 0x00000000;
  dut->addr_i_b = 0x00000000;
}


int main(int argc, char** argv, char** env) {
    Vram *dut = new Vram;
    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    uint64_t sim_time = 0;
    // TEST1
    dut->clk_i_a ^= 1;
    dut->clk_i_b ^= 1;
    read_a(dut, 0x00000000);
    read_b(dut, 0x00000001);
    dut->eval();
    m_trace->dump(sim_time++);
    dut->clk_i_a ^= 1;
    dut->clk_i_b ^= 1;
    dut->eval();
    m_trace->dump(sim_time++);
    reset_inputs(dut);

    // TEST1
    dut->clk_i_a ^= 1;
    dut->clk_i_b ^= 1;
    write_a(dut, 0x00000000, 0x13377331);
    write_b(dut, 0x00000001, 0x13377331);
    dut->eval();
    m_trace->dump(sim_time++);
    dut->clk_i_a ^= 1;
    dut->clk_i_b ^= 1;
    dut->eval();
    m_trace->dump(sim_time++);
    reset_inputs(dut);

    // TEST1
    dut->clk_i_a ^= 1;
    dut->clk_i_b ^= 1;
    read_a(dut, 0x00000000);
    read_b(dut, 0x00000001);
    dut->eval();
    m_trace->dump(sim_time++);
    dut->clk_i_a ^= 1;
    dut->clk_i_b ^= 1;
    dut->eval();
    m_trace->dump(sim_time++);
    reset_inputs(dut);

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}
