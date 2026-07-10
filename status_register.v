// Status register with asynchronous reset.
// zero_flag updates for arithmetic instructions.
// overflow_flag checks whether the ALU operation overflowed or underflowed.
// carry_flag records carry/borrow information for arithmetic operations.

module status_register(clk, reset, sr_en, result, a_value, b_value, alu_ctl, zero_flag, overflow_flag, carry_flag);

    input clk;
    input reset;
    input sr_en;
    input [15:0] result;
    input [15:0] a_value;
    input [15:0] b_value;
    input [3:0] alu_ctl;

    output reg zero_flag;
    output reg overflow_flag;
    output reg carry_flag;

    reg [16:0] add_result;
    reg [31:0] mult_result;

    always @(*) begin
        add_result = {1'b0, a_value} + {1'b0, b_value};
        mult_result = a_value * b_value;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            zero_flag <= 1'b0;
            overflow_flag <= 1'b0;
            carry_flag <= 1'b0;
        end
        else if (sr_en) begin
            zero_flag <= (result == 16'b0);

            case (alu_ctl)
                4'b0000: begin
                    overflow_flag <= add_result[16];             // ADD carry out
                    carry_flag <= add_result[16];
                end

                4'b0001: begin
                    overflow_flag <= (a_value < b_value);        // SUB underflow/borrow
                    carry_flag <= (a_value < b_value);
                end

                4'b0010: begin
                    overflow_flag <= (mult_result > 32'd65535);  // MUL too large
                    carry_flag <= (mult_result > 32'd65535);
                end

                default: begin
                    overflow_flag <= 1'b0;
                    carry_flag <= 1'b0;
                end
            endcase
        end
    end

endmodule
