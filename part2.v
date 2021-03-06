// Part 2 skeleton

module part2
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]

	wire resetn;
	assign resetn = KEY[0];

	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	wire [1:0] offset_x;
	wire [1:0] offset_y;
	wire ld_x, ld_y;


	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";

	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.


    // Instantiate datapath
	datapath d0(
		.x(SW[6:0]),
		.y(SW[6:0]),
		.offset_x(offset_x),
		.offset_y(offset_y),
		.colour(SW[9:7]),
		.ld_x(ld_x),
		.ld_y(ld_y),
		.reset_n(n),
		.clock(CLOCK_50),

		.out_x(x),
		.out_y(y),
		.out_colour(colour)
	);

    // Instantiate FSM control
    control c0(
		.clock(CLOCK_50),
		.reset_n(resetn),
		.go(KEY[1]),
		.ld(KEY[3]),

		.ld_x(ld_x),
		.ld_y(ld_y),
		.offset_x(offset_x),
		.offset_y(offset_y),
		.plot(writeEn)
	);

endmodule

module datapath(
	input [6:0] x,
	input [6:0] y,
	input [1:0] offset_x,
	input [1:0] offset_y,
	input [2:0] colour,
	input ld_x,
	input ld_y,
	input reset_n,
	input clock,
	output reg [7:0] out_x,
	output reg [6:0] out_y,
	output reg [2:0] out_colour
	);
	reg [7:0] original_x;
	reg [6:0] original_y;


	always @(posedge clock)
	begin
		if (!reset_n)
		begin
			out_x <= 0;
			out_y <= 0;
			out_colour <= 0;
		end
		else
		begin
			out_colour <= colour;
			if (ld_x)
			begin
				original_x <= {1'b0, x};
				out_x <= original_x;
			end
			else
				out_x <= original_x + offset_x;
			if (ld_y)
			begin
				original_y <= {1'b0, y};
				out_y <= original_y;
			end
			else
				out_y <= original_y + offset_y;
		end
	end
endmodule

module control(
	input clock,
	input reset_n,
	input go,
	input ld,

	output reg ld_x,
	output reg ld_y,
	output reg [1:0] offset_x,
	output reg [1:0] offset_y,
	output reg plot
	);

	wire load;
	assign load = ~ld;

	reg [4:0] current_state, next_state;

	localparam  S_LOAD_X        = 5'd0,
                S_LOAD_X_WAIT   = 5'd1,
                S_LOAD_Y        = 5'd2,
                S_LOAD_Y_WAIT   = 5'd3,
                S_LOADED        = 5'd4,
                S_LOADED_WAIT   = 5'd5,
                S_DRAW_0_0      = 5'd6,
                S_DRAW_1_0      = 5'd7,
                S_DRAW_2_0      = 5'd8,
                S_DRAW_3_0      = 5'd9,
				S_DRAW_0_1      = 5'd10,
                S_DRAW_1_1      = 5'd11,
                S_DRAW_2_1      = 5'd12,
                S_DRAW_3_1      = 5'd13,
				S_DRAW_0_2      = 5'd14,
                S_DRAW_1_2      = 5'd15,
                S_DRAW_2_2      = 5'd16,
                S_DRAW_3_2      = 5'd17,
				S_DRAW_0_3      = 5'd18,
                S_DRAW_1_3      = 5'd19,
                S_DRAW_2_3      = 5'd20,
                S_DRAW_3_3      = 5'd21,
				S_BUFFER        = 5'd22;

	always @(*)
	begin: state_table
		case(current_state)
			S_LOAD_X: next_state = load ? S_LOAD_X_WAIT : S_LOAD_X;
			S_LOAD_X_WAIT: next_state = load ? S_LOAD_X_WAIT : S_LOAD_Y;
			S_LOAD_Y: next_state = load ? S_LOAD_Y_WAIT : S_LOAD_Y;
			S_LOAD_Y_WAIT: next_state = load ? S_LOAD_Y_WAIT : S_LOADED;
			S_LOADED: next_state = go ? S_LOADED_WAIT : S_LOADED;
			S_LOADED_WAIT: next_state = go ? S_LOADED_WAIT : S_DRAW_0_0;
			S_DRAW_0_0: next_state = go ? S_DRAW_1_0 : S_DRAW_0_0;
			S_DRAW_1_0: next_state = go ? S_DRAW_2_0 : S_DRAW_1_0;
			S_DRAW_2_0: next_state = go ? S_DRAW_3_0 : S_DRAW_2_0;
			S_DRAW_3_0: next_state = go ? S_DRAW_0_1 : S_DRAW_3_0;
			S_DRAW_0_1: next_state = go ? S_DRAW_1_1 : S_DRAW_0_1;
			S_DRAW_1_1: next_state = go ? S_DRAW_2_1 : S_DRAW_1_1;
			S_DRAW_2_1: next_state = go ? S_DRAW_3_1 : S_DRAW_2_1;
			S_DRAW_3_1: next_state = go ? S_DRAW_0_2 : S_DRAW_3_1;
			S_DRAW_0_2: next_state = go ? S_DRAW_1_2 : S_DRAW_0_2;
			S_DRAW_1_2: next_state = go ? S_DRAW_2_2 : S_DRAW_1_2;
			S_DRAW_2_2: next_state = go ? S_DRAW_3_2 : S_DRAW_2_2;
			S_DRAW_3_2: next_state = go ? S_DRAW_0_3 : S_DRAW_3_2;
			S_DRAW_0_3: next_state = go ? S_DRAW_1_3 : S_DRAW_0_3;
			S_DRAW_1_3: next_state = go ? S_DRAW_2_3 : S_DRAW_1_3;
			S_DRAW_2_3: next_state = go ? S_DRAW_3_3 : S_DRAW_2_3;
			S_DRAW_3_3: next_state = load ? S_DRAW_3_3: S_BUFFER;
			S_BUFFER: next_state = load ? S_BUFFER: S_LOAD_X;
			default: next_state = S_LOAD_X;
		endcase
	end

	always @(*)
	begin: enable_signals
		ld_x = 1'b0;
		ld_y = 1'b0;
		offset_x = 2'b0;
		offset_y = 2'b0;
		plot = 1'b0;

		case(current_state)
			S_LOAD_X: begin
				ld_x = 1'b1;
				ld_y = 1'b0;
				offset_x = 2'b0;
				offset_y = 2'b0;
				plot = 1'b0;
				end
			S_LOAD_Y: begin
				ld_x = 1'b0;
				ld_y = 1'b1;
				offset_x = 2'b0;
				offset_y = 2'b0;
				plot = 1'b0;
				end
			S_LOADED: begin
				ld_x = 1'b0;
				ld_y = 1'b0;
				offset_x = 2'b0;
				offset_y = 2'b0;
				plot = 1'b0;
				end
			S_DRAW_0_0: begin
				ld_x = 1'b0;
				ld_y = 1'b0;
				offset_x = 2'b0;
				offset_y = 2'b0;
				plot = 1'b1;
				end
			S_DRAW_1_0: begin
				ld_x = 1'b0;
				ld_y = 1'b0;
				offset_x = 2'b1;
				offset_y = 2'b0;
				plot = 1'b1;
				end
			S_DRAW_2_0: begin
				ld_x = 1'b0;
				ld_y = 1'b0;
				offset_x = 2'b10;
				offset_y = 2'b0;
				plot = 1'b1;
				end
			S_DRAW_3_0: begin
				ld_x = 1'b0;
				ld_y = 1'b0;
				offset_x = 2'b11;
				offset_y = 2'b0;
				plot = 1'b1;
				end
			S_DRAW_0_1: begin
				ld_x = 1'b0;
				ld_y = 1'b0;
				offset_x = 2'b0;
				offset_y = 2'b1;
				plot = 1'b1;
				end
			S_DRAW_1_1: begin
				ld_x = 1'b0;
				ld_y = 1'b0;
				offset_x = 2'b1;
				offset_y = 2'b1;
				plot = 1'b1;
				end
			S_DRAW_2_1: begin
				ld_x = 1'b0;
				ld_y = 1'b0;
				offset_x = 2'b10;
				offset_y = 2'b1;
				plot = 1'b1;
				end
			S_DRAW_3_1: begin
				ld_x = 1'b0;
				ld_y = 1'b0;
				offset_x = 2'b11;
				offset_y = 2'b1;
				plot = 1'b1;
				end
			S_DRAW_0_2: begin
				ld_x = 1'b0;
				ld_y = 1'b0;
				offset_x = 2'b0;
				offset_y = 2'b10;
				plot = 1'b1;
				end
			S_DRAW_1_2: begin
				ld_x = 1'b0;
				ld_y = 1'b0;
				offset_x = 2'b1;
				offset_y = 2'b10;
				plot = 1'b1;
				end
			S_DRAW_2_2: begin
				ld_x = 1'b0;
				ld_y = 1'b0;
				offset_x = 2'b10;
				offset_y = 2'b10;
				plot = 1'b1;
				end
			S_DRAW_3_2: begin
				ld_x = 1'b0;
				ld_y = 1'b0;
				offset_x = 2'b11;
				offset_y = 2'b10;
				plot = 1'b1;
				end
			S_DRAW_0_3: begin
				ld_x = 1'b0;
				ld_y = 1'b0;
				offset_x = 2'b0;
				offset_y = 2'b11;
				plot = 1'b1;
				end
			S_DRAW_1_3: begin
				ld_x = 1'b0;
				ld_y = 1'b0;
				offset_x = 2'b1;
				offset_y = 2'b11;
				plot = 1'b1;
				end
			S_DRAW_2_3: begin
				ld_x = 1'b0;
				ld_y = 1'b0;
				offset_x = 2'b10;
				offset_y = 2'b11;
				plot = 1'b1;
				end
			S_DRAW_3_3: begin
				ld_x = 1'b0;
				ld_y = 1'b0;
				offset_x = 2'b11;
				offset_y = 2'b11;
				plot = 1'b1;
				end
		endcase
	end

	always @(posedge clock)
	begin: state_FFs
		if(!reset_n)
			current_state <= S_LOAD_X;
		else
			current_state <= next_state;
	end
endmodule
