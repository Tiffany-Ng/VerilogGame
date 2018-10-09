// Part 2 skeleton

module part2
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW
//		// The ports below are for the VGA output.  Do not change.
//		VGA_CLK,   						//	VGA Clock
//		VGA_HS,							//	VGA H_SYNC
//		VGA_VS,							//	VGA V_SYNC
//		VGA_BLANK_N,						//	VGA BLANK
//		VGA_SYNC_N,						//	VGA SYNC
//		VGA_R,   						//	VGA Red[9:0]
//		VGA_G,	 						//	VGA Green[9:0]
//		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
//	output			VGA_CLK;   				//	VGA Clock
//	output			VGA_HS;					//	VGA H_SYNC
//	output			VGA_VS;					//	VGA V_SYNC
//	output			VGA_BLANK_N;				//	VGA BLANK
//	output			VGA_SYNC_N;				//	VGA SYNC
//	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
//	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
//	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire ld_x, ld_y, ld_c, ld_r, alu_op, ld_alu_out;
	wire [3:0] counter;
	wire writeEn;
	wire [1:0]go;
	assign go[0] = ~KEY[3];
	assign go[1] = ~KEY[1];

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
//	vga_adapter VGA(
//			.resetn(resetn),
//			.clock(CLOCK_50),
//			.colour(colour),
//			.x(x),
//			.y(y),
//			.plot(writeEn),
//			/* Signals for the DAC to drive the monitor. */
//			.VGA_R(VGA_R),
//			.VGA_G(VGA_G),
//			.VGA_B(VGA_B),
//			.VGA_HS(VGA_HS),
//			.VGA_VS(VGA_VS),
//			.VGA_BLANK(VGA_BLANK_N),
//			.VGA_SYNC(VGA_SYNC_N),
//			.VGA_CLK(VGA_CLK));
//		defparam VGA.RESOLUTION = "160x120";
//		defparam VGA.MONOCHROME = "FALSE";
//		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
//		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
    
    // Instansiate datapath
	 datapath d0(.data_in(SW[9:0]), .clk(CLOCK_50), .resetn(resetn), .ld_x(ld_x), .ld_y(ld_y), .ld_c(ld_c), .ld_r(ld_r), .counter(counter), .alu_op(alu_op), .ld_alu_out(ld_alu_out), .x_result(x), .y_result(y), .colour_result(colour));
    // Instansiate FSM control
    control c0(.clk(CLOCK_50), .resetn(resetn), .go(go), .counter(counter), .writeEn(writeEn), .ld_x(ld_x), .ld_y(ld_y), .ld_c(ld_c), .ld_r(ld_r), .alu_op(alu_op), .ld_alu_out(ld_alu_out));
    
endmodule

module control(
    input clk,
    input resetn,
    input [1:0]go,
	 
	 output reg [3:0] counter,
	 output reg writeEn,
    output reg  ld_x, ld_y,ld_c, ld_r,
    output reg  ld_alu_out,
    output reg alu_op
    );

    reg [3:0] current_state, next_state; 
    
    localparam  S_LOAD_X        = 4'd0,
                S_LOAD_X_WAIT   = 4'd1,
					 S_LOAD_Y        = 4'd2,
					 S_LOAD_Y_WAIT   = 4'd3,
                S_CYCLE_0       = 4'd4,
					 S_CYCLE_1       = 4'd5;
    
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                S_LOAD_X: next_state = go[0] ? S_LOAD_X_WAIT : S_LOAD_X; // Loop in current state until value is input
                S_LOAD_X_WAIT: next_state = go[0] ? S_LOAD_X_WAIT : S_LOAD_Y; // Loop in current state until go signal goes low
					 S_LOAD_Y: next_state = go[1] ? S_LOAD_Y_WAIT : S_LOAD_Y; // Loop in current state until go signal goes low
					 S_LOAD_Y_WAIT: next_state = go[1] ? S_LOAD_Y_WAIT : S_CYCLE_0;
					 S_CYCLE_0: next_state = S_CYCLE_1;
					 S_CYCLE_1: begin
					 if(counter != 4'b1111)
						next_state = S_CYCLE_0;
					 else
					   next_state = S_LOAD_X;
					end
            default:     next_state = S_LOAD_X;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        ld_alu_out = 1'b0;
        ld_x = 1'b0;
		  ld_y = 1'b0;
		  ld_c = 1'b0;
        ld_r = 1'b0;
		  writeEn = 1'b0;
        alu_op       = 1'b0;

        case (current_state)
            S_LOAD_X: begin
                ld_x = 1'b1;
					 ld_c = 1'b1;
					 counter = -4'd1;
                end
				S_LOAD_Y: begin
                ld_y = 1'b1;
                end
            S_CYCLE_0: begin 
                ld_alu_out = 1'b1; 
					 ld_r = 1'b1;
//					 ld_x = 1'b1; // store result back 
//					 ld_y = 1'b1; // store result back 
					 counter = counter + 1'b1;
					 writeEn = 1'b1;

                alu_op = 1'b0; 
            end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= S_LOAD_X;
        else
            current_state <= next_state;
    end // state_FFS
endmodule 

module datapath(input [9:0] data_in, input clk, input resetn, input ld_x, input ld_y, input ld_c, input ld_r, input [3:0]counter, 
input alu_op, input ld_alu_out, output reg [7:0] x_result, output reg [6:0] y_result, output reg [2:0] colour_result) ;
    // input registers
    reg [7:0] x, y;
    // output of the alu
    reg [7:0] x_out, y_out;

    always @ (posedge clk) begin
        if (!resetn) begin
            x <= 8'd0; 
            y <= 7'd0; 
        end
        else begin
            if (ld_x)
                x <= ld_alu_out ? x_out : {1'b0, data_in[6:0]}; // load alu_out if load_alu_out signal is high, otherwise load from data_in
            if (ld_y)
                y <= ld_alu_out ? y_out : data_in[6:0]; // load alu_out if load_alu_out signal is high, otherwise load from data_in
				if (ld_c)
					colour_result <= data_in[9:7];
				
        end
    end

    // Output result register
    always @ (posedge clk) begin
        if (!resetn) begin
            x_result <= 8'd0; 
            y_result <= 7'd0; 
        end
        else 
            if(ld_r) begin
               x_result <= x_out;
					y_result <= y_out;
				end
    end

    // The ALU 
    always @(*)
    begin : ALU
        // alu
        case (alu_op)
            1'b0: begin
						x_out = x + counter[1:0];
			         y_out = y + counter[3:2];

               end
            default: begin 
                   x_out = 8'd0; 
		             y_out = 7'd0;
					end
        endcase
    end
endmodule 