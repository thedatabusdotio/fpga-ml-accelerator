`timescale 1ns / 1ps

module comparator2(
    input [31:0] ip1,
    input [31:0] ip2,
    output [31:0] comp_op);
    
    assign comp_op = (ip1>ip2) ? ip1:ip2;
endmodule