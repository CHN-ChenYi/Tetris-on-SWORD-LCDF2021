`timescale 1ns / 1ps

module bcd_adder(input wire[11:0] a,b,
                 output wire[11:0] c);
  wire[4:0] ta, tb, tc;
  assign ta={1'b0,a[3:0]}+{1'b0,b[3:0]};
  assign tb={1'b0,a[7:4]}+{1'b0,b[7:4]};
  assign tc={1'b0,a[11:8]}+{1'b0,b[11:8]};

  wire[4:0] taa, tbb, tcc;
  assign taa=(ta>5'd9)?ta+5'd6:ta;
  assign tbb=(tb>5'd9)?tb+5'd6:tb;
  assign tcc=(tc>5'd9)?tc+5'd6:tc;

  assign c[11:8]=tcc[3:0]+tbb[4];
  assign c[7:4]=tbb[3:0]+taa[4];
  assign c[3:0]=taa[3:0];
endmodule


module getHitTime(
	input hit,
  input rst,
	input [1:0] lineCount,
	output reg[11:0] score
);

initial score=0;

reg [11:0] t=12'h001;

always@(*)begin
  case(lineCount)
    2'b00:t<=12'h001;
    2'b01:t<=12'h004;
    2'b10:t<=12'h009;
    2'b11:t<=12'h016;
  endcase
end

wire[11:0] update;

bcd_adder b0 (score,t,update);

always@(posedge hit or posedge rst) begin
  if(rst==1'b1) score<=12'h000;
  else score<=update;
end

/* initial remainingTime = 0;

always @(negedge clk) begin
    if (hit == 1'b1) begin
		hitTime <= 1'b1;
        if (lineCount == 2'b01)
			remainingTime <= 4'b0011;
		else if (lineCount == 2'b10) 
			remainingTime <= 4'b1000;
		else if (lineCount == 2'b11) 
			remainingTime <= 4'b1111;
	end
	else if (remainingTime != 4'b0000) begin
		hitTime <= 1'b1;
		remainingTime <= remainingTime - 4'b0001;
	end
	else
		hitTime <= 1'b0;
end */

endmodule
