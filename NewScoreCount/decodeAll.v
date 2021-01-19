`timescale 1ns / 1ps

// decode all three numbers
module decodeAll(
    input [11:0] num,
    output [23:0] segnum
);

SegmentDecoder s1(.hex(num[3:0]),.SEGMENTS(segnum[7:0]));
SegmentDecoder s2(.hex(num[7:4]),.SEGMENTS(segnum[15:8]));
SegmentDecoder s3(.hex(num[11:8]),.SEGMENTS(segnum[23:16]));

endmodule