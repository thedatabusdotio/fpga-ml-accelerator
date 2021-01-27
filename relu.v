`timescale 1ns / 1ps

module relu #(parameter N = 16)(
    input [N-1:0] din_relu,
    output [N-1:0] dout_relu
    );
assign dout_relu = (din_relu[N-1] == 0)? din_relu : 0;

endmodule
