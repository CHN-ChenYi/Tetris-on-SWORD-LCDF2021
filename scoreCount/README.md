# scoreCount 模块

用途：将分数显示至数码管上

结构

- scoreCount
   -  getHitTime
   - allAdd
      - singleAdd
   - decodeAll
      - SegmentDecoder
   - Para2Ser

## 顶层模块

接受“消除了一行”的信号和“消除了几行”的信号。

调用 getHitTime 模块，将消除几行换算成增加几分，然后将几分换算成输出几个时钟周期的 hitTime 信号。

调用 allAdd 模块，使用 BCD 码来加分，每次读到一个 hitTime 信号，分数 + 1。

渲染出 SCORE 的字母。

复用以前实验写的显示模块来显示分数。

## 分数计算模块

消除 1 行加 1 分，2 行加 4 分，3 行加 9 分， 4 行加 16 分。

### getHitTime 模块

用于将对应分数转换成对应长度时间周期的信号。接受到 hit 信号表示有无击中，接收到 lineCount 表示一次性消除了几行，用两位二进制表示消除1到4行。比如，如果接收到一次性消除了3行，那么会传递 9（因为消除3行加9分）个时钟周期长度的 hitTime 信号。

仿真代码和结果放这儿记录一下，方便日后写报告。

仿真代码

```verilog
`timescale 1ns / 1ps


module sim_getHitTime;

	// Inputs
	reg clk;
	reg hit;
	reg [1:0] lineCount;

	// Outputs
	wire hitTime;

	// Instantiate the Unit Under Test (UUT)
	getHitTime uut (
		.clk(clk), 
		.hit(hit), 
		.lineCount(lineCount), 
		.hitTime(hitTime)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		hit = 1;
		lineCount = 0;

		// Wait 100 ns for global reset to finish
		#10;
      hit = 0;
		#100;
		lineCount = 2'b01;
		hit = 1;
		#12;
		hit = 0;
		#100;
		lineCount = 2'b10;
		hit = 1;
		#15;
		hit = 0;
		#200;
		lineCount = 2'b11;
		hit = 1;
		#15;
		hit = 0;
		// Add stimulus here

	end
	
	always begin
		clk = 0; #10;
		clk = 1; #10;
	end
      
endmodule


```

仿真结果

![](img/getHitTime.jpg)

仿真结果表明，在 hit 为 0 的时候（没有出现消除行的情况下），hitTime 始终为0。在 hit 为 1 且 lineCount 为 00 (表明消除了一行)，hitTime 为 1 个时钟周期。在 hit 为 1 且 lineCount 为 01(表明消除了两行)，hitTime 为 4 个时钟周期。在 hit 为 1 且 lineCount 为 10 (表明消除了三行)，hitTime 为 9 个时钟周期。在 hit 为 1 且 lineCount 为 11(表明消除了四行)，hitTime 为 16 个时钟周期。

### allAdd 模块

调用了 singleAdd 模块，然后实现十进制的进位。每次接收到加分信号就加分。难点是处理进位的关系。

我的仿真代码如下

```verilog
`timescale 1ns / 1ps

module sim;

	// Inputs
	reg clk;
	reg hit;
	reg rst;

	// Outputs
	wire [11:0] num;

	// Instantiate the Unit Under Test (UUT)
	allAdd uut (
		.clk(clk), 
		.hit(hit), 
		.rst(rst), 
		.num(num)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		hit = 1;
		rst = 1;

		// Wait 100 ns for global reset to finish
		#100;
      rst = 0;
		// Add stimulus here

	end
   always begin
		clk = 0;#10;
		clk = 1;#10;
	end
endmodule


```

仿真结果如下

![](img/addAll.jpg)

仿真结果（已切换到 Hexadecimal 显示）中可以看到，最容易出现问题的 100 交接的地方也顺利完成了自增操作。

### singleAdd 模块

核心是控制一个 4 位 BCD 码。

当复位信号或者进位信号（由上层控制，指自己加到10了）来临时，输出0。

当 hit 信号来临时，输出的值增加1。 比较简单，不做仿真了。

### 联合仿真

将整个 scoreCount 模块进行仿真。

仿真代码如下：

```verilog
`timescale 1ns / 1ps

module sim_scoreCount;

	// Inputs
	reg clk;
	reg rst;
	reg hit;
	reg [2:0] lineCount;

	// Outputs
	wire SEGCLK;
	wire SEGCLR;
	wire SEGDT;
	wire SEGEN;

	// Instantiate the Unit Under Test (UUT)
	scoreCount uut (
		.clk(clk), 
		.rst(rst), 
		.hit(hit), 
		.lineCount(lineCount),  
		.SEGCLK(SEGCLK), 
		.SEGCLR(SEGCLR), 
		.SEGDT(SEGDT), 
		.SEGEN(SEGEN)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		hit = 0;
		lineCount = 0;

		// Wait 100 ns for global reset to finish
		#100;
		rst = 0;
      hit = 1;
		#9;
		hit = 0;
		#100;
		hit = 1;
		lineCount = 2'b01;
		#9;
		hit = 0;
		#100;
		hit = 1;
		lineCount = 2'b10;
		#9;
		hit = 0;
		#100;
		hit = 1;
		lineCount = 2'b11;
		#9;
		hit = 0;
		// Add stimulus here

	end
	always begin
		clk = 0; #5;
		clk = 1; #5;
	end
      
endmodule


```

仿真结果如下：

![](img/scoreCount.jpg)

由于 SEGDT 模块太难看懂，我们添加 num 和 hitTime 两个中间变量来观测，可以看到 num 成功地随着 hit 和 lineCount 的变化而更新了。而显示模块只是复用以前的，所以不会出错。

## 显示模块

### decodeAll 模块

将 32位 的 BCD 码（即 8 个十进制数）译码成八个七段数码管的对应值。其中调用了 SegmentDecoder 模块，用于对单一的4位二进制数译码成七段数码管的值。以前实验调用过，不赘述，没仿真。

### Para2Ser 模块

串行转并行，用于数码管显示，以前实验调用过，不赘述，没仿真。