`timescale 1ns / 1ps

module ZigZagGen(
         input wire clk,
         input wire zigzag,
         output reg o
       );

initial o = 1'b0;
reg old_zigzag = 1'b0;

always @ (negedge clk)
  begin
    old_zigzag <= zigzag;
    if (old_zigzag != zigzag) // posedge | negedge
      o <= 1'b1;
    else
      o <= 1'b0;
  end

endmodule
