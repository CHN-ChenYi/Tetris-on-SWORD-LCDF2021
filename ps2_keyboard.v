`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    22:51:46 01/03/2021
// Design Name:
// Module Name:    ps2_keyboard
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

module ps2_keyboard (input wire clk, ps2_clk, ps2_data,
                     output reg [7:0] data, output reg valid);

reg idle = 1'b1;
reg [9:0] ps2_shift = 10'b1000000000;
reg [1:0] Fall_Clk;

always @ (posedge clk)
  Fall_Clk <= {Fall_Clk[0], ps2_clk};

reg zigzag = 1'b1;
always @ (posedge clk)
  begin
    if (idle)
      begin
        ps2_shift <= 10'b1000000000;
        if ((Fall_Clk == 2'b10) && (!ps2_data))
          idle <= 1'b0;
        else
          idle <= 1'b1;
      end
    else
      begin
        if (Fall_Clk == 2'b10)
          begin
            if (ps2_shift[0] && ps2_data)
              begin
                data <= ps2_shift[8:1];
                zigzag = zigzag ^ 1'b1;
                idle <= 1'b1;
              end
            else
              begin
                ps2_shift <= {ps2_data, ps2_shift[9:1]};
                idle <= 1'b0;
              end
          end
        else
          begin
            idle <= 1'b0;
          end
      end
  end

reg old_zigzag;
ZigZagGen zig_zag_gen(clk, zigzag, valid);

endmodule
