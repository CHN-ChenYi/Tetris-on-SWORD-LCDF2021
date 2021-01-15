`timescale 1ns / 1ps

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
