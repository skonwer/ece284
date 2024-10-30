// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac (out, a, b, c);

parameter bw = 4;
parameter psum_bw = 16;

output signed [psum_bw-1:0] out;
input  [3:0][bw-1:0] a;
input  signed [3:0][bw-1:0] b;
input  signed [psum_bw-1:0] c;

wire signed [2*bw-1:0] p0,p1,p2,p3;
wire signed [2*bw:0] s0,s1;

assign p0 = $signed({1'b0,a[0]})*b[0];
assign p1 = $signed({1'b0,a[1]})*b[1];
assign p2 = $signed({1'b0,a[2]})*b[2];
assign p3 = $signed({1'b0,a[3]})*b[3];

assign s0 = p0 + p1;
assign s1 = p2 + p3;

assign out = s0 + s1 + c;

endmodule
