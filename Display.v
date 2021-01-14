`timescale 1ns / 1ps

module vgac (vga_clk,clrn,d_in,row_addr,col_addr,rdn,r,g,b,hs,vs); // vgac
   input     [11:0] d_in;     // bbbb_gggg_rrrr, pixel
   input            vga_clk;  // 25MHz
   input            clrn;
   output reg [8:0] row_addr; // pixel ram row address, 480 (512) lines
   output reg [9:0] col_addr; // pixel ram col address, 640 (1024) pixels
   output reg [3:0] r,g,b; // red, green, blue colors
   output reg       rdn;      // read pixel RAM (active_low)
   output reg       hs,vs;    // horizontal and vertical synchronization
   // h_count: VGA horizontal counter (0-799)
   reg [9:0] h_count; // VGA horizontal counter (0-799): pixels

   always @ (posedge vga_clk) begin
       if (!clrn) begin
           h_count <= 10'h0;
       end else if (h_count == 10'd799) begin
           h_count <= 10'h0;
       end else begin 
           h_count <= h_count + 10'h1;
       end
   end
   // v_count: VGA vertical counter (0-524)
   reg [9:0] v_count; // VGA vertical   counter (0-524): lines
   always @ (posedge vga_clk or negedge clrn) begin
       if (!clrn) begin
           v_count <= 10'h0;
       end else if (h_count == 10'd799) begin
           if (v_count == 10'd524) begin
               v_count <= 10'h0;
           end else begin
               v_count <= v_count + 10'h1;
           end
       end
   end

    /* initial begin
        h_count=0;
        v_count=0;
        row_addr=0;
        col_addr=0;
        r=0;
        g=0;
        b=0;
        hs=0;
        vs=0;
    end */

    // signals, will be latched for outputs
    wire  [9:0] row    =  v_count - 10'd35;     // pixel ram row addr 
    wire  [9:0] col    =  h_count - 10'd143;    // pixel ram col addr 
    wire        h_sync = (h_count > 10'd95);    //  96 -> 799
    wire        v_sync = (v_count > 10'd1);     //   2 -> 524
    wire        read   = (h_count > 10'd142) && // 143 -> 782
                         (h_count < 10'd783) && //        640 pixels
                         (v_count > 10'd34)  && //  35 -> 514
                         (v_count < 10'd515);   //        480 lines
    // vga signals
    always @ (posedge vga_clk) begin
        row_addr <=  row[8:0]; // pixel ram row address
        col_addr <=  col;      // pixel ram col address
        rdn      <= ~read;     // read pixel (active low)
        hs       <=  h_sync;   // horizontal synchronization
        vs       <=  v_sync;   // vertical   synchronization
        r        <=  rdn ? 4'h0 : d_in[3:0]; // 4-bit red
        g        <=  rdn ? 4'h0 : d_in[7:4]; // 4-bit green
        b        <=  rdn ? 4'h0 : d_in[11:8]; // 4-bit blue
    end
endmodule

module vgaio(input wire clk,
             input wire clk_25MHz,
             input wire clrn,
             input wire Load,
             input wire[8:0] HAddr,
             input wire[9:0] LAddr,
             input wire[1:0] Data,
             output wire[3:0] r,
             output wire[3:0] g,
             output wire[3:0] b,
             output wire hs,
             output wire vs);
    
    wire[8:0] row_addr;
    wire[9:0] col_addr;
    
    reg[11:0] Dotout;
    wire[18:0] DotAddr;
    wire[18:0] LoadAddr;
    
    assign DotAddr  = row_addr*640+col_addr;
    assign LoadAddr = HAddr*640+LAddr;
    
    //reg[1:0] ram[0:307199]; //4 color vga ram

    /* initial begin
        Dotout=0;
    end */
    
    /* always@(posedge Load) begin
        ram[LoadAddr] <= Data;
    end */
    
    wire[1:0] ram_read;

    vram ram (
    .clka(clk), // input clka
    .wea(Load), // input [0 : 0] wea
    .addra(LoadAddr), // input [18 : 0] addra
    .dina(Data), // input [1 : 0] dina
    .clkb(clk), // input clkb
    .addrb(DotAddr), // input [18 : 0] addrb
    .doutb(ram_read) // output [1 : 0] doutb
    );
    
    always@(posedge clk_25MHz) begin
        case(ram_read)
            2'b00:Dotout<=12'h000; //black
            2'b01:Dotout<=12'hF00; //blue
            2'b10:Dotout<=12'h0F0; //green
            2'b11:Dotout<=12'h00F; //red
            //3'b100:Dotout<=12'hF5B; //pink
            //3'b101:Dotout<=12'h5FF; //yellow
            //3'b110:Dotout<=12'h777; //gray
            //3'b111:Dotout<=12'hFFF; //white
        endcase
    end
    
   /*  wire[3:0] aa, bb, cc;
    reg[3:0] rt, gt, bt;
    always@(posedge clk) begin
        rt<=aa;
        gt<=bb;
        bt<=cc;
    end

    assign r=rt;
    assign g=gt;
    assign b=bt; */

    vgac v0 (.vga_clk(clk_25MHz),.clrn(clrn),.d_in(Dotout),.row_addr(row_addr),.col_addr(col_addr),.r(r),.g(g),.b(b),.hs(hs),.vs(vs));

endmodule

module blockmode(input wire clk,
                 input wire [0:2399] d,
                 input wire[8:0] HAddr,
                 input wire[9:0] LAddr,
                 output reg[1:0] Data);

    /* initial begin
        Data=0;
    end  */

    wire[4:0] HBlock;
    wire[5:0] LBlock;
    wire[12:0] BAddr;
    assign HBlock      = HAddr[8:4];
    assign LBlock      = LAddr[9:4];
    assign BAddr[12:1] = HBlock*40+LBlock;
    assign BAddr[0]  = 1'b0;
    
    always@(posedge clk)
    begin
        if ({d[BAddr],d[BAddr+1]} == 2'b00)
        begin
            Data <= 2'b00;
        end
        else
        begin
            if (HAddr[3:0] == 4'h0||HAddr[3:0] == 4'hF||LAddr[3:0] == 4'h0||LAddr[3:0] == 4'hF)
            begin
                Data <= 2'b00;
            end
            else
            begin
                case({d[BAddr],d[BAddr+1]})
                    2'd1:Data   <= 2'b11;
                    2'd2:Data   <= 2'b10;
                    2'd3:Data   <= 2'b01;
                endcase
            end
        end
    end
    
endmodule

module textmode(input wire clk,
                input wire clk_25MHz,
                //input wire ena,
                input wire[8:0] HAddr,
                input wire[9:0] LAddr,
                output reg[1:0] Data);
    
    wire[5:0] HBlock;
    wire[6:0] LBlock;
    wire[12:0] BAddr;
    assign HBlock      = HAddr[8:4];
    assign LBlock      = LAddr[9:3];
    assign BAddr[12:0] = HBlock*80+LBlock;
    
    reg [11:0] readAddr;
    wire [7:0] read;
    textrom trom (
    .clka(clk), // input clka
    .ena(1'b1), // input ena
    .addra(readAddr), // input [11 : 0] addra
    .douta(read) // output [7 : 0] douta
    );

    /* initial begin
        readAddr=0;
    end */

    always@(posedge clk_25MHz)
    begin
        case(BAddr)
            13'd1234:readAddr <= 12'd624+HAddr[3:0]; //G
            13'd1235:readAddr <= 12'd528+HAddr[3:0]; //A
            13'd1236:readAddr <= 12'd720+HAddr[3:0]; //M 
            13'd1237:readAddr <= 12'd592+HAddr[3:0]; //E
            13'd1238:readAddr <= 12'd000+HAddr[3:0]; //" "
            13'd1239:readAddr <= 12'd752+HAddr[3:0]; //O
            13'd1240:readAddr <= 12'd864+HAddr[3:0]; //V
            13'd1241:readAddr <= 12'd592+HAddr[3:0]; //E
            13'd1242:readAddr <= 12'd800+HAddr[3:0]; //R
            13'd1243:readAddr <= 12'd016+HAddr[3:0]; //!
            default:readAddr <= 12'h000;
        endcase
    end
    
    //assign Data=(read&(8'b10000000>>LAddr[2:0]))?2'b11:2'b01;
    always@(negedge clk_25MHz)
    begin
        case(LAddr[2:0])
            3'd0:Data<=read[7]?2'b11:2'b01;
            3'd1:Data<=read[6]?2'b11:2'b01;
            3'd2:Data<=read[5]?2'b11:2'b01;
            3'd3:Data<=read[4]?2'b11:2'b01;
            3'd4:Data<=read[3]?2'b11:2'b01;
            3'd5:Data<=read[2]?2'b11:2'b01;
            3'd6:Data<=read[1]?2'b11:2'b01;
            3'd7:Data<=read[0]?2'b11:2'b01;
        endcase
    end
    
endmodule

module Display(input wire clk, //100MHz clock
                input wire mode, //0-game mode 1-text mode
                input wire [0:199] d, //image block
                output wire[3:0] r,
                output wire[3:0] g,
                output wire[3:0] b,
                output wire hs,
                output wire vs);

    
    reg[1:0] clk_div;
    always@(posedge clk) begin
        clk_div <= clk_div + 2'b1;
    end

    /* initial begin
        clk_div=0;
    end */

    wire Load;
    //assign Load = (~clk_div[1])&(~clk_div[0]);
    assign Load = ~clk_div[1];
    
    wire[1:0] Data;
    reg[8:0] HAddr;
    reg[9:0] LAddr;
    
    /* initial begin
        HAddr=0;
        LAddr=0;
    end */

    wire[1:0] D1,D2;
    
    always@(posedge clk_div[1])
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

    wire[0:2399] dd;
    generate
        genvar ii, jj;
        for(jj=0; jj<30; jj=jj+1) begin
            for(ii=0; ii<40; ii=ii+1) begin
                if((ii==15&&jj>=4&&jj<=25)||(ii==26&&jj>=4&&jj<=25)||(jj==4&&ii>=15&&ii<=26)||(jj==25&&ii>=15&&ii<=26))
                begin:map0
                    assign dd[(jj*40+ii)*2:(jj*40+ii)*2+1]=2'b11;
                end
                else
                begin
                    if(ii>15&&ii<26&&jj>4&&jj<25)
                    begin:map1
                        assign dd[(jj*40+ii)*2:(jj*40+ii)*2+1]=(d[(24-jj)*10+(ii-16)])?2'b01:2'b00;
                    end
                    else
                    begin:map2
                        assign dd[(jj*40+ii)*2:(jj*40+ii)*2+1]=2'b00;
                    end
                end
            end
        end
    endgenerate

    blockmode bm (.clk(clk),.d(dd),.Data(D1),.HAddr(HAddr),.LAddr(LAddr));
    textmode tm (.clk(clk),.clk_25MHz(clk_div[1]),.Data(D2),.HAddr(HAddr),.LAddr(LAddr));
    
    assign Data=mode?D2:D1;
    
    vgaio vio (.clk(clk),.clk_25MHz(clk_div[1]),.clrn(1'b1),.Load(Load),.HAddr(HAddr),.LAddr(LAddr),.Data(Data),.r(r),.g(g),.b(b),.hs(hs),.vs(vs));
    
endmodule

module Combine( //anchor float[15]
         input wire clk,
         input wire [3:0] pos_x, //col 0-12
         input wire [4:0] pos_y, //row 0-22
         input wire [0:15] float,
         input wire [0:199] static,
         output reg [0:199] comb
       );

    reg[4:0] row;
    reg[3:0] col;
    wire[7:0] Addr;
    assign Addr=10*row+col;

    always@(posedge clk) begin
        if(col==4'd9) begin
            col<=0;
            if(row==5'd19) begin
                row<=0;
            end
            else
            begin
                row<=row+1;
            end
        end
        else
        begin
            col<=col+1;
        end
    end

    wire[4:0] row_dis;
    wire[3:0] col_dis;
    wire block;
    assign row_dis=pos_y-row;
    assign col_dis=pos_x-col;
    assign block=(|row_dis[4:2])|(|col_dis[3:2])?(static[Addr]):(static[Addr]|float[(3-row_dis)*4+(3-col_dis)]);

    /* initial begin
        comb<=0;
        row<=0;
        col<=0;
    end */

    always@(posedge clk) begin
        comb[Addr]<=block;
    end

endmodule
