`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    19:19:35 01/10/2021
// Design Name:
// Module Name:    ZigZagGen
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module ZigZagGen(
         input wire clk,
         input wire zigzag,
         output reg o
       );

reg old_zigzag;

always @ (negedge clk)
  begin
    old_zigzag <= zigzag;
    if (old_zigzag != zigzag)
      o <= 1'b1;
    else
      o <= 1'b0;
  end

endmodule
