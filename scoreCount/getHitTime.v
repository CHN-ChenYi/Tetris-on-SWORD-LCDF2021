`timescale 1ns / 1ps

module getHitTime(
	input clk,
	input hit,
	input [1:0] lineCount,
	output reg hitTime
);

reg [4:0] remainingTime;

always @(posedge clk) begin
    if (hit == 1'b1) begin
		hitTime <= 1'b1;
        if (lineCount == 2'b01)
			remainingTime <= 4'b0011;
		else if (lineCount == 2'b10) 
			remainingTime <= 4'b1000;
		else if (lineCount == 2'b11) 
			remainingTime <= 4'b1111;
	end
	else if (remainingTime > 4'b0000) begin
		hitTime <= 1'b1;
		remainingTime <= remainingTime - 1;
	end
	else begin
		hitTime <= 1'b0;
	end
end

endmodule