# Parameterized Neuron Accelerator in Verilog using OpenSky130
A parameterized hardware implementation of an Artificial Neuron using Verilog HDL, synthesized using Yosys and timing analyzed using OpenSTA with the SKY130 standard cell library.

This project demonstrates the complete front-end ASIC RTL flow:

```
Specification
↓
RTL Design
↓
Simulation
↓
Logic Synthesis (Yosys)
↓
Gate-Level Netlist
↓
Static Timing Analysis (OpenSTA)
```

---

# Project Overview

The neuron computes:

Y = ReLU( Σ(XᵢWᵢ) + Bias )

where:

- Xᵢ = Inputs
- Wᵢ = Weights
- Bias = Neuron bias term
- ReLU = Activation Function

The design is fully parameterized and scalable to any number of inputs.

---

# Features

- Parameterized number of neuron inputs (`N`)
- Parameterized input width (`WIDTH`)
- Signed arithmetic support
- Sequential Multiply-Accumulate (MAC) architecture
- ReLU activation function
- FSM controlled datapath
- Synthesizable Verilog RTL
- OpenSky130 standard cell mapping
- Static Timing Analysis using OpenSTA

---

# Architecture

The architecture uses a resource shared sequential MAC datapath.

Instead of using N multipliers in parallel, a single multiplier is reused over multiple clock cycles.

This reduces area significantly at the cost of increased latency.

## Datapath

```
x_bus ----\
           \
            MUX ---> Multiplier ---> Accumulator ---> Bias Add ---> ReLU ---> Result
           /
w_bus ----/
```

---

## Architecture Tradeoff

| Parameter | Sequential MAC |
|-----------|---------------|
| Multipliers | 1 |
| Area | Low |
| Latency | Higher |
| Throughput | Lower |
| Scalability | Excellent |

---

# FSM Architecture

The neuron controller is implemented using a finite state machine.

## FSM States

## IDLE

Waits for `start = 1`

Actions:
- Reset accumulator
- Reset index counter

---

## MAC

Performs:

```
accumulator = accumulator + x[index] * w[index]
```

Runs for `N` clock cycles.

---

## ADD_BIAS

Adds neuron bias:

```
accumulator = accumulator + bias
```

---

## ACTIVATE

Applies ReLU activation:

```
if(accumulator < 0)
    result = 0;
else
    result = accumulator;
```

---

## DONE

Raises:

```
done = 1
```

indicating valid output.

---

## FSM Diagram

```
IDLE
 ↓
MAC
 ↓
ADD_BIAS
 ↓
ACTIVATE
 ↓
DONE
```

---

# Packed Bus Implementation

Initially the design attempted to use:

```verilog
input signed [WIDTH-1:0] x [0:N-1];
```

However standard Verilog does not support unpacked array ports.

Therefore inputs and weights are packed into buses:

```verilog
input signed [N*WIDTH-1:0] x_bus;
input signed [N*WIDTH-1:0] w_bus;
```

Example:

```
x_bus = {x3,x2,x1,x0}
w_bus = {w3,w2,w1,w0}
```

The current operand is extracted using indexed part-select:

```verilog
current_x = x_bus[index*WIDTH +: WIDTH];
current_w = w_bus[index*WIDTH +: WIDTH];
```

---

# Simulation

## Test Vector

Inputs:

| Input | Value |
|-------|------|
| x0 | 1 |
| x1 | 3 |
| x2 | -2 |
| x3 | 1 |

Weights:

| Weight | Value |
|--------|------|
| w0 | -3 |
| w1 | -1 |
| w2 | -3 |
| w3 | 1 |

Bias:

```
1
```

Expected Result:

```
1×(-3) + 3×(-1) + (-3)×(-2) + 1×1 + 1
= 2
```

Output:

```
2
```

Simulation PASSED.

---

# Synthesis Flow

Synthesis was performed using:

- Yosys
- ABC Mapper
- SKY130 HD Standard Cell Library

Commands:

```bash
yosys -s synthesis/Synthesis_Script.tcl
```

Generated Outputs:

- Gate-level netlist
- Cell utilization report
- Mapped SKY130 standard cells

---

# Static Timing Analysis

Timing analysis was performed using OpenSTA.

Command:

```bash
sta sta/STA_script.tcl
```

---

## Timing Results

### 100 MHz Constraint

| Clock Period | WNS | Status |
|-------------|-----|--------|
| 10 ns | -2.54 ns | Violated |

---

### 80 MHz Constraint

| Clock Period | WNS | Status |
|-------------|-----|--------|
| 12.5 ns | -0.04 ns | Near Closure |

---

## Estimated Maximum Frequency

```
Critical Path Delay = 12.54 ns
```

Maximum operating frequency:

```
79.74 MHz
```

---

## Critical Path

The critical path consists primarily of:

```
Accumulator Register
↓
Multiplier
↓
Adder
↓
Accumulator Register
```

This is the classic MAC feedback path commonly seen in AI accelerators.

---

# Repository Structure

```
.
├── RTL_neuron/
│   ├── neuron.v
│   └── Testbench.v
│
├── synthesis/
│   └── Synthesis_Script.ys
│
├── sta/
│   └── STA_script.tcl
│
├── results/
│   ├── Synthesis1.png
│   ├── Synthesis2.png
│   └── timing_reports.png
│
└── README.md
```

---

# Building the Project

## Simulation

Using Vivado Simulator:

```bash
Run Behavioral Simulation
```

---

## Synthesis

```bash
yosys -s synthesis/Synthesis_Script.ys
```

---

## Timing Analysis

```bash
sta sta/STA_script.tcl
```

---

# Future Improvements

- Pipelined MAC architecture
- Multiple neuron instances
- Additional activation functions
- On-chip weight memory
- Multi-layer perceptron implementation
- FPGA implementation on Spartan-7
- During STA, Ideal Clock was considered, Some uncertainties, jitter and skew can be introduced

---

# Tools Used

- Verilog HDL
- Vivado Simulator
- Yosys
- OpenSTA
- ABC Mapper
- SKY130 HD Standard Cell Library

---

# Author

Aadi Agarwal

Electronics and Communication Engineering  
NIT Uttarakhand

Interested in:
- RTL Design
- Verification
- ASIC Front-End Design
- Physical Design
- AI Accelerators
