`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    15:20:29 01/10/2021
// Design Name:
// Module Name:    Display
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
module combine( //锚点标记在4*4块右上角即float[15]处
         input wire [3:0] x, //锚点列位置，0-12
         input wire [4:0] y, //锚点行位置，0-22
         input wire [0:15] float, //动态方块
         input wire [0:199] static, //静态方块
         output wire [0:199] comb //组合图像
       );

endmodule

module display(input wire clk, //100MHz时钟
                input wire mode, //0为显示游戏内容，1为显示Game Over
                input wire [0:199] d, //组合图像输入
                output wire[3:0] r,
                output wire[3:0] g,
                output wire[3:0] b,
                output wire hs,
                output wire vs);

endmodule
