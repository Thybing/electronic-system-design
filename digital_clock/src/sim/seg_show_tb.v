`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/05 23:04:35
// Design Name: 
// Module Name: seg_show_tb
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


module seg_show_tb(

    );
    reg clk,rst_n;
    top u_top(
        .clk(clk),
        .rstn(rst_n),
        .rx_pin(1'b0)
    );

    initial begin
        clk = 'h0;
        rst_n = 'h1;
        #5
        rst_n = 'h0;
        #5
        rst_n = 'h1;
    end
    always#5 clk = ~clk;
endmodule
