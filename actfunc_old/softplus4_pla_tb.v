`include "softplus4_pla.v"
`timescale 1ns / 1ps

module softplus4_pla_tb();

    // Testbench signals
    reg clk;
    reg rst;
    reg signed [15:0] x;
    wire [15:0] y;

    softplus4_pla uut (
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
        $dumpfile("softplus4_pla_tb.vcd");
        $dumpvars(0, softplus4_pla_tb);

        // Initialize inputs
        rst = 1;
        x = 16'sd0;

        // Wait for a few clock cycles with reset
        #20;
        rst = 0;

        // Test with different x values
        #10 x = -16'sd1792; // Lower than -6
        #10 x = -16'sd1280; // -5
        #10 x = -16'sd1024; // -4
        #10 x = -16'sd768; // -3
        #10 x = -16'sd512;  // -2
        #10 x = -16'sd384;  // -1.5
        #10 x = -16'sd256;  // -1
        #10 x = 16'sd0;      // At zero
        #10 x = 16'sd256;   // 1
        #10 x = 16'sd384;   // 1.5
        #10 x = 16'sd512;   // 2
        #10 x = 16'sd768;  // 3
        #10 x = 16'sd1024;  // 4
        #10 x = 16'sd1280;  // 5
        #10 x = 16'sd1792;  // Higher than 6

        // Finish simulation
        #50 $finish;
    end

endmodule
