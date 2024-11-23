module segment_calculator (
    input wire clk,
    input wire signed [15:0] x_in,
    input wire signed [15:0] slope,
    input wire signed [15:0] intercept,
    output reg [15:0] result
);
    parameter FIXED_POINT = 8;
    
    always @(posedge clk) begin
        result <= ((slope * x_in) >>> FIXED_POINT) + intercept;
    end
endmodule