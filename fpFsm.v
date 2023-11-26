/*
fsm states:
1.setup (clear screen and reset x,y coordinates)
2.waitForMovement
2.up
3.down
4.left
5.right
6.reset

...or

1. clear screen
2. draw square

*/


module control(input restart, input start, input W_KEY, input S_KEY, input A_KEY, input D_KEY);
  reg [5:0] current_state, next_state;  

    localparam  S_SETUP = 5'd0,
                S_WAIT_MOVE = 5'd1,
                S_UP   = 5'd2,
                S_DOWN        = 5'd3,
                S_LEFT   = 5'd4,
                S_RIGHT       = 5'd5;
					 
					 
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
                    end else if(W) begin
                        next_state <= S_UP
                    end else if(S) begin
                        next_state <= S_DOWN;
                    end else if(A) begin
                        next_state <= S_LEFT;
                    end else if (D) begin
                        next_state <= S_RIGHT;
                    end
                    default: begin
                        next_state <= S_WAIT_MOVE;
                    end
                end
                S_UP: begin // unless w is no longer pressed, stay in "up"state
                    if(restart)begin
                        next_state <= S_SETUP;
                    end else if(~W_KEY)begin
                        next_state <= S_WAIT_MOVE;
                    end else begin
                        next_state <= S_UP;
                    end
                end
                S_DOWN: begin // unless S is no longer pressed, stay in "down"state
                    if(restart)begin
                        next_state <= S_SETUP;
                    end else if(~S_KEY)begin
                        next_state <= S_WAIT_MOVE;
                    end else begin
                        next_state <= S_DOWN;
                    end
                end
                S_LEFT: begin // unless A is no longer pressed, stay in "left"state
                    if(restart)begin
                        next_state <= S_SETUP;
                    end else if(~A_KEY)begin
                        next_state <= S_WAIT_MOVE;
                    end else begin
                        next_state <= S_LEFT;
                    end
                end
                S_RIGHT: begin // unless D is no longer pressed, stay in "right"state
                    if(restart)begin
                        next_state <= S_SETUP;
                    end else if(~D_KEY)begin
                        next_state <= S_WAIT_MOVE;
                    end else begin
                        next_state <= S_RIGHT;
                    end
                end			
					 
        default: next_state = S_WAIT_MOVE;
        endcase
    end // state_table
	 
    /*
      always @(*) begin : enable_signals
      // By default make all our signals 0
      ld_yc = 1'b0;
    ld_b= 1'b0;
      ld_x = 1'b0;
      select_x = 1'b0;
        select_y = 1'b0; 
        select_c = 1'b0; 
      inc=0;
    

      case (current_state)
        S_Black: begin 
        if(iBlack)begin
        ld_b=1;
        oDone = 1'b0; 
          oPlot = 1'b0;
        end
        end
        
          S_LOAD_X: begin
              ld_x = 1'b1;
              oDone = 1'b0; 
              oPlot = 1'b0;
          inc=1'b0;
          end
          S_LOAD_Y: begin
              ld_yc = 1'b1;
          end
          S_draw_0: begin
        select_x=1'b1;
        select_y=1'b1;
        select_c=1'b1;
      oPlot = 1'b1;
        inc=1'b1;	
        
        
      end
        
        S_draw_b: begin
        select_x = 1'b0;
          select_y = 1'b0; 
          select_c = 1'b0; 
              oPlot = 1'b1;
          inc8=1;
          
        
      end
          S_done: begin
              oDone = 1'b1;
          select_x = 1'b0;
          select_y = 1'b0; 
          select_c = 1'b0;
          inc=1'b0;	
          oPlot=1'b0;
        
          inc8=1'b0;
          end
          // default: No default case needed
      endcase

  end // enable_signals

  */

endmodule