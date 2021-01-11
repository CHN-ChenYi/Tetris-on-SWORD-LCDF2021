`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    10:52:52 01/11/2021
// Design Name:
// Module Name:    LoadGen
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
module LoadGen(
         input wire clk,
         input wire [2:0] btn,
         input wire [2:0] supposed_btn,
         output reg load_out
       );

initial
  load_out = 0;
reg [2:0] old_btn;

always@(posedge clk)
  begin
    if ((old_btn == supposed_btn) && (btn == 3'b0))
      load_out <= 1'b1;
    else
      load_out <= 1'b0;
  end
always@(posedge clk)
  begin
    old_btn <= btn;
  end

endmodule
