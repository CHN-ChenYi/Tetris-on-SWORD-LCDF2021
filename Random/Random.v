`timescale 1ns / 1ps

module Random(
         input  wire clk,
         output reg [4:0] data
       );

// fibonacci_lfsr

initial
  data = 4'hf;

wire feedback = data[4] ^ data[1];

always @(posedge clk)
  data <= {data[3:0], feedback};

endmodule
