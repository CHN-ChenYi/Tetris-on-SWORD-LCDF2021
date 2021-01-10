`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    15:48:31 01/10/2021
// Design Name:
// Module Name:    ClkDiv
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
module ClkDiv(
         input wire clk,
         input wire [31:0] upperbound,
         output reg clkdiv
       );

reg [31:0] cnt;

initial
  cnt = 0;

always @ (posedge clk)
  begin
    if (cnt < upperbound)
      begin
        cnt <= cnt + 1;
      end
    else
      begin
        cnt <= 0;
        clkdiv <= ~clkdiv;
      end
  end

endmodule
