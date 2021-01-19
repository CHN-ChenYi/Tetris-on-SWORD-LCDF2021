`timescale 1ns / 1ps

//output the sum of two single BCD coded number a+b to c
module bcd_bit(input wire[3:0] a,b,
                output wire[3:0] c,
                input wire cin,
                output wire cout
                );

    wire [4:0] t;
    assign t={1'b0,a}+{1'b0,b}+{4'b0,cin};
    assign {cout,c}=(t>5'd9)?t+5'd6:t;

endmodule

// output the results of BCD code a+b to c
module bcd_adder(input wire[11:0] a,b,
                 output wire[11:0] c);

    wire [1:0] out;
    bcd_bit bcd0 (.a(a[3:0]),.b(b[3:0]),.c(c[3:0]),.cin(1'b0),.cout(out[0]));
    bcd_bit bcd1 (.a(a[7:4]),.b(b[7:4]),.c(c[7:4]),.cin(out[0]),.cout(out[1]));
    bcd_bit bcd2 (.a(a[11:8]),.b(b[11:8]),.c(c[11:8]),.cin(out[1]));

endmodule


module addScore(
	input hit,
  input rst,
	input [1:0] lineCount,
	output reg[11:0] score
);

initial score=0;

reg [11:0] t=12'h001;

// map the lines to the score
always@(*)begin
  case(lineCount)
    2'b00:t<=12'h001;
    2'b01:t<=12'h004;
    2'b10:t<=12'h009;
    2'b11:t<=12'h016;
  endcase
end

wire[11:0] update;

// add the scores accordingly to wire update
bcd_adder b0 (score,t,update);

// when reset, score = 0
always@(posedge hit or posedge rst) begin
  if(rst==1'b1) score<=12'h000;
  else score<=update;
end

endmodule
