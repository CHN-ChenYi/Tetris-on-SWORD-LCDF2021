`timescale 1ns / 1ps

module CollisionChecker(
         input wire clk,
         input wire [3:0] pos_x, // anchor point position
         input wire [4:0] pos_y, // anchor point position
         input wire [0:15] float, // float blocks' status
         input wire [0:199] static, // static blocks' status
         output wire collision // 1 for collision
       );

// 12 13 14 15
// 8  9  10 11
// 4  5  6  7
// 0  1  2  3

reg patternCollision;
reg bottomCollision;
reg leftCollision;
reg rightCollision;

// realPosition for 16 points
wire [8:0] realPos[0:15];
assign realPos[0] = ((pos_y - 2'b11) * 4'b1010) + pos_x - 2'b11; 
assign realPos[1] = ((pos_y - 2'b11) * 4'b1010) + pos_x - 2'b10; 
assign realPos[2] = ((pos_y - 2'b11) * 4'b1010) + pos_x - 1'b1; 
assign realPos[3] = ((pos_y - 2'b11) * 4'b1010) + pos_x; 
assign realPos[4] = ((pos_y - 2'b10) * 4'b1010) + pos_x - 2'b11; 
assign realPos[5] = ((pos_y - 2'b10) * 4'b1010) + pos_x - 2'b10; 
assign realPos[6] = ((pos_y - 2'b10) * 4'b1010) + pos_x - 1'b1; 
assign realPos[7] = ((pos_y - 2'b10) * 4'b1010) + pos_x; 
assign realPos[8] = ((pos_y - 1'b1) * 4'b1010) + pos_x - 2'b11; 
assign realPos[9] = ((pos_y - 1'b1) * 4'b1010) + pos_x - 2'b10; 
assign realPos[10] = ((pos_y - 1'b1) * 4'b1010) + pos_x - 1'b1; 
assign realPos[11] = ((pos_y - 1'b1) * 4'b1010) + pos_x; 
assign realPos[12] = (pos_y * 4'b1010) + pos_x - 2'b11; 
assign realPos[13] = (pos_y * 4'b1010) + pos_x - 2'b10; 
assign realPos[14] = (pos_y * 4'b1010) + pos_x - 1'b1; 
assign realPos[15] = (pos_y * 4'b1010) + pos_x; 

// from bottom to up, whether each row has at least a block
wire [0:3] row;
assign row[0] = |float[0:3];
assign row[1] = |float[4:7];
assign row[2] = |float[8:11];
assign row[3] = |float[12:15];

// from left to right
wire [0:3] col;
assign col[0] = |{float[0],float[4],float[8],float[12]};
assign col[1] = |{float[1],float[5],float[9],float[13]};
assign col[2] = |{float[2],float[6],float[10],float[14]};
assign col[3] = |{float[3],float[7],float[11],float[15]};

// once collide, collision = 1
assign collision = patternCollision | bottomCollision | leftCollision | rightCollision;

// judge pattern
always @(posedge clk) begin
  case (pos_x)
    4'b0000:
      case (pos_y)
        5'b00000:patternCollision <= (float[15] & static[realPos[15]]); 
        5'b00001:patternCollision <= (float[11] & static[realPos[11]]) | (float[15] & static[realPos[15]]);
        5'b00010:patternCollision <= (float[7] & static[realPos[7]]) | (float[11] & static[realPos[11]]) | (float[15] & static[realPos[15]]); 
        5'b10100:patternCollision <= (float[3] & static[realPos[3]]) | (float[7] & static[realPos[7]]) | (float[11] & static[realPos[11]]);
        5'b10101:patternCollision <=(float[3] & static[realPos[3]]) | (float[7] & static[realPos[7]]); 
        5'b10110:patternCollision <= (float[3] & static[realPos[3]]); 
        default: patternCollision <= (float[3] & static[realPos[3]]) | (float[7] & static[realPos[7]]) | (float[11] & static[realPos[11]]) | (float[15] & static[realPos[15]]); 
      endcase
    4'b0001:
      case (pos_y)
        5'b00000: patternCollision <= (float[14] & static[realPos[14]]) | (float[15] & static[realPos[15]]);
        5'b00001: patternCollision <= (float[14] & static[realPos[14]]) | (float[15] & static[realPos[15]]) | (float[10] & static[realPos[10]]) | (float[11] & static[realPos[11]]);
        5'b00010: patternCollision <= (float[14] & static[realPos[14]]) | (float[15] & static[realPos[15]]) | (float[10] & static[realPos[10]]) | (float[11] & static[realPos[11]]) | (float[6] & static[realPos[6]]) | (float[7] & static[realPos[7]]);
        5'b10100: patternCollision <= (float[2] & static[realPos[2]]) | (float[6] & static[realPos[6]]) | (float[10] & static[realPos[10]]) | (float[3] & static[realPos[3]]) | (float[7] & static[realPos[7]]) | (float[11] & static[realPos[11]]);
        5'b10101: patternCollision <= (float[2] & static[realPos[2]]) | (float[6] & static[realPos[6]]) | (float[3] & static[realPos[3]]) | (float[7] & static[realPos[7]]) ;
        5'b10110: patternCollision <= (float[2] & static[realPos[2]]) | (float[3] & static[realPos[3]]);
        default: patternCollision <= (float[2] & static[realPos[2]]) | (float[6] & static[realPos[6]]) | (float[10] & static[realPos[10]]) | (float[14] & static[realPos[14]]) | (float[3] & static[realPos[3]]) | (float[7] & static[realPos[7]]) | (float[11] & static[realPos[11]]) | (float[15] & static[realPos[15]]); 
      endcase
    4'b0010:
      case (pos_y)
        5'b00000: patternCollision <= (float[13] & static[realPos[13]]) | (float[14] & static[realPos[14]]) | (float[15] & static[realPos[15]]);
        5'b00001: patternCollision <= (float[9] & static[realPos[9]]) | (float[10] & static[realPos[10]]) | (float[11] & static[realPos[11]]) | (float[13] & static[realPos[13]]) | (float[14] & static[realPos[14]]) | (float[15] & static[realPos[15]]);
        5'b00010: patternCollision <= (float[5] & static[realPos[5]]) | (float[6] & static[realPos[6]]) | (float[7] & static[realPos[7]]) | (float[9] & static[realPos[9]]) | (float[10] & static[realPos[10]]) | (float[11] & static[realPos[11]]) | (float[13] & static[realPos[13]]) | (float[14] & static[realPos[14]]) | (float[15] & static[realPos[15]]);
        5'b10100: patternCollision <= (float[1] & static[realPos[1]]) | (float[2] & static[realPos[2]]) | (float[3] & static[realPos[3]]) | (float[5] & static[realPos[5]]) | (float[6] & static[realPos[6]]) | (float[7] & static[realPos[7]]) | (float[9] & static[realPos[9]]) | (float[10] & static[realPos[10]]) | (float[11] & static[realPos[11]]);
        5'b10101: patternCollision <= (float[1] & static[realPos[1]]) | (float[2] & static[realPos[2]]) | (float[3] & static[realPos[3]]) | (float[5] & static[realPos[5]]) | (float[6] & static[realPos[6]]) | (float[7] & static[realPos[7]]);
        5'b10110: patternCollision <= (float[1] & static[realPos[1]]) | (float[2] & static[realPos[2]]) | (float[3] & static[realPos[3]]);
        default: patternCollision <= (float[1] & static[realPos[1]]) | (float[2] & static[realPos[2]]) | (float[3] & static[realPos[3]]) | (float[5] & static[realPos[5]]) | (float[6] & static[realPos[6]]) | (float[7] & static[realPos[7]]) | (float[9] & static[realPos[9]]) | (float[10] & static[realPos[10]]) | (float[11] & static[realPos[11]]) | (float[13] & static[realPos[13]]) | (float[14] & static[realPos[14]]) | (float[15] & static[realPos[15]]);
      endcase
    4'b1010:
      case (pos_y)
        5'b00000: patternCollision <= (float[13] & static[realPos[13]]) | (float[14] & static[realPos[14]]) | (float[12] & static[realPos[12]]);
        5'b00001: patternCollision <= (float[9] & static[realPos[9]]) | (float[10] & static[realPos[10]]) | (float[8] & static[realPos[8]]) | (float[13] & static[realPos[13]]) | (float[14] & static[realPos[14]]) | (float[12] & static[realPos[12]]);
        5'b00010: patternCollision <= (float[5] & static[realPos[5]]) | (float[6] & static[realPos[6]]) | (float[4] & static[realPos[4]]) | (float[9] & static[realPos[9]]) | (float[10] & static[realPos[10]]) | (float[8] & static[realPos[8]]) | (float[13] & static[realPos[13]]) | (float[14] & static[realPos[14]]) | (float[12] & static[realPos[12]]);
        5'b10100: patternCollision <= (float[1] & static[realPos[1]]) | (float[2] & static[realPos[2]]) | (float[0] & static[realPos[0]]) | (float[5] & static[realPos[5]]) | (float[6] & static[realPos[6]]) | (float[4] & static[realPos[4]]) | (float[9] & static[realPos[9]]) | (float[10] & static[realPos[10]]) | (float[8] & static[realPos[8]]);
        5'b10101: patternCollision <= (float[1] & static[realPos[1]]) | (float[2] & static[realPos[2]]) | (float[0] & static[realPos[0]]) | (float[5] & static[realPos[5]]) | (float[6] & static[realPos[6]]) | (float[4] & static[realPos[4]]);
        5'b10110: patternCollision <= (float[1] & static[realPos[1]]) | (float[2] & static[realPos[2]]) | (float[0] & static[realPos[0]]);
        default: patternCollision <= (float[1] & static[realPos[1]]) | (float[2] & static[realPos[2]]) | (float[0] & static[realPos[0]]) | (float[5] & static[realPos[5]]) | (float[6] & static[realPos[6]]) | (float[4] & static[realPos[4]]) | (float[9] & static[realPos[9]]) | (float[10] & static[realPos[10]]) | (float[8] & static[realPos[8]]) | (float[13] & static[realPos[13]]) | (float[14] & static[realPos[14]]) | (float[12] & static[realPos[12]]);
      endcase
    4'b1011:
      case (pos_y)
        5'b00000: patternCollision <= (float[12] & static[realPos[12]]) | (float[13] & static[realPos[13]]);
        5'b00001: patternCollision <= (float[12] & static[realPos[12]]) | (float[13] & static[realPos[13]]) |  (float[8] & static[realPos[8]])  |  (float[9] & static[realPos[9]]) ;
        5'b00010: patternCollision <= (float[12] & static[realPos[12]]) | (float[13] & static[realPos[13]]) |  (float[8] & static[realPos[8]])  |  (float[9] & static[realPos[9]]) | (float[4] & static[realPos[4]]) | (float[5] & static[realPos[5]]) ;
        5'b10100: patternCollision <= (float[8] & static[realPos[8]])  |  (float[9] & static[realPos[9]]) | (float[4] & static[realPos[4]]) | (float[5] & static[realPos[5]]) | (float[0] & static[realPos[0]]) | (float[1] & static[realPos[1]]);
        5'b10101: patternCollision <= (float[4] & static[realPos[4]]) | (float[5] & static[realPos[5]]) | (float[0] & static[realPos[0]]) | (float[1] & static[realPos[1]]);
        5'b10110: patternCollision <= (float[0] & static[realPos[0]]) | (float[1] & static[realPos[1]]);
        default: patternCollision <= (float[12] & static[realPos[12]]) | (float[13] & static[realPos[13]]) |  (float[8] & static[realPos[8]])  |  (float[9] & static[realPos[9]]) | (float[4] & static[realPos[4]]) | (float[5] & static[realPos[5]]) | (float[0] & static[realPos[0]]) | (float[1] & static[realPos[1]]);
      endcase
    4'b1100:
      case (pos_y)
        5'b00000: patternCollision <= (float[0] & static[realPos[0]]); 
        5'b00001: patternCollision <= (float[0] & static[realPos[0]]) | (float[4] & static[realPos[4]]); 
        5'b00010: patternCollision <= (float[0] & static[realPos[0]]) | (float[4] & static[realPos[4]]) | (float[8] & static[realPos[8]]); 
        5'b10100: patternCollision <= (float[4] & static[realPos[4]]) | (float[8] & static[realPos[8]]) | (float[12] & static[realPos[12]]); 
        5'b10101: patternCollision <= (float[8] & static[realPos[8]]) | (float[12] & static[realPos[12]]); 
        5'b10110: patternCollision <= (float[12] & static[realPos[12]]);
        default: patternCollision <= (float[0] & static[realPos[0]]) | (float[4] & static[realPos[4]]) | (float[8] & static[realPos[8]]) | (float[12] & static[realPos[12]]); 
      endcase
    default:
      case (pos_y)
        5'b00000: patternCollision <= (float[12] & static[realPos[12]]) | (float[13] & static[realPos[13]]) | (float[14] & static[realPos[14]]) | (float[15] & static[realPos[15]]);
        5'b00001: patternCollision <= (float[8] & static[realPos[8]]) | (float[9] & static[realPos[9]]) | (float[10] & static[realPos[10]]) | (float[11] & static[realPos[11]]) | (float[12] & static[realPos[12]]) | (float[13] & static[realPos[13]]) | (float[14] & static[realPos[14]]) | (float[15] & static[realPos[15]]);
        5'b00010: patternCollision <= (float[4] & static[realPos[4]]) | (float[5] & static[realPos[5]]) | (float[6] & static[realPos[6]]) | (float[7] & static[realPos[7]]) | (float[8] & static[realPos[8]]) | (float[9] & static[realPos[9]]) | (float[10] & static[realPos[10]]) | (float[11] & static[realPos[11]]) | (float[12] & static[realPos[12]]) | (float[13] & static[realPos[13]]) | (float[14] & static[realPos[14]]) | (float[15] & static[realPos[15]]);
        5'b10100: patternCollision <= (float[0] & static[realPos[0]]) | (float[1] & static[realPos[1]]) | (float[2] & static[realPos[2]]) | (float[3] & static[realPos[3]]) | (float[4] & static[realPos[4]]) | (float[5] & static[realPos[5]]) | (float[6] & static[realPos[6]]) | (float[7] & static[realPos[7]]) | (float[8] & static[realPos[8]]) | (float[9] & static[realPos[9]]) | (float[10] & static[realPos[10]]) | (float[11] & static[realPos[11]]);
        5'b10101: patternCollision <= (float[0] & static[realPos[0]]) | (float[1] & static[realPos[1]]) | (float[2] & static[realPos[2]]) | (float[3] & static[realPos[3]]) | (float[4] & static[realPos[4]]) | (float[5] & static[realPos[5]]) | (float[6] & static[realPos[6]]) | (float[7] & static[realPos[7]]);
        5'b10110: patternCollision <=  (float[0] & static[realPos[0]]) | (float[1] & static[realPos[1]]) | (float[2] & static[realPos[2]]) | (float[3] & static[realPos[3]]);
        default:patternCollision <= (float[0] & static[realPos[0]]) | (float[1] & static[realPos[1]]) | (float[2] & static[realPos[2]]) | (float[3] & static[realPos[3]]) | (float[4] & static[realPos[4]]) | (float[5] & static[realPos[5]]) | (float[6] & static[realPos[6]]) | (float[7] & static[realPos[7]]) | (float[8] & static[realPos[8]]) | (float[9] & static[realPos[9]]) | (float[10] & static[realPos[10]]) | (float[11] & static[realPos[11]]) | (float[12] & static[realPos[12]]) | (float[13] & static[realPos[13]]) | (float[14] & static[realPos[14]]) | (float[15] & static[realPos[15]]); 
      endcase
  endcase
end

// judge bottom
// if pos_y < 0, then pos_y = 11111
always @(posedge clk) begin
  if (pos_y == 5'b11111)
    bottomCollision <= 1'b1;
  else if (row[0] == 1'b1)
    bottomCollision <= ~ (pos_y[1:0] == 2'b11 || |pos_y[4:2]);
  else if (row[1] == 1'b1)
    bottomCollision <= ~ (|pos_y[4:1]);
  else if (row[2] == 1'b1)
    bottomCollision <= ~ (|pos_y);
  else
	  bottomCollision <= 1'b0;
end

// judge left
always @(posedge clk) begin
  if (pos_x == 4'b1111)
    leftCollision <= 1'b1;
  else if (col[0] == 1'b1)
    leftCollision <= ~ (pos_x[1:0] == 2'b11 || |pos_x[3:2]);
  else if (col[1] == 1'b1)
    leftCollision <= ~ (|pos_x[3:1]);
  else if (col[2] == 1'b1)
    leftCollision <= ~ (|pos_x);
  else
    leftCollision <= 1'b0;
end

// judge right
always @(posedge clk) begin
  if (pos_x == 4'b1101)
    rightCollision <= 1'b1;
  else if (col[3] == 1'b1) 
    rightCollision <= (pos_x[3] == 1'b1) && (|pos_x[2:1]);
  else if (col[2] == 1'b1)
    rightCollision <= pos_x[3:2] == 2'b11 || pos_x == 4'b1011;
  else if (col[1] == 1'b1)
    rightCollision <= pos_x[3:2] == 2'b11;
  else
    rightCollision <= 1'b0;
end

endmodule