# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules in mux.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)
vlog -timescale 1ns/1ns part2.v

# Load simulation using mux as the top level simulation module.
vsim part2

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}


#module part2
#	(
#		CLOCK_50,						//	On Board 50 MHz
#		// Your inputs and outputs here
#        KEY,
#        SW,
#		// The ports below are for the VGA output.  Do not change.
#		VGA_CLK,   						//	VGA Clock
#		VGA_HS,							//	VGA H_SYNC
#		VGA_VS,							//	VGA V_SYNC
#		VGA_BLANK_N,						//	VGA BLANK
#		VGA_SYNC_N,						//	VGA SYNC
#		VGA_R,   						//	VGA Red[9:0]
#		VGA_G,	 						//	VGA Green[9:0]
#		VGA_B   						//	VGA Blue[9:0]
#	);


force {CLOCK_50} 0 0 ns, 1 1 ns -r 2 ns
force {KEY[0]} 0 0 ns, 1 2 ns
force {SW[9:0]} 1110000000 0 ns, 1110000001 6 ns
force {KEY[1]} 1 0 ns, 0 8 ns, 1 10 ns, 0 83 ns, 1 85 ns
force {KEY[3]} 1 0 ns, 0 4ns, 1 6 ns, 0 79 ns, 1 81 ns