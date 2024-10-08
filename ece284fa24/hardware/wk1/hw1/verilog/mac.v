// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac (out, A, B, format, acc, clk, reset);

parameter bw = 8;
parameter psum_bw = 16;

input clk;
input acc;
input reset;
input format;

input signed [bw-1:0] A;
input signed [bw-1:0] B;

output signed [psum_bw-1:0] out;

reg signed [psum_bw-1:0] psum_q;
reg signed [bw-1:0] a_q;
reg signed [bw-1:0] b_q;

assign out = psum_q;

// Your code goes here

// Wire| Reg
reg [psum_bw-1:0]  psum_int;
wire [1:0]         case_input;

// Localparams
//
//=========================================
// format 0 (2's Complement mode)
// format 1 (Signed mode)
// acc    0 (no accumulation)
// acc    1 (mac operation)
// ---------------------------------------
localparam [1:0] f0a0 = 2'b00;
localparam [1:0] f0a1 = 2'b01;
localparam [1:0] f1a0 = 2'b10;
localparam [1:0] f1a1 = 2'b11;


// Logic
assign case_input = {format,acc};

always @(*) begin    
    case (case_input)
        f0a0: begin
            psum_int = psum_q;
        end

        f0a1: begin
            psum_int = psum_q + a_q*b_q;
        end

        f1a0: begin
            psum_int = psum_q;
        end

        f1a1: begin
            if (!(psum_q[psum_bw-1]^a_q[bw-1]^b_q[bw-1])) begin // checking if the signs of psum and a*b are the same
                psum_int[psum_bw-1]   = psum_q[psum_bw-1];
                psum_int[psum_bw-2:0] = psum_q[psum_bw-2:0] + a_q[bw-2:0]*b_q[bw-2:0];
            end 

            else if (psum_q[psum_bw-2:0] > a_q[bw-2:0]*b_q[bw-2:0]) begin // check for bigger magnitude
                psum_int[psum_bw-1]   = psum_q[psum_bw-1];
                psum_int[psum_bw-2:0] = psum_q[psum_bw-2:0] - a_q[bw-2:0]*b_q[bw-2:0];
            end 
                
            else if (psum_q[psum_bw-2:0] < a_q[bw-2:0]*b_q[bw-2:0]) begin // check for bigger magnitude
                psum_int[psum_bw-1]   = a_q[bw-1]^b_q[bw-1];
                psum_int[psum_bw-2:0] = a_q[bw-2:0]*b_q[bw-2:0] - psum_q[psum_bw-2:0];
            end 
        end

        default: begin
            psum_int = psum_q;
        end
    endcase
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        psum_q <= 0;
        a_q    <= 0;
        b_q    <= 0;
    end
    else begin
        psum_q <= psum_int;
        a_q    <= A;
        b_q    <= B;
    end
end

endmodule
