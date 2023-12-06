`timescale 1ns / 1ns 

module blocky(iReset,iClock,PS2,oX,oY,oColour,oPlot,currentX,currentY);
    parameter X_SCREEN_PIXELS = 8'd160;
    parameter Y_SCREEN_PIXELS = 7'd120;

    input wire iReset;
    input wire [7:0] PS2;
    input wire iClock;
    output  wire  [7:0] oX;         // VGA pixel coordinates
    output  wire  [6:0] oY;
    output  wire  [2:0] oColour;     // 	VGA pixel colour (0-7)
    output   wire  oPlot;       // Pixel draw enable
    wire oDone;       // goes high when finished drawing frame
    wire ld_up,ld_down,ld_right,ld_left,ld_set,select_draw,select_erase,select_update_current,resetTFF,resetTFF2,delay	;
    wire [20:0] counter;
	wire [20:0] delaycounter;
    wire [7:0] nextX;
	wire [6:0] nextY;
    output  wire [7:0] currentX;
	output  wire [6:0] currentY;
    wire [7:0] x,xEr;
    wire [6:0] y,yEr;
    wire collisionDetected;
	assign counter=50000000/30;
    wire continue,inc,incEr,continue2;

    control draw0(iReset, collisionDetected,iClock,PS2,ld_up,ld_down,ld_right,ld_left,ld_set,continue,continue2,select_draw,select_erase,oPlot,oDone,select_update_current,resetTFF,resetTFF2	,inc,incEr,delay);
    datapath d0(iClock, ld_up, ld_down, ld_right, ld_left, ld_set, select_draw, select_erase,select_update_current,x, y,xEr,yEr, currentX, currentY,nextX,nextY	, oX,oY,oColour); 
    delay d1(iClock,counter,iReset,delay,delaycounter);
    tflopFour t0(iClock, resetTFF, inc, nextX, nextY, x, y, continue);
    tflopFour t1(iClock, resetTFF2, incEr, currentX, currentY, xEr, yEr, continue2);

    collisionChecker c1(iClock,nextX,nextY,collisionDetected);


endmodule // part2


module control(
    input restart, input collision, input iClock, input  [7:0] PS2,  
    output reg ld_up,ld_down,ld_right,ld_left,ld_set,input continue,continue2 , output reg select_draw,select_erase,oPlot, oDone,select_update_current,resetTFF,resetTFF2	,inc,incEr,input delay
);
  reg [5:0] current_state, next_state;
 
  reg [2:0] counter;
    
    localparam  S_SETUP = 5'd0,
                S_WAIT_MOVE = 5'd1,
                S_UP = 5'd2,
                S_DOWN = 5'd3,
                S_LEFT = 5'd4,
                S_RIGHT = 5'd5,
				S_erase = 5'd6,
				S_done = 5'd7,
				S_draw = 5'd9,
				S_draw1= 5'd10,
				S_done2= 5'd11,
				S_wait= 5'd12;
					 
					 
					 always@(*)
    begin: state_table
            case (current_state)
				S_SETUP: begin
                    if(!restart)begin
                          next_state <= S_SETUP;
                    end else  begin
                          next_state <= S_draw;
                    end
                   
                end 
                S_WAIT_MOVE: begin
                    //WAIT_MOVE state could go 4 ways depending on the key pressed (or restart)
                    if(!restart)begin
                        next_state <= S_SETUP;
                    end else if(((PS2==8'h1d)&&(delay))|| collision)begin
                        next_state <= S_UP;
                    end else if(((PS2==8'h1b)&&(delay))|| collision) begin
                        next_state <= S_DOWN;
                    end else if(((PS2==8'h1c)&&(delay))|| collision) begin
                        next_state <= S_LEFT;
                    end else if (((PS2==8'h23)&&(delay))|| collision) begin
                        next_state <= S_RIGHT;
                    end
                  
                end
                S_UP: begin 
                    if(!restart || collision)begin
                        next_state <= S_SETUP;
                    end  else begin
                        next_state <= S_erase;
                    end
                end
                S_DOWN: begin
                    if(!restart || collision)begin
                        next_state <= S_SETUP;
                    end  else begin
                        next_state <= S_erase;
                    end
                end
                S_LEFT: begin
                    if(!restart || collision)begin
                        next_state <= S_SETUP;
                    end  else begin
                        next_state <= S_erase;
                    end
                end
                S_RIGHT: begin
                    if(!restart || collision)begin
                        next_state <= S_SETUP;
                    end  else begin
                        next_state <= S_erase;
                    end
                end	
				S_erase: begin // unless D is no longer pressed, stay in "right"state
                    if(!restart)begin
                        next_state <= S_SETUP;
                    end else if(continue2)begin
                        next_state <= S_erase;
                    end else if(collision) begin
                        next_state <= S_SETUP;//go to setup only after you have erased
                    end else begin
                        next_state <= S_done2;
                    end
                end	
			    S_draw:begin // unless D is no longer pressed, stay in "right"state
                    if(!restart )begin
                        next_state <= S_SETUP;
                    end else if(continue)begin
                        next_state <= S_draw;
                    end else begin
                        next_state <= S_done;
                    end
                end
				S_wait:begin // unless D is no longer pressed, stay in "right"state
                    if(!restart)begin
                        next_state <= S_SETUP;
                    end else if(continue)begin
                        next_state <= S_draw;
                    end else begin
                        next_state <= S_done2;
                    end
                end
					 
				S_done: begin // unless D is no longer pressed, stay in "right"state
                    if(!restart)begin
                        next_state <= S_SETUP;
                    end else begin
                        next_state <= S_WAIT_MOVE;
                    end
                end	
		        S_done2: begin // unless D is no longer pressed, stay in "right"state
                    if(!restart)begin
                        next_state <= S_SETUP;
                    end else begin
                        next_state <=  S_draw;
                    end
                end					 
					 
            default: next_state = S_SETUP;
        endcase
    end // state_table
	 
    always @(*) begin : enable_signals
        // By default make all our signals 0
        ld_up = 1'b0;
        ld_down= 1'b0;
        ld_left = 1'b0;
        ld_right = 1'b0;
        ld_set = 1'b0;
        select_draw = 1'b0;
        select_erase = 1'b0; 
		     oPlot=1'b0;
		  resetTFF=1'b0;
		  oDone=0;
        inc=0;
		  incEr=0;
        select_update_current=0;
		  resetTFF2=0;

        case (current_state)
        
            S_SETUP:begin
                ld_set=1;
					 end
         
            
            S_UP: begin 
                ld_up=1;
              //stop reseting TFF count to 0 (counting needed to draw in next state)
            end
            S_DOWN: begin
                ld_down = 1'b1;
               //stop reseting TFF count to 0 (counting needed to draw in next state)
            end
            S_LEFT: begin
                ld_left = 1'b1;
               //stop reseting TFF count to 0 (counting needed to draw in next state)
            end
            S_RIGHT: begin
                ld_right = 1'b1;
                //stop reseting TFF count to 0 (counting needed to draw in next state)
            end
            S_erase: begin
                select_erase=1'b1;
					  resetTFF2=1;
                oPlot = 1'b1;
                incEr=1'b1;	
            end
            S_draw: begin
				  resetTFF=1;//reset TFF count before recieving a new input
                select_draw=1'b1;                
                oPlot = 1'b1;
                inc=1'b1;	
                select_update_current = 1'b1;//(set current to the "next", after erasing is over)
            end
            S_done: begin
                oDone = 1'b1;
                select_draw = 1'b0; 
					 select_erase=0;
                select_update_current = 1'b0;
                inc=1'b0;	
					 incEr=0;
                oPlot=1'b0;
            end
				   S_done2: begin
                oDone = 1'b1;
 
					 select_erase=0;
                select_update_current = 1'b0;
             
					 incEr=0;
                oPlot=1'b0;
            end
            // default: No default case needed
        endcase
    end // enable_signals

    always @(posedge iClock) begin : state_FFs
        if (!restart)
            current_state <= S_SETUP;
        else
            current_state <= next_state;
    end // state_FFs

endmodule


module collisionChecker(
    input Clock,
    input [7:0]leftmostX, input [7:0]topmostY,
    output reg collisionDetected
);
			
			//collision of individual rectangles
			reg colBorder, colRect1, colRect2, colRect3;
        //the extreme pixles (besides top left, which is the coordinates)
        reg[7:0] rightmostX, botmostY;
        //update the extreme pixles
        always@(*)begin
            rightmostX = leftmostX+3;
            botmostY = topmostY+3;
        end
		  

		  
        //checks border, then individual rectangles
		always@(posedge Clock)begin
			if(leftmostX < 15 || rightmostX > 139 || topmostY < 19 || botmostY > 104) begin //border (correct)
			    colBorder<=1;
				 //we know the other ones are false ig
				 colRect1 <= 0;
				 colRect2 <= 0;
				 colRect3 <= 0;
         end 
			else begin //cases where player within border (now checking rectangles)
					
					//we know for sure colBorder is false
					colBorder <= 0;
			
                if(
                    (rightmostX < 41)
                        ||
                    (leftmostX > 118)
                        ||
                    (topmostY > 90)
                        ||
                    (botmostY <85)
                ) begin //bottom rectanagle
                    colRect1<=0;
                end else begin
							colRect1 <= 1;
					 end 
					 
					 if(
                    (rightmostX < 58)
                        ||
                    (leftmostX > 65)
                        ||
                    (topmostY > 73)
                        ||
                    (botmostY < 31)
                ) begin //left rectangle
                    colRect2<=0;
                end else begin
							colRect2<=1;
					 end 
					 
					 if(
                    (rightmostX < 83)
                        ||
                    (leftmostX > 122)
                        ||
                    (topmostY > 50)
                        ||
                    (botmostY < 40)
                ) begin //right rectangle
                    colRect3<=0;
                end else begin 
                    colRect3<=1;
                end
            end //end of cases within bounds of map
				
		end
    //add more cases depending on what the maze looks like (mif file)
	 
	 
	 //if any of the rectangles collided with player, return collision true
	 always@(*) begin
		if(colBorder || colRect1 || colRect2 || colRect3)begin
			collisionDetected = 1;
		end else begin
			collisionDetected = 0;
		end
	 end
	 
endmodule


module datapath(
    input iClock,
    input ld_up, ld_down, ld_right, ld_left, ld_set, select_draw, select_erase,
    input select_update_current, 
    input [7:0] x4,input [6:0] y4,input [7:0] xEr,input [6:0] yEr,
    output reg [7:0]currentX,  output reg [6:0] currentY,  output reg [7:0] nextX,  output reg [6:0] nextY ,output reg[7:0] oX,  output reg [6:0]oY,  output reg [2:0] oColour
);  
reg [2:0] c;
    //the player coordinates (to be saved and updated)
    //these will be the starting points 
    //(like the tmp coordinates, that will be taken in and iterated by the TflopFour)
    //for drawing
    //current is set to the next value in the done state

    // input registers with respective input logic
    //RECALL: (0,0) is top left corner
always @(posedge iClock) begin
    if (ld_set) begin
        currentX <= 22;
        currentY <= 88;
        nextX <= 22;
        nextY <= 88;
        c <= 3'b100;
      
    end
    else if (ld_up) begin
        nextY <= currentY - 1; // up
        // reset TFF = 1'b1; // reset count (so you can prepare to draw again)
    end
    else if (ld_down) begin
        nextY <= currentY + 1;
    end
    else if (ld_left) begin
        nextX <= currentX - 1;
    end
    else if (ld_right) begin
        nextX <= currentX + 1;
    end
    else if (select_update_current) begin
        currentX <= nextX;
        currentY <= nextY;
    end
end

always @(*) begin
    if (select_erase)
        begin
            oColour <= 3'b000; // erase in black
            // coordinates given by the TflopFour
            oX <= xEr;
            oY <= yEr;
        end
        
    

   else if (select_draw)
       begin
            oColour <= c; // erase in red
            // coordinates given by the TflopFour
            oX <= x4;
            oY <= y4;
        end
        
        end
    


endmodule

module tflopFour(
    input Clock, 
    input resetTFF, 
    input inc,  
    input [7:0] tmpX, 
    input [6:0] tmpY,
    output reg [7:0] x4, 
    output reg [6:0] y4,
    output reg continue
);
    reg [3:0] CounterValue; 

    always @(posedge Clock) begin
        if (!resetTFF) begin
            CounterValue <= 4'b0;
            continue <= 1'b1; 
        end 
		  if (inc) begin
		  
            
            x4 <= CounterValue[1:0] + tmpX;
            y4 <= CounterValue[3:2] + tmpY;
			CounterValue <= CounterValue + 1;
            
            if((x4 == tmpX + 3'b011 - 1) && (y4 == tmpY + 2'b11 )) begin
                continue <= 1'b0;
            end else begin
                continue <= 1'b1; 
            end
				
        end
         else if(~inc) begin
		  x4<=tmpX;
		  y4<=tmpY;
      
    end // missing end statement
    end
endmodule


module delay( input Clock, input [20:0] counter, input reset,output reg delay, output reg [20:0] delaycounter);


always @(posedge Clock) begin 
 if(!reset) begin
	delaycounter<= 21'd0;
 end
 
 else if(delaycounter==counter)begin
 delay<=1;
 delaycounter<=0;
 end 
 
 else 
 begin
	delay<=0;
	delaycounter<=delaycounter +1;
 end
 
end
endmodule 
 

