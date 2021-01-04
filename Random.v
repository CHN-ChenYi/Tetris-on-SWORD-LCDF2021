`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    16:49:54 01/04/2021
// Design Name:
// Module Name:    Random
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
module Random(
         input  wire clk,
         output reg [4:0] data
       );

// fibonacci_lfsr

initial
  data = 4'hf;

wire feedback = data[4] ^ data[1] ;

always @(posedge clk)
  data <= {data[3:0], feedback} ;

endmodule
