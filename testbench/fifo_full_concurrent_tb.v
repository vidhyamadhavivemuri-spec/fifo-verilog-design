
`timescale 1ns/1ps

module fifo_full_concurrent_tb;

    reg clk;
    reg rst;
    reg wr_en;
    reg rd_en;
    reg [7:0] din;

    wire [7:0] dout;
    wire full;
    wire empty;

    integer i;

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

    // Write one byte into FIFO
    task write_data(input [7:0] data);
        begin
            @(negedge clk);
            wr_en = 1;
            din = data;

            @(posedge clk);
            #1;
            wr_en = 0;
        end
    endtask

    // Read and verify one byte
    task read_expected(input [7:0] expected);
        begin
            @(negedge clk);
            rd_en = 1;

            @(posedge clk);
            #1;

            if (dout !== expected) begin
                $display("FAIL: Expected %h, got %h", expected, dout);
                $fatal;
            end
            else begin
                $display("PASS: Read %h", dout);
            end

            rd_en = 0;
        end
    endtask

    initial begin

        clk = 0;
        rst = 1;
        wr_en = 0;
        rd_en = 0;
        din = 0;

        // Reset FIFO
        repeat (2) @(posedge clk);
        #1;
        rst = 0;

        // Fill all 16 FIFO locations
        for (i = 0; i < 16; i = i + 1)
            write_data(8'h20 + i);

        if (full)
            $display("PASS: FIFO is FULL");
        else
            $fatal(1, "FAIL: FIFO did not become FULL");

        // Simultaneous read and write while FULL
        @(negedge clk);
        wr_en = 1;
        rd_en = 1;
        din = 8'hEE;

        @(posedge clk);
        #1;

        if (dout !== 8'h20)
            $fatal(1, "FAIL: Incorrect data during simultaneous operation");

        if (!full || uut.count != 16)
            $fatal(1, "FAIL: FIFO occupancy changed");

        $display("PASS: Simultaneous read/write at FULL");
        $display("PASS: Oldest data 20 read successfully");
        $display("PASS: New data EE accepted");
        $display("PASS: FIFO count remains 16");

        @(negedge clk);
        wr_en = 0;
        rd_en = 0;

        // Read the remaining 15 old values
        for (i = 1; i < 16; i = i + 1)
            read_expected(8'h20 + i);

        // Read the newly written value
        read_expected(8'hEE);

        if (empty)
            $display("PASS: FIFO is EMPTY");
        else
            $fatal(1, "FAIL: FIFO did not become EMPTY");

        $display("--------------------------------");
        $display("ALL FULL CONCURRENT TESTS PASSED!");
        $display("--------------------------------");

        $finish;
    end

endmodule
