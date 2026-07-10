// Data memory for LD, ST, PUSH and POP.
// Reads are combinational. Writes happen on the clock edge.
// This FPGA-friendly version does not reset every memory location.

module data_memory(clk, reset, mem_en, mem_we, address, data_in, data_out);

    input clk;
    input reset;
    input mem_en;
    input mem_we;
    input [7:0] address;
    input [15:0] data_in;

    output reg [15:0] data_out;

    reg [15:0] memory [0:255];

    always @(posedge clk) begin
        if (mem_en && mem_we) begin
            memory[address] <= data_in;
        end
    end

    always @(*) begin
        if (mem_en) begin
            data_out = memory[address];
        end
        else begin
            data_out = 16'b0;
        end
    end

endmodule
