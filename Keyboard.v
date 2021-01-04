`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    13:43:32 01/04/2021
// Design Name:
// Module Name:    Keyboard
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
module Keyboard(
         input wire clk, ps2_clk, ps2_data,
         output reg [7:0] data
       );

wire valid;
wire [7:0] raw_data;
reg [7:0] last_raw_data;
ps2_keyboard keyboard(clk, ps2_clk, ps2_data, raw_data, valid);

always @ (posedge clk)
  begin
    if (valid == 1'b1)
      begin
        if (last_raw_data == 8'hF0)
          data <= 8'b0;
        else if (raw_data != 8'hF0)
          data <= raw_data;
        last_raw_data <= raw_data;
      end
  end

endmodule
