// 调用其他文件夹的 .v 文件示例
// `include "scoreCount/scoreCount.v"

// ***************** 计分模块 ***************
// 最后四个是板子上的引脚，不用管，前面 clk 和 rst 也不说了，太水了
// 重点是 hit 和 lineCount，当得分的时候,hit 置为1，当消除一行，lineCount 为 0，当消除两行，lineCount 为 2'b01，三行为 2'b10 ，四行为 2'b11
// scoreCount sC1(.clk(clk),.rst(rst),hit(hit),.lineCount(lineCount),.SEGCLK(SEGCLK),.(SEGCLR),.SEGDT(SEGDT),.SEGEN(SEGEN));
module Top(
         input wire clk,
         input wire PS2_clk, PS2_data,
         output wire SEGCLK, SEGCLR, SEGDT, SEGEN
       );

reg [0:7] pressed;
reg [2:0] last_key;
wire [2:0] key;
wire or_key;
Keyboard keyboard(clk, PS2_clk, PS2_data, key);
assign or_key = | key;
always @ (posedge or_key)
  last_key <= key;
always @ (negedge or_key)
  pressed[last_key] <= 1'b1;

/////////////////////////////////////////////////////////////////////////
genvar var_i;
integer int_i;

reg [31:0] operation_pointer;
reg [0:3] float[0:3];
reg [0:9] static[0:19];
reg [3:0] x;
reg [4:0] y;

wire [0:15] float_unpacked;
generate
  for (var_i = 0; var_i < 16; var_i = var_i + 1)
    begin
      assign float_unpacked[var_i] = float[var_i / 4][var_i % 4];
    end
endgenerate

wire [0:199] static_unpacked;
generate
  for (var_i = 0; var_i < 200; var_i = var_i + 1)
    begin
      assign static_unpacked[var_i] = static[var_i / 10][var_i % 10];
    end
endgenerate

/////////////////////////////////////////////////////////////////////////
wire user_clk;
ClkDiv UserClk(clk, 32'd500_000_000, user_clk);

wire [2:0] random_number;
Random random(clk, random_number);

always @ (posedge user_clk)
  begin
    operation_pointer <= 1;
    if (random_number == 0)
      begin
        float[3] <= 4'b0100;
        float[2] <= 4'b0100;
        float[1] <= 4'b0100;
        float[0] <= 4'b0100;
      end
    else if (random_number == 1)
      begin
        float[3] <= 4'b0000;
        float[2] <= 4'b0100;
        float[1] <= 4'b0111;
        float[0] <= 4'b0000;
      end
    else if (random_number == 2)
      begin
        float[3] <= 4'b0000;
        float[2] <= 4'b0010;
        float[1] <= 4'b1110;
        float[0] <= 4'b0000;
      end
    else if (random_number == 3)
      begin
        float[3] <= 4'b0000;
        float[2] <= 4'b0110;
        float[1] <= 4'b1100;
        float[0] <= 4'b0000;
      end
    else if (random_number == 4)
      begin
        float[3] <= 4'b0000;
        float[2] <= 4'b1100;
        float[1] <= 4'b0110;
        float[0] <= 4'b0000;
      end
    else if (random_number == 5)
      begin
        float[3] <= 4'b0000;
        float[2] <= 4'b0100;
        float[1] <= 4'b1110;
        float[0] <= 4'b0000;
      end
    else if (random_number == 6)
      begin
        float[3] <= 4'b0000;
        float[2] <= 4'b0110;
        float[1] <= 4'b0110;
        float[0] <= 4'b0000;
      end
  end

/////////////////////////////////////////////////////////////////////////
wire logic_clk;
ClkDiv LogicClk(clk, 32'd50_000, logic_clk);

wire clockwise_valid;
wire [0:15] clockwise_float;
Rotate clockwise(clk, float_unpacked, 1'b0, clockwise_float);
CollisionChecker clockwise_checker(clk, x, y, clockwise_float, static_unpacked, clockwise_valid);

wire counter_clockwise_valid;
wire [0:15] counter_clockwise_float;
Rotate counter_clockwise(clk, float_unpacked, 1'b1, counter_clockwise_float);
CollisionChecker counter_clockwise_checker(clk, x, y, counter_clockwise_float, static_unpacked, counter_clockwise_valid);

wire left_valid;
wire left_x = x - 4'b1;
CollisionChecker left_checker(clk, left_x, y, float_unpacked, static_unpacked, left_valid);

wire right_valid;
wire right_x = x + 4'b1;
CollisionChecker right_checker(clk, right_x, y, float_unpacked, static_unpacked, right_valid);

wire down_valid;
wire down_y = y - 5'b1;
CollisionChecker down_checker(clk, x, down_y, float_unpacked, static_unpacked, down_valid);

always @ (posedge logic_clk)
  begin
    if (operation_pointer == 1) // esc
      begin
        if (pressed[1])
          begin
            // TODO(TO/GA): reset
          end
        pressed[1] <= 1'b0;
      end
    else if (operation_pointer == 2) // clockwise
      begin
        if (pressed[3] && clockwise_valid)
          begin
            for (int_i = 0; int_i < 4; int_i = int_i + 1)
              float[int_i] <= {clockwise_float[int_i * 4], clockwise_float[int_i * 4 + 1], clockwise_float[int_i * 4 + 2], clockwise_float[int_i * 4 + 3]}; // TODO(TO/GA): how to avoid collisions?
          end
        pressed[3] <= 1'b0;
      end
    else if (operation_pointer == 3) // counter_clockwise
      begin
        if (pressed[4] && counter_clockwise_valid)
          begin
            for (int_i = 0; int_i < 4; int_i = int_i + 1)
              float[int_i] <= {counter_clockwise_float[int_i * 4], counter_clockwise_float[int_i * 4 + 1], counter_clockwise_float[int_i * 4 + 2], counter_clockwise_float[int_i * 4 + 3]}; // TODO(TO/GA): how to avoid collisions?
          end
        pressed[4] <= 1'b0;
      end
    else if (operation_pointer == 4) // left
      begin
        if (pressed[5] && left_valid)
          x <= x - 4'b1;
        pressed[5] <= 1'b0;
      end
    else if (operation_pointer == 5) // right
      begin
        if (pressed[6] && right_valid)
          x <= x + 4'b1;
        pressed[6] <= 1'b0;
      end
    else if (operation_pointer == 6) // down
      begin
        if (down_valid)
          y <= y - 5'b1;
      end
    else if (7 <= operation_pointer && operation_pointer <= 31) // space
      begin
        if (pressed[2] && down_valid)
          y <= y - 5'b1;
      end
    else if (operation_pointer == 32) // clear space
      begin
        pressed[2] <= 1'b0;
      end
    else if (operation_pointer == 33) // update static
      begin

      end

    if (operation_pointer != 0) // next operation
      operation_pointer <= operation_pointer + 1;
  end

endmodule
