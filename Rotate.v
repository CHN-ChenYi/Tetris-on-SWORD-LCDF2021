`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    15:31:35 01/10/2021
// Design Name:
// Module Name:    Rotate
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
module Rotate(
         input wire clk,
         input wire [0:15] float, // float blocks' status
         input wire direction, // 0 for clockwise
         output wire [0:15] new_float // after rotation
       );

genvar i, j;
generate
  for (i = 0; i < 4; i = i + 1)
    begin
      for (j = 0; j < 4; j = j + 1)
        begin
          assign new_float[i * 4 + j] = direction ? float[j * 4 + 3 - i] : float[(3 - j) * 4 + i];
        end
    end
endgenerate

endmodule
