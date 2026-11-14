
`timescale 1ns/1ps

module fifo_boundary_tb;

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

        // Fill all 16 locations
        for (i = 0; i < 16; i = i + 1)
            write_data(8'h40 + i);

        if (full !== 1'b1)
            $fatal(1, "FAIL: FIFO did not become full");

        $display("PASS: FIFO FULL condition");

        // Attempt overflow
        write_data(8'hFF);

        if (full !== 1'b1 || uut.count !== 16)
            $fatal(1, "FAIL: Overflow handling");

        $display("PASS: Overflow prevented");

        // Read all 16 values
        for (i = 0; i < 16; i = i + 1)
            read_check(8'h40 + i);

        if (empty !== 1'b1)
            $fatal(1, "FAIL: FIFO should be empty");

        $display("PASS: FIFO EMPTY condition");

        // Attempt underflow
        @(negedge clk);
        rd_en = 1;

        @(posedge clk);
        #1;

        if (empty !== 1'b1 || uut.count !== 0)
            $fatal(1, "FAIL: Underflow handling");

        @(negedge clk);
        rd_en = 0;

        $display("PASS: Underflow prevented");

        $display("--------------------------------");
        $display("ALL BOUNDARY TESTS PASSED!");
        $display("--------------------------------");

        $finish;

    end

endmodule
