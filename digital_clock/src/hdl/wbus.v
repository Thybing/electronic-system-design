`timescale 1ns/100ps

module wbus #(
  parameter  BASEADDR = 32'h0000_0000,
  parameter  BASEADDR_WIDTH = 8,
  parameter  SLAVEADDR_WIDTH = 32-BASEADDR_WIDTH
) (
  input                         dmem_wr,
  input                  [31:0] dmem_waddr,
  input                  [ 3:0] dmem_wstrb,
  input                  [31:0] dmem_wdata,

  output                        slave_wr,
  output  [SLAVEADDR_WIDTH-1:0] slave_waddr,
  output                 [ 3:0] slave_wstrb,
  output                 [31:0] slave_wdata
);

  localparam OFFADDR_WIDTH = 32-BASEADDR_WIDTH;

  wire [31:0] waddr_mask;
  wire sel;
  
  assign waddr_mask = { {BASEADDR_WIDTH{1'b1}}, {OFFADDR_WIDTH{1'b0}} };
  
  assign sel = ((dmem_waddr & waddr_mask) == BASEADDR);
  assign slave_wr = dmem_wr & sel;
  assign slave_waddr = dmem_waddr[SLAVEADDR_WIDTH-1:0];
  assign slave_wdata = dmem_wdata;
  assign slave_wstrb = dmem_wstrb;

endmodule

