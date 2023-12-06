
module Top (
	// Inputs
	CLOCK_50,
	KEY,

	// Bidirectionals
	PS2_CLK,
	PS2_DAT,
	
	// Outputs
	HEX0,
	HEX1,
	HEX4,
	HEX5,
	VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]

);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

// Inputs
input				CLOCK_50;
input		[3:0]	KEY;

wire        [7:0] currentX;
wire        [6:0] currentY;

// Bidirectionals
inout				PS2_CLK;
inout				PS2_DAT;

// Outputs
output		[6:0]	HEX0;
output		[6:0]	HEX1;
output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   		
output		[6:0]	HEX4;
output		[6:0]	HEX5;


/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Wires
wire		[7:0]	ps2_key_data;
wire				ps2_key_pressed;
 wire [7:0] dataa;
 wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

// Internal Registers
reg 			[7:0]	last_data_received;
reg			[7:0]	data2;
reg en;
reg			[7:0]	data1;

reg w,a,s,d,stop;



// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

always @(posedge CLOCK_50)
begin
	if (en == 1'b0|| KEY[0]==0)
		last_data_received <= 8'h00;
		 else if (ps2_key_pressed == 1'b1)
		last_data_received <= ps2_key_data;
		

		
end

always @(posedge CLOCK_50)
begin 
    if (last_data_received == 8'hF0) begin
        data2 <= last_data_received;
        // Set data1 to 0 only when the key is released (F0)
    end else if(last_data_received == 8'h1d && data2==8'hF0)begin
       en<=0;
 end else if(last_data_received == 8'h1c && data2==8'hF0)begin
         en<=0;
 end else if(last_data_received == 8'h23 && data2==8'hF0)begin
        en<=0;
 end else if(last_data_received == 8'h1b && data2==8'hF0)begin
        en<=0;
 end else


 begin
data2<=0;
en<=1;
data1<=last_data_received;
end
         	
end

 /* always@(*)begin
if(KEY[0]==0) begin
w<= 0;
a<=0;
s<=0;
d<=0;
stop=0;
end else if(stop==1)begin
	if(last_data_received==8'hF0)begin
	stop<=1;
	end else if (last_data_received==8'h1d)begin
	w<=0;
	end else if(last_data_received==8'h1b)begin
	s<=0;
	end else if(last_data_received==8'h1c)begin
	a<=0;
	end else if(last_data_received==8'h23)begin
	d<=0;
	end 
end else if(stop==0) begin
	if(last_data_received==8'hF0)begin
	stop<=1;
	end else if (last_data_received==8'h1d)begin
	w<=1;
	end else if(last_data_received==8'h1b)begin
	s<=1;
	end else if(last_data_received==8'h1c)begin
	a<=1;
	end else if(last_data_received==8'h23)begin
	d<=1;
	end 
end
end
/*
/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/
 vga_adapter VGA(
			.resetn(KEY[2]),
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
		
		
PS2_Controller PS2 (
	// Inputs
	.CLOCK_50				(CLOCK_50),
	.reset				(~KEY[0]),

	// Bidirectionals
	.PS2_CLK			(PS2_CLK),
 	.PS2_DAT			(PS2_DAT),

	// Outputs
	.received_data		(ps2_key_data),
	.received_data_en	(ps2_key_pressed)
);


/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/


 blocky d1(KEY[1],CLOCK_50,data1,x,y,colour, writeEn ,currentX,currentY);

 
decoder Segment0 (
currentX[3:0],	HEX0	
);

decoder Segment1 (
	// Inputs
		currentX[7:4],

	// Bidirectional

	// Outputs
	HEX1
);

decoder Segment3 (
	// Inputs
			currentY[3:0],

	// Bidirectional

	// Outputs
	HEX4
);

decoder Segment4 (
	// Inputs
			currentY[6:4],

	// Bidirectional

	// Outputs
		HEX5
);
	

endmodule
