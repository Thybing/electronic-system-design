`timescale 1ns/100ps

// A port/B port: Write after Read
module segled #(
  parameter  ADDRESS_WIDTH = 5
) (
  input                          clk,
  input                          rstn,
  input                          wr,
  input   [(ADDRESS_WIDTH-1):0]  waddr,
  input                  [31:0]  wdata,

  output                 [ 7:0]  segled_pin
);

  localparam ADDR_DATA = 'd0;

  ////////  Write Logic ///////
  reg [7:0] segled_data;
  
  always @(posedge clk or negedge rstn)
  begin
  	if (~rstn)
  	  segled_data <= 'd0;
  	else if (wr & (waddr == ADDR_DATA))
  	  segled_data <= wdata[7:0];
  end

  assign segled_pin = segled_data;

endmodule