`timescale 1ns / 1ps

module decodeAll(
    input [11:0] num,
    output [23:0] segnum
);

SegmentDecoder s1(.hex(num[3:0]),.SEGMENTS(segnum[7:0]));
SegmentDecoder s2(.hex(num[7:4]),.SEGMENTS(segnum[15:8]));
SegmentDecoder s3(.hex(num[11:8]),.SEGMENTS(segnum[23:16]));
// SegmentDecoder s4(.hex(num[15:12]),.SEGMENTS(segnum[31:24]));
// SegmentDecoder s5(.hex(num[19:16]),.SEGMENTS(segnum[39:32]));
// SegmentDecoder s6(.hex(num[23:20]),.SEGMENTS(segnum[47:40]));
// SegmentDecoder s7(.hex(num[27:24]),.SEGMENTS(segnum[55:48]));
// SegmentDecoder s8(.hex(num[31:28]),.SEGMENTS(segnum[63:56]));

endmodule