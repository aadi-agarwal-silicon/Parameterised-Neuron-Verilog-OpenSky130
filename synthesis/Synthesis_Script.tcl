# Read RTL
read_verilog neuron.v

# Specify top module
hierarchy -check -top neuron

# Convert processes
proc

# Optimize logic
opt

# Detect and optimize FSM
fsm
opt

# Handle memories if present
memory
opt

# Technology independent optimizations
techmap
opt

# Map flip-flops and logic to SKY130 cells
dfflibmap -liberty (Path to the tech library in the directory)
abc -liberty (Path to the tech library in the directory)
# Remove unused cells and wires
clean

# Print synthesis statistics
stat

# Generate synthesized netlist
write_verilog neuron_map.v
