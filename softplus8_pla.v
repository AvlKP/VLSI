
`include "segment_calculator.v"

module softplus_8slice_pipelined (
    input wire clk,
    input wire rst,
    input wire signed [15:0] x_in,
    input wire valid_in,
    output reg [15:0] y_out,
    output reg valid_out
);
    reg signed [15:0] x_stage1;
    reg valid_stage1;
    reg [2:0] segment_select;
    
    wire [15:0] segment_results [0:7];
    
    parameter FIXED_POINT = 8;
    
    parameter signed [15:0] BP0 = -16'sd1536;
    parameter signed [15:0] BP1 = -16'sd1152;
    parameter signed [15:0] BP2 = -16'sd768;
    parameter signed [15:0] BP3 = -16'sd384;
    parameter signed [15:0] BP4 = 16'sd0;
    parameter signed [15:0] BP5 = 16'sd384;
    parameter signed [15:0] BP6 = 16'sd768;
    parameter signed [15:0] BP7 = 16'sd1152;
    parameter signed [15:0] BP8 = 16'sd1536;

    parameter signed [15:0] SLOPE_0 = 16'sd1;   // 0.00571
    parameter signed [15:0] SLOPE_1 = 16'sd6;   // 0.02503
    parameter signed [15:0] SLOPE_2 = 16'sd26;  // 0.10188
    parameter signed [15:0] SLOPE_3 = 16'sd84;  // 0.32782
    parameter signed [15:0] SLOPE_4 = 16'sd172; // 0.67218
    parameter signed [15:0] SLOPE_5 = 16'sd230; // 0.89812
    parameter signed [15:0] SLOPE_6 = 16'sd250; // 0.97497
    parameter signed [15:0] SLOPE_7 = 16'sd255; // 0.99429

    parameter signed [15:0] INTERCEPT_0 = 16'sd9;   // 0.03676
    parameter signed [15:0] INTERCEPT_1 = 16'sd32;  // 0.12367
    parameter signed [15:0] INTERCEPT_2 = 16'sd91; // 0.35424
    parameter signed [15:0] INTERCEPT_3 = 16'sd177; // 0.69315
    parameter signed [15:0] INTERCEPT_4 = 16'sd177; // 0.69315
    parameter signed [15:0] INTERCEPT_5 = 16'sd91; // 0.35424
    parameter signed [15:0] INTERCEPT_6 = 16'sd32; // 0.12367
    parameter signed [15:0] INTERCEPT_7 = 16'sd9; // 0.03676

    segment_calculator softplus_seg_calc_0 (
        .clk(clk),
        .x_in(x_stage1),
        .slope(SLOPE_0),
        .intercept(INTERCEPT_0),
        .result(segment_results[0])
    );

    segment_calculator softplus_seg_calc_1 (
        .clk(clk),
        .x_in(x_stage1),
        .slope(SLOPE_1),
        .intercept(INTERCEPT_1),
        .result(segment_results[1])
    );

    segment_calculator softplus_seg_calc_2 (
        .clk(clk),
        .x_in(x_stage1),
        .slope(SLOPE_2),
        .intercept(INTERCEPT_2),
        .result(segment_results[2])
    );

    segment_calculator softplus_seg_calc_3 (
        .clk(clk),
        .x_in(x_stage1),
        .slope(SLOPE_3),
        .intercept(INTERCEPT_3),
        .result(segment_results[3])
    );

    segment_calculator softplus_seg_calc_4 (
        .clk(clk),
        .x_in(x_stage1),
        .slope(SLOPE_4),
        .intercept(INTERCEPT_4),
        .result(segment_results[4])
    );

    segment_calculator softplus_seg_calc_5 (
        .clk(clk),
        .x_in(x_stage1),
        .slope(SLOPE_5),
        .intercept(INTERCEPT_5),
        .result(segment_results[5])
    );

    segment_calculator softplus_seg_calc_6 (
        .clk(clk),
        .x_in(x_stage1),
        .slope(SLOPE_6),
        .intercept(INTERCEPT_6),
        .result(segment_results[6])
    );

    segment_calculator softplus_seg_calc_7 (
        .clk(clk),
        .x_in(x_stage1),
        .slope(SLOPE_7),
        .intercept(INTERCEPT_7),
        .result(segment_results[7])
    );

    // Pipeline stages
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            x_stage1 <= 0;
            valid_stage1 <= 0;
        end else begin
            x_stage1 <= x_in;
            valid_stage1 <= valid_in;
            
            // Segment selection logic
            if (x_in <= BP0) segment_select <= 0;
            else if (x_in >= BP8) segment_select <= 7;
            else if (x_in < BP1) segment_select <= 0;
            else if (x_in < BP2) segment_select <= 1;
            else if (x_in < BP3) segment_select <= 2;
            else if (x_in < BP4) segment_select <= 3;
            else if (x_in < BP5) segment_select <= 4;
            else if (x_in < BP6) segment_select <= 5;
            else if (x_in < BP7) segment_select <= 6;
            else segment_select <= 7;
        end
    end

    // Output stage
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            y_out <= 0;
            valid_out <= 0;
        end else begin
            valid_out <= valid_stage1;
            
            if (x_stage1 <= BP0)
                y_out <= 16'sd0;
            else if (x_stage1 >= BP8)
                y_out <= x_stage1;  // Pass through x for large values
            else
                y_out <= segment_results[segment_select];
        end
    end
endmodule