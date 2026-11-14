
`timescale 1ns/1ps

module fifo_wraparound_tb;

    reg clk, rst, wr_en, rd_en;
    reg [7:0] din;

    wire [7:0] dout;
    wire full, empty;

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

        // Write 12 values
        for (i = 0; i < 12; i = i + 1)
            write_data(i);

        // Read 10 values
        for (i = 0; i < 10; i = i + 1)
            read_check(i);

        // Write 8 more values
        // Write pointer crosses position 15
        for (i = 0; i < 8; i = i + 1)
            write_data(8'h80 + i);

        if (uut.wr_ptr !== 4'd4)
            $fatal(1, "FAIL: Write pointer wraparound");

        $display("PASS: Write pointer wrapped to 4");

        // Read remaining old values
        read_check(8'h0A);
        read_check(8'h0B);

        // Read newly written values
        for (i = 0; i < 8; i = i + 1)
            read_check(8'h80 + i);

        if (empty !== 1'b1)
            $fatal(1, "FAIL: FIFO should be empty");

        $display("--------------------------------");
        $display("ALL WRAPAROUND TESTS PASSED!");
        $display("--------------------------------");

        $finish;

    end

endmodule
