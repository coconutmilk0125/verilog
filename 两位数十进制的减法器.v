//两位数十进制的减法器的IP核
（1）源代码：
`timescale 1ns / 1ps
module sub_bcd(
    input [3:0] a0,
    input [3:0] a1,
    input [3:0] b0,
    input [3:0] b1,
    input c,
    output [3:0] d0,
    output [3:0] d1,
    output ci
    );
    reg[3:0] d0;
    reg[3:0] d1;
    reg ci;
    reg temp_c;
    always @(*)
    begin
        if(a0>=b0+c) begin
            temp_c=1'b0;
            d0=a0-b0-c;
            if(a1>=b1+temp_c) begin
                 ci=1'b0;
                 d1=a1-b1-temp_c;
                 end
             else if(a1<b1+temp_c) begin
                         ci=1'b1;
                         d1=4'b1010-b1+a1-temp_c;
                         end
            end
            else if(a0<b0+c) begin
                    temp_c=1'b1;
                    d0=4'b1010-b0+a0-c;
                    if(a1>=b1+temp_c) begin
                       ci=0;
                       d1=a1-b1-temp_c;
                       end
                    else if(a1<b1+temp_c) begin
                                ci=1'b1;
                                d1=4'b1010-b1+a1-temp_c;
                                end
                    end
      end
endmodule

//数码管显示模块的IP核
module display(clk,b_0,b_1,b_2,b_3,sel,seg);

input clk;//50M
input [3:0] b_0,b_1,b_2,b_3;
output [2:0]sel;//位选（控制哪个数码管亮）
output reg [7:0]seg;//段选（控制数码管显示什么数据）



//分频器的代码，这里为了完整，不做多个文件来写模块了
reg [2:0]sel_r=3'b000;
reg [3:0]data_temp;//待显示数据缓存

reg clock_25m=0;
    always@(posedge clk)
    begin
            clock_25m <= ~clock_25m;
    end

    //计数器，约为10ms扫描一次
    reg [17:0] cnt=0;
    always @(posedge clock_25m)
    begin
		if(cnt == 18'b111111111111111111)  
            cnt <= 18'b0;
        else
            cnt <= cnt+1;
    end
    

//位选移位寄存器
always@(posedge clock_25m)
if(sel_r==3'b111)
sel_r<=3'b000;
else 
sel_r<=sel_r+1'b1;

//设计一个多路器
always@(*)
case(sel_r)
3'b000:data_temp=b_3;
3'b001:data_temp=b_2;
3'b010:data_temp=b_1;
3'b011:data_temp=b_0;
3'b100:data_temp=4'ha;
3'b101:data_temp=4'ha;
3'b110:data_temp=4'ha;
3'b111:data_temp=4'ha;
//default
//data_temp<=4'ha;
endcase

//译码器
always@(*)
case (data_temp)
4'h0:seg=8'b00111111;//这里按数码管码表来
4'h1:seg=8'b00000110;
4'h2:seg=8'b01011011;
4'h3:seg=8'b01001111;
4'h4:seg=8'b01100110;
4'h5:seg=8'b01101101;
4'h6:seg=8'b01111101;
4'h7:seg=8'b00000111;
4'h8:seg=8'b01111111;
4'h9:seg=8'b01101111;
4'ha:seg=8'b00000000;
endcase

assign sel=sel_r;

endmodule

（1）	调用自编写IP核生成的源代码：
`timescale 1 ps / 1 ps

module bcd_sub_wrapper
   (
    ci,
    clk,
    seg,
    sel);
  output ci;
  input clk;
  output [7:0]seg;
  output [2:0]sel;

  reg [3:0]a0=4'd1;
  reg [3:0]a1=4'd5;
  reg [3:0]a2=4'd7;
  reg [3:0]a3=4'd4;
  reg [3:0]b0=4'd5;
  reg [3:0]b1=4'd2;
  reg [3:0]b2=4'd9;
  reg [3:0]b3=4'd3;
  reg c=0;
  wire ci;
  wire clk;
  wire [7:0]seg;
  wire [2:0]sel;

  bcd_sub bcd_sub_i
       (.a0(a0),
        .a1(a1),
        .a2(a2),
        .a3(a3),
        .b0(b0),
        .b1(b1),
        .b2(b2),
        .b3(b3),
        .c(c),
        .ci(ci),
        .clk(clk),
        .seg(seg),
        .sel(sel));
Endmodule

