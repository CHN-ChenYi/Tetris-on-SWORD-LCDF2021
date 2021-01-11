`timescale 1ns / 1ps

module GameOverChecker_sim;

// Inputs
reg [4:0] pos_y;
reg [0:15] float;

// Outputs
wire game_over;

// Instantiate the Unit Under Test (UUT)
GameOverChecker uut (
                  .pos_y(pos_y),
                  .float(float),
                  .game_over(game_over)
                );

initial
  begin
    float = 16'b0000000000000000;
    pos_y = 5'd23;
    #5;
    float = 16'b0100000000000000;
    #10;

    float = 16'b1111000000000000;
    pos_y = 5'd22;
    #5;
    float = 16'b1111010000000000;
    #10;

    float = 16'b1111111100000000;
    pos_y = 5'd21;
    #5;
    float = 16'b1111111101000000;
    #10;

    float = 16'b1111111111110000;
    pos_y = 5'd20;
    #5;
    float = 16'b1111111111110100;
    #10;

    float = 16'b1111111111111111;
    pos_y = 5'd19;
  end

endmodule
