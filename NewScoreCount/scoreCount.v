`timescale 1ns / 1ps

module scoreCount(
	input clk,
	input rst,
	input hit,
	input [1:0] lineCount,
	output SEGCLK, 
	output SEGCLR, 
	output SEGDT,
	output SEGEN
	);

wire [11:0] num;
wire [63:0] segnum;

getHitTime aA(.hit(hit),.rst(rst),.lineCount(lineCount),.score(num));

decodeAll d1(.num(num),.segnum(segnum[23:0]));

assign segnum[63:56] = 8'b10010010;
assign segnum[55:48] = 8'b11000110;
assign segnum[47:40] = 8'b11000000;
assign segnum[39:32] = 8'b10001000;
assign segnum[31:24] = 8'b10000110;

Para2Ser p1(.clk(clk),.num(segnum),.sout({SEGCLK,SEGCLR,SEGDT,SEGEN}));

endmodule
