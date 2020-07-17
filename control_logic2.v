`timescale 1ns / 1ps


control_logic2(
    input clk,
    input master_rst,
    input ce,
    output reg [1:0] sel,
    output reg rst_m,
    output reg op_en,
    output reg load_sr,
    output reg global_rst,
    output reg end_op
    );

    parameter m = 9'h01a;
    parameter p = 9'h002;
    integer row_count =0;
    integer col_count =0;
    integer count =0;
    integer nbgh_row_count;

    always@(posedge clk) begin 
        if(master_rst) begin
        sel <=0;
        load_sr <=0;
        rst_m <=0;
        op_en <=0;
        global_rst <=0;
        end_op <=0;
        end
        else begin
        if(((col_count+1)%p !=0)&&(row_count == p-1)&&(col_count == p*count+ (p-2))&&ce)   
        begin     
        op_en <=1;
        end 
        else begin
        op_en <=0;
        end
            if(ce) 
            begin
                if(nbgh_row_count == m/p)    
                        begin     
                    end_op <=1;
                end
                else 
                begin
                    end_op <=0;
                end

                if(((col_count+1) % p != 0)&&(col_count == m-2)&&(row_count == p-1)) 
                        begin   
                    global_rst <= 1;                           
                            end
                else 
                begin
                    global_rst <= 0;
                end  
                
                

                
                         if((((col_count+1) % p == 0)&&(count != m/p-1)&&(row_count != p-1))||((col_count == m-1)&&(row_count == p-1)))     
                        begin    
                  rst_m <= 1;              
                end  
                else 
                begin
                    rst_m <= 0;
                end   
                
                if(((col_count+1) % p != 0)&&(col_count == m-2)&&(row_count == p-1)) 
                begin
                    sel <= 2'b10;
                end
                else 
                begin
                    if((((col_count) % p == 0)&&(count == m/p-1)&&(row_count != p-1))|| (((col_count) % p == 0)&&(count != m/p-1)&&(row_count == p-1))) begin     
                                    sel<=2'b01;
                    end 
                    else 
                    begin
                        sel <= 2'b00;
                    end
                end

                if((((col_count+1) % p == 0)&&((count == m/p-1)))||((col_count+1) % p == 0)&&((count != m/p-1))) 
                        begin     
                    load_sr <= 1;                                 
                            end 
                else 
                begin
                    load_sr <= 0;
                end
            end
        end 
    end 

    always@(posedge clk) begin            
    if(master_rst) begin
            row_count <=0;
            col_count <=32'hffffffff;
            count <=32'hffffffff;
            nbgh_row_count <=0;
        end
        else 
        begin
            if(ce) 
            begin
                if(global_rst)
                begin
                   row_count <=0;
                   col_count <=32'h0;
                              count <=32'h0;
                              nbgh_row_count <= nbgh_row_count + 1'b1; 
                end
                else
                begin
                    if(((col_count+1) % p == 0)&&(count == m/p-1)&&(row_count != p-1)) 
                                begin
                        col_count <= 0;
                        row_count <= row_count + 1'b1;
                        count <=0;
                    end
                    else 
                    begin
                        col_count<=col_count+1'b1;
                        if(((col_count+1) % p == 0)&&(count != m/p-1)) 
                        begin
                            count <= count+ 1'b1;
                        end 
                    end
                end
            end
        end  
    end 
    endmodule
