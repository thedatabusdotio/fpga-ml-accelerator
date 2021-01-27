`timescale 1ns / 1ps

module comparator2 #(
    parameter N = 16,
    parameter Q = 12,
    parameter ptype = 1
    )(
    input ce,
    input [N-1:0] ip1,
    input [N-1:0] ip2,
    output [N-1:0] comp_op
    );
    
    wire [N-1:0] ip1_2cmp, ip2_2cmp;  //two's complemented versions of the input values
    reg [N-1:0] temp;
    
    
    assign ip1_2cmp = {~ip1[N-1],~ip1[N-2:0] + 1'b1};
    assign ip2_2cmp = {~ip2[N-1],~ip2[N-2:0] + 1'b1};
    assign comp_op = ce ? temp : 'd0;
    //assign comp_op = ptype ? (ip1 + ip2) : ((ip1>ip2) ? ip1:ip2);
    always@(*)
    begin
        if(ptype == 0)
        begin
            temp = ip1 + ip2;        //when in the average pooling mode, the comparator doubles up as the adder
        end
        else
        begin
            if( (ip1[N-1] == 0) & (ip2[N-1] == 0) )
            begin
                temp = (ip1>ip2) ? ip1:ip2;
            end
            else if ( (ip1[N-1] == 1) & (ip2[N-1] == 1) )
            begin
                temp = (ip1_2cmp > ip2_2cmp) ? ip2 : ip1;   //higher the magnitude of a -ve no. lower its value
            end
            else if ( (ip1[N-1] == 1) & (ip2[N-1] == 0) )
            begin
                temp = ip2;
            end            
            else if ( (ip1[N-1] == 0) & (ip2[N-1] == 1) )
            begin
                temp = ip1;
            end
        end
    end
endmodule