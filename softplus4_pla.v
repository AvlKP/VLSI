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
    parameter signed [15:0] BP1 = -16'sd768;
    parameter signed [15:0] BP2 = 16'sd0;
    parameter signed [15:0] BP3 = 16'sd768;
    parameter signed [15:0] BP4 = 16'sd1536;

    parameter signed [15:0] SLOPE_0 = 16'sd4;   // 0.01537
    parameter signed [15:0] SLOPE_1 = 16'sd55;  // 0.21485
    parameter signed [15:0] SLOPE_2 = 16'sd201; // 0.78515
    parameter signed [15:0] SLOPE_3 = 16'sd252; // 0.98463

    parameter signed [15:0] INTERCEPT_0 = 16'sd24;   // 0.0947
    parameter signed [15:0] INTERCEPT_1 = 16'sd177; // 0.69315
    parameter signed [15:0] INTERCEPT_2 = 16'sd177; // 0.69315
    parameter signed [15:0] INTERCEPT_3 = 16'sd24; // 0.0947

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
            else if (x_in >= BP4) segment_select <= 3;
            else if (x_in < BP1) segment_select <= 0;
            else if (x_in < BP2) segment_select <= 1;
            else if (x_in < BP3) segment_select <= 2;
            else segment_select <= 3;
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
            else if (x_stage1 >= BP4)
                y_out <= x_stage1;  // Pass through x for large values
            else
                y_out <= segment_results[segment_select];
        end
    end
endmodule