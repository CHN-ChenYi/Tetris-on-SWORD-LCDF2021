`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    15:28:37 01/10/2021
// Design Name:
// Module Name:    RowEliminator
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
module RowEliminator(
         input wire clk,
         input wire [0:199] static, // static blocks' status
         output wire eliminated, // 1 for one row eliminated
         output wire [0:199] new_static // after removing a complete row
       );


endmodule
