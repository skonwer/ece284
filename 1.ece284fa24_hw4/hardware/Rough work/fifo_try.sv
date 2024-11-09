module fifo #(

    parameter DEPTH = 8,
    parameter DW = 32

) (
    input clock,
    input reset,
    input wen,
    output full,
    input ren,
    output empty,
    input  [DW-1:0] data_in,
    output [DW-1:0] data_out
    
);

    localparam ADDR = $clog2(DEPTH);
    reg [DW-1:0] fifo_m [DEPTH-1:0];
    reg [ADDR:0] wptr,rptr;

// FLags
assign full = (wptr[ADDR-1:0]==rptr[ADDR-1:0])&&(wptr[ADDR]!=rptr[ADDR]);
assign empty = (wptr == rptr);

// Read
always @(posedge clock or posedge reset) begin
    if (reset)
        rptr <='b0;
    else if (ren & !empty) begin
        fifo_m[rptr[ADDR-1:0]] <= data_in;
        rptr[ADDR-1:0] <= (rptr[ADDR-1:0] +1)%DEPTH;

    end
// Write
always @(posedge clock or posedge reset) begin
    if (reset)
        wptr <='b0;
    else if (ren && !empty) begin
        data_out <= fifo_m[wptr[ADDR-1:0]];
        wptr[ADDR-1:0] <= (wptr[ADDR-1:0] +1)%DEPTH;

    end

//Flag 2
always @(posedge clock or posedge reset) begin
    if (reset)
        rptr[ADDR] <=1'b0;
        wptr[ADDR] <=1'b0;
    else if ((ren && !empty) && (rptr[ADDR-1:0]+1==DEPTH)) begin
        rptr[ADDR] <= ~rptr[ADDR];
    end
     else if ((wen && !full) && (wptr[ADDR-1:0]+1==DEPTH)) begin
        wptr[ADDR] <= ~wptr[ADDR];
    end

end


module fifo #(
    parameter DEPTH = 8,
    parameter DW = 32
) (
    input clock,
    input reset,
    input wen,
    output full,
    input ren,
    output empty,
    input [DW-1:0] data_in,
    output reg [DW-1:0] data_out
);

    localparam ADDR = $clog2(DEPTH);
    reg [DW-1:0] fifo_m [DEPTH-1:0];
    reg [ADDR:0] wptr, rptr;

    // Flags
    assign full = (wptr[ADDR-1:0] == rptr[ADDR-1:0]) && (wptr[ADDR] != rptr[ADDR]);
    assign empty = (wptr == rptr);

    // Write Operation
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            wptr <= 'b0;
        end else if (wen && !full) begin
            fifo_m[wptr[ADDR-1:0]] <= data_in;
            wptr[ADDR-1:0] <= wptr[ADDR-1:0] + 1;
            if (wptr[ADDR-1:0] + 1 == DEPTH)
                wptr[ADDR] <= ~wptr[ADDR];
        end
    end

    // Read Operation
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            rptr <= 'b0;
            data_out <= 'b0;
        end else if (ren && !empty) begin
            data_out <= fifo_m[rptr[ADDR-1:0]];
            rptr[ADDR-1:0] <= rptr[ADDR-1:0] + 1;
            if (rptr[ADDR-1:0] + 1 == DEPTH)
                rptr[ADDR] <= ~rptr[ADDR];
        end
    end
endmodule
