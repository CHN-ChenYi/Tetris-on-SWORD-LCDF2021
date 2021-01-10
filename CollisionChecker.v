`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    15:35:21 01/10/2021
// Design Name:
// Module Name:    CollisionChecker
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
module CollisionChecker(
         input wire clk,
         input wire [3:0] pos_x, // anchor point position
         input wire [4:0] pos_y, // anchor point position
         input wire [0:15] float, // float blocks' status
         input wire [0:199] static, // static blocks' status
         output wire collision // 1 for collision
       );


endmodule
