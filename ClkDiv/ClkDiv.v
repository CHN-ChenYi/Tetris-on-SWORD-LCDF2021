`timescale 1ns / 1ps

module ClkDiv(
         input wire clk,
         input wire [31:0] upperbound,
         output reg clkdiv
       );

reg [31:0] cnt;

initial
  begin
    cnt = 0;
    clkdiv = 0;
  end

always @ (posedge clk)
  begin
    if (cnt < upperbound)
      begin
        cnt <= cnt + 1;
      end
    else
      begin
        cnt <= 0;
        clkdiv <= ~clkdiv;
      end
  end

endmodule
