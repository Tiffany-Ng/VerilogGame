module game
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		  HEX0,
		  HEX1,HEX2,HEX3,HEX4,HEX5,
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
	
		output   [6:0]   HEX0;
		output   [6:0]   HEX1;
	output   [6:0]   HEX2;
	output   [6:0]   HEX3;
	output  [6:0]   HEX4;

	output   [6:0]   HEX5;

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

	
	part2 p2(.CLOCK_50(CLOCK_50),
	.KEY(KEY), 
	.SW(SW), 
	.HEX0(HEX0),
	.HEX1(HEX1),
	.HEX2(HEX2),
	.HEX3(HEX3),
	.HEX4(HEX4),
	.HEX5(HEX5),

	.VGA_CLK(VGA_CLK), 
	.VGA_HS(VGA_HS), 
	.VGA_VS(VGA_VS), 
	.VGA_BLANK_N(VGA_BLANK_N), 
	.VGA_SYNC_N(VGA_SYNC_N), 
	.VGA_R(VGA_R), 
	.VGA_G(VGA_G), 
	.VGA_B(VGA_B) );
	
endmodule 

// Part 2 skeleton

module part2
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,HEX0,
		  	HEX1,HEX2,HEX3,HEX4,HEX5,

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
	
		output   [6:0]   HEX0;
		output   [6:0]   HEX1;
	output   [6:0]   HEX2;
	output   [6:0]   HEX3;
	output  [6:0]   HEX4;

	output   [6:0]   HEX5;

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
	wire [6:0] count;
	wire [4:0] thing_count;
	wire [1:0]draw_count;
	wire ld_count;
	wire [1:0]ld_thing_count;
	
	reg [25:0]laser_count;
	
	reg [7:0] self_x;
	reg [6:0] self_y;
	reg [7:0] enemy_x;
	reg [6:0] enemy_y;
	reg [7:0] laser_x[15:0];
	reg [6:0] laser_y[15:0];
	
	reg [7:0] temp_x;
	reg[6:0] temp_y;
	
	reg [7:0]i;
	reg done;
	wire [25:0]frame;
	wire ld_frame;
	
	wire erase;
	wire change;
	reg end_game;
	
	wire check;
	
	always @(posedge CLOCK_50)
	begin: counter1e
		if(!KEY[0])begin
				for(i = 0; i < 7'd16; i = i + 1'b1) begin
					laser_x[i] <= 8'd0;
					laser_y[i] <= 8'd0;
				end
				self_x <= 8'd0;
				self_y <= 7'd110;					
				enemy_x <= 8'd0;
				enemy_y <= 7'd0;
				end_game <= 1'b0;
	end
	else begin
	if(change) begin
	
	if(thing_count <= 5'd15 && laser_y[thing_count] > 7'd0)
		laser_y[thing_count] <= laser_y[thing_count] + 1'b1;
	
	if(thing_count == 5'd17)
		enemy_x <= enemy_x + 1'b1;
	end
	if(thing_count == 5'd16 &&!KEY[2] && change == 1'b1)
		self_x <= self_x + 1'b1;
		
	else if(thing_count == 5'd16 &&!KEY[3]&& change == 1'b1)
		self_x <= self_x - 1'b1;
	
	end
	
	if(frame == 26'd833333)
		laser_count <= laser_count + 1'b1;
	

	if(laser_count % 15 == 26'd0 && thing_count == 5'd17 && change == 1'b1)begin
		done = 1'b0;
		for(i = 0; i < 7'd16; i = i + 1'b1) begin
		if(laser_y[i] == 7'd0 && done == 1'b0)begin
			laser_x[i] <= enemy_x;
			laser_y[i] <= 7'd10;
			done = 1'b1;
			end
		end
	end
	
	if(check) begin
		for(i = 0; i < 7'd16; i = i + 1'b1) begin
		if(laser_y[i] >= 7'd102 && laser_x[i] + 8'd4 >= self_x && laser_x[i] + 8'd2 <= self_x + 8'd8)begin
				end_game <= 1'b1;
			end
		end
	
	end
	end

	always @(*)
	begin: temp
//				if(!KEY[0])begin
//					for(i = 0; i < 7'd16; i = i + 1'b1) begin
//						laser_x[i] <= i;
//						laser_y[i] <= 8'd0;
//					end
//					self_x <= 8'd0;
//					self_y <= 7'd110;					
//					enemy_x <= 8'd0;
//					enemy_y <= 7'd0;
//					temp_x <= laser_x[0];
//					temp_y <= laser_y[0];
//					end
//				else if(thing_count <= 5'd15) begin
//				if(change) begin
//					laser_y[thing_count] <= laser_y[thing_count] + 1'b1;
//				end
if(thing_count <= 5'd15) begin
					temp_x <= laser_x[thing_count];
					temp_y <= laser_y[thing_count];
					end
				else if(thing_count == 5'd16) begin
					temp_x <= self_x;
					temp_y <= self_y;
					end
				else if(thing_count == 5'd17) begin
//				if(change) begin
//					enemy_x <= enemy_x + 1'b1;
//				end
					temp_x <= enemy_x;
					temp_y <= enemy_y;
					end
				else begin
					temp_x <= 8'd0;
					temp_y <= 7'd0;
					end
	end

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
		.x(temp_x),
		.y(temp_y),
		.count(count),
		.draw_count(draw_count),
		.thing_count(thing_count),
		.frame(frame),
		.reset_n(KEY[0]),
		.clock(CLOCK_50),
		.erase(erase),
		.end_game(end_game),

		.out_x(x),
		.out_y(y),
		.out_colour(colour)
	);

    // Instantiate FSM control
    control c0(
		.clock(CLOCK_50),
		.reset_n(resetn),
		.go(~KEY[1]),
		
		.y(temp_y),
		.check (check),

		.change(change),
		.ld_frame(ld_frame),
		.frame(frame),
		.count(count),
		.thing_count(thing_count),
		.draw_count(draw_count),
		.erase(erase),
		.plot(writeEn),
		.ld_count(ld_count),
		.ld_thing_count(ld_thing_count)
	);
	
	count co0(
		.count(count),
		.thing_count(thing_count),
		.ld_count(ld_count),
		.ld_thing_count(ld_thing_count),
		.ld_frame(ld_frame),
		.frame(frame),
		.clock(CLOCK_50));
		
	hex_decoder h0(.hex_digit(laser_count[3:0]), .segments(HEX0));
	hex_decoder h1(.hex_digit(laser_count[7:4]), .segments(HEX1));
	hex_decoder h2(.hex_digit(laser_count[11:8]), .segments(HEX2));
	hex_decoder h3(.hex_digit(laser_count[15:12]), .segments(HEX3));
	hex_decoder h4(.hex_digit(laser_count[19:16]), .segments(HEX4));
	hex_decoder h5(.hex_digit(laser_count[23:20]), .segments(HEX5));

	
		

endmodule

module datapath(
	input [7:0] x,
	input [6:0] y,
	input [6:0] count,
	input [1:0]draw_count,
	input [4:0] thing_count,
	input [25:0]frame,
	input erase,
	input end_game,

	input reset_n,
	input clock,
	output reg [7:0] out_x,
	output reg [6:0] out_y,
	output reg [2:0] out_colour
	);


	always @(posedge clock)
	begin
		if (!reset_n)begin
		begin
			out_x <= 0;
			out_y <= 0;
			out_colour <= 0;
		end
		end
		
		else
		begin
			if(draw_count == 2'b00) begin
				if(erase || end_game)
					out_colour <= 3'b000;
				else
					out_colour <= 3'b001;
				out_x <= x + count[2:0];
				out_y <= y + count[5:3];
			end
			else if(draw_count == 2'b01) begin
				if(erase || end_game)
					out_colour <= 3'b000;
				else
					out_colour <= 3'b011;
				out_x <= x + count[2:0];
				out_y <= y + count[5:3];
			end
			else if(draw_count == 2'b10) begin
				if(erase || end_game)
					out_colour <= 3'b000;
				else
					out_colour <= 3'b101;
				out_x <= x + count[2:0];
				out_y <= y + count[5:3];
			end
			else begin
				out_colour <= 3'b111;
				out_x <= 0;
				out_y <= 0;
			end
		end
	end
endmodule

module control(
	input clock,
	input reset_n,
	input go,
	input [6:0]count,
	input [4:0]thing_count,
	input [25:0] frame,
	input [6:0] y,
	
	output reg check,
	output reg change,
	output reg erase,
	output reg [1:0]draw_count,
	output reg plot,
	output reg ld_count,
	output reg [1:0]ld_thing_count,
	output reg ld_frame
	);

	reg [4:0] current_state, next_state;

	localparam   S_LOAD        = 5'd0,
                S_LOAD_WAIT   = 5'd1,
                DRAW_SELF        = 5'd2,
                DRAW_SELF_WAIT   = 5'd3,
					 DRAW_BUFFER_0   = 5'd8,
					 DRAW_BUFFER_1   = 5'd9,
					 DRAW_BUFFER_2   = 5'd10,
					 DRAW_BUFFER_3   = 5'd11,
                FRAME_WAIT       = 5'd4,
                SET_ERASE   = 5'd5,
                ERASE      = 5'd6,
                CHANGE      = 5'd7,
					 CHECK_END = 5'd13,
					 CHANGE_WAIT      = 5'd12;

	always @(*)
	begin: state_table
		case(current_state)
			S_LOAD: next_state = go ? S_LOAD_WAIT : S_LOAD;
			
			S_LOAD_WAIT: next_state = go ? S_LOAD_WAIT : DRAW_SELF;
			
			DRAW_SELF: begin
				if(count != 7'd64)
					next_state = DRAW_SELF;
				else
					next_state = DRAW_BUFFER_0;
			end
//			DRAW_SELF_WAIT: begin
//				if(count != 7'd64)
//					next_state = DRAW_SELF;
//				else
//					next_state = DRAW_BUFFER_0;
//			end
			
			DRAW_BUFFER_0: 
				if(thing_count != 5'd17)
					next_state = DRAW_SELF;
				else
					next_state = DRAW_BUFFER_1;
					
			DRAW_BUFFER_1: next_state = FRAME_WAIT;
			//20'd833333
			FRAME_WAIT: next_state = (frame == 26'd833333) ? SET_ERASE : FRAME_WAIT;
			
			SET_ERASE: next_state = ERASE;
			
			ERASE: 		next_state = (count == 7'd64) ? DRAW_BUFFER_2 : ERASE;
			
			DRAW_BUFFER_2: 
				if(thing_count != 5'd17)
					next_state = ERASE;
				else
					next_state = DRAW_BUFFER_3;
					
			DRAW_BUFFER_3: next_state = CHANGE;
			
			CHANGE: 	
				if(thing_count != 5'd17)
					next_state = CHANGE;
				else
					next_state = CHANGE_WAIT;
					
			CHANGE_WAIT: next_state = CHECK_END;
			
			CHECK_END: next_state = DRAW_SELF;
			
			default: next_state = S_LOAD;
		endcase
	end

	always @(*)
	begin: enable_signals
		ld_count = 1'b0;
		ld_thing_count = 2'b10;
		draw_count = 2'b00;
		plot = 1'b0;
		ld_frame = 1'b0;
		erase = 1'b0;
		change = 1'b0;
		check = 1'b0;

		case(current_state)
			DRAW_SELF: begin
				ld_count = 1'b1;
				
				if(thing_count == 5'd16)
					draw_count = 2'b00;
				else if(thing_count == 5'd17)
					draw_count = 2'b01;
				else
					draw_count = 2'b10;
					
				ld_thing_count = 2'b00;
				if(count == 7'd0)
					plot = 1'b0;
				else if(thing_count > 15 || (count[2:0] >= 3'b010 && count[2:0] <= 3'b100 && y > 7'd0  && y < 7'd110))
					plot = 1'b1;
				end
//			DRAW_SELF_WAIT: begin
//				ld_count = 1'b1;
//				
//				if(thing_count == 5'd16)
//					draw_count = 2'b00;
//				else if(thing_count == 5'd17)
//					draw_count = 2'b10;
//				else
//					draw_count = 2'b10;
//					
//				ld_thing_count = 2'b00;
//				plot = 1'b1;
//				end
				
			DRAW_BUFFER_0: begin
				ld_count = 1'b0;
				ld_thing_count = 2'b01;
				plot = 1'b0;
				
				if(thing_count == 5'd16)
					draw_count = 2'b00;
				else if(thing_count == 5'd17)
					draw_count = 2'b01;
				else
					draw_count = 2'b10;
				end
				
			DRAW_BUFFER_1: begin
				ld_count = 1'b0;
				plot = 1'b0;
				end
				
			FRAME_WAIT: begin
				ld_frame = 1'b1;
				end
				
			ERASE: begin
				ld_count = 1'b1;
				
				if(thing_count == 5'd16)
					draw_count = 2'b00;
				else if(thing_count == 5'd17)
					draw_count = 2'b01;
				else
					draw_count = 2'b10;
					
				ld_thing_count = 2'b00;
				
				if(count == 7'd0)
					plot = 1'b0;
				else
					plot = 1'b1;
				
				
				erase = 1'b1;
				
			end
		
				
			DRAW_BUFFER_2: begin
				ld_count = 1'b0;
				ld_thing_count = 2'b01;
				plot = 1'b0;
				
				if(thing_count == 5'd16)
					draw_count = 2'b00;
				else if(thing_count == 5'd17)
					draw_count = 2'b01;
				else
					draw_count = 2'b10;	
				end
				
			DRAW_BUFFER_3: begin
				ld_count = 1'b0;
				ld_thing_count = 2'b10;
				plot = 1'b0;
				end
				
			CHANGE: begin
				change = 1'b1;
				ld_thing_count = 2'b01;
				plot = 1'b0;
				end
				
			CHANGE_WAIT: begin
				ld_thing_count = 2'b11;
				ld_count = 1'b0;
			end
			
			CHECK_END: begin
				check = 1'b1;
			end
		endcase
	end

	always @(posedge clock)
	begin: state_FFs
		if(!reset_n)
			current_state <= S_LOAD;
		else
			current_state <= next_state;
	end
	

endmodule

module count(
	input clock,
	input ld_count,
	input [1:0]ld_thing_count,
	input ld_frame,
	
	output reg [6:0] count,
	output reg [4:0] thing_count,
	output reg [25:0] frame);
	
	always @(posedge clock)
	begin: counter
		if(!ld_count)
			count <= 6'd0;
		else
			count <= count + 1'b1;
	end
	
	always @(posedge clock)
	begin: counter3
		if(!ld_frame)
			frame <= 26'd0;
		else
			frame <= frame + 1'b1;
	end
	
	
	always @(posedge clock)
	begin: counter1
		if(ld_thing_count == 2'b00)
			thing_count <= thing_count;
		else if (ld_thing_count == 2'b01)
			thing_count <= thing_count + 1'b1;
		else
			thing_count <= 5'd0;
	end
	
endmodule 

module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule
