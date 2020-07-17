`timescale 1ns / 1ps

module input_mux(
    input [31:0] ip1,
    input [31:0] ip2,
    input [1:0] sel,
    output [31:0] op
    );
    assign op = (sel == 2'b01)?ip1:(sel == 2'b00)?ip2:32'h0;
endmodule
