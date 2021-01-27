`timescale 1ns / 1ps
`define FIXED_POINT 1
module convolver #(
parameter n = 9'h00a,     // activation map size
parameter k = 9'h003,     // kernel size 
parameter s = 1,          // value of stride (horizontal and vertical stride are equal)
parameter N = 16,         //total bit width
parameter Q = 12          //number of fractional bits in case of fixed point representation.
)(
input clk,
input ce,
input global_rst,
input [N-1:0] activation,
input [(k*k)*16-1:0] weight1,
output[N-1:0] conv_op,
output valid_conv,
output end_conv
);

wire [N-1:0] weight [0:k*k-1];
wire [N-1:0] tmp [k*k+1:0];
wire conv_vld;
reg conv_vld_d1;

generate
	genvar l;
	for(l=0;l<k*k;l=l+1)
	begin
        assign weight [l][N-1:0] = weight1[N*l +: N]; 		
	end	
endgenerate

assign tmp[0] = 'd0;
generate
genvar i;
  for(i = 0;i<k*k;i=i+1)
  begin: MAC
    if((i+1)%k ==0)                      //end of the row
    begin
      if(i==k*k-1)                        //end of convolver
      begin
      mac_manual #(.N(N)) mac(                     //implements a*b+c
        .clk(clk),                        // input clk
        .ce(ce),                          // input ce
        .sclr(global_rst),                // input sclr
        .a(activation),                   // activation input [N-1 : 0] a
        .b(weight[i]),                    // weight input [N-1 : 0] b
        .c(tmp[i]),                       // previous mac sum input [N-1 : 0] c
        .p(conv_op)                       // output [N-1 : 0] p
        );
      end
      else
      begin
      wire [N-1:0] tmp2;
      //make a mac unit
      mac_manual #(.N(N))  mac(                   
        .clk(clk), 
        .ce(ce), 
        .sclr(global_rst), 
        .a(activation), 
        .b(weight[i]), 
        .c(tmp[i]), 
        .p(tmp2) 
        );
      
      variable_shift_reg #(.WIDTH(N),.SIZE(n-k)) SR (
          .d(tmp2),                  // input [32 : 0] d
          .clk(clk),                 // input clk
          .ce(ce),                   // input ce
          .rst(global_rst),          // input sclr
          .out(tmp[i+1])             // output [32 : 0] q
          );
      end
    end
    else
    begin
    mac_manual #(.N(N),.Q(Q))  mac2(                    
      .clk(clk), 
      .ce(ce),
      .sclr(global_rst),
      .a(activation),
      .b(weight[i]),
      .c(tmp[i]), 
      .p(tmp[i+1])
      );
    end 
  end 
endgenerate


reg [31:0] count,count2,count3,row_count;
reg en1,en2,en3;

always@(posedge clk) 
begin
  if(global_rst)
  begin
    count <=0;                      //master counter: counts the clock cycles
    count2<=0;                      //counts the valid convolution outputs
    count3<=0;                      // counts the number of invalid onvolutions where the kernel wraps around the next row of inputs.
    row_count <= 0;                 //counts the number of rows of the output.  
    en1<=0;
    en2<=1;
    en3<=0;
  end
  else if(ce)
  begin
    if(count == (k-1)*n+k-1)   // time taken for the pipeline to fill up is (k-1)*n+k-1
    begin
      en1 <= 1'b1;
      count <= count+1'b1;
    end
    else
    begin 
      count<= count+1'b1;
    end
  end
  if(en1 && en2) 
  begin
    if(count2 == n-k)
    begin
      count2 <= 0;
      en2 <= 0 ;
      row_count <= row_count + 1'b1;
    end
    else 
    begin
      count2 <= count2 + 1'b1;
    end
  end
  
  if(~en2) 
  begin
  if(count3 == k-2)
  begin
    count3<=0;
    en2 <= 1'b1;
  end
  else
    count3 <= count3 + 1'b1;
  end
  
  if((((count2 + 1) % s == 0) && (row_count % s == 0))||(count3 == k-2)&&(row_count % s == 0)||(count == (k-1)*n+k-1))
  begin                                                                                                                        //one in every s convolutions becomes valid
    en3 <= 1;                                                                                                                  //some exceptional cases handled for high when count2 = 0                
  end
  else 
    en3 <= 0;
end

assign conv_vld = (en1 && en2 && en3);
assign end_conv = (count>= n*n+2) ? 1'b1 : 1'b0;

always@(posedge clk or posedge global_rst)
begin
    if(global_rst)
        conv_vld_d1<= 0;
    else
        conv_vld_d1 <= conv_vld;
end

`ifdef FIXED_POINT
    assign valid_conv = conv_vld_d1;
`else 
    assign valid_conv = conv_vld;
`endif

endmodule