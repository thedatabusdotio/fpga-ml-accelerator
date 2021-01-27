`timescale 1ns / 1ps
module qadd #(
	parameter N = 16,
	parameter Q = 12
	)
	(
    input [N-1:0] a,
    input [N-1:0] b,
    output [N-1:0] c
    );

// (Q,N) = (12,16) => 1 sign-bit + 3 integer-bits + 12 fractional-bits = 16 total-bits
//                    |S|III|FFFFFFFFFFFF|
// The same thing in A(I,F) format would be A(3,12)

//Since we supply every negative number in it's 2's complement form by default, all we 
//need to do is add these two numbers together (note that to subtract a binary number 
//is the same as to add its two's complement)
assign c = a + b;

//If for whatever reason your system (the software/testbench feeding this hadrware with 
//inputs) does not supply negative numbers in their two's complement form,(some people 
//prefer to keep the magnitude as it is and make the sign bit '1' to represent negatives)
// then you should take a look at the fixed point arithmetic modules at opencores linked 
//above this code.

endmodule
