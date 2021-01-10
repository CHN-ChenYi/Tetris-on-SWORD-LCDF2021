`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    15:39:08 01/10/2021
// Design Name:
// Module Name:    GameOverChecker
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
module GameOverChecker(
         input wire clk,
         input wire [3:0] pos_x, // anchor point position
         input wire [4:0] pos_y, // anchor point position
         input wire [0:15] float, // float blocks' status
         output wire game_over // 1 for game over
       );


endmodule
