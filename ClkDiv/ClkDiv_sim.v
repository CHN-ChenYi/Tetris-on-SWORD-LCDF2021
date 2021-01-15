`timescale 1ns / 1ps

module ClkDiv_sim;

// Inputs
reg clk;
reg [31:0] upperbound;

// Outputs
wire clkdiv;

// Instantiate the Unit Under Test (UUT)
ClkDiv uut (
         .clk(clk),
         .upperbound(upperbound),
         .clkdiv(clkdiv)
       );

initial
  begin
    // Initialize Inputs
    clk = 0;
    upperbound = 5;
    #500;

    upperbound = 1;
  end

always
  begin
    clk = 1;
    #10;
    clk = 0;
    #10;
  end

endmodule
