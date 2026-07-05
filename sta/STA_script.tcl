# Read Standard Cell Library
read_liberty /home/aadi_agarwal/OpenROAD-flow-scripts/flow/platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

# Read synthesized netlist
read_verilog ../synthesis/neuron_map.v

# Set top module
link_design neuron

# Clock Definition (80 MHz)
create_clock -period 12.5 [get_ports clk]

# Setup Timing Report
report_checks -path_delay max

# Hold Timing Report
report_checks -path_delay min

# Worst Negative Slack
report_wns

# Total Negative Slack
report_tns

# Minimum achievable clock period and Fmax
report_clock_min_period
