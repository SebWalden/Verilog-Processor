// Top-level full 16-bit processor.
// Only clk and reset are inputs. The program is stored in instruction_memory.

module simple_processor(
    clk,
    reset,

    r0_value,
    r1_value,
    r2_value,

    pc_value,
    current_instruction_number,
    return_address_value,
    sp_value,
    instruction_value,
    bus_value,
    a_value,
    g_value,

    zero_flag,
    overflow_flag,
    carry_flag,
    state_value,

    data_mem_16
);

    input clk;
    input reset;

    output [15:0] r0_value;
    output [15:0] r1_value;
    output [15:0] r2_value;

    output [7:0] pc_value;
    output [7:0] current_instruction_number;
    output [7:0] return_address_value;
    output [7:0] sp_value;
    output [15:0] instruction_value;
    output [15:0] bus_value;
    output [15:0] a_value;
    output [15:0] g_value;

    output zero_flag;
    output overflow_flag;
    output carry_flag;
    output [3:0] state_value;

    output [15:0] data_mem_16;

    reg [7:0] current_instruction_number_reg;

    wire [15:0] bus;

    wire [15:0] instruction_from_memory;
    wire [15:0] instruction_reg_value;

    wire [3:0] opcode;
    wire [1:0] rx;
    wire [1:0] ry;
    wire [7:0] imm;

    wire pc_en;
    wire pc_load;
    wire pc_ret;
    wire ir_en;
    wire return_en;
    reg [7:0] return_address;
    wire [7:0] pc_input;

    wire r0_en;
    wire r1_en;
    wire r2_en;

    wire r0_tri;
    wire r1_tri;
    wire r2_tri;

    wire imm_tri;
    wire mem_tri;

    wire a_en;
    wire g_en;
    wire sr_en;
    wire g_tri;

    wire mem_en;
    wire mem_we;

    wire stack_addr;
    wire stack_pop;
    wire sp_en;
    wire sp_inc;
    reg [7:0] sp_reg;
    wire [7:0] mem_address;

    wire [3:0] alu_ctl;
    wire [15:0] alu_result;
    wire [15:0] imm_value;
    wire [15:0] mem_data_out;

    assign bus_value = bus;
    assign instruction_value = instruction_reg_value;
    assign current_instruction_number = current_instruction_number_reg;
    assign return_address_value = return_address;
    assign sp_value = sp_reg;
    assign imm_value = {8'b0, imm};
    assign pc_input = (pc_ret) ? return_address : imm;
    assign mem_address = (stack_addr) ? ((stack_pop) ? (sp_reg + 8'b1) : sp_reg) : imm;

    pc_register pc(
        .clk(clk),
        .reset(reset),
        .pc_en(pc_en),
        .pc_load(pc_load),
        .pc_in(pc_input),
        .pc_out(pc_value)
    );

    instruction_memory imem(
        .address(pc_value),
        .instruction(instruction_from_memory)
    );

    register16 instruction_reg(
        .clk(clk),
        .reset(reset),
        .en(ir_en),
        .data_in(instruction_from_memory),
        .data_out(instruction_reg_value)
    );

    // Stores the instruction memory address currently being executed.
    // This makes jumps easy to track in the waveform.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_instruction_number_reg <= 8'b0;
        end
        else if (ir_en) begin
            current_instruction_number_reg <= pc_value;
        end
    end

    // Stores the address to return to after CALL.
    // During CALL, pc_value already points to the next instruction after CALL.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            return_address <= 8'b0;
        end
        else if (return_en) begin
            return_address <= pc_value;
        end
    end

    // Stack pointer.
    // The stack starts at address 255 and grows downward.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sp_reg <= 8'hFF;
        end
        else if (sp_en) begin
            if (sp_inc) begin
                sp_reg <= sp_reg + 8'b1;
            end
            else begin
                sp_reg <= sp_reg - 8'b1;
            end
        end
    end

    instruction_decoder decoder(
        .instruction(instruction_reg_value),
        .opcode(opcode),
        .rx(rx),
        .ry(ry),
        .imm(imm)
    );

    controller control(
        .clk(clk),
        .reset(reset),

        .opcode(opcode),
        .rx(rx),
        .ry(ry),
        .imm(imm),

        .zero_flag(zero_flag),
        .overflow_flag(overflow_flag),

        .pc_en(pc_en),
        .pc_load(pc_load),
        .pc_ret(pc_ret),
        .ir_en(ir_en),
        .return_en(return_en),

        .r0_en(r0_en),
        .r1_en(r1_en),
        .r2_en(r2_en),

        .r0_tri(r0_tri),
        .r1_tri(r1_tri),
        .r2_tri(r2_tri),

        .imm_tri(imm_tri),
        .mem_tri(mem_tri),

        .a_en(a_en),
        .g_en(g_en),
        .sr_en(sr_en),
        .g_tri(g_tri),

        .mem_en(mem_en),
        .mem_we(mem_we),

        .stack_addr(stack_addr),
        .stack_pop(stack_pop),
        .sp_en(sp_en),
        .sp_inc(sp_inc),

        .alu_ctl(alu_ctl),
        .state(state_value)
    );

    register16 r0(
        .clk(clk),
        .reset(reset),
        .en(r0_en),
        .data_in(bus),
        .data_out(r0_value)
    );

    tri_buffer r0_out(
        .data_in(r0_value),
        .tri_en(r0_tri),
        .bus(bus)
    );

    register16 r1(
        .clk(clk),
        .reset(reset),
        .en(r1_en),
        .data_in(bus),
        .data_out(r1_value)
    );

    tri_buffer r1_out(
        .data_in(r1_value),
        .tri_en(r1_tri),
        .bus(bus)
    );

    register16 r2(
        .clk(clk),
        .reset(reset),
        .en(r2_en),
        .data_in(bus),
        .data_out(r2_value)
    );

    tri_buffer r2_out(
        .data_in(r2_value),
        .tri_en(r2_tri),
        .bus(bus)
    );

    tri_buffer imm_out(
        .data_in(imm_value),
        .tri_en(imm_tri),
        .bus(bus)
    );

    register16 a_reg(
        .clk(clk),
        .reset(reset),
        .en(a_en),
        .data_in(bus),
        .data_out(a_value)
    );

    alu alu_unit(
        .a(a_value),
        .b(bus),
        .alu_ctl(alu_ctl),
        .result(alu_result)
    );

    register16 g_reg(
        .clk(clk),
        .reset(reset),
        .en(g_en),
        .data_in(alu_result),
        .data_out(g_value)
    );

    status_register sr(
        .clk(clk),
        .reset(reset),
        .sr_en(sr_en),
        .result(alu_result),
        .a_value(a_value),
        .b_value(bus),
        .alu_ctl(alu_ctl),
        .zero_flag(zero_flag),
        .overflow_flag(overflow_flag),
        .carry_flag(carry_flag)
    );

    tri_buffer g_out(
        .data_in(g_value),
        .tri_en(g_tri),
        .bus(bus)
    );

    data_memory dmem(
        .clk(clk),
        .reset(reset),
        .mem_en(mem_en),
        .mem_we(mem_we),
        .address(mem_address),
        .data_in(bus),
        .data_out(mem_data_out)
    );

    tri_buffer mem_out(
        .data_in(mem_data_out),
        .tri_en(mem_tri),
        .bus(bus)
    );

    assign data_mem_16 = mem_data_out;

endmodule
