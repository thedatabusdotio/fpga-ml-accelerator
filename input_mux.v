`timescale 1ns / 1ps

module input_mux #(parameter N = 16)(
    input [N-1:0] ip1,
    input [N-1:0] ip2,
    input [1:0] sel,
    output [N-1:0] op
    );
    assign op = (sel == 2'b01) ? ip1 : ((sel == 2'b00) ? ip2: 0);
endmodule
