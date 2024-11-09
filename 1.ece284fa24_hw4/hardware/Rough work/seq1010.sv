module seq1010(
    input clk,
    input reset,
    input enable,
    input value,
    output seq_detect

);

localparam RESET = 3'b000;
localparam S1    = 3'b001;
localparam S10   = 3'b010;
localparam S101  = 3'b100;
localparam S1010 = 3'b101;

logic [2:0] pstate, nstate;

always @(*) begin
    seq_detect = 0;
    case(pstate) begin
        RESET: begin
            if (value)
                nstate = S1;
            else
                nstate = pstate;
        end
        S1: begin
            if (value)
                nstate = pstate;
            else
                nstate = S10;
        end
        S10: begin
            if (value)
                nstate = S101;
            else 
                nstate = RESET;
        end
        S101: begin
            if (value)
                nstate = S1;
            else
                nstate = S1010;
        end
        S1010: begin
            seq_detect = 1'b1;
            if (value)
                nstate = S101;
            else
                nstate = RESET;
        end
        default: begin
            nstate = pstate;
        end


    endcase
end

always @ (posedge clk posedge reset) begin
    if (reset)
        pstate <= RESET;
    else if (enable)
        pstate <= nstate;
    else
        pstate <= pstate;
end

endmodule
