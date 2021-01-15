`timescale 1ns / 1ps

module LoadGen_sim;

// Inputs
reg clk;
reg [2:0] btn;
reg [2:0] supposed_btn;

// Outputs
wire load_out;

// Instantiate the Unit Under Test (UUT)
LoadGen uut (
          .clk(clk),
          .btn(btn),
          .supposed_btn(supposed_btn),
          .load_out(load_out)
        );

initial
  begin
    // Initialize Inputs
    clk = 0;
    btn = 0;
    supposed_btn = 3'b111;

    // Wait 100 ns for global reset to finish
    #100;

    btn = 3'b111;
    #30;
    btn = 0;
    # 30;
    btn = 3'b101;
    #30;
    btn = 0;
  end

always
  begin
    clk = 1;
    #10;
    clk = 0;
    #10;
  end

endmodule
