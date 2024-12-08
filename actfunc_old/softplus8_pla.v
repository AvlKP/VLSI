module softplus8_pla #(
    parameter WIDTH = 16,
    parameter SLICES = 8,
    parameter FP = 8
) (
    input wire clk,
    input wire rst,
    input wire signed [WIDTH - 1:0] x,
    output wire [WIDTH - 1:0] y
);

    localparam signed [(WIDTH * SLICES - 1):0] SLOPES = {
        16'sd255,
        16'sd250,
        16'sd230,
        16'sd172,
        16'sd84,
        16'sd26,
        16'sd6,
        16'sd1
    };

    localparam signed [(WIDTH * SLICES - 1):0] INTERCEPTS = {
        16'sd9,
        16'sd32,
        16'sd91,
        16'sd177,
        16'sd177,
        16'sd91,
        16'sd32,
        16'sd9
    };

    localparam signed [(WIDTH * (SLICES + 1) - 1):0] BREAKPOINTS = {
        16'sd1536,
        16'sd1152,
        16'sd768,
        16'sd384,
        16'sd0,
        -16'sd384,
        -16'sd768,
        -16'sd1152,
        -16'sd1536
    };

    // Combinational
    reg [SLICES:0] sel; // mux selector
    reg signed [(2 * WIDTH - 1):0] segmult [SLICES - 1:0]; // multiplication result of a segment
    reg [WIDTH - 1:0] segres [SLICES - 1:0]; // result of a segment
    reg [WIDTH - 1:0] mux; // muxed result of segments

    integer i;
    always @(*) begin
        // selector
        for (i = 0; i < SLICES + 1; i = i + 1) begin
            sel[i] = (x_reg > $signed(BREAKPOINTS[WIDTH * i +: WIDTH]));
        end

        // segment multiplier
        for (i = 0; i < SLICES; i = i + 1) begin
            segmult[i] = x_reg * $signed(SLOPES[WIDTH * i +: WIDTH]);
        end

        // segment result
        for (i = 0; i < SLICES; i = i + 1) begin
            segres[i] = (segmult_reg[i] >> FP) + $signed(INTERCEPTS[WIDTH * i +: WIDTH]);
        end

        // output mux
        mux = {WIDTH{1'b0}};

        if (sel_reg2 == {(SLICES+1){1'b0}}) begin
            mux = {WIDTH{1'b0}};
        end else if (sel_reg2 == {(SLICES+1){1'b1}}) begin
            mux = segres_reg[SLICES - 1];
        end else begin
            for (i = 0; i < SLICES; i = i + 1) begin
                if (sel_reg2 == ((1 << (i + 1)) - 1)) begin
                    mux = segres_reg[i];
                end
            end
        end
    end

    // Sequential - Pipelining
    // Stage 1
    reg signed [WIDTH - 1:0] x_reg;

    // Stage 2
    reg [SLICES:0] sel_reg1;
    reg signed [2 * WIDTH - 1:0] segmult_reg [SLICES - 1:0];

    // Stage 3
    reg [SLICES:0] sel_reg2;
    reg [WIDTH - 1:0] segres_reg [SLICES - 1:0];

    // Stage 4
    reg [WIDTH - 1:0] mux_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            x_reg <= {WIDTH{1'b0}};

            sel_reg1 <= {(SLICES + 1){1'b0}};
            for (i = 0; i < SLICES; i = i + 1) begin
                segmult_reg[i] <= {(WIDTH * 2){1'b0}};
            end

            sel_reg2 <= {(SLICES + 1){1'b0}};
            for (i = 0; i < SLICES; i = i + 1) begin
                segres_reg[i] <= {WIDTH{1'b0}};
            end

            mux_reg <= {WIDTH{1'b0}};
        end else begin
            x_reg <= x;

            sel_reg1 <= sel;
            for (i = 0; i < SLICES; i = i + 1) begin
                segmult_reg[i] <= segmult[i];
            end

            sel_reg2 <= sel_reg1;
            for (i = 0; i < SLICES; i = i + 1) begin
                segres_reg[i] <= segres[i];
            end

            mux_reg <= mux;
        end
    end

    assign y = mux_reg;
endmodule