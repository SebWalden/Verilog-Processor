// Program counter with asynchronous reset.
// Holds the address of the next instruction in instruction memory.

module pc_register(clk, reset, pc_en, pc_load, pc_in, pc_out);

    input clk;
    input reset;
    input pc_en;
    input pc_load;
    input [7:0] pc_in;

    output reg [7:0] pc_out;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_out <= 8'b0;
        end
        else if (pc_load) begin
            pc_out <= pc_in;
        end
        else if (pc_en) begin
            pc_out <= pc_out + 8'b1;
        end
    end

endmodule
