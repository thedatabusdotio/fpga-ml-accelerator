`timescale 1ns / 1ps
`define FIXED_POINT 1
module accelerator_tb;

	// Inputs
	reg clk;
	reg ce;
	reg [143:0] weight1;
	reg global_rst;
	reg [15:0] activation;

	// Outputs
	wire [15:0] acc_op,conv_out;
	wire conv_valid,conv_end;
	wire end_op;
	wire valid_op;
	integer i;
    parameter clkp = 20;
    integer ip_file,r3,op_file;
	// Instantiate the Unit Under Test (UUT)
	acclerator #(.n('d6),.p('d2),.k('d3),.N('d16),.Q('d12),.ptype('d0),.s('d1),.psqr_inv(16'b0000010000000000)) uut (
		.clk(clk), 
		.ce(ce), 
		.weight1(weight1), 
		.global_rst(global_rst), 
		.activation(activation), 
		.data_out(acc_op), 
		.valid_op(valid_op), 
		.end_op(end_op),
		.conv_out(conv_out),
		.conv_valid(conv_valid),
		.conv_end(conv_end)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		ce = 0;
		weight1 = 0;
		global_rst = 0;
		activation = 0;

		// Wait 100 ns for global reset to finish
		#100;
		
        clk = 0;
		ce = 0;
		weight1 = 0;
		activation = 0;
        global_rst =1;
        #60;
        global_rst =0;	
        //#10;	
		ce=1;
		ip_file = $fopen("activations.txt","r");
		op_file = $fopen("acc_out.txt","a");
		`ifdef FIXED_POINT
		weight1 = 144'b1111100110010111_0000001111010001_1111011010001101_1111101010010011_1111110101110100_1111110111101111_0000000110010110_1111000011010101_1111110111110100;
		`else
        weight1 = 144'h0008_0007_0006_0005_0004_0003_0002_0001_0000;
		`endif
		// Initialize Inputs
		for(i=0;i<36;i=i+1) begin
		`ifdef FIXED_POINT
		r3 = $fscanf(ip_file,"%b\n",activation);
    	`else
		activation = i;
		`endif
		#clkp; 
		end
	end 
      always #(clkp/2) clk = ~clk;  
      
      always@(posedge clk) begin
        if(valid_op & !end_op) begin 
            $fdisplay(op_file,"%b",acc_op); 
        end
        if(conv_end) begin
        if(ce)
        begin
        $fdisplay(op_file,"%s%0d","end",0);
        $finish;
        end
      end
    end    
endmodule