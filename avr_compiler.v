// avr_style_compiler.v
// Converts AVR-style Verilog instruction fields into the processor's 16-bit opcode.
//
// Instruction format:
// [15:12] opcode
// [11:10] rx
// [9:8]   ry
// [7:0]   imm
//
// Example:
//
// instr = "LDI "
// reg_x = "r0"
// reg_y = "  "
// imm   = 8'd8
//
// opcode = 0000_00_00_00001000

module avr_compiler(instr, reg_x, reg_y, imm, opcode);

    input [31:0] instr;  // 4 characters
    input [15:0] reg_x;  // 2 characters
    input [15:0] reg_y;  // 2 characters
    input [7:0] imm;

    output reg [15:0] opcode;

    function [1:0] get_reg;
        input [15:0] reg_str;
        begin
            case (reg_str)
                "r0": get_reg = 2'b00;
                "r1": get_reg = 2'b01;
                "r2": get_reg = 2'b10;
                "R0": get_reg = 2'b00;
                "R1": get_reg = 2'b01;
                "R2": get_reg = 2'b10;
                default: get_reg = 2'b00;
            endcase
        end
    endfunction

    reg [1:0] rx;
    reg [1:0] ry;

    always @(*) begin
        rx = get_reg(reg_x);
        ry = get_reg(reg_y);

        case (instr)

            // LDI rx imm
            "LDI ": opcode = {4'b0000, rx,    2'b00, imm};

            // Register-register instructions
            "MOV ": opcode = {4'b0001, rx,    ry,    8'h00};
            "ADD ": opcode = {4'b0010, rx,    ry,    8'h00};
            "SUB ": opcode = {4'b0011, rx,    ry,    8'h00};
            "MUL ": opcode = {4'b0100, rx,    ry,    8'h00};

            // One-register instructions
            "MAC ": opcode = {4'b0101, rx,    2'b00, 8'h00};
            "PUSH": opcode = {4'b0110, rx,    2'b00, 8'h00};
            "POP ": opcode = {4'b0111, rx,    2'b00, 8'h00};

            // Address-only instructions
            "CALL": opcode = {4'b1000, 2'b00, 2'b00, imm};
            "RET ": opcode = {4'b1001, 2'b00, 2'b00, 8'h00};

            // Memory instructions
            "LD  ": opcode = {4'b1010, rx,    2'b00, imm};
            "ST  ": opcode = {4'b1011, rx,    2'b00, imm};

            // Jumps
            "JMP ": opcode = {4'b1100, 2'b00, 2'b00, imm};
            "JZ  ": opcode = {4'b1101, 2'b00, 2'b00, imm};
            "JO  ": opcode = {4'b1110, 2'b00, 2'b00, imm};

            // Stop
            "HALT": opcode = {4'b1111, 2'b00, 2'b00, 8'h00};

            default: opcode = {4'b1111, 2'b00, 2'b00, 8'h00};

        endcase
    end

endmodule
