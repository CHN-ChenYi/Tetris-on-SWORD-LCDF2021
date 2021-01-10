// 调用其他文件夹的 .v 文件示例
// `include "scoreCount/scoreCount.v"
module Top(
         input wire clk,
         input wire PS2_clk, PS2_data,
         output wire SEGCLK, SEGCLR, SEGDT, SEGEN,
         output wire [3:0] r, g, b,
         output wire hs, vs
       );

reg [1:0] pressed_write[0:7] = {2'b0, 2'b0, 2'b0, 2'b0, 2'b0, 2'b0, 2'b0, 2'b0}, pressed_read[0:7] = {2'b0, 2'b0, 2'b0, 2'b0, 2'b0, 2'b0, 2'b0, 2'b0};
reg [2:0] last_key = 2'b0;
wire [2:0] key;
wire or_key;
Keyboard keyboard(clk, PS2_clk, PS2_data, key);
assign or_key = | key;
always @ (posedge or_key)
  last_key <= key;
always @ (negedge or_key)
  pressed_write[last_key] <= pressed_write[last_key] + 1'b1;

/////////////////////////////////////////////////////////////////////////
wire logic_clk;
ClkDiv LogicClk(clk, 32'd50_000, logic_clk);
wire user_clk;
ClkDiv UserClk(clk, 32'd500_000_000, user_clk);

genvar var_i;
integer int_i;

reg game_status = 1'b0; // 1 for over
reg [31:0] operation_pointer = 1'b0;
reg [0:3] float[0:3] = {4'b0, 4'b0, 4'b0, 4'b0};
reg [0:9] static[0:19] = {10'b0, 10'b0, 10'b0, 10'b0, 10'b0, 10'b0, 10'b0, 10'b0, 10'b0, 10'b0, 10'b0, 10'b0, 10'b0, 10'b0, 10'b0, 10'b0, 10'b0, 10'b0, 10'b0, 10'b0};
parameter pos_x_ori = 4'd6, pos_y_ori = 5'd24;
reg [3:0] pos_x = pos_x_ori;
reg [4:0] pos_y = pos_y_ori;

wire [0:15] float_unpacked;
generate
  for (var_i = 0; var_i < 16; var_i = var_i + 1)
    begin : generate_float_unpacked
      assign float_unpacked[var_i] = float[var_i / 4][var_i % 4];
    end
endgenerate

wire [0:199] static_unpacked;
generate
  for (var_i = 0; var_i < 200; var_i = var_i + 1)
    begin : generate_static_unpacked
      assign static_unpacked[var_i] = static[var_i / 10][var_i % 10];
    end
endgenerate

/////////////////////////////////////////////////////////////////////////
reg iteration_zigzag = 1'b0;
wire start_iteration;
ZigZagGen start_iteration_gen(logic_clk, iteration_zigzag, start_iteration);

always @ (posedge user_clk)
  begin
    iteration_zigzag <= iteration_zigzag ^ 1'b1;
  end

/////////////////////////////////////////////////////////////////////////
wire [2:0] random_number;
Random random(clk, random_number);

wire clockwise_valid;
wire [0:15] clockwise_float;
Rotate clockwise(clk, float_unpacked, 1'b0, clockwise_float);
CollisionChecker clockwise_checker(clk, pos_x, pos_y, clockwise_float, static_unpacked, clockwise_valid);

wire counter_clockwise_valid;
wire [0:15] counter_clockwise_float;
Rotate counter_clockwise(clk, float_unpacked, 1'b1, counter_clockwise_float);
CollisionChecker counter_clockwise_checker(clk, pos_x, pos_y, counter_clockwise_float, static_unpacked, counter_clockwise_valid);

wire left_valid;
wire [3:0] left_pos_x = pos_x - 4'b1;
CollisionChecker left_checker(clk, left_pos_x, pos_y, float_unpacked, static_unpacked, left_valid);

wire right_valid;
wire [3:0] right_pos_x = pos_x + 4'b1;
CollisionChecker right_checker(clk, right_pos_x, pos_y, float_unpacked, static_unpacked, right_valid);

wire down_valid;
wire [4:0] down_pos_y = pos_y - 5'b1;
CollisionChecker down_checker(clk, pos_x, down_pos_y, float_unpacked, static_unpacked, down_valid);

wire [0:199] combined;
Combine combine(clk, pos_x, pos_y, float_unpacked, static_unpacked, combined);

reg [2:0] row_cnt = 3'b0;
wire eliminate_valid;
wire [0:199] eliminated;
RowEliminator row_eliminator(clk, static_unpacked, eliminate_valid, eliminated);

reg score_rst = 1'b0, score_hit = 1'b0;
wire score_rst_o, score_hit_o;
wire [1:0] line_cnt = row_cnt - 3'b1;
ZigZagGen score_rst_gen(clk, score_rst, score_rst_o);
ZigZagGen score_hit_gen(clk, score_hit, score_hit_o);
scoreCount score_count(clk, score_rst_o, score_hit_o, line_cnt, SEGCLK, SEGCLR, SEGDT, SEGEN);

wire game_over;
GameOverChecker game_over_checker(pos_y, float_unpacked, game_over);
wire current_valid;
CollisionChecker current_checker(clk, pos_x, pos_y, float_unpacked, static_unpacked, current_valid);

always @ (posedge logic_clk)
  begin
    if (start_iteration) // init
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
    else
      begin
        if (operation_pointer == 1) // esc
          begin
            if (pressed_read[1] != pressed_write[1])
              begin
                score_rst <= score_rst ^ 1'b1;
                game_status <= 1'b0;
                for (int_i = 0; int_i < 20; int_i = int_i + 1)
                  static[int_i] <= 10'b0;
                pos_x <= pos_x_ori;
                pos_y <= pos_y_ori;
              end
            pressed_read[1] <= pressed_write[1];
          end
        else if (operation_pointer == 2) // clockwise
          begin
            if (pressed_read[3] != pressed_write[3] && clockwise_valid)
              begin
                for (int_i = 0; int_i < 4; int_i = int_i + 1)
                  float[int_i] <= {clockwise_float[int_i * 4], clockwise_float[int_i * 4 + 1], clockwise_float[int_i * 4 + 2], clockwise_float[int_i * 4 + 3]}; // TODO(TO/GA): how to avoid collisions?
              end
            pressed_read[3] <= pressed_write[3];
          end
        else if (operation_pointer == 3) // counter_clockwise
          begin
            if (pressed_read[4] != pressed_write[4] && counter_clockwise_valid)
              begin
                for (int_i = 0; int_i < 4; int_i = int_i + 1)
                  float[int_i] <= {counter_clockwise_float[int_i * 4], counter_clockwise_float[int_i * 4 + 1], counter_clockwise_float[int_i * 4 + 2], counter_clockwise_float[int_i * 4 + 3]}; // TODO(TO/GA): how to avoid collisions?
              end
            pressed_read[4] <= pressed_write[4];
          end
        else if (operation_pointer == 4) // left
          begin
            if (pressed_read[5] != pressed_write[5] && left_valid)
              pos_x <= pos_x - 4'b1;
            pressed_read[5] <= pressed_write[5];
          end
        else if (operation_pointer == 5) // right
          begin
            if (pressed_read[6] != pressed_write[6] && right_valid)
              pos_x <= pos_x + 4'b1;
            pressed_read[6] <= pressed_write[6];
          end
        else if (operation_pointer == 6) // down
          begin
            if (down_valid)
              pos_y <= pos_y - 5'b1;
          end
        else if (7 <= operation_pointer && operation_pointer <= 31) // space
          begin
            if (pressed_read[2] != pressed_write[2] && down_valid)
              pos_y <= pos_y - 5'b1;
          end
        else if (operation_pointer == 32) // clear space
          begin
            pressed_read[2] <= pressed_write[2];
          end
        else if (operation_pointer == 33) // update static
          begin
            for (int_i = 0; int_i < 20; int_i = int_i + 1)
              static[int_i] <= {combined[int_i * 10], combined[int_i * 10 + 1], combined[int_i * 10 + 2], combined[int_i * 10 + 3], combined[int_i * 10 + 4], combined[int_i * 10 + 5], combined[int_i * 10 + 6], combined[int_i * 10 + 7], combined[int_i * 10 + 8], combined[int_i * 10 + 9]}; // TODO(TO/GA): how to avoid collisions?
            row_cnt <= 3'b0; // prepare for next operation
          end
        else if (34 <= operation_pointer && operation_pointer <= 37) // eliminate rows
          begin
            if (eliminate_valid)
              begin
                row_cnt <= row_cnt + 3'b1;
                for (int_i = 0; int_i < 20; int_i = int_i + 1)
                  static[int_i] <= {eliminated[int_i * 10], eliminated[int_i * 10 + 1], eliminated[int_i * 10 + 2], eliminated[int_i * 10 + 3], eliminated[int_i * 10 + 4], eliminated[int_i * 10 + 5], eliminated[int_i * 10 + 6], eliminated[int_i * 10 + 7], eliminated[int_i * 10 + 8], eliminated[int_i * 10 + 9]}; // TODO(TO/GA): how to avoid collisions?
              end
          end
        else if (operation_pointer == 38) // update score
          begin
            if (row_cnt)
              begin
                score_hit <= score_hit ^ 1'b1;
              end
          end
        else if (operation_pointer == 39) // game over
          begin
            if (game_over || !current_valid)
              begin
                game_status <= 1'b1;
              end
          end
        else if (operation_pointer == 40) // update pos
          begin
            pos_x <= pos_x_ori;
            pos_y <= pos_y_ori;
          end

        if (pressed_read[1] != pressed_write[1] || game_status) // game over //TODO(TO/GA): test pressed[1]
          operation_pointer <= 1'b0;
        else if (operation_pointer != 0) // next operation
          operation_pointer <= operation_pointer + 1;
      end
  end

wire display_clk;
ClkDiv DisplayClk(clk, 100_000_000, display_clk);
Display display(display_clk, game_status, combined, r, g, b, hs, vs);

endmodule
