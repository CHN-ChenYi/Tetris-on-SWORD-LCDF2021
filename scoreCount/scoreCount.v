`timescale 1ns / 1ps

module scoreCount(
	input clk,
	input rst,
	input hit,
	input [1:0] lineCount,
	output SEGCLK,
	output SEGCLR,
	output SEGDT,
	output SEGEN);

wire [63:0] segnum;
wire hitTime;
wire [11:0] num;

// 根据得分情况输出要加的时钟周�
getHitTime g1(.clk(clk),.hit(hit),.lineCount(lineCount),.hitTime(hitTime));
// 加分，每�hit 的时候都�
allAdd a1(.clk(clk),.hit(hitTime),.rst(rst),.num(num));
// 译码
decodeAll d1(.num(num),.segnum(segnum[23:0]));
// 输出 SCORE 的大写字�
assign segnum[63:56] = 7'b0010010;
assign segnum[55:48] = 7'b1000110;
assign segnum[47:40] = 7'b1000000;
assign segnum[39:32] = 7'b0001000;
assign segnum[31:24] = 7'b0000110;
// 输出
Para2Ser p1(.clk(clk),.num(segnum[23:0]),.sout({SEGCLK,SEGCLR,SEGDT,SEGEN}));

endmodule