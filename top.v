// 调用其他文件夹的 .v 文件示例
// `include "scoreCount/scoreCount.v"

// ***************** 计分模块 ***************
// 最后四个是板子上的引脚，不用管，前面 clk 和 rst 也不说了，太水了
// 重点是 hit 和 lineCount，当得分的时候,hit 置为1，当消除一行，lineCount 为 0，当消除两行，lineCount 为 2'b01，三行为 2'b10 ，四行为 2'b11
// scoreCount sC1(.clk(clk),.rst(rst),hit(hit),.lineCount(lineCount),.SEGCLK(SEGCLK),.(SEGCLR),.SEGDT(SEGDT),.SEGEN(SEGEN));