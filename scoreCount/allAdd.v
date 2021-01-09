`timescale 1ns / 1ps

module allAdd(
    input clk,
    input hit,
    input rst,
    output [11:0] num
    );

// 控制进位
wire carry_1;
wire carry_2;
wire carry_3;
// wire carry_4;
// wire carry_5;
// wire carry_6;
// wire carry_7;
// wire carry_8;

assign carry_1 = (num[0]&num[3]);
assign carry_2 = (num[4]&num[7]) & carry_1;
assign carry_3 = (num[8]&num[11]) & carry_2;
// assign carry_4 = (num[12]&num[15]) & carry_3;
// assign carry_5 = (num[16]&num[19]) & carry_4;
// assign carry_6 = (num[20]&num[23]) & carry_5;
// assign carry_7 = (num[24]&num[27]) & carry_6;
// assign carry_8 = (num[28]&num[31]) & carry_7;

// 控制使能
wire hit_2;
wire hit_3;
// wire hit_4;
// wire hit_5;
// wire hit_6;
// wire hit_7;
// wire hit_8;

assign hit_2 = (num[0]&num[3]);
assign hit_3 = (num[4]&num[7]) & carry_2;
// assign hit_4 = (num[8]&num[11]) & carry_3;
// assign hit_5 = (num[12]&num[15]) & carry_4;
// assign hit_6 = (num[16]&num[19]) & carry_5;
// assign hit_7 = (num[20]&num[23]) & carry_6;
// assign hit_8 = (num[24]&num[27]) & carry_7;

singleAdd sa1(.clk(clk),.rst(rst),.hit(hit),.CR(carry_1),.Q(num[3:0]));
singleAdd sa2(.clk(clk),.rst(rst),.hit(hit_2),.CR(carry_2),.Q(num[7:4]));
singleAdd sa3(.clk(clk),.rst(rst),.hit(hit_3),.CR(carry_3),.Q(num[11:8]));
// singleAdd sa4(.clk(clk),.rst(rst),.hit(hit_4),.CR(carry_4),.Q(num[15:12]));
// singleAdd sa5(.clk(clk),.rst(rst),.hit(hit_5),.CR(carry_5),.Q(num[19:16]));
// singleAdd sa6(.clk(clk),.rst(rst),.hit(hit_6),.CR(carry_6),.Q(num[23:20]));
// singleAdd sa7(.clk(clk),.rst(rst),.hit(hit_7),.CR(carry_7),.Q(num[27:24]));
// singleAdd sa8(.clk(clk),.rst(rst),.hit(hit_8),.CR(carry_8),.Q(num[31:28]));


endmodule
