/*

*/

module part2(iReset,iClock,PS2,oX,oY,oColour,oPlot,oDone);
    parameter X_SCREEN_PIXELS = 8'd160;
    parameter Y_SCREEN_PIXELS = 7'd120;

    input wire iReset;
	input wire [7:0] PS2;
    input wire iClock;
    output wire [7:0] oX;         // VGA pixel coordinates
    output wire [6:0] oY;
    output wire [2:0] oColour;     // VGA pixel colour (0-7)
    output wire oPlot;       // Pixel draw enable
    output wire oDone;       // goes high when finished drawing frame
    wire ld_up,ld_down,ld_right,ld_left,ld_set,select_draw,select_erase;
    wire 
control draw0(iResetn,iClock,PS2,ld_up,ld_down,ld_right,ld_left,ld_set,continue,oPlot,oDone);
datapath d0(iXY_Coord, iColour, ld_x, ld_yc, select_x, select_y, select_c, iClock,iResetn,oX, oY, oColour, tmpX,x,x8, tmpY,y,y8,ld_b);   

tflopFour t0(iClock, iResetn, inc, tmpX, tmpY, x, y, continue);
tflopFour t1(iClock, iResetn, inc, ErX, ErY, x8, y8, continue);
tflopEight t1(iClock, iResetn,inc8, x8, y8, continue2);

endmodule // part2


