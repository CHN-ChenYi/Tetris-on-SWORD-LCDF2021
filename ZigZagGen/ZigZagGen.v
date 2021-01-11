`timescale 1ns / 1ps

module ZigZagGen(
         input wire clk,
         input wire zigzag,
         output reg o
       );

reg old_zigzag;

always @ (negedge clk)
  begin
    old_zigzag <= zigzag;
    if (old_zigzag != zigzag)
      o <= 1'b1;
    else
      o <= 1'b0;
  end

endmodule
