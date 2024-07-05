`timescale 1ns/100ps

module rbus #(
  parameter  BASEADDR = 32'h0000_0000,
  parameter  BASEADDR_WIDTH = 8,
  parameter  SLAVEADDR_WIDTH = 32-BASEADDR_WIDTH
) (
  input                         clk,
  input                         dmem_rd,
  input                  [31:0] dmem_raddr,
  output                 [31:0] dmem_rdata_mux_in,

  output                        slave_rd,
  output  [SLAVEADDR_WIDTH-1:0] slave_raddr,
  input                  [31:0] slave_rdata
);

  localparam OFFADDR_WIDTH = 32-BASEADDR_WIDTH;

  wire [31:0] raddr_mask;
  wire sel;
  
  assign raddr_mask = { {BASEADDR_WIDTH{1'b1}}, {OFFADDR_WIDTH{1'b0}} };
  
  assign sel = ((dmem_raddr & raddr_mask) == BASEADDR);
  assign slave_rd = dmem_rd & sel;
  assign slave_raddr = dmem_raddr[SLAVEADDR_WIDTH-1:0];


  assign dmem_rdata_mux_in = slave_rdata;



endmodule
