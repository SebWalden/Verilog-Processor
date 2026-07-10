// 16-bit register with enable and asynchronous reset.
// The register stores data_in on the rising clock edge when en = 1.

module register16(clk, reset, en, data_in, data_out);

    input clk;
    input reset;
    input en;
    input [15:0] data_in;

    output reg [15:0] data_out;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_out <= 16'b0;
        end
        else if (en) begin
            data_out <= data_in;
        end
    end

endmodule
