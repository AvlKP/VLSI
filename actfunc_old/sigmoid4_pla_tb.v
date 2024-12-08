`include "sigmoid4_pla.v"
`timescale 1ns / 1ps

module sigmoid4_pla_tb();

    // Testbench signals
    reg clk;
    reg rst;
    reg signed [15:0] x;
    wire [15:0] y;

    sigmoid4_pla uut (
        .clk(clk),
        .rst(rst),
        .x(x),
        .y(y)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 ns clock period
    end

    initial begin
        $dumpfile("sigmoid4_pla_tb.vcd");
        $dumpvars(0, sigmoid4_pla_tb);

        // Initialize inputs
        rst = 1;
        x = 16'sd0;

        // Wait for a few clock cycles with reset
        #20;
        rst = 0;

        // Test with different x values
        #10 x = -16'sd30000; // Lower than -6
        #10 x = -16'sd20480; // -5
        #10 x = -16'sd16384; // -4
        #10 x = -16'sd12288; // -3
        #10 x = -16'sd8192;  // -2
        #10 x = -16'sd6144;  // -1.5
        #10 x = -16'sd4096;  // -1
        #10 x = 16'sd0;      // At zero
        #10 x = 16'sd4096;   // 1
        #10 x = 16'sd6144;   // 1.5
        #10 x = 16'sd8192;   // 2
        #10 x = 16'sd12288;  // 3
        #10 x = 16'sd16384;  // 4
        #10 x = 16'sd20480;  // 5
        #10 x = 16'sd30000;  // Higher than 6

        #10 x = -16'sd15000;
        #10 x = 16'sd10000;

        // Finish simulation
        #50 $finish;
    end

endmodule
