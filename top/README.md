# Top 模块

## 输入输出

### 输入

* 键盘输入
  * 允许 `WASD`，`HJKL`（参考 Vim）和方向键的上下左右
    * “上”表示方块顺时针旋转
    * “下”表示方块逆时针旋转
    * “左”表示方块向左平移
    * “右”表示方块向右平移
  * `Escape` 键表示重新开始游戏。由于默认游戏状态为游戏结束，因此刚上板时 `Escape` 键相当于开始游戏。
* 开关输入
  * 从 `SW[0]` 到 `SW[3]` 一共四个速度选择开关，其中 `SW[3]` 为速度最快的，若有速度快的开关和速度慢的开关同时为 1 的话，采取快的那个速度

### 输出

* VGA 输出：显示当前游戏状态
* 八位七段数码管输出：`SCOREXXX`，其中 `XXX` 为玩家当前分数

## 逻辑

### 总体逻辑

游戏本质上是如图所示的一个时序电路。其中的 `Game Logic Circuit` 虽然也是时序电路，但在大体上看可以当作一个延时较高（几十个周期）的组合电路，原因是当某模块前序模块输出稳定后，其输出也会稳定，最终达到串行处理的效果，其具体构成见状态转移部分。

![](img/top-Page-1.svg)

每个 logic_clk，逻辑电路都会更新一下游戏局面。当 user_clk（周期比 logic_clk 长） 为上升沿的时候，俄罗斯方块会向下移动一格，这个设计使得用户可以在方块下落一格的时间段中多次平移/旋转。

### 状态

俄罗斯方块游戏的游戏状态被定义为了 5 个子状态：
* `static`: 当前已经静止的方块的状态，由一个 200 位的数表示，从左下角 0 开始先向右再向上编号，即右下角的块的编号为 9，右上角为 199。对应编号的位若为 0 则表示那里没有方块
* `float`: 当前仍在浮动的方块的状态，用一个 16 位数表示，与 `static` 的编号方式类似，下面给出 7 种俄罗斯方块的初始状态
  * 1 型
    ```
    0100
    0100
    0100
    0100
    ```
  * J 型
    ```
    0000
    0100
    0111
    0000
    ```
  * L 型
    ```
    0000
    0010
    1110
    0000
    ```
  * S 型
    ```
    0000
    0110
    1100
    0000
    ```
  * Z 型
    ```
    0000
    1100
    0110
    0000
    ```
  * T 型
    ```
    0000
    0100
    1110
    0000
    ```
  * O 型
    ```
    0000
    0110
    0110
    0000
    ```
* `pos_x` 与 `pos_y`: 浮动的方块的 4*4 矩形的右上角的方块在静止游戏局面的坐标，以右上角为锚点是为了防止负数的出现
* `game_status`: 当前游戏的状态，0 表示游戏正在进行中，1 表示游戏已经结束

### 状态转移

首先定义一个模板模块（类似于 C++ 中的模板函数），以降低电路图的绘制复杂度。如下图为一个 `UpdateState` 模板模块，其参数为 `(T, en, State, NextState)`。功能为：若当前游戏局面经过 T 的改变后依旧合法（指没有碰撞或超出边界），且使能输入为真，则输出改变后的游戏局面，不然的话输出原游戏局面。
![](img/top-Page-2.svg)

如下图即为 `Game Logic Circuit` 的示意图。原游戏状态一次经过了旋转、平移、下降、加速下降等操作后进行了一次对于浮动方块能否继续下落的判断。如果能继续下落，说明当前浮动的方块没有落地，则更新显示输出并正常进行下一个周期的逻辑判断。如果不能继续下落，说明浮动的方块落到底了，此时进行消行操作，更新静止模块、积分模块的状态并将浮动模块移回到屏幕最上方，同时更新成为下一个俄罗斯方块。与之并行的，还有对于游戏是否结束的判断，在图中并没有画出。
![](img/top-Page-final.svg)

下面是 logic_clk 上升沿对游戏局面进行更新的代码。

``` verilog
always @ (posedge logic_clk)
  begin
    if (pressed[1])
      begin
        score_rst <= score_rst ^ 1'b1;
        game_status <= 1'b0;
        static <= 200'b0;
        pos_x <= pos_x_ori;
        pos_y <= pos_y_ori;
        if (random_number == 0)
          float <= 16'b0100_0100_0100_0100;
        else if (random_number == 1)
          float <= 16'b0000_0111_0100_0000;
        else if (random_number == 2)
          float <= 16'b0000_1110_0010_0000;
        else if (random_number == 3)
          float <= 16'b0000_1100_0110_0000;
        else if (random_number == 4)
          float <= 16'b0000_0110_1100_0000;
        else if (random_number == 5)
          float <= 16'b0000_1110_0100_0000;
        else
          float <= 16'b0000_0110_0110_0000;
      end
    else
      begin
        game_status <= new_game_status;
        if (new_pos_x == pos_x_ori && new_pos_y == pos_y_ori)
          begin
            if (random_number == 0)
              float <= 16'b0100_0100_0100_0100;
            else if (random_number == 1)
              float <= 16'b0000_0111_0100_0000;
            else if (random_number == 2)
              float <= 16'b0000_1110_0010_0000;
            else if (random_number == 3)
              float <= 16'b0000_1100_0110_0000;
            else if (random_number == 4)
              float <= 16'b0000_0110_1100_0000;
            else if (random_number == 5)
              float <= 16'b0000_1110_0100_0000;
            else
              float <= 16'b0000_0110_0110_0000;
          end
        else
          float <= counter_clockwise_float_o;
        static <= eliminated_o[3];
        pos_x <= new_pos_x;
        pos_y <= new_pos_y;

        if (row_cnt[3])
          score_hit <= score_hit ^ 1'b1;

        display_o <= display;
      end
  end
```
