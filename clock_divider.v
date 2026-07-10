// Slow clock divider for FPGA demonstration.
// The FPGA board clock is too fast to see processor progress on LEDs.
// Reset clears the divider counter, while the processor itself uses asynchronous reset.

module clock_divider(CLOCK_50, reset, slow_clk);

    input CLOCK_50;
    input reset;

    output slow_clk;

    reg [24:0] count;

    always @(posedge CLOCK_50 or posedge reset) begin
        if (reset) begin
            count <= 25'b0;
        end
        else begin
            count <= count + 25'b1;
        end
    end

    assign slow_clk = count[24];

endmodule
