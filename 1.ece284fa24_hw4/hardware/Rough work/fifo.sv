module sync_fifo #(
    parameter DATA_WIDTH = 8,      // Width of each data word
    parameter FIFO_DEPTH = 16      // Depth of FIFO (number of data words)
) (
    input wire clk,                // Clock input
    input wire reset,              // Reset input (active high)
    input wire wr_en,              // Write enable
    input wire rd_en,              // Read enable
    input wire [DATA_WIDTH-1:0] data_in, // Data input
    output reg [DATA_WIDTH-1:0] data_out, // Data output
    output wire full,              // FIFO full flag
    output wire empty              // FIFO empty flag
);

    // Calculate address width based on FIFO depth
    localparam ADDR_WIDTH = $clog2(FIFO_DEPTH);

    reg [DATA_WIDTH-1:0] fifo_mem [0:FIFO_DEPTH-1]; // FIFO memory array
    reg [ADDR_WIDTH-1:0] wr_ptr;  // Write pointer
    reg [ADDR_WIDTH-1:0] rd_ptr;  // Read pointer
    reg [ADDR_WIDTH:0] fifo_count; // Tracks the number of items in the FIFO

    // Full and empty flag logic
    assign full = (fifo_count == FIFO_DEPTH);
    assign empty = (fifo_count == 0);

    // Write operation
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            wr_ptr <= 0;
        end else if (wr_en && !full) begin
            fifo_mem[wr_ptr] <= data_in;
            wr_ptr <= wr_ptr + 1;
        end
    end

    // Read operation
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            rd_ptr <= 0;
            data_out <= 0;
        end else if (rd_en && !empty) begin
            data_out <= fifo_mem[rd_ptr];
            rd_ptr <= rd_ptr + 1;
        end
    end

    // FIFO count update
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            fifo_count <= 0;
        end else begin
            case ({wr_en && !full, rd_en && !empty})
                2'b10: fifo_count <= fifo_count + 1;  // Write only
                2'b01: fifo_count <= fifo_count - 1;  // Read only
                default: fifo_count <= fifo_count;    // No change or simultaneous read/write
            endcase
        end
    end

endmodule


module dual_port_fifo #(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 256  // Larger depth, more scalable
) (
    input wire wr_clk,           // Write clock
    input wire rd_clk,           // Read clock
    input wire reset,            // Synchronous reset
    input wire wr_en,            // Write enable
    input wire rd_en,            // Read enable
    input wire [DATA_WIDTH-1:0] data_in, // Data input
    output reg [DATA_WIDTH-1:0] data_out, // Data output
    output wire full,            // FIFO full flag
    output wire empty            // FIFO empty flag
);

    localparam ADDR_WIDTH = $clog2(FIFO_DEPTH);

    // Dual-port memory (using FPGA block RAM)
    reg [DATA_WIDTH-1:0] fifo_mem [0:FIFO_DEPTH-1];
    reg [ADDR_WIDTH:0] wr_ptr = 0; // Write pointer
    reg [ADDR_WIDTH:0] rd_ptr = 0; // Read pointer

    // Full and empty flags
    assign full = (wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0]) && (wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH]);
    assign empty = (wr_ptr == rd_ptr);

    // Write operation
    always @(posedge wr_clk) begin
        if (reset) begin
            wr_ptr <= 0;
        end else if (wr_en && !full) begin
            fifo_mem[wr_ptr[ADDR_WIDTH-1:0]] <= data_in;
            wr_ptr <= wr_ptr + 1;
        end
    end

    // Read operation
    always @(posedge rd_clk) begin
        if (reset) begin
            rd_ptr <= 0;
            data_out <= 0;
        end else if (rd_en && !empty) begin
            data_out <= fifo_mem[rd_ptr[ADDR_WIDTH-1:0]];
            rd_ptr <= rd_ptr + 1;
        end
    end

endmodule
