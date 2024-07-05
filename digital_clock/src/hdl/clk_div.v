`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/03 22:42:30
// Design Name: 
// Module Name: clk_div
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module clk_div 
#(
    parameter   cnt_width   =   4,
    parameter   div_cnt     =   16
)
(
    input   clk     ,
            rst_n   ,
    output  clk_o
);
    reg [cnt_width-1:0]     cnt;
    reg                     clk_o_reg;

    assign clk_o = clk_o_reg;

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cnt         <=  'h0;
            clk_o_reg   <=  'h0;
        end
        else begin
            if(cnt >= div_cnt - 1) begin
                cnt         <=  'h0         ;
                clk_o_reg   <=  ~clk_o_reg  ;
            end 
            else begin
                cnt     <=  cnt + 1;
            end
        end
    end

endmodule