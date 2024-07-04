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

    .tx_pin(),
    .rx_pin(1'b1)
  );


//  initial begin
//    $fsdbDumpfile("sim.fsdb");
//    $fsdbDumpvars;
//    forever #20000 $fsdbDumpflush;   // flush fsdb file per 20us
//  end

endmodule