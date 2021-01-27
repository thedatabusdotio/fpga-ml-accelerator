//`define FIXED_POINT 1
module mac_manual #(parameter N = 16,parameter Q = 12)(
    input clk,sclr,ce,
    input [N-1:0] a,
    input [N-1:0] b,
    input [N-1:0] c,
    output [N-1:0] p
    );
 
`ifdef FIXED_POINT
    wire [N-1:0] mult,add;
    reg [N-1:0] tmp;
    wire ovr;
    qmult #(N,Q) mul (
                .clk(clk),
                .rst(sclr),
                .a(a),
                .b(b),
                .q_result(mult),
                .overflow(ovr)
                );
    qadd #(N,Q) add1 (
                .a(mult),
                .b(c),
                .c(add)
                );
     
    always@(posedge clk,posedge sclr)
           begin
               if(sclr)
               begin
                   tmp <= 0;
               end
               else if(ce)
               begin
                   tmp <= add;
               end
           end
           assign p = tmp;
`else
    reg [N-1:0] temp;
    always@(posedge clk,posedge sclr)
    begin
        if(sclr)
        begin
            temp <= 0;
        end
        else if(ce)
        begin
            temp <= (a*b+c);
        end
    end
    assign p = temp;
 `endif 
endmodule