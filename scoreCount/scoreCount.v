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
	
wire hitTime;
wire [11:0] num;
wire [63:0] segnum;

// 根据得分情况输出要加的时钟周�?
getHitTime g1(.clk(clk),.hit(hit),.lineCount(lineCount),.hitTime(hitTime));
// 加分，每 hit 的时候加�?�?
allAdd aA(.clk(clk),.hit(hitTime),.rst(rst),.num(num));
// 译码
decodeAll d1(.num(num),.segnum(segnum[23:0]));
// 输出 SCORE 的大写字�?
assign segnum[63:56] = 8'b10010010;
assign segnum[55:48] = 8'b11000110;
assign segnum[47:40] = 8'b11000000;
assign segnum[39:32] = 8'b10001000;
assign segnum[31:24] = 8'b10000110;
// 输出
Para2Ser p1(.clk(clk),.num(segnum),.sout({SEGCLK,SEGCLR,SEGDT,SEGEN}));

endmodule