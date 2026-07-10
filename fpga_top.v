// FPGA top-level wrapper.
//
// Inputs:
// CLOCK_50 = FPGA board clock
// KEY[0]   = reset button
//
// This assumes KEY buttons are active-low.
// If your board uses active-high buttons, change reset = ~KEY[0] to reset = KEY[0].
//
// Seven-segment display layout:
// HEX1 HEX0 = R0 lower byte in hex
// HEX3 HEX2 = R1 lower byte in hex
// HEX5 HEX4 = R2 lower byte in hex

module fpga_top(CLOCK_50, KEY, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);

    input CLOCK_50;
    input [3:0] KEY;

    output [9:0] LEDR;
    output [6:0] HEX0;
    output [6:0] HEX1;
    output [6:0] HEX2;
    output [6:0] HEX3;
    output [6:0] HEX4;
    output [6:0] HEX5;

    wire reset;
    wire slow_clk;

    wire [15:0] r0_value;
    wire [15:0] r1_value;
    wire [15:0] r2_value;

    wire [7:0] pc_value;
    wire [7:0] current_instruction_number;
    wire [7:0] return_address_value;
    wire [7:0] sp_value;

    wire [15:0] instruction_value;
    wire [15:0] bus_value;
    wire [15:0] a_value;
    wire [15:0] g_value;

    wire zero_flag;
    wire overflow_flag;
    wire carry_flag;
    wire [3:0] state_value;

    wire [15:0] data_mem_16;

    assign reset = ~KEY[0];

    clock_divider divider(
        .CLOCK_50(CLOCK_50),
        .reset(reset),
        .slow_clk(slow_clk)
    );

    simple_processor cpu(
        .clk(slow_clk),
        .reset(reset),

        .r0_value(r0_value),
        .r1_value(r1_value),
        .r2_value(r2_value),

        .pc_value(pc_value),
        .current_instruction_number(current_instruction_number),
        .return_address_value(return_address_value),
        .sp_value(sp_value),
        .instruction_value(instruction_value),
        .bus_value(bus_value),
        .a_value(a_value),
        .g_value(g_value),

        .zero_flag(zero_flag),
        .overflow_flag(overflow_flag),
        .carry_flag(carry_flag),
        .state_value(state_value),

        .data_mem_16(data_mem_16)
    );

    // LED debug display:
    // LEDR[3:0] shows current instruction number.
    // LEDR[7:4] shows stack pointer lower 4 bits.
    // LEDR[8] shows zero_flag.
    // LEDR[9] shows overflow_flag.
    assign LEDR[3:0] = current_instruction_number[3:0];
    assign LEDR[7:4] = sp_value[3:0];
    assign LEDR[8]   = zero_flag;
    assign LEDR[9]   = overflow_flag;

    // Seven-segment displays:
    // Two displays per register, showing the lower byte in hex.
    // HEX0 is the low nibble, HEX1 is the high nibble of R0[7:0].
    seven_seg_decoder r0_low_display(
        .value(r0_value[3:0]),
        .segments(HEX0)
    );

    seven_seg_decoder r0_high_display(
        .value(r0_value[7:4]),
        .segments(HEX1)
    );

    seven_seg_decoder r1_low_display(
        .value(r1_value[3:0]),
        .segments(HEX2)
    );

    seven_seg_decoder r1_high_display(
        .value(r1_value[7:4]),
        .segments(HEX3)
    );

    seven_seg_decoder r2_low_display(
        .value(r2_value[3:0]),
        .segments(HEX4)
    );

    seven_seg_decoder r2_high_display(
        .value(r2_value[7:4]),
        .segments(HEX5)
    );

endmodule
