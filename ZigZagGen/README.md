# ZigZagGen 模块

## 基本信息

### 输入

* `input wire clk`: 时钟
* `input wire zigzag`: 见输出部分

### 输出

* `output reg o`: 当 `zigzag` 的值改变时，输出一个时钟周期的高电平

### 仿真模拟

![](./img/ZigZagGen.png)

如图，每当 `zigzag` 的值发生改变，都会输出 1 个周期的高电平，符合预期。