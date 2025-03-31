# ucrv32

**ucrv32** is a simple educational RV32I microcontroller featuring a 5-stage pipeline architecture. Written in SystemVerilog and equipped with simulation support via Verilator, it offers a practical platform for learning digital design and computer architecture concepts.

## Features

- **RV32I Instruction Set:** Implements the basic subset of the RISC-V architecture.
- **5-Stage Pipeline:** Includes Instruction Fetch (IF), Instruction Decode (ID), Execution (EX), Memory Access/Write (MEM), and Write Back (WB) stages.
- **Educational Focus:** Designed to help users understand key digital design and processor architecture principles.
- **Simulation Support:** Easily simulate your design using Verilator for tick-by-tick verification.

## Overview

The project is intended as a learning tool for students and hobbyists interested in microcontroller design and the RISC-V architecture. By studying and experimenting with **ucrv32**, you can gain hands-on experience with:
- Digital circuit design using SystemVerilog.
- Implementing a pipeline architecture.
- Verifying hardware designs using simulation tools like Verilator.

## Getting Started

### Prerequisites

- **SystemVerilog Toolchain:** Ensure you have a compatible simulator or synthesis tool.
- **Verilator:** Install Verilator to run simulations. Refer to the [Verilator documentation](https://www.veripool.org/wiki/verilator) for installation instructions.

### Installation

1. **Clone the Repository:**
    ```bash
    git clone https://github.com/LeftarCode/ucrv32.git
    cd ucrv32
    ```

2. **Setup Simulation Environment:**
    Follow the instructions below to configure and run the simulation.

## Simulation

To run the simulation and view the waveform:

1. Navigate to the `tb/top` directory:
    ```bash
    cd tb/top
    ```
2. Execute `make`:
    ```bash
    make
    ```
3. The simulation output will appear in the directory as a waveform file.

### Instruction Loading

By default, the simulation loads the file `assets/instr.bin`. This file is a specially formatted batch file for BRAM that has been properly divided into segments. If needed, you can generate or update this file using the Python script:
```bash
python3 assets/convert_bin_to_hex.py
```
*Note: The simulation startup process will be improved in future updates.*
### Usage
- **Simulation**: Run the simulation using Verilator to observe the tick-by-tick operation of the processor.
- **Experimentation**: Modify the design, add new features, or implement additional test benches to further explore digital design concepts.

## Contributing

Contributions are welcome! If you have ideas for improvements, bug fixes, or new features, please open an issue or submit a pull request.

## License

This project is licensed under the [MIT License](LICENSE).
