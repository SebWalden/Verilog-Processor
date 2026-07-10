// Splits a 16-bit instruction into opcode, rx, ry and imm fields.
// Instruction format: [15:12] opcode, [11:10] rx, [9:8] ry, [7:0] imm.

module instruction_decoder(instruction, opcode, rx, ry, imm);

    input [15:0] instruction;

    output [3:0] opcode;
    output [1:0] rx;
    output [1:0] ry;
    output [7:0] imm;

    assign opcode = instruction[15:12];
    assign rx     = instruction[11:10];
    assign ry     = instruction[9:8];
    assign imm    = instruction[7:0];

endmodule
