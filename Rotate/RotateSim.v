`timescale 1ns / 1ps

module rotate_sim;

// Inputs
reg [0:15] float;
reg direction;

// Outputs
wire [0:15] new_float;

// Instantiate the Unit Under Test (UUT)
Rotate uut (
         .float(float),
         .direction(direction),
         .new_float(new_float)
       );

initial
  begin
    // Initialize Inputs
    float = 0;
    direction = 0;

    float = 16'b0100_0100_0100_0100;
    #10;
    float = 16'b0000_0111_0100_0000;
    #10;
    float = 16'b0000_1110_0010_0000;
    #10;
    float = 16'b0000_1100_0110_0000;
    #10;
    float = 16'b0000_0110_1100_0000;
    #10;
    float = 16'b0000_1110_0100_0000;
    #10;
    float = 16'b0000_0110_0110_0000;
    #10;

    #20;
    direction = 1;
    float = 16'b0100_0100_0100_0100;
    #10;
    float = 16'b0000_0111_0100_0000;
    #10;
    float = 16'b0000_1110_0010_0000;
    #10;
    float = 16'b0000_1100_0110_0000;
    #10;
    float = 16'b0000_0110_1100_0000;
    #10;
    float = 16'b0000_1110_0100_0000;
    #10;
    float = 16'b0000_0110_0110_0000;
    #10;

  end

endmodule
