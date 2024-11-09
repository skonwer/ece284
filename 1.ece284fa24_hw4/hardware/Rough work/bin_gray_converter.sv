




module converter #(
    parameter BW = 4
) (
    input clk,
    input reset,
    input enable,
    input mode, // 0 bin to gray| 1 gray to bin
    input [0+:BW] ip_value,
    output [0+:BW ]op_value
);

localparam B2G = 1'b0;
localparam G2B = 1'b1;

logic [0+:BW] op_value_q, op;

assign op_value = op_value_q;

always @(*) begin
    case (mode) begin
        B2G: op = ip_value ^ (ip_value >> 1);
        G2B: begin
            for(int i=0; i < BW; i++)
                op[i] = ^(ip_value>>i);
            end
            default: op = op_value_q;
    endcase
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        op_value <= '0;
    end
    else if (enable) begin
        op_value <= op;
    end
    else
        op_value <= op_value;
end

endmodule
