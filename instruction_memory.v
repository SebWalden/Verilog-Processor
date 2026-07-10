module instruction_memory(address, instruction);

    input [7:0] address;

    output [15:0] instruction;

    wire [31:0] instr;
    wire [15:0] reg_x;
    wire [15:0] reg_y;
    wire [7:0] imm;

    avr_program program(
        .address(address),
        .instr(instr),
        .reg_x(reg_x),
        .reg_y(reg_y),
        .imm(imm)
    );

    avr_compiler compiler(
        .instr(instr),
        .reg_x(reg_x),
        .reg_y(reg_y),
        .imm(imm),
        .opcode(instruction)
    );

endmodule
