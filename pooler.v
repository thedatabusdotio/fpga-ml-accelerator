`timescale 1ns / 1ps

module pooler(
    input clk,
    input ce,
    input master_rst,
    input [31:0] data_in,
    output [31:0] data_out,
    output valid_op,
    output end_op
    );

    wire rst_m,op_en,pause_ip,load_sr,global_rst;
    wire [1:0] sel;
    wire [31:0] comp_op;
    wire [31:0] Q;
    wire [31:0] reg_op;
    wire [31:0] mux_out;
    wire temp_rst;
    wire temp2;
    reg [31:0] temp;

    parameter m = 9'h00c;
    parameter p = 9'h003;
    
    assign temp_rst = master_rst;
    
    control_logic2 #(m,p) log(     
      clk,
      master_rst,
      ce,
      sel,
      rst_m,
      valid_op,
      load_sr,
      global_rst,
      end_op
      );
    
    comparator2 cmp(              
      data_in,
      mux_out,
      comp_op
      );
  
    max_reg m1(               
      clk,
      comp_op,
      rst_m,
      temp2,
      master_rst,
      reg_op
      );
variable_shift_reg #(.WIDTH(32),.SIZE((m/p))) SR (
         .d(comp_op),                 
         .clk(clk),                 
         .ce(load_sr),                 
         .rst(global_rst&&temp_rst),         
         .out(Q)             
         );

   input_mux mux(Q,reg_op,sel,mux_out);

   assign data_out = reg_op;
endmodule
