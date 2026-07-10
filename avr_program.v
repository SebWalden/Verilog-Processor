module avr_program(address, instr, reg_x, reg_y, imm);

    input [7:0] address;

    output reg [31:0] instr;  // 4 characters, e.g. "LDI ", "CALL", "HALT"
    output reg [15:0] reg_x;  // 2 characters, e.g. "r0"
    output reg [15:0] reg_y;  // 2 characters, e.g. "r1"
    output reg [7:0] imm;     // immediate/address

    always @(*) begin

        // Default instruction.
        instr = "HALT";
        reg_x = "  ";
        reg_y = "  ";
        imm = 8'd0;

        case (address)

            8'd0: begin
                // LDI r0 8
                instr = "LDI ";
                reg_x = "r0";
                imm = 8'd8;
            end

            8'd1: begin
                // LDI r1 8
                instr = "LDI ";
                reg_x = "r1";
                imm = 8'd8;
            end

            8'd2: begin
                // SUB r0 r1
                instr = "SUB ";
                reg_x = "r0";
                reg_y = "r1";
            end

            8'd3: begin
                // JZ 5
                instr = "JZ  ";
                imm = 8'd5;
            end

            8'd4: begin
                // LDI r2 99
                instr = "LDI ";
                reg_x = "r2";
                imm = 8'd99;
            end

            8'd5: begin
                // LDI r0 2
                instr = "LDI ";
                reg_x = "r0";
                imm = 8'd2;
            end

            8'd6: begin
                // LDI r1 3
                instr = "LDI ";
                reg_x = "r1";
                imm = 8'd3;
            end

            8'd7: begin
                // LDI r2 4
                instr = "LDI ";
                reg_x = "r2";
                imm = 8'd4;
            end

            8'd8: begin
                // PUSH r0
                instr = "PUSH";
                reg_x = "r0";
            end

            8'd9: begin
                // PUSH r1
                instr = "PUSH";
                reg_x = "r1";
            end

            8'd10: begin
                // LDI r0 9
                instr = "LDI ";
                reg_x = "r0";
                imm = 8'd9;
            end

            8'd11: begin
                // LDI r1 8
                instr = "LDI ";
                reg_x = "r1";
                imm = 8'd8;
            end

            8'd12: begin
                // POP r1
                instr = "POP ";
                reg_x = "r1";
            end

            8'd13: begin
                // POP r0
                instr = "POP ";
                reg_x = "r0";
            end

            8'd14: begin
                // CALL 18
                instr = "CALL";
                imm = 8'd18;
            end

            8'd15: begin
                // ST r2 16
                instr = "ST  ";
                reg_x = "r2";
                imm = 8'd16;
            end

            8'd16: begin
                // HALT
                instr = "HALT";
            end

            8'd17: begin
                // HALT
                instr = "HALT";
            end

            8'd18: begin
                // MAC r2
                instr = "MAC ";
                reg_x = "r2";
            end

            8'd19: begin
                // RET
                instr = "RET ";
            end

            default: begin
                instr = "HALT";
            end

        endcase
    end

endmodule
