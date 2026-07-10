// Tri-state buffer used to connect one source to the shared bus.
// When tri_en = 1, data_in drives the bus.
// When tri_en = 0, the output disconnects from the bus.

module tri_buffer(data_in, tri_en, bus);

    input [15:0] data_in;
    input tri_en;

    output [15:0] bus;

    assign bus = (tri_en) ? data_in : 16'bz;

endmodule
