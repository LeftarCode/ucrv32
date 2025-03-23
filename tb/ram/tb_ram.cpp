#include <cstdlib>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vtb_ram.h"
#include <cstdint>

int32_t read_a(Vtb_ram* dut, int32_t addr) {
  dut->en_i_a = 1;
  dut->we_i_a = 0;
  dut->addr_i_a = addr;
  dut->eval();
  int32_t data = dut->data_o_a;
  std::cout << "[READ_A] Address: 0x" << std::hex << addr 
            << " -> Data: 0x" << std::hex << data << std::endl;
  return data;
}

int32_t read_b(Vtb_ram* dut, int32_t addr) {
  dut->en_i_b = 1;
  dut->we_i_b = 0;
  dut->addr_i_b = addr;
  dut->eval();
  int32_t data = dut->data_o_b;
  std::cout << "[READ_B] Address: 0x" << std::hex << addr 
            << " -> Data: 0x" << std::hex << data << std::endl;
  return data;
}

void write_a(Vtb_ram* dut, int32_t addr, int32_t value) {
  dut->en_i_a = 1;
  dut->we_i_a = 0xF;
  dut->addr_i_a = addr;
  dut->data_i_a = value;
  std::cout << "[WRITE_A] Address: 0x" << std::hex << addr 
            << " <- Data: 0x" << std::hex << value << std::endl;
  dut->eval();
}

void write_b(Vtb_ram* dut, int32_t addr, int32_t value) {
  dut->en_i_b = 1;
  dut->we_i_b = 0xF;
  dut->addr_i_b = addr;
  dut->data_i_b = value;
  std::cout << "[WRITE_B] Address: 0x" << std::hex << addr 
            << " <- Data: 0x" << std::hex << value << std::endl;
  dut->eval();
}

void reset_inputs(Vtb_ram* dut) {
  dut->en_i_a = 0;
  dut->en_i_b = 0;
  dut->we_i_a = 0;
  dut->we_i_b = 0;
  dut->data_i_a = 0x00000000;
  dut->data_i_b = 0x00000000;
  dut->addr_i_a = 0x00000000;
  dut->addr_i_b = 0x00000000;
  dut->eval();
}

int main(int argc, char** argv) {
  Verilated::commandArgs(argc, argv);
  Vtb_ram* dut = new Vtb_ram;
  Verilated::traceEverOn(true);
  VerilatedVcdC* m_trace = new VerilatedVcdC;
  dut->trace(m_trace, 5);
  m_trace->open("waveform.vcd");
  uint64_t sim_time = 0;
  const int clk_period = 1;
  auto tick = [&]() {
    for (int i = 0; i < 4; i++) {
      dut->clk_i ^= 1;
      dut->eval();
      m_trace->dump(sim_time);
      sim_time += clk_period;
    }
  };
  std::cout << "\n===== TEST 1: Port A Full Write/Read =====\n";
  tick();
  write_a(dut, 0x00, 0xAABBCCDD);
  tick();
  int32_t data_a = read_a(dut, 0x00);
  if (data_a != 0xAABBCCDD) {
    std::cerr << "Error: Port A - expected 0xAABBCCDD, got 0x" 
              << std::hex << data_a << std::endl;
    exit(EXIT_FAILURE);
  } else {
    std::cout << "Test Port A full write/read PASSED.\n";
  }
  reset_inputs(dut);
  std::cout << "\n===== TEST 2: Port B Full Write/Read =====\n";
  tick();
  write_b(dut, 0x04, 0x11223344);
  tick();
  int32_t data_b = read_b(dut, 0x04);
  if (data_b != 0x11223344) {
    std::cerr << "Error: Port B - expected 0x11223344, got 0x" 
              << std::hex << data_b << std::endl;
    exit(EXIT_FAILURE);
  } else {
    std::cout << "Test Port B full write/read PASSED.\n";
  }
  reset_inputs(dut);
  std::cout << "\n===== TEST 3: Port A Partial Write =====\n";
  tick();
  dut->en_i_a = 1;
  dut->we_i_a = 1 << 0;
  dut->addr_i_a = 0x08;
  dut->data_i_a = 0xFF000000;
  dut->eval();
  tick();
  int32_t data_a2 = read_a(dut, 0x08);
  if (((data_a2 >> 24) & 0xFF) != 0xFF) {
    std::cerr << "Error: Port A Partial Write - expected MSB 0xFF, got 0x" 
              << std::hex << ((data_a2 >> 24) & 0xFF) << std::endl;
    exit(EXIT_FAILURE);
  } else {
    std::cout << "Test Port A partial write PASSED.\n";
  }
  reset_inputs(dut);
  std::cout << "\n===== TEST 4: Simultaneous Write/Read on Both Ports =====\n";
  tick();
  write_a(dut, 0x00, 0xDEADBEEF);
  write_b(dut, 0x04, 0xCAFEBABE);
  tick();
  int32_t data_a3 = read_a(dut, 0x00);
  int32_t data_b3 = read_b(dut, 0x04);
  if (data_a3 != 0xDEADBEEF) {
    std::cerr << "Error: Port A simultaneous test - expected 0xDEADBEEF, got 0x"
              << std::hex << data_a3 << std::endl;
    exit(EXIT_FAILURE);
  }
  if (data_b3 != 0xCAFEBABE) {
    std::cerr << "Error: Port B simultaneous test - expected 0xCAFEBABE, got 0x"
              << std::hex << data_b3 << std::endl;
    exit(EXIT_FAILURE);
  }
  std::cout << "Simultaneous write/read test PASSED.\n";
  reset_inputs(dut);
  m_trace->close();
  delete m_trace;
  delete dut;
  std::cout << "\nALL TESTS PASSED.\n";
  exit(EXIT_SUCCESS);
}