module control(
    input restart, input iClock, input PS2,  
    output reg ld_up,ld_down,ld_right,ld_left,ld_set,select_draw,select_erase,oPlot, oDone,select_update_current,select_resetTFF,	
);

    localparam  S_SETUP = 5'd0,
                S_WAIT_MOVE = 5'd1,
                S_UP = 5'd2,
                S_DOWN = 5'd3,
                S_LEFT = 5'd4,
                S_RIGHT = 5'd5,
				S_erase = 5'd6,
				S_done_0 = 5'd7,
				S_draw = 5'd9;
					 
					 
					 always@(*)
    begin: state_table
            case (current_state)
				S_SETUP: begin
                    if(restart)begin
                          next_state <= S_SETUP;
                    end else if(start) begin
                          next_state <= S_WAIT_MOVE;
                    end
                    default: begin
                        next_state <= S_SETUP
                    end
                end 
                S_WAIT_MOVE: begin
                    //WAIT_MOVE state could go 4 ways depending on the key pressed (or restart)
                    if(restart)begin
                        next_state <= S_SETUP;
                    end else if(PS2==7'd29)begin
                        next_state <= S_UP
                    end else if(PS2==7'd27) begin
                        next_state <= S_DOWN;
                    end else if(PS2==7'd28) begin
                        next_state <= S_LEFT;
                    end else if (PS2==7'd35) begin
                        next_state <= S_RIGHT;
                    end
                    default: begin
                        next_state <= S_WAIT_MOVE;
                    end
                end
                S_UP: begin 
                    if(restart)begin
                        next_state <= S_SETUP;
                    end  else begin
                        next_state <= S_draw_0;
                    end
                end
                S_DOWN: begin
                    if(restart)begin
                        next_state <= S_SETUP;
                    end  else begin
                        next_state <= S_draw_0;
                    end
                end
                S_LEFT: begin
                    if(restart)begin
                        next_state <= S_SETUP;
                    end  else begin
                        next_state <= S_draw_0;
                    end
                end
                S_RIGHT: begin
                    if(restart)begin
                        next_state <= S_SETUP;
                    end  else begin
                        next_state <= S_draw_0;
                    end
                end	
				S_erase: begin // unless D is no longer pressed, stay in "right"state
                    if(restart)begin
                        next_state <= S_SETUP;
                    end else if(continue)begin
                        next_state <= S_erase;
                    end else begin
                        next_state <= S_draw;
                    end
                end	
			    S_draw:begin // unless D is no longer pressed, stay in "right"state
                    if(restart)begin
                        next_state <= S_SETUP;
                    end else if(continue)begin
                        next_state <= S_draw;
                    end else begin
                        next_state <= S_done_0;
                    end
                end
				S_done_0: begin // unless D is no longer pressed, stay in "right"state
                    if(restart)begin
                        next_state <= S_SETUP;
                    end else begin
                        next_state <= S_WAIT_MOVE;
                    end
                end				 	 
					 
            default: next_state = S_WAIT_MOVE;
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
    
        inc=0;
        

        case (current_state)
        
            S_SETUP:begin
                ld_set=1;
            S_WAIT_MOVE:begin
                select_resetTFF=1;//reset TFF count before recieving a new input
            end
            end
            S_UP: begin 
                ld_up=1;
                select_resetTFF = 1'b0;//stop reseting TFF count to 0 (counting needed to draw in next state)
            end
            S_DOWN: begin
                ld_down = 1'b1;
                select_resetTFF = 1'b0;//stop reseting TFF count to 0 (counting needed to draw in next state)
            end
            S_LEFT: begin
                ld_left = 1'b1;
                select_resetTFF = 1'b0;//stop reseting TFF count to 0 (counting needed to draw in next state)
            end
            S_RIGHT: begin
                ld_right = 1'b1;
                select_resetTFF = 1'b0;//stop reseting TFF count to 0 (counting needed to draw in next state)
            end
            S_erase: begin
                select_erase=1'b1;
                oPlot = 1'b1;
                inc=1'b1;	
            end
            S_draw: begin
                select_draw=1'b1;                
                oPlot = 1'b1;
                inc=1'b1;	
                select_update_current = 1'b1;//(set current to the "next", after erasing is over)
            end
            S_done: begin
                oDone = 1'b1;
                select_x = 1'b0;
                select_draw = 1'b0; 
                select_update_current = 1'b0;
                inc=1'b0;	
                oPlot=1'b0;
            end
            // default: No default case needed
        endcase
    end // enable_signals

    always @(posedge iClock) begin : state_FFs
        if (!iResetn)
            current_state <= S_Black;
        else
            current_state <= next_state;
    end // state_FFs

endmodule

module datapath(
    input Clock,
    input ld_up, ld_down, ld_right, ld_left, ld_set, select_draw, select_erase,
    input select_update_current, select_resetTFF,
    input x4, y4,
    output currentX, currentY, nextX, nextY, resetTFF, oX, oY, oColour
);
    //the player coordinates (to be saved and updated)
    //these will be the starting points 
    //(like the tmp coordinates, that will be taken in and iterated by the TflopFour)
    reg[0:6] currentX, currentY;//for erasing
    reg[0:6] nextX, nextY;//for drawing
    //current is set to the next value in the draw state

    // input registers with respective input logic
    //RECALL: (0,0) is top left corner
    always@(posedge iClock) begin
        if(ld_set) begin
            currentX <= 10;
		    currentY <= 10;
            nextX <= 10;
		    nextY <= 10;
			oColour=3'b100
            reset TFF = 1'b1;
        end
        else if(ld_up) begin
            nextY <= currentY-1;//up
            //reset TFF = 1'b1;//reset count (so you can prepare to draw again)
        end
		else if(ld_down) begin
            nextY <= currentY+1;
        end
		else  if(ld_left) begin
            nextX <= currentX-1; 
        end
		else  if(ld_right) begin
            nextX <= currentX+1;
        end	
    end

	always @(*)
    begin
        case(select_update_current)//called during draw state, after erase is over (set to 0 at done)
            1'b1:
                currentX <= nextX;
                currentY <= nextY;
        endcase
        case(select_resetTFF)//called at WAIT state(set to 0 at up,down,left or right)
            //before an input (WAIT STATE), resets TFF count before waiting for a new input
            //turned off once an input is recieved
            1'b1:
                resetTFF <= 1'b1;
        endcase
        case (select_erase)
            1'b1: 
                oColour = 3'b000;//erase in black
                //coordinates given by the TflopFour
                oX = x4;
				oY = y4;
        endcase
        case (select_draw)
            1'b1:
                oColour = 3'b100;//erase in red
                //coordinates given by the TflopFour
                oX = x4;
				oY = y4;		
        endcase
    end
endmodule

module tflopFour(
    input Clock, 
    input resetTFF, 
    input inc,  
    input [6:0] tmpX, 
    input [6:0] tmpY,
    output reg [6:0] x4, 
    output reg [6:0] y4,
    output reg continue
);
    reg [3:0] CounterValue; 

    always @(posedge Clock) begin
        if (resetTFF) begin
            CounterValue <= 4'b0;
            continue <= 1'b1; 
        end else if (inc) begin
		  
            
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