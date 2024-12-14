#include <stdlib.h>
#include <iostream>
#include <cstdlib>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Valu.h"
#include <vector>
#include <stdint.h>
#include <random>
#include <exception>
#include <limits.h>

typedef std::tuple<int32_t,int32_t,int32_t,int32_t> testcase;

int random32bit() {
    std::random_device rd;
    std::mt19937 engine(rd());
    std::uniform_int_distribution<int> dist(0, (1 << 31) - 1);

    return dist(engine);
}

std::vector<int> availableOperations = {
  0b0000, //ALU_ADD
  0b0001, //ALU_SUB
  0b0010, //ALU_SLL
  0b0011, //ALU_SLT
  0b0100, //ALU_SLTU
  0b0101, //ALU_SEQ
  0b0110, //ALU_XOR
  0b0111, //ALU_SRL
  0b1000, //ALU_SRA
  0b1001, //ALU_OR
  0b1010  //ALU_AND
};

static inline int32_t rotr32 (int32_t value, uint32_t shift)
{
  if (value < 0 && shift > 0) {
      int32_t signMask = (static_cast<int32_t>(-1)) << (std::numeric_limits<int32_t>::digits - shift);
      return (value >> shift) | signMask;
  }
  return value >> shift;
}

int getResult(int op, int32_t a, int32_t b) {
  switch (op) {
    case 0b0000:
      return a + b;
    case 0b0001:
      return a - b;
    case 0b0010:
      return a << b;
    case 0b0011:
      return a < b;
    case 0b0100:
      return ((uint32_t)a) < ((uint32_t)b);
    case 0b0101:
      return a == b;
    case 0b0110:
      return a ^ b;
    case 0b0111:
      return a >> b;
    case 0b1000:
      return rotr32(a,b);
    case 0b1001:
      return a | b;
    case 0b1010:
      return a & b;
    default:
      throw new std::string("[ERROR] Invalid ALU operation");
      break;
  }
}

std::vector<testcase> generateTestCases(int n) {
  std::vector<testcase> testCases;
  for (const int& op : availableOperations) {
    for (int i = 0; i < n; i++) {
      int a = random32bit();
      int b = random32bit();
      int result = getResult(op, a, b);
      testCases.push_back({op, a, b, result});
      testCases.push_back({0b1111, 0, 0, result});
    }
  }

  return testCases;
}

int main(int argc, char** argv, char** env) {
    std::vector<testcase> testcases = generateTestCases(10000);
    
    Valu *dut = new Valu;
    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    int fails = 0;
    uint64_t sim_time = 0;
    for (testcase tc : testcases) {
      dut->clk_i ^= 1;
      dut->operation = std::get<0>(tc);
      dut->operand_a = std::get<1>(tc);
      dut->operand_b = std::get<2>(tc);
      dut->eval();
      m_trace->dump(sim_time++);

      uint32_t result = std::get<3>(tc);
      if (dut->result != result) {
        std::cout 
          << "[FAIL] op=" << std::get<0>(tc)
          << ", a=" << dut->operand_a
          << ", b=" << dut->operand_b 
          << ", result: " << dut->result 
          << ", expected: " << result << std::endl;
        fails++;
      }
    }

    if (fails == 0) {
      std::cout << "[SUCCESS] All test passed!" << std::endl;
    }

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}
