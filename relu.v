`timescale 1ns / 1ps
module relu(
    input [31:0] din_relu,
    output [31:0] dout_relu
    );
assign dout_relu = (din_relu[30] == 0)? din_relu : 0;
endmodule
