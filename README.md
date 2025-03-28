# RV32E Microcontroller

# Pipeline stages
1. IF - fetch instruction from BRAM.
2. ID - decoding instructions.
3. EX - execution.
4. MEM - memory access.
5. WB - write back.

# Not working
- Memory write cause i don't forward rs2 value to save it (ID -> EX -> MEM)

# Development toolchain
- Synthesis: `yosys`,
- Simulator: `verilator`,
- Waveform: `GTKwave`.
