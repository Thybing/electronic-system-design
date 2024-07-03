`timescale 1ns/100ps


module top (
  input clk,
  input rstn,

  output [7:0] leds
);

  wire imem_rd;
  wire [31:0] imem_addr, imem_rdata;

  wire dmem_wr, dmem_rd;
  wire [31:0] dmem_waddr, dmem_wdata;
  wire [31:0] dmem_raddr, dmem_rdata;

  wire [11:0] instr_mem_addr;

  tiny_riscv1 u_cpu(
    .clk(clk),
    .rstn(rstn),

    // interface of instruction RAM
    .imem_rd(imem_rd),
    .imem_addr(imem_addr),
    .imem_rdata(imem_rdata),

    // interface of data RAM
    .dmem_wr(dmem_wr),
    .dmem_waddr(dmem_waddr),
    .dmem_wdata(dmem_wdata),

    .dmem_rd(dmem_rd),
    .dmem_raddr(dmem_raddr),
    .dmem_rdata(dmem_rdata)
  );

  rom #(
    .DATA_WIDTH(32),
    .ADDRESS_WIDTH(12),
    .FILE("blinking_led.txt")
  ) u_instr_mem (
    .clk(clk),
    .en(imem_rd),
    .addr(instr_mem_addr),
    .dout(imem_rdata)
  );

  assign instr_mem_addr = imem_addr[11:0];


  reg [7:0] reg_leds;
  always @(posedge clk or negedge rstn) 
  begin
    if (!rstn) 
      reg_leds <= 'd0;
    else if (dmem_wr && dmem_waddr == 32'h0100)
      reg_leds <= dmem_wdata;
  end

  assign leds = reg_leds;

  assign dmem_rdata = 'd0;

endmodule

