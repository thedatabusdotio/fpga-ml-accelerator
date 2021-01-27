`timescale 1ns / 1ps
// (Q,N) = (12,16) => 1 sign-bit + 3 integer-bits + 12 fractional-bits = 16 total-bits
//                    |S|III|FFFFFFFFFFFF|
// The same thing in A(I,F) format would be A(3,12)
module qmult #(
	//Parameterized values
	parameter N = 16,
	parameter Q = 12
	)
	(
	 input                  clk,
	 input                  rst,
	 input			[N-1:0]	a,
	 input			[N-1:0]	b,
	 output         [N-1:0] q_result,    //output quantized to same number of bits as the input
     output			overflow             //signal to indicate output greater than the range of our format
	 );
	 
	 //	The underlying assumption, here, is that both fixed-point values are of the same length (N,Q)
	 //	Because of this, the results will be of length N+N = 2N bits
	 //	This also simplifies the hand-back of results, as the binimal point 
	 //	will always be in the same location
	
	wire [2*N-1:0]	f_result;		//	Multiplication by 2 values of N bits requires a 
									//	register that is N+N = 2N deep
	wire [N-1:0]   multiplicand;
	wire [N-1:0]	multiplier;
	wire [N-1:0]    a_2cmp, b_2cmp;
	wire [N-2:0]    quantized_result,quantized_result_2cmp;
	
	assign a_2cmp = {~a[N-1],~a[N-2:0]+ 1'b1};  //2's complement of a {(N-1){1'b1}} - 
	assign b_2cmp = {~b[N-1],~b[N-2:0]+ 1'b1};  //2's complement of b  {(N-1){1'b1}} - 
	
    assign multiplicand = (a[N-1]) ? a_2cmp : a;              
    assign multiplier   = (b[N-1]) ? b_2cmp : b;
    
 //   always @(posedge clk)                                     //pipelining a bit in order to prevent too much combo delay
 //   begin
 //   if(rst)
 //       f_result <= 0;
 //   else
     assign f_result = multiplicand[N-2:0] * multiplier[N-2:0];  //We remove the sign bit for multiplication
//    end
    
    assign q_result[N-1] = a[N-1]^b[N-1];                     //Sign bit of output would be XOR or input sign bits
    assign quantized_result = f_result[N-2+Q:Q];              //Quantization of output to required number of bits
    assign quantized_result_2cmp = ~quantized_result[N-2:0] + 1'b1;  //2's complement of quantized_result  {(N-1){1'b1}} - 
    assign q_result[N-2:0] = (a[N-1]^b[N-1]) ? quantized_result_2cmp : quantized_result; //If the result is negative, we return a 2's complement representation 
    																					 //of the output value
    assign overflow = (f_result[2*N-2:N-1+Q] > 0) ? 1'b1 : 1'b0;

endmodule