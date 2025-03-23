module mux2to1 (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic        sel,
    output logic [31:0] y
);

    assign y = sel ? b : a;

endmodule
