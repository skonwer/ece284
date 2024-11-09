// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission


module mac_array_tb;

// Parameters
parameter bw = 4;
parameter psum_bw = 16;

// Testbench Signals
reg clk;
reg reset;
reg [bw-1:0] in_w;
reg [psum_bw-1:0] in_n;
reg [1:0] inst_w;
wire [psum_bw-1:0] out_s;
wire [bw-1:0] out_e;
wire [1:0] inst_e;

// Instantiate the DUT (Device Under Test)
mac_array #(
    .bw(bw),
    .psum_bw(psum_bw)
) dut (
    .clk(clk),
    .out_s(out_s),
    .in_w(in_w),
    .out_e(out_e),
    .in_n(in_n),
    .inst_w(inst_w),
    .inst_e(inst_e),
    .reset(reset)
);

// Clock generation
always #5 clk = ~clk;

// Stimulus
initial begin
    $dumpfile("mac_tb.vcd");
    $dumpvars(0,mac_array_tb);
    // Initialize inputs
    clk = 0;
    reset = 1;
    in_w = 4'hf;
    in_n = 0;
    inst_w = 0;

    // Apply reset
    #10;
    reset = 0;
    #10;
    reset = 1;
    #10 
    inst_w = 2'b01;
    #10
    in_w = 4'h1;
    #10
    in_w = 4'hc;
    #10
    in_w = 4'hd;
    #10
    in_w = 4'h9;
    #10
    in_w = 4'hf;
    #10
    in_w = 4'h1;
    #10
    reset = 1'b1;
    #20 $finish;
end

    // Test case 1: Load kernel (set inst

    endmodule



module mac_array (clk, out_s, in_w, out_e, in_n, inst_w, inst_e, reset);

parameter bw = 4;
parameter psum_bw = 16;

output [psum_bw-1:0] out_s;
input  [bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
output [bw-1:0] out_e; 
input  [1:0] inst_w;
output [1:0] inst_e;
input  [psum_bw-1:0] in_n;
input  clk;
input  reset;

wire [bw-1:0] in_w2;
wire [1:0] inst_w2;

mac_tile mac_t0 (
    .clk(clk),
    .reset(reset),
    .in_n(16'b0),
    .in_w(in_w),
    .out_s(),
    .out_e(in_w2),
    .inst_w(inst_w),
    .inst_e(inst_w2)
);

mac_tile mac_t1 (
    .clk(clk),
    .reset(reset),
    .in_n(16'b0),
    .in_w(in_w2),
    .out_s(),
    .out_e(out_e),
    .inst_w(inst_w2),
    .inst_e(inst_e)
);



endmodule

module mac_tile (clk, out_s, in_w, out_e, in_n, inst_w, inst_e, reset);

parameter bw = 4;
parameter psum_bw = 16;

output [psum_bw-1:0] out_s;
input  [bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
output [bw-1:0] out_e; 
input  [1:0] inst_w;
output [1:0] inst_e;
input  [psum_bw-1:0] in_n;
input  clk;
input  reset;

// Wire & Reg declaration   
wire [psum_bw-1:0] mac_out;
wire               act_reg_enable;
wire               w_reg_enable;
wire               psum_reg_enable;
wire               load_status;
wire               inst_reg0_enable,inst_reg1_enable,inst_q0_wire,inst_q1_wire;
reg                load_ready;
reg [bw -1:0]      a_q,b_q;
reg [psum_bw-1:0]  c_q;
reg [2:0]          inst_q;


// Assign Statements
assign out_e           = a_q;
assign out_s           = mac_out;
assign load_status     = inst_w[0] & load_ready;
assign act_reg_enable  = |inst_w;
assign w_reg_enable    = inst_w[0] & load_ready;
assign psum_reg_enable  = inst_w[1];
assign inst_reg0_enable = ~load_ready;
assign inst_reg1_enable = inst_w[1];
assign inst_q0_wire   = inst_q[0];
assign inst_q1_wire   = inst_q[1];
    
// Load Ready Register
    always @ (posedge clk) begin
        if (reset)
            load_ready <= 1'b1;
        else if (load_status)
            load_ready <= 1'b0;
    end

// Activation Register
    always @ (posedge clk) begin
        if (reset)
            a_q <= 'b0;
        else if (act_reg_enable)
            a_q <= in_w;
    end

// Weight Register
    always @ (posedge clk) begin
        if (reset)
            b_q <= 'b0;
        else if (w_reg_enable)
            b_q <= in_w;
    end

// Psum Register
    always @ (posedge clk) begin
        if (reset)
            c_q <= 'b0;
        else if (psum_reg_enable)
            c_q <= in_n;
    end
            
// Instruction Register   
    always @ (posedge clk) begin
        if (reset)
            inst_q <= 2'b0;
        else if (inst_reg0_enable)
            inst_q <= {inst_q1_wire,inst_w[0]};
        else if (inst_reg1_enable)
            inst_q <= {inst_w[1],inst_q0_wire};
    end

            
mac #(.bw(bw), .psum_bw(psum_bw)) mac_instance (
        .a(a_q), 
        .b(b_q),
        .c(c_q),
	.out(mac_out)
); 


endmodule


// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac (out, a, b, c);

parameter bw = 4;
parameter psum_bw = 16;

output signed [psum_bw-1:0] out;
input signed  [bw-1:0] a;  // activation
input signed  [bw-1:0] b;  // weight
input signed  [psum_bw-1:0] c;


wire signed [2*bw:0] product;
wire signed [psum_bw-1:0] psum;
wire signed [bw:0]   a_pad;

assign a_pad = {1'b0, a}; // force to be unsigned number
assign product = a_pad * b;

assign psum = product + c;
assign out = psum;

endmodule
