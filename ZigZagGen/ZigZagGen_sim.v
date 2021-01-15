`timescale 1ns / 1ps

module ZigZagGen_sim;

// Inputs
reg clk;
reg zigzag;

// Outputs
wire o;

// Instantiate the Unit Under Test (UUT)
ZigZagGen uut (
            .clk(clk),
            .zigzag(zigzag),
            .o(o)
          );

initial
  begin
    // Initialize Inputs
    clk = 0;
    zigzag = 0;

    // Wait 100 ns for global reset to finish
    #100;

    // Add stimulus here
    zigzag = 1;
    #45;
    zigzag = 0;
  end

always
  begin
    clk = 1;
    #10;
    clk = 0;
    #10;
  end

endmodule
