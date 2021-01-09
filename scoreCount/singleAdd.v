`timescale 1ns / 1ps

module singleAdd(
    input clk,
	input rst,
	input hit,
    input CR,
	output reg [3:0] Q
    );

always @(posedge clk or negedge rst) begin
	if (rst == 1'b1 || CR == 1'b1) 
	   Q <= 4'b0;
	else if (CR == 1'b0 && hit == 1'b1) 
	   Q <= Q + 1'b1;
end

endmodule