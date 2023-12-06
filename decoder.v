/******************************************************************************
 *                                                                            *
 * Module:       Hexadecimal_To_Seven_Segment                                 *
 * Description:                                                               *
 *      This module converts hexadecimal numbers for seven segment displays.  *
 *                                                                            *
 ******************************************************************************/
module decoder(inputValues, hexdisplay);
    input [3:0] inputValues;
    output reg [6:0] hexdisplay;
    always @(*)
        begin
            case(inputValues)
            4'b0000: hexdisplay= 7'b1000000;
            4'b0001: hexdisplay= 7'b1111001;
            4'b0010: hexdisplay= 7'b0100100;
            4'b0011: hexdisplay= 7'b0110000;
            4'b0100: hexdisplay= 7'b0011001;
            4'b0101: hexdisplay= 7'b0010010;
            4'b0110: hexdisplay= 7'b0000010;
            4'b0111: hexdisplay= 7'b1111000;
            4'b1000: hexdisplay= 7'b0000000;
            4'b1001: hexdisplay= 7'b0010000;
            4'b1010: hexdisplay= 7'b0001000;
            4'b1011: hexdisplay= 7'b0000011;
            4'b1100: hexdisplay= 7'b1000110;
            4'b1101: hexdisplay= 7'b0100001;
            4'b1110: hexdisplay= 7'b1111001;
            4'b1111: hexdisplay= 7'b0001110;
            endcase
        end

endmodule
