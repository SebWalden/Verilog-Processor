// ALU for the processor.
// A comes from the A register. B usually comes from the shared bus.

module alu(a, b, alu_ctl, result);

    input [15:0] a;
    input [15:0] b;
    input [3:0] alu_ctl;

    output reg [15:0] result;

    always @(*) begin
        case (alu_ctl)
            4'b0000: result = a + b;        // ADD
            4'b0001: result = a - b;        // SUB
            4'b0010: result = a * b;        // MUL
            default: result = 16'b0;
        endcase
    end

endmodule
