`include "sigmoid8_pla.v"

// Testbench for pipelined implementations
module sigmoid8_pla_tb;
    reg clk;
    reg rst;
    reg signed [15:0] x_in;
    reg valid_in;
    wire [15:0] sigmoid_out;
    wire sigmoid_valid_out;
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Instantiate the modules
    sigmoid8_pla sigmoid_inst (
        .clk(clk),
        .rst(rst),
        .x_in(x_in),
        .valid_in(valid_in),
        .y_out(sigmoid_out),
        .valid_out(sigmoid_valid_out)
    );
    
    initial begin
        $dumpfile("sigmoid8_pla_tb.vcd");
        $dumpvars(0, sigmoid8_pla_tb);
        
        // Reset sequence
        rst = 1;
        valid_in = 0;
        x_in = 0;
        #20;
        rst = 0;
        
        // Test sequence with pipeline
        // Each value needs multiple cycles to propagate
        @(posedge clk); // Wait for clock
        valid_in = 1;
        x_in = -16'sd1536; // -6.0
        #10;
        
        x_in = -16'sd1152; // -4.5
        #10;
        
        x_in = -16'sd768; // -3.0
        #10;
        
        x_in = 16'sd0;
        #10;
        
        x_in = 16'sd768;
        #10;
        
        x_in = 16'sd1536;
        #10;
        
        valid_in = 0;
        // Wait for pipeline to flush
        #30;
        
        $finish;
    end
    
    // Monitor results
    always @(posedge clk) begin
        if (sigmoid_valid_out)
            $display("Time=%0t Sigmoid: x=%d, y=%d", $time, x_in, sigmoid_out);
    end
endmodule