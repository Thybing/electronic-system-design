`timescale 1ns/100ps


module top_tb ();

  reg clk;
  reg rstn;

  always #10 clk  = ~clk;
  // Reset
  initial begin
    clk = 0;
    rstn = 0;
    #500 rstn = 1;
  end


  top u_top(
    .clk(clk),
    .rstn(rstn),

    .leds()
  );

  wire [31:0] x1, x2, x3, x4;
  assign x1 = u_top.u_cpu.regs[1];
  assign x2 = u_top.u_cpu.regs[2];
  assign x3 = u_top.u_cpu.regs[3];
  assign x4 = u_top.u_cpu.regs[4];  

//  initial begin
//    $fsdbDumpfile("sim.fsdb");
//    $fsdbDumpvars;
//    forever #20000 $fsdbDumpflush;   // flush fsdb file per 20us
//  end

endmodule