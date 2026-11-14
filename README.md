# Synchronous FIFO Design using Verilog HDL

## Overview

This project implements a **Synchronous First-In First-Out (FIFO) buffer** using Verilog HDL.

A FIFO stores data in the order it is received and outputs it in the same order. This design uses a circular buffer architecture with independent read and write pointers to manage data storage and retrieval.

The project focuses on RTL design, digital logic, simulation, and functional verification using Icarus Verilog.

## Design Specifications

| Parameter | Specification |
|---|---|
| FIFO Type | Synchronous FIFO |
| Data Width | 8 bits |
| FIFO Depth | 16 entries |
| Clock | Positive-edge triggered |
| Reset | Synchronous, active-high |
| Read Pointer | 4 bits |
| Write Pointer | 4 bits |
| Occupancy Counter | 5 bits |
| HDL | Verilog |

## Features

- 8-bit data storage.
- 16-entry FIFO memory.
- Independent read and write pointers.
- Full and empty status detection.
- Overflow and underflow prevention.
- Simultaneous read and write operations.
- Circular pointer wraparound.
- Support for simultaneous read/write when the FIFO is full, with the oldest data read and new data accepted in the same clock cycle.

## Architecture

The FIFO consists of the following main components:

1. **FIFO Memory:** Stores 16 entries of 8-bit data.
2. **Write Pointer:** Identifies the memory location for the next write operation.
3. **Read Pointer:** Identifies the memory location for the next read operation.
4. **Occupancy Counter:** Tracks the number of stored entries.
5. **Status Logic:** Generates `full` and `empty` signals.
6. **Control Logic:** Manages read and write operations.

### Block Diagram

```text
                 +----------------------+
                 |      FIFO Control    |
                 |                      |
   wr_en ------->|                      |
   rd_en ------->|                      |
   clk --------->|                      |
   rst --------->|                      |
                 +----------+-----------+
                            |
              +-------------+-------------+
              |                           |
       +------v------+             +------v------+
       | Write       |             | Read        |
       | Pointer     |             | Pointer     |
       +------+------+             +------+------+
              |                           |
              +-------------+-------------+
                            |
                    +-------v-------+
                    |               |
                    |  FIFO Memory  |
                    |  16 x 8 bits  |
                    |               |
                    +-------+-------+
                            |
                    +-------v-------+
                    |  Data Output  |
                    +---------------+

                 +------------------+
                 | Occupancy Counter|
                 +--------+---------+
                          |
                    +-----v-----+
                    | Full/Empty|
                    |   Flags   |
                    +-----------+
```

## Input and Output Signals

| Signal | Direction | Description |
|---|---|---|
| `clk` | Input | Clock signal |
| `rst` | Input | Synchronous active-high reset |
| `wr_en` | Input | Enables write operation |
| `rd_en` | Input | Enables read operation |
| `din[7:0]` | Input | 8-bit input data |
| `dout[7:0]` | Output | 8-bit output data |
| `full` | Output | Indicates FIFO is full |
| `empty` | Output | Indicates FIFO is empty |

## Project Structure

```text
fifo-verilog-design/
│
├── rtl/
│   └── fifo.v
│
├── testbench/
│   ├── fifo_tb.v
│   ├── fifo_boundary_tb.v
│   ├── fifo_concurrent_tb.v
│   ├── fifo_wraparound_tb.v
│   └── fifo_full_concurrent_tb.v
│
├── simulation/
│
├── docs/
│
└── README.md
```

## Tools Used

- **Verilog HDL** – RTL design.
- **Icarus Verilog** – Compilation and simulation.
- **GTKWave** – Waveform visualization.
- **Visual Studio Code** – Code editing.
- **Git and GitHub** – Version control and project hosting.

## Simulation and Verification

Compile and simulate the testbenches from the project root directory.

### 1. Basic FIFO Test

```bash
iverilog -g2012 -o simulation/fifo_tb.vvp rtl/fifo.v testbench/fifo_tb.v
vvp simulation/fifo_tb.vvp
```

### 2. Boundary Test

```bash
iverilog -g2012 -o simulation/fifo_boundary.vvp rtl/fifo.v testbench/fifo_boundary_tb.v
vvp simulation/fifo_boundary.vvp
```

### 3. Concurrent Read/Write Test

```bash
iverilog -g2012 -o simulation/fifo_concurrent.vvp rtl/fifo.v testbench/fifo_concurrent_tb.v
vvp simulation/fifo_concurrent.vvp
```

### 4. Pointer Wraparound Test

```bash
iverilog -g2012 -o simulation/fifo_wraparound.vvp rtl/fifo.v testbench/fifo_wraparound_tb.v
vvp simulation/fifo_wraparound.vvp
```

### 5. Full FIFO Concurrent Read/Write Test

```bash
iverilog -g2012 -o simulation/fifo_full_concurrent.vvp rtl/fifo.v testbench/fifo_full_concurrent_tb.v
vvp simulation/fifo_full_concurrent.vvp
```

## Verification Results

The following functional scenarios have been simulated successfully:

| Test Scenario | Result |
|---|---|
| FIFO reset | PASS |
| Basic write and read | PASS |
| FIFO full detection | PASS |
| FIFO empty detection | PASS |
| Overflow prevention | PASS |
| Underflow prevention | PASS |
| Concurrent read/write | PASS |
| Pointer wraparound | PASS |
| Concurrent read/write at full condition | PASS |

## Waveform Visualization

GTKWave can be used to inspect the generated VCD waveform files.

For example, to open the basic test waveform:

```bash
gtkwave simulation/fifo.vcd
```

Waveforms help visualize clock transitions, control signals, data movement, pointers, and FIFO status flags.

## Learning Outcomes

Through this project, I explored:

- Synchronous digital design using Verilog HDL.
- FIFO memory organization and circular buffering.
- Pointer management and occupancy tracking.
- RTL simulation and functional verification.
- Boundary-condition and corner-case testing.
- Waveform analysis using GTKWave.

## Future Improvements

- Parameterized FIFO design.
- Asynchronous FIFO implementation.
- Almost-full and almost-empty status flags.
- Randomized and assertion-based verification.
- FPGA synthesis and hardware implementation.

---

**Project Type:** Digital Design / RTL Design  
**Language:** Verilog HDL  
**Verification:** Icarus Verilog  
**Waveform Tool:** GTKWave