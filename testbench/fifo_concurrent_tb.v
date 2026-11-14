
`timescale 1ns/1ps

module fifo_concurrent_tb;

    reg clk, rst, wr_en, rd_en;
    reg [7:0] din;

    wire [7:0] dout;
    wire full, empty;

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

    always #5 clk = ~clk;

    task write_data(input [7:0] data);
        begin
            @(negedge clk);
            wr_en = 1;
            din = data;

            @(negedge clk);
            wr_en = 0;
        end
    endtask

    task read_check(input [7:0] expected);
        begin
            @(negedge clk);
            rd_en = 1;

            @(posedge clk);
            #1;

            if (dout !== expected)
                $fatal(1, "FAIL: Expected %h, Got %h",
                       expected, dout);
            else
                $display("PASS: Read %h", dout);

            @(negedge clk);
            rd_en = 0;
        end
    endtask

    initial begin

        clk = 0;
        rst = 1;
        wr_en = 0;
        rd_en = 0;
        din = 0;

        repeat(2) @(posedge clk);
        @(negedge clk);
        rst = 0;

        // Write two values
        write_data(8'hA1);
        write_data(8'hA2);

        // Simultaneous read and write
        @(negedge clk);
        wr_en = 1;
        rd_en = 1;
        din = 8'hA3;

        @(posedge clk);
        #1;

        if (dout !== 8'hA1)
            $fatal(1, "FAIL: Simultaneous read");

        if (uut.count !== 2)
            $fatal(1, "FAIL: FIFO count changed");

        $display("PASS: Simultaneous read/write");
        $display("PASS: FIFO count unchanged");

        @(negedge clk);
        wr_en = 0;
        rd_en = 0;

        // Verify remaining data
        read_check(8'hA2);
        read_check(8'hA3);

        if (empty !== 1'b1)
            $fatal(1, "FAIL: FIFO should be empty");

        $display("--------------------------------");
        $display("ALL CONCURRENT TESTS PASSED!");
        $display("--------------------------------");

        $finish;

    end

endmodule
