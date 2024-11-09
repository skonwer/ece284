
module gray_counter
#(
    parameter N = 4
)

(
    input clk,
    input rst,
    input enable,
    output gray_cntr

);

reg [N-1:0] bin;

always @ (posedge clk or posedge rst) begin: binary_counter
    if (rst)
        bin <= 0;
    else if (enable)
        bin <= bin + 1;
    else
        bin <= bin;
end

//binary to gray 

assign gray_cntr = {bin[N-1], bin[N-2:0] ^ bin[N-1:1]};

endmodule
