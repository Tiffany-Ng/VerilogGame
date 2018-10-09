# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules in mux.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)
vlog -timescale 1ns/1ns game.v

# Load simulation using mux as the top level simulation module.
vsim game

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}


#module datapath(input [6:0] data_in, input clk, input resetn, input ld_x, input ld_y, input ld_r, 
#input [3:0]counter, input [1:0] alu_op, input ld_alu_out, output reg [7:0] x_result, output reg [6:0] y_result) ;

force {CLOCK_50} 0 0 ns, 1 1 ns -r 2 ns
force {KEY[0]} 0 0 ns, 1 2 ns
force {KEY[1]} 1 4 ns, 0 6 ns, 1 8 ns

