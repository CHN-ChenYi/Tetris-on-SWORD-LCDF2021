`timescale 1ns / 1ps

module Random_sim;

// Inputs
reg clk;

// Outputs
wire [4:0] data;

// Instantiate the Unit Under Test (UUT)
Random uut (
         .clk(clk),
         .data(data)
       );

always
  begin
    clk = 1;
    #10;
    clk = 0;
    #10;
  end

endmodule
