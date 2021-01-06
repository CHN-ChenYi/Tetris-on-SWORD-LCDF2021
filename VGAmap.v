`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    11:40:55 01/04/2021
// Design Name:
// Module Name:    VGAmap
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module VGAmap(input wire clk,
              input wire clrn,
              input wire [0:1199] d,
              output wire[3:0] r,
              output wire[3:0] g,
              output wire[3:0] b,
              output wire hs,
              output wire vs);
    
    reg[11:0] Data;
    reg[8:0] HAddr;
    reg[9:0] LAddr;
    wire Load;
    
    assign Load = ~clk;
    
    always@(posedge clk)
    begin
        if (LAddr == 10'd639)
        begin
            LAddr <= 10'b0;
            if (HAddr == 9'd479)
            begin
                HAddr <= 0;
            end
            else
            begin
                HAddr <= HAddr+9'b1;
            end
        end
        else
        begin
            LAddr <= LAddr+10'b1;
        end
    end
    
    wire[4:0] HBlock;
    wire[5:0] LBlock;
    wire[11:0] BAddr;
    assign HBlock = HAddr[8:4];
    assign LBlock = LAddr[9:4];
    assign BAddr  = HBlock*40+LBlock;
    
    always@(posedge clk)
    begin
        if (d[BAddr] == 1'b1)
        begin
            Data <= 12'hFFF;
        end
        else
        begin
            Data <= 12'h000;
        end
    end
    
    VGAIO vio (
    .clk(clk),
    .clrn(clrn),
    .Load(Load),
    .HAddr(HAddr),
    .LAddr(LAddr),
    .Data(Data),
    .r(r),
    .g(g),
    .b(b),
    .hs(hs),
    .vs(vs)
    );
    
endmodule
