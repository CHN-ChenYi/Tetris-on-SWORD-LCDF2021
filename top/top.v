module Top(
         input wire clk,
         input wire PS2_clk, PS2_data,
         input wire [3:0] SW,
         output wire SEGCLK, SEGCLR, SEGDT, SEGEN,
         output wire [3:0] r, g, b,
         output wire hs, vs,
         output wire [7:0] LED
       );

/////////////////////////////////////////////////////////////////////////
wire logic_clk;
ClkDiv LogicClk(clk, 32'd500_000, logic_clk);
wire user_clk, user_clk_o;
wire [31:0] speed = SW[3] ? 32'd12_500_000 :
                    SW[2] ? 32'd16_666_666 :
                    SW[1] ? 32'd25_000_000 :
                    32'd50_000_000;
ClkDiv UserClk(clk, speed, user_clk);
LoadGen user_gen(logic_clk, {2'b0, user_clk}, 3'b1, user_clk_o);

reg game_status = 1'b0; // 1 for over
reg [0:15] float = 16'b0;
reg [0:199] static = 200'b0;
parameter pos_x_ori = 4'd6, pos_y_ori = 5'd20; // TODO(TO/GA): delete it
// parameter pos_x_ori = 4'd6, pos_y_ori = 5'd23;
reg [3:0] pos_x = pos_x_ori;
reg [4:0] pos_y = pos_y_ori;

genvar i;
/////////////////////////////////////////////////////////////////////////
wire pressed[0:7];
wire [2:0] key;
Keyboard keyboard(clk, PS2_clk, PS2_data, key);
generate
  for (i = 0; i < 8; i = i + 1)
    begin : generate_load_gen
      LoadGen load_gen(logic_clk, key, i, pressed[i]);
    end
endgenerate

/////////////////////////////////////////////////////////////////////////
wire [2:0] random_number;
Random random(clk, random_number);

wire clockwise_valid;
wire [0:15] clockwise_float;
Rotate clockwise(float, 1'b0, clockwise_float);
CollisionChecker clockwise_checker(clk, pos_x, pos_y, clockwise_float, static, clockwise_valid);
wire [0:15] clockwise_float_o = (pressed[3] && clockwise_valid) ? clockwise_float : float;

wire counter_clockwise_valid;
wire [0:15] counter_clockwise_float;
Rotate counter_clockwise(clockwise_float_o, 1'b1, counter_clockwise_float);
CollisionChecker counter_clockwise_checker(clk, pos_x, pos_y, counter_clockwise_float, static, counter_clockwise_valid);
wire [0:15] counter_clockwise_float_o = (pressed[4] && counter_clockwise_valid) ? counter_clockwise_float : clockwise_float_o;

wire left_valid;
wire [3:0] left_pos_x = pos_x - 4'b1;
CollisionChecker left_checker(clk, left_pos_x, pos_y, counter_clockwise_float_o, static, left_valid);
wire [3:0] left_pos_x_o = (pressed[5] && left_valid) ? left_pos_x : pos_x;

wire right_valid;
wire [3:0] right_pos_x = left_pos_x_o + 4'b1;
CollisionChecker right_checker(clk, right_pos_x, pos_y, counter_clockwise_float_o, static, right_valid);
wire [3:0] right_pos_x_o = (pressed[6] && right_valid) ? right_pos_x : left_pos_x_o;

wire down_valid;
wire [4:0] down_pos_y = pos_y - 5'b1;
CollisionChecker down_checker(clk, right_pos_x_o, down_pos_y, counter_clockwise_float_o, static, down_valid);
wire [4:0] down_pos_y_o = (user_clk_o && down_valid) ? down_pos_y : pos_y;

wire space_valid[0:24];
wire [4:0] space_pos_y[0:24], space_pos_y_o[0:24];
assign space_pos_y[0] = down_pos_y_o - 5'b1;
CollisionChecker space_checker0(clk, right_pos_x_o, space_pos_y[0], counter_clockwise_float_o, static, space_valid[0]);
assign space_pos_y_o[0] = (pressed[2] && space_valid[0]) ? space_pos_y[0] : down_pos_y_o;
generate
  for (i = 1; i < 25; i = i + 1)
    begin : generate_space_checker
      assign space_pos_y[i] = space_pos_y_o[i - 1] - 5'b1;
      CollisionChecker space_checker(clk, right_pos_x_o, space_pos_y[i], counter_clockwise_float_o, static, space_valid[i]);
      assign space_pos_y_o[i] = (pressed[2] && space_valid[i]) ? space_pos_y[i] : space_pos_y_o[i - 1];
    end
endgenerate

wire down_valid2;
wire [4:0] down_pos_y2 = space_pos_y_o[24] - 5'b1;
CollisionChecker down_checker2(clk, right_pos_x_o, down_pos_y2, counter_clockwise_float_o, static, down_valid2);
wire down_valid2_o = down_valid2 | (~user_clk_o) | (user_clk_o & down_valid);
wire [3:0] new_pos_x = down_valid2_o ? right_pos_x_o : pos_x_ori;
wire [4:0] new_pos_y = down_valid2_o ? space_pos_y_o[24] : pos_y_ori;

wire [0:199] combined;
Combine combine(clk, right_pos_x_o, space_pos_y_o[24], counter_clockwise_float_o, static, combined);
wire [0:199] combined_o = down_valid2_o ? static : combined;

wire [2:0] row_cnt[0:3];
wire eliminate_valid[0:3];
wire [0:199] eliminated[0:3], eliminated_o[0:3];
RowEliminator row_eliminator0(clk, combined_o, eliminate_valid[0], eliminated[0]);
assign eliminated_o[0] = eliminate_valid[0] ? eliminated[0] : combined_o;
assign row_cnt[0] = {2'b0, eliminate_valid[0]};
generate
  for (i = 1; i < 4; i = i + 1)
    begin : generate_row_eliminator
      RowEliminator row_eliminator(clk, eliminated_o[i - 1], eliminate_valid[i], eliminated[i]);
      assign eliminated_o[i] = eliminate_valid[i] ? eliminated[i] : eliminated_o[i - 1];
      assign row_cnt[i] = eliminate_valid[i] ? row_cnt[i - 1] + 3'b1 : row_cnt[i - 1];
    end
endgenerate

wire game_over;
GameOverChecker game_over_checker(space_pos_y_o[24], counter_clockwise_float_o, game_over);

wire new_game_status = (~down_valid2_o & game_over) | game_status;

/////////////////////////////////////////////////////////////////////////

reg score_rst = 1'b0, score_hit = 1'b0;
wire score_rst_o, score_hit_o;
reg [1:0] line_cnt;
ZigZagGen score_rst_gen(clk, score_rst, score_rst_o);
ZigZagGen score_hit_gen(clk, score_hit, score_hit_o);
scoreCount score_count(clk, score_rst_o, score_hit_o, line_cnt, SEGCLK, SEGCLR, SEGDT, SEGEN);

wire [0:199] display;
Combine combine_display(clk, new_pos_x, new_pos_y, counter_clockwise_float_o, eliminated_o[3], display);

reg [0:199] display_o;
Display display_(clk, game_status, display_o, r, g, b, hs, vs);

always @ (negedge logic_clk)
  line_cnt <= row_cnt[3] - 3'b1;

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

// TODO(TO/GA): delete it
assign LED[0] = left_valid;
assign LED[1] = right_valid;
assign LED[2] = down_valid2;
assign LED[3] = down_valid2_o;
assign LED[4] = user_clk;
assign LED[5] = down_valid;
assign LED[6] = line_cnt[0];
assign LED[7] = line_cnt[1];

endmodule
