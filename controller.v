// Controller FSM for the full one-bus processor.
// It handles fetch, decode, arithmetic, memory, stack, CALL, RET, JO and HALT.
// Overflow blocks ALU write-back, so an overflow result does not update Rx.

module controller(
    clk,
    reset,

    opcode,
    rx,
    ry,
    imm,

    zero_flag,
    overflow_flag,

    pc_en,
    pc_load,
    pc_ret,
    ir_en,
    return_en,

    r0_en,
    r1_en,
    r2_en,

    r0_tri,
    r1_tri,
    r2_tri,

    imm_tri,
    mem_tri,

    a_en,
    g_en,
    sr_en,
    g_tri,

    mem_en,
    mem_we,

    stack_addr,
    stack_pop,
    sp_en,
    sp_inc,

    alu_ctl,
    state
);

    input clk;
    input reset;

    input [3:0] opcode;
    input [1:0] rx;
    input [1:0] ry;
    input [7:0] imm;

    input zero_flag;
    input overflow_flag;

    output reg pc_en;
    output reg pc_load;
    output reg pc_ret;
    output reg ir_en;
    output reg return_en;

    output reg r0_en;
    output reg r1_en;
    output reg r2_en;

    output reg r0_tri;
    output reg r1_tri;
    output reg r2_tri;

    output reg imm_tri;
    output reg mem_tri;

    output reg a_en;
    output reg g_en;
    output reg sr_en;
    output reg g_tri;

    output reg mem_en;
    output reg mem_we;

    output reg stack_addr;
    output reg stack_pop;
    output reg sp_en;
    output reg sp_inc;

    output reg [3:0] alu_ctl;
    output reg [3:0] state;

    reg [3:0] current_opcode;
    reg [1:0] current_rx;
    reg [1:0] current_ry;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= 4'b0000;
            current_opcode <= 4'b0000;
            current_rx <= 2'b00;
            current_ry <= 2'b00;
        end
        else begin
            case (state)

                4'b0000: begin
                    state <= 4'b0001; // FETCH -> DECODE
                end

                4'b0001: begin
                    current_opcode <= opcode;
                    current_rx <= rx;
                    current_ry <= ry;

                    case (opcode)
                        4'b0000: state <= 4'b0010; // LDI
                        4'b0001: state <= 4'b0011; // MOV
                        4'b0101: state <= 4'b1010; // MAC
                        4'b0110: state <= 4'b0111; // PUSH
                        4'b0111: state <= 4'b1000; // POP
                        4'b1000: state <= 4'b1001; // CALL
                        4'b1001: state <= 4'b1001; // RET
                        4'b1010: state <= 4'b0111; // LD
                        4'b1011: state <= 4'b1000; // ST
                        4'b1100: state <= 4'b1001; // JMP
                        4'b1101: state <= 4'b1001; // JZ
                        4'b1110: state <= 4'b1001; // JO
                        4'b1111: state <= 4'b1111; // HALT
                        default: state <= 4'b0100; // ADD/SUB/MUL
                    endcase
                end

                4'b0010: state <= 4'b0000; // LDI_WRITE -> FETCH
                4'b0011: state <= 4'b0000; // MOV_WRITE -> FETCH

                4'b0100: state <= 4'b0101; // ALU_LOAD_A -> ALU_EXEC
                4'b0101: state <= 4'b0110; // ALU_EXEC -> ALU_WRITE
                4'b0110: state <= 4'b0000; // ALU_WRITE -> FETCH

                4'b0111: state <= 4'b0000; // LD/PUSH -> FETCH
                4'b1000: state <= 4'b0000; // ST/POP -> FETCH
                4'b1001: state <= 4'b0000; // JMP/JZ/JN/CALL/RET -> FETCH

                4'b1010: state <= 4'b1011; // MAC_LOAD_OTHER1 -> MAC_MUL
                4'b1011: state <= 4'b1100; // MAC_MUL -> MAC_PRODUCT_TO_A
                4'b1100: state <= 4'b1101; // MAC_PRODUCT_TO_A -> MAC_ADD_RX
                4'b1101: state <= 4'b1110; // MAC_ADD_RX -> MAC_WRITE
                4'b1110: state <= 4'b0000; // MAC_WRITE -> FETCH

                4'b1111: state <= 4'b1111; // HALT stays stopped until reset

                default: state <= 4'b0000;

            endcase
        end
    end

    always @(*) begin

        pc_en = 0;
        pc_load = 0;
        pc_ret = 0;
        ir_en = 0;
        return_en = 0;

        r0_en = 0;
        r1_en = 0;
        r2_en = 0;

        r0_tri = 0;
        r1_tri = 0;
        r2_tri = 0;

        imm_tri = 0;
        mem_tri = 0;

        a_en = 0;
        g_en = 0;
        sr_en = 0;
        g_tri = 0;

        mem_en = 0;
        mem_we = 0;

        stack_addr = 0;
        stack_pop = 0;
        sp_en = 0;
        sp_inc = 0;

        alu_ctl = 4'b0000;

        case (state)

            4'b0000: begin
                // FETCH: instruction memory output is loaded into IR, then PC increments.
                ir_en = 1;
                pc_en = 1;
            end

            4'b0010: begin
                // LDI Rx, imm: immediate -> bus -> Rx
                imm_tri = 1;
                case (current_rx)
                    2'b00: r0_en = 1;
                    2'b01: r1_en = 1;
                    2'b10: r2_en = 1;
                endcase
            end

            4'b0011: begin
                // MOV Rx, Ry: Ry -> bus -> Rx
                case (current_ry)
                    2'b00: r0_tri = 1;
                    2'b01: r1_tri = 1;
                    2'b10: r2_tri = 1;
                endcase

                case (current_rx)
                    2'b00: r0_en = 1;
                    2'b01: r1_en = 1;
                    2'b10: r2_en = 1;
                endcase
            end

            4'b0100: begin
                // ALU_LOAD_A: Rx -> bus -> A
                case (current_rx)
                    2'b00: r0_tri = 1;
                    2'b01: r1_tri = 1;
                    2'b10: r2_tri = 1;
                endcase
                a_en = 1;
            end

            4'b0101: begin
                // ALU_EXEC: choose operation, place Ry on bus if needed, store result in G/SR.
                case (current_opcode)
                    4'b0010: alu_ctl = 4'b0000; // ADD
                    4'b0011: alu_ctl = 4'b0001; // SUB
                    4'b0100: alu_ctl = 4'b0010; // MUL
                    default: alu_ctl = 4'b0000;
                endcase

                if ((current_opcode == 4'b0010) ||
                    (current_opcode == 4'b0011) ||
                    (current_opcode == 4'b0100)) begin

                    case (current_ry)
                        2'b00: r0_tri = 1;
                        2'b01: r1_tri = 1;
                        2'b10: r2_tri = 1;
                    endcase
                end

                g_en = 1;
                sr_en = 1;
            end

            4'b0110: begin
                // ALU_WRITE: G -> bus -> Rx.
                // Overflow results do not write back.
                if (!overflow_flag) begin
                    g_tri = 1;

                    case (current_rx)
                        2'b00: r0_en = 1;
                        2'b01: r1_en = 1;
                        2'b10: r2_en = 1;
                    endcase
                end
            end

            4'b0111: begin
                if (current_opcode == 4'b1010) begin
                    // LD Rx, [imm]: data memory -> bus -> Rx
                    mem_en = 1;
                    mem_tri = 1;

                    case (current_rx)
                        2'b00: r0_en = 1;
                        2'b01: r1_en = 1;
                        2'b10: r2_en = 1;
                    endcase
                end
                else if (current_opcode == 4'b0110) begin
                    // PUSH Rx:
                    // memory[SP] = Rx, then SP = SP - 1
                    stack_addr = 1;
                    mem_en = 1;
                    mem_we = 1;
                    sp_en = 1;
                    sp_inc = 0;

                    case (current_rx)
                        2'b00: r0_tri = 1;
                        2'b01: r1_tri = 1;
                        2'b10: r2_tri = 1;
                    endcase
                end
            end

            4'b1000: begin
                if (current_opcode == 4'b1011) begin
                    // ST Rx, [imm]: Rx -> bus -> data memory
                    mem_en = 1;
                    mem_we = 1;

                    case (current_rx)
                        2'b00: r0_tri = 1;
                        2'b01: r1_tri = 1;
                        2'b10: r2_tri = 1;
                    endcase
                end
                else if (current_opcode == 4'b0111) begin
                    // POP Rx:
                    // SP = SP + 1, then Rx = memory[SP]
                    // The memory address uses SP + 1 during this state.
                    stack_addr = 1;
                    stack_pop = 1;
                    mem_en = 1;
                    mem_tri = 1;
                    sp_en = 1;
                    sp_inc = 1;

                    case (current_rx)
                        2'b00: r0_en = 1;
                        2'b01: r1_en = 1;
                        2'b10: r2_en = 1;
                    endcase
                end
            end

            4'b1001: begin
                // JMP/JZ/JO/CALL/RET.
                if (current_opcode == 4'b1100) begin
                    pc_load = 1; // JMP imm
                end
                else if ((current_opcode == 4'b1101) && zero_flag) begin
                    pc_load = 1; // JZ imm
                end
                else if ((current_opcode == 4'b1110) && overflow_flag) begin
                    pc_load = 1; // JO imm
                end
                else if (current_opcode == 4'b1000) begin
                    // CALL imm:
                    // Save return address and jump to imm.
                    return_en = 1;
                    pc_load = 1;
                end
                else if (current_opcode == 4'b1001) begin
                    // RET:
                    // Load PC from return address register.
                    pc_ret = 1;
                    pc_load = 1;
                end
            end

            4'b1010: begin
                // MAC_LOAD_OTHER1:
                // Load the first non-Rx register into A.
                case (current_rx)
                    2'b00: r1_tri = 1; // MAC R0 uses R1 first
                    2'b01: r0_tri = 1; // MAC R1 uses R0 first
                    2'b10: r0_tri = 1; // MAC R2 uses R0 first
                endcase
                a_en = 1;
            end

            4'b1011: begin
                // MAC_MUL:
                // Put the second non-Rx register on the bus.
                // ALU calculates other1 * other2 and stores it in G.
                case (current_rx)
                    2'b00: r2_tri = 1; // MAC R0 uses R2 second
                    2'b01: r2_tri = 1; // MAC R1 uses R2 second
                    2'b10: r1_tri = 1; // MAC R2 uses R1 second
                endcase

                alu_ctl = 4'b0010; // MUL
                g_en = 1;
                sr_en = 1;
            end

            4'b1100: begin
                // MAC_PRODUCT_TO_A:
                // Move product from G into A.
                if (!overflow_flag) begin
                    g_tri = 1;
                    a_en = 1;
                end
            end

            4'b1101: begin
                // MAC_ADD_RX:
                // Put Rx on the bus.
                // ALU calculates product + Rx and stores it in G.
                if (!overflow_flag) begin
                    case (current_rx)
                        2'b00: r0_tri = 1;
                        2'b01: r1_tri = 1;
                        2'b10: r2_tri = 1;
                    endcase

                    alu_ctl = 4'b0000; // ADD
                    g_en = 1;
                    sr_en = 1;
                end
            end

            4'b1110: begin
                // MAC_WRITE:
                // Write final MAC result back to Rx unless overflow occurred.
                if (!overflow_flag) begin
                    g_tri = 1;

                    case (current_rx)
                        2'b00: r0_en = 1;
                        2'b01: r1_en = 1;
                        2'b10: r2_en = 1;
                    endcase
                end
            end

            4'b1111: begin
                // HALT: no signals are enabled.
            end

        endcase
    end

endmodule
