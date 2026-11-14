
`timescale 1ns/1ps

module fifo_tb;

    reg clk;
    reg rst;
    reg wr_en;
    reg rd_en;
    reg [7:0] din;

    wire [7:0] dout;
    wire full;
    wire empty;

    // Instantiate FIFO design
    fifo uut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .din(din),
        .dout(dout),
        .full(full),
        .empty(empty)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Write task
    task write_data;
        input [7:0] data;
        begin
            @(negedge clk);
            wr_en = 1;
            din = data;

            @(negedge clk);
            wr_en = 0;

            $display("WRITE: Data = %0d", data);
        end
    endtask

    // Read and verify task
    task read_data;
        input [7:0] expected;
        begin
            @(negedge clk);
            rd_en = 1;

            @(posedge clk);
            #1;

            if (dout === expected)
                $display("PASS: Read Data = %0d", dout);
            else begin
                $display("FAIL: Expected = %0d, Got = %0d",
                         expected, dout);
                $stop;
            end

            @(negedge clk);
            rd_en = 0;
        end
    endtask

    // Main test sequence
    initial begin

        $dumpfile("simulation/fifo.vcd");
        $dumpvars(0, fifo_tb);

        clk = 0;
        rst = 1;
        wr_en = 0;
        rd_en = 0;
        din = 0;

        // Reset test
        repeat(2) @(negedge clk);
        rst = 0;

        #1;
        if (empty)
            $display("PASS: FIFO is initially EMPTY");
        else
            $display("FAIL: FIFO should be EMPTY");

        // Write test
        write_data(8'd10);
        write_data(8'd20);
        write_data(8'd30);

        // Read test
        read_data(8'd10);
        read_data(8'd20);
        read_data(8'd30);

        #1;
        if (empty)
            $display("PASS: FIFO is EMPTY after all reads");
        else
            $display("FAIL: FIFO should be EMPTY");

        $display("--------------------------------");
        $display("FIFO BASIC TEST COMPLETED");
        $display("--------------------------------");

        #10;
        $finish;

    end

endmodule
