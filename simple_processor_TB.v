// simple_processor_TB.v
// Basic simulation testbench for the processor.
//
// This file is only for Icarus Verilog / GTKWave simulation.
// Do not include this file in the Quartus FPGA project.

module simple_processor_TB;

    reg clk;
    reg reset;

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

    simple_processor uut(
        .clk(clk),
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

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;

        $dumpfile("processor_waveform.vcd");
        $dumpvars(0, simple_processor_TB);

        #20;
        reset = 0;

        // Let the program run.
        #1200;

        $display("Final R0 = %d", r0_value);
        $display("Final R1 = %d", r1_value);
        $display("Final R2 = %d", r2_value);
        $display("Final PC = %d", pc_value);
        $display("Current instruction number = %d", current_instruction_number);
        $display("Return address = %d", return_address_value);
        $display("Stack pointer = %d", sp_value);
        $display("Zero flag = %b", zero_flag);
        $display("Overflow flag = %b", overflow_flag);
        $display("Carry flag = %b", carry_flag);
        $display("Data memory [16] = %d", data_mem_16);

        $finish;
    end

endmodule
