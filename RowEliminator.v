`timescale 1ns / 1ps

module RowEliminator(
         input wire clk,
         input wire [0:199] static, // static blocks' status
         output wire eliminated, // 1 for one row eliminated
         output reg [0:199] new_static // after removing a complete row
       );

// ...
// 10  11  12  13  14  15  16  17  18  19 
// 0   1   2   3   4   5   6   7   8   9   

// full[0] 表示现在状态下最底下那一行有没有满
wire [19:0] full;
// fullRowBelow[5] 表示第6行以及更下面的行中有多少行是满的，最多只会有4行
wire [2:0] fullRowBelow[20:0];
// eliminated 只要对全体 full 取或即可
assign eliminated = |full;

// 暂存下一个局面
wire [0:199] temp_static;

// 判断每行有没有满
genvar	i;
generate for(i = 0;i < 20;i = i + 1)
	begin : afor
		assign full[i] = & static[i*10:i*10+9];
	end
endgenerate

// 判断每一行它们下面都有多少行是满的
assign fullRowBelow[0] = full[0];
generate for(i = 1;i < 20;i = i + 1)
	begin : bfor
		  assign fullRowBelow[i] = fullRowBelow[i-1] + full[i];
	end
endgenerate

// 如果这一行（含自己）以及下面的行有full的，
// 那么假设记录这些 full 的行数为 n
// 那么这一行等于这一行上面 n 行的方块格局
generate for(i = 0;i < 20;i = i + 1)
  begin : cfor
      assign temp_static[i] = static[i+fullRowBelow[i]];
  end
endgenerate

// 每个时钟周期更新一次局面
// 反正其他都是 wire，不如全更新
always @(posedge clk) begin
  new_static <= temp_static;
end

endmodule
