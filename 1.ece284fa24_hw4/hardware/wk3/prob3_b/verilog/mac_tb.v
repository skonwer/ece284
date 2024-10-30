// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 


module mac_tb;

parameter bw = 4;
parameter psum_bw = 16;

reg clk = 0;

reg  [bw-1:0] a0,a1,a2,a3;
reg  [bw-1:0] b0,b1,b2,b3;
reg  [3:0][bw-1:0] a,b;
reg  [psum_bw-1:0] c;
wire [psum_bw-1:0] out;
reg  [psum_bw-1:0] expected_out = 0;

integer w_file ; // file handler
integer w_scan_file ; // file handler

integer x_file ; // file handler
integer x_scan_file ; // file handler

integer x_dec0,x_dec1,x_dec2,x_dec3;
integer w_dec0,w_dec1,w_dec2,w_dec3;
integer i; 
integer u; 

function [3:0] w_bin ;
  input integer  weight ;
  begin

    if (weight>-1)
     w_bin[3] = 0;
    else begin
     w_bin[3] = 1;
     weight = weight + 8;
    end

    if (weight>3) begin
     w_bin[2] = 1;
     weight = weight - 4;
    end
    else 
     w_bin[2] = 0;

    if (weight>1) begin
     w_bin[1] = 1;
     weight = weight - 2;
    end
    else 
     w_bin[1] = 0;

    if (weight>0) 
     w_bin[0] = 1;
    else 
     w_bin[0] = 0;

  end
endfunction



function [3:0] x_bin ;
    input integer act;
    begin
    if (act > 7) begin
        x_bin[3] = 1'b1;
        act = act - 8;
    end else
        x_bin[3] = 1'b0;

    if (act > 3) begin
        x_bin[2] = 1'b1;
        act = act - 4;
    end else
        x_bin[2] = 1'b0;

    if (act > 1) begin
        x_bin[1] = 1'b1;
        act = act - 2;
    end else
        x_bin[1] = 1'b0;

    if (act > 0) begin
        x_bin[0] = 1'b1;
    end else
        x_bin[0] = 1'b0;
end
endfunction


// Below function is for verification
function [psum_bw-1:0] mac_predicted;
    input [3:0][bw-1:0] a;
    input signed [3:0][bw-1:0] b;
    input signed [psum_bw-1:0] c;

    begin
        mac_predicted = $signed({1'b0,a[0]})*b[0]+ $signed({1'b0,a[1]})*b[1]+ $signed({1'b0,a[2]})*b[2]+ $signed({1'b0,a[3]})*b[3] +c;

end
endfunction

always @(*) begin
    a = {a3,a2,a1,a0};
    b = {b3,b2,b1,b0};
    //c = out;
end


mac_wrapper #(.bw(bw), .psum_bw(psum_bw)) mac_wrapper_instance (
	.clk(clk), 
        .a(a), 
        .b(b),
        .c(c),
	.out(out)
);
 

initial begin 

  w_file = $fopen("b_data.txt", "r");  //weight data
  x_file = $fopen("a_data.txt", "r");  //activation

  $dumpfile("mac_tb.vcd");
  $dumpvars(0,mac_tb);
 
  #1 clk = 1'b0;  
  #1 clk = 1'b1;  
  #1 clk = 1'b0;

  $display("-------------------- Computation start --------------------");
  //c = 0; 
    
  for (i=0; i<5; i=i+1) begin  // Data lenght is 10 in the data files

     #1 clk = 1'b1;
     #1 clk = 1'b0;

     w_scan_file = $fscanf(w_file, "%d %d %d %d\n", w_dec0, w_dec1, w_dec2, w_dec3);
     x_scan_file = $fscanf(x_file, "%d %d %d %d\n", x_dec0, x_dec1, x_dec2, x_dec3);

     a0 = x_bin(x_dec0); // unsigned number
     a1 = x_bin(x_dec1); // unsigned number
     a2 = x_bin(x_dec2); // unsigned number
     a3 = x_bin(x_dec3); // unsigned number

     b0 = w_bin(w_dec0); // signed number
     b1 = w_bin(w_dec1); // signed number
     b2 = w_bin(w_dec2); // signed number
     b3 = w_bin(w_dec3); // signed number

     c = expected_out;
     expected_out = mac_predicted({a3,a2,a1,a0}, {b3,b2,b1,b0}, c);

  end



  #1 clk = 1'b1;
  #1 clk = 1'b0;

  $display("-------------------- Computation completed --------------------");

  #10 $finish;


end

endmodule




