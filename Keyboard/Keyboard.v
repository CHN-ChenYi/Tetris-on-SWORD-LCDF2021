`timescale 1ns / 1ps

module Keyboard(
         input wire clk, ps2_clk, ps2_data,
         output wire [2:0] key
       );

wire valid;
wire [7:0] raw_data;
reg [7:0] last_raw_data, data;
ps2_keyboard keyboard(clk, ps2_clk, ps2_data, raw_data, valid);

always @ (posedge clk)
  begin
    if (valid == 1'b1 && raw_data != 8'hE0)
      begin
        if (last_raw_data == 8'hF0)
          data <= 8'b0;
        else if (raw_data != 8'hF0)
          data <= raw_data;
        last_raw_data <= raw_data;
      end
  end

assign key = (data == 8'h00) ? 3'd0 :            // not pressed
       (data == 8'h76) ? 3'd1 :                  // esc
       (data == 8'h29) ? 3'd2 :                  // space
       (data == 8'h1D || data == 8'h42 || data == 8'h75) ? 3'd3 : // up
       (data == 8'h1B || data == 8'h3B || data == 8'h72) ? 3'd4 : // down
       (data == 8'h1C || data == 8'h33 || data == 8'h6B) ? 3'd5 : // left
       (data == 8'h23 || data == 8'h4B || data == 8'h74) ? 3'd6 : // right
       3'd7;

endmodule
