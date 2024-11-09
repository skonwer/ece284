

module seq1011(
 input clk,
 input reset,
 input seq,
 output seq_detected 
  ); 

localparam RESET = 3'b000;
localparam S1    = 3'b001;
localparam S10   = 3'b010;
localparam S101  = 3'b011;
localparam S1011 = 3'b100;

reg [3:0] pstate;
wire [3:0] nstate;
//reg detected;

always @(posedge clk or posedge reset) begin
    if (reset)
        pstate <= RESET;
    else
        pstate <= nstate;
end


always @(*) begin
    seq_detected = 1'b0;
    case(pstate)
        RESET: begin
               if (seq)
                nstate = S1;
               else
                nstate = pstate;
            end
                
            S1:    begin
                if (!seq)
                nstate = S10;
               else 
                nstate = pstate;
            end
            
            S10:     begin
               if (seq)
                nstate = S101;
               else
                nstate = RESET;
            end
            
            S101:   begin
                if (seq)
                nstate = S1011;
               else
                nstate = S10;
            end

        S1011: begin  
               seq_detected = 1'b1;
               if (seq)
                nstate = S1;
               else
                nstate = S10;
        end

        default: begin
            nstate = RESET;

    endcase
    end

    endmodule


