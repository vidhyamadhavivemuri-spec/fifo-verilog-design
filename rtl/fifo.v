
module fifo (
    input wire clk,
    input wire rst,

    input wire wr_en,
    input wire rd_en,

    input wire [7:0] din,
    output reg [7:0] dout,

    output wire full,
    output wire empty
);

    // FIFO memory
    reg [7:0] mem [0:15];

    // Read and write pointers
    reg [3:0] wr_ptr;
    reg [3:0] rd_ptr;

    // FIFO occupancy counter
    reg [4:0] count;

    // Internal control signals
    wire do_read;
    wire do_write;

    // Status flags
    assign full  = (count == 16);
    assign empty = (count == 0);

    // Read and write conditions
    assign do_read  = rd_en && !empty;
    assign do_write = wr_en && (!full || do_read);

    // FIFO sequential logic
    always @(posedge clk) begin

        if (rst) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count  <= 0;
            dout   <= 0;
        end

        else begin

            // Write operation
            if (do_write) begin
                mem[wr_ptr] <= din;
                wr_ptr <= wr_ptr + 1'b1;
            end

            // Read operation
            if (do_read) begin
                dout <= mem[rd_ptr];
                rd_ptr <= rd_ptr + 1'b1;
            end

            // Update FIFO count
            case ({do_write, do_read})

                2'b10: count <= count + 1'b1;

                2'b01: count <= count - 1'b1;

                default: count <= count;

            endcase

        end
    end

endmodule
