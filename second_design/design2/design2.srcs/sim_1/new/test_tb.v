`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/02 17:30:41
// Design Name: 
// Module Name: test_tb
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


module test_tb(
output[7:0] seg_led,
output buzzer,
output [2:0] tst_slave_sel
);

reg clk,rstn;


top obj(
   .clk(clk),
  .rstn(rstn),

  .switch_pin(4'b0001),
  .static_segled_pin(seg_led),
  .buzzer_pin(buzzer),
  .tst_slave_sel(tst_slave_sel)
);

initial begin
    clk = 1'b0;
    rstn = 1'b1;
    #10
    rstn = 1'b0;
    #10
    rstn = 1'b1;
end

always #2 clk = ~clk;



endmodule
