`timescale 1ns / 1ps

module Rotate(
         input wire [0:15] float, // float blocks' status
         input wire direction, // 0 for clockwise
         output wire [0:15] new_float // after rotation
       );

genvar i, j;
generate
  for (i = 0; i < 4; i = i + 1)
    begin : generate_new_float_i
      for (j = 0; j < 4; j = j + 1)
        begin : generate_new_float_j
          assign new_float[i * 4 + j] = (!direction) ? float[j * 4 + 3 - i] : float[(3 - j) * 4 + i];
        end
    end
endgenerate

endmodule
