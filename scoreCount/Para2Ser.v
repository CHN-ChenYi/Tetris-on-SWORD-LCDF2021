`timescale 1ns / 1ps

module Para2Ser(
	input [23:0] num,
	input clk,
	output [3:0] sout
    );

wire SEGCLK,SEGCLR,SEGDT,SEGEN;
assign sout[3:0]={SEGCLK,SEGCLR,SEGDT,SEGEN};

reg [24:0] shift;
initial shift = 0;
reg [23:0] num_old;
reg update;

wire clken;
assign clken = | shift[23:0];
assign SEGCLK = ~clk & clken;
assign SEGDT = shift[24];
assign SEGCLR = 1'b1;
assign SEGEN = 1'b1;

always @(posedge clk) begin
	num_old <= num;  
	if(num_old != num)
		update <= 1;
	else 
		update <= 0;
	if(clken)
		shift = {shift[23:0],1'b0};
	else if (update)
		shift = {num,1'b1};
end

endmodule