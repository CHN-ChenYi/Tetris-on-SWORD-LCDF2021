`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    01:23:28 01/04/2021
// Design Name:
// Module Name:    VGAIO
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
module VGAIO(input wire clk,
             input wire clrn,
             input wire Load,
             input wire[8:0] HAddr,
             input wire[9:0] LAddr,
             input wire[11:0] Data,
             output wire[3:0] r,
             output wire[3:0] g,
             output wire[3:0] b,
             output wire hs,
             output wire vs);
    
    reg[31:0] clk_div;
    always@(posedge clk) begin
        clk_div <= clk_div + 32'b1;
    end
    
    wire[8:0] row_addr;
    wire[9:0] col_addr;
    
    reg[11:0] Dotout;
    wire[19:0] DotAddr;
    wire[19:0] LoadAddr;
    
    assign DotAddr  = row_addr*640+col_addr;
    assign LoadAddr = HAddr*640+LAddr;
    
    reg[11:0] ram[0:307199];
    
    //reg[19:0] i;
    //initial begin
    //   clk_div <= 32'b0;
    //    for(i = 0; i<20'd307200; i = i+1) begin
    //        ram[i] <= 0;
    //    end
    //end
    
    always@(posedge Load) begin
        ram[LoadAddr] <= Data;
    end
    
    always@(negedge clk) begin
        Dotout <= ram[DotAddr];
    end
    
    vgac v0 (
    .vga_clk(clk_div[1]),
    .clrn(clrn),
    .d_in(Dotout),
    .row_addr(row_addr),
    .col_addr(col_addr),
    //.rdn(rdn),
    .r(r),
    .g(g),
    .b(b),
    .hs(hs),
    .vs(vs)
    );
    
endmodule
