`timescale 1ns / 1ps

module singleAdd(
    input clk,
	input hit,
    input carry,
	output reg [3:0] Q
    );

initial Q <= 4'b0000;
always @(posedge clk or negedge carry) begin
	if (carry == 1'b0) 
		Q <= 4'b0000;
	else if (hit == 1'b1) 
		Q <= Q + 4'b0001;
end

endmodule