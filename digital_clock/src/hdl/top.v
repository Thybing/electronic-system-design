`timescale 1ns/100ps

module top (
    input clk,
    input rstn,

    output tx_pin,
    input  rx_pin,
    
    output [3:0]    seg_cs_pin      ,
    output [7:0]    seg_scan_pin    ,
                    seg_static_pin  ,
    output        buzzer_pin 
);

  localparam    BASEADDR_WIDTH    =  8;

  localparam    BASEADDR_IRAM     =  32'h0000_0000;   // should not be change!
  localparam    BASEADDR_DRAM     =  32'h0100_0000;
  localparam    BASEADDR_UART     =  32'h0200_0000;
  localparam    BASEADDR_SEG      =  32'h0300_0000;

  localparam    ADDRWIDTH_IRAM    =   14;  // Instr MEM: 2^14 = 16KB
  localparam    ADDRWIDTH_DRAM    =   14;  // Data MEM: 2^14 = 16KB
  localparam    ADDRWIDTH_UART    =   8;   // UART MAP RANGE: 2^8 = 256Bytes
  localparam    ADDRWIDTH_SEG     =   4;   // Segment LEDs MAP RANGE: 2^8 = 256Bytes

  // interface of CPU instruction RAM
  wire         imem_rd;
  wire [31:0]  imem_addr;
  wire  [31:0] imem_rdata;

  // interface of CPU DATA BUS
  wire         dmem_wr;
  wire [31:0]  dmem_waddr;
  wire [31:0]  dmem_wdata;
  wire [ 3:0]  dmem_wstrb;

  wire         dmem_rd;
  wire [31:0]  dmem_raddr;
  wire [31:0]  dmem_rdata;

  // internal wire
  wire instr_rd, iram_rd;
  wire [ADDRWIDTH_IRAM-1:0] instr_raddr, iram_raddr;
  wire [31:0] instr_rdata, iram_rdata;

  wire dram_wr, dram_rd;
  wire [ADDRWIDTH_DRAM-1:0] dram_raddr, dram_waddr;
  wire [31:0] dram_rdata, dram_wdata;
  wire [3:0] dram_wstrb;

  wire uart_wr, uart_rd;
  wire [ADDRWIDTH_UART-1:0] uart_raddr, uart_waddr;
  wire [31:0] uart_rdata, uart_wdata;

  wire seg_wr, seg_rd;
  wire [ADDRWIDTH_SEG-1:0] seg_waddr,seg_raddr;
  wire [31:0] seg_wdata,seg_rdata;

//  wire buzzer_rd,buzzer_wr;
//  wire [ADDRWIDTH_BUZZER-1:0] buzzer_raddr,buzzer_waddr;
//  wire [31:0] buzzer_rdata,buzzer_wdata;

  ///////////////  Risc-v Processor ///////////////
  riscv #(
    .RV32M(0)
  ) u_riscv (
      .clk (clk),
      .rstn(rstn),

      .stall    (1'b0),
      .exception(),
      .timer_en (),

      .timer_irq(1'b0),
      .sw_irq   (1'b0),
      .interrupt(1'b0),

      .imem_rd(imem_rd),
      .imem_addr (imem_addr),
      .imem_rdata(imem_rdata),

      .dmem_wr(dmem_wr),
      .dmem_waddr (dmem_waddr),
      .dmem_wdata (dmem_wdata),
      .dmem_wstrb (dmem_wstrb),

      .dmem_rd(dmem_rd),
      .dmem_raddr (dmem_raddr),
      .dmem_rdata (dmem_rdata)
  );

  ///////////////  Risc-v Instr MEM  ///////////////
  ram2port #(
      .ADDRESS_WIDTH(ADDRWIDTH_IRAM), 
      .FILE("seg_show_test.txt") 
  ) u_iram (
      .clk(clk),
      .addra(instr_raddr),
      .rena(instr_rd),
      .douta(instr_rdata),
      .wena(1'b0),
      .wstrba(4'b0000),
      .dina(32'h0),

      .addrb(iram_raddr),
      .renb(iram_rd),
      .doutb(iram_rdata)
  );

  assign instr_raddr = imem_addr[ADDRWIDTH_IRAM-1:0];
  assign instr_rd = imem_rd;
  assign imem_rdata = instr_rdata;

  /////////////// Risc-v DATA MEM ///////////////
  ram2port #(
      .ADDRESS_WIDTH(ADDRWIDTH_DRAM), 
      .FILE("") 
  ) u_dram (
      .clk(clk),

      .addra(dram_waddr),
      .rena(1'b0),
      .douta(),
      .wena(dram_wr),
      .wstrba(dram_wstrb),
      .dina(dram_wdata),

      .addrb(dram_raddr),
      .renb(dram_rd),
      .doutb(dram_rdata)
  );

  ///////////////       UART       ///////////////
  uart u_uart(
      .clk(clk), 
      .rstn(rstn), 

      .i_we(uart_wr), 
      .i_waddr(uart_waddr), 
      .i_wdata(uart_wdata), 

      .i_raddr(uart_raddr),
      .o_rdata(uart_rdata), 

      .tx_pin(tx_pin), 
      .rx_pin(rx_pin)
  );

  //////////////   Segment LEDs   ////////////////
  seg_show #(
    .ADDRWIDTH(ADDRWIDTH_SEG)
  ) u_seg_show (
      .clk(clk), 
      .rst_n(rstn), 

      .wr(seg_wr),
      .waddr(seg_waddr),
      .wdata(seg_wdata),

      .rd(seg_rd),
      .raddr(seg_raddr),
      .rdata(seg_rdata),

      .scan_cs(seg_cs_pin),
      .scan_out(seg_scan_pin),
      .static_out(seg_static_pin)
  );

//   /////////////  Buzzer //////////////
//   buzzer #(
//       .ADDRWIDTH(ADDRWIDTH_BUZZER)
//   )
//   u_buzzer(
//       .clk      (clk)     ,
//       .rst_n    (rstn)   ,
      
//       // interface to CPU
//       .wr       (buzzer_wr)      ,
//       .waddr    (buzzer_waddr)   ,
//       .wdata    (buzzer_wdata)   ,
      
//       .rd       (buzzer_rd)      ,
//       .raddr    (buzzer_raddr)   ,
//       .rdata    (buzzer_rdata)   , 

//       // pin 
//       .buzzer_pin(buzzer_pin)
//   );


  ///////////////  Data BUS interconnect  ///////////////
  
  // (1) IRAM Read only
  wire [31:0] iram_rdata_mux_in;

  rbus #(
      .BASEADDR(BASEADDR_IRAM),
      .BASEADDR_WIDTH(BASEADDR_WIDTH),
      .SLAVEADDR_WIDTH(ADDRWIDTH_IRAM) 
  ) u_rbus_iram (
      .clk(clk),
      .dmem_rd(dmem_rd),
      .dmem_raddr(dmem_raddr),
      .dmem_rdata_mux_in(iram_rdata_mux_in),

      .slave_rd(iram_rd),
      .slave_raddr(iram_raddr),
      .slave_rdata(iram_rdata)
  );
  
  // (2) DRAM Write/Read
  wire [31:0] dram_rdata_mux_in;

  rbus #(
      .BASEADDR(BASEADDR_DRAM),
      .BASEADDR_WIDTH(BASEADDR_WIDTH),
      .SLAVEADDR_WIDTH(ADDRWIDTH_DRAM) 
  ) u_rbus_dram (
      .clk(clk),
      .dmem_rd(dmem_rd),
      .dmem_raddr(dmem_raddr),
      .dmem_rdata_mux_in(dram_rdata_mux_in),

      .slave_rd(dram_rd),
      .slave_raddr(dram_raddr),
      .slave_rdata(dram_rdata)
  );

  wbus #(
      .BASEADDR(BASEADDR_DRAM),
      .BASEADDR_WIDTH(BASEADDR_WIDTH),
      .SLAVEADDR_WIDTH(ADDRWIDTH_DRAM) 
  ) u_wbus_dram (
      .dmem_wr(dmem_wr),
      .dmem_waddr(dmem_waddr),
      .dmem_wstrb(dmem_wstrb),
      .dmem_wdata(dmem_wdata),

      .slave_wr(dram_wr),
      .slave_waddr(dram_waddr),
      .slave_wstrb(dram_wstrb),
      .slave_wdata(dram_wdata)
  );

  // (3) UART Write/Read
  wire [31:0] uart_rdata_mux_in;

  rbus #(
      .BASEADDR(BASEADDR_UART),
      .BASEADDR_WIDTH(BASEADDR_WIDTH),
      .SLAVEADDR_WIDTH(ADDRWIDTH_UART) 
  ) u_rbus_uart (
      .clk(clk),
      .dmem_rd(dmem_rd),
      .dmem_raddr(dmem_raddr),
      .dmem_rdata_mux_in(uart_rdata_mux_in),

      .slave_rd(uart_rd),
      .slave_raddr(uart_raddr),
      .slave_rdata(uart_rdata)
  );

  wbus #(
      .BASEADDR(BASEADDR_UART),
      .BASEADDR_WIDTH(BASEADDR_WIDTH),
      .SLAVEADDR_WIDTH(ADDRWIDTH_UART) 
  ) u_wbus_uart (
      .dmem_wr(dmem_wr),
      .dmem_waddr(dmem_waddr),
      .dmem_wstrb(dmem_wstrb),
      .dmem_wdata(dmem_wdata),

      .slave_wr(uart_wr),
      .slave_waddr(uart_waddr),
      .slave_wstrb(),
      .slave_wdata(uart_wdata)
  );

  // (4) SEGLED Write 
  wire [31:0] seg_rdata_mux_in;

  rbus #(
      .BASEADDR(BASEADDR_SEG),
      .BASEADDR_WIDTH(BASEADDR_WIDTH),
      .SLAVEADDR_WIDTH(ADDRWIDTH_SEG) 
  ) u_rbus_seg_show (
      .clk(clk),
      .dmem_rd(dmem_rd),
      .dmem_raddr(dmem_raddr),
      .dmem_rdata_mux_in(seg_rdata_mux_in),

      .slave_rd(seg_rd),
      .slave_raddr(seg_raddr),
      .slave_rdata(seg_rdata)
  );

  wbus #(
      .BASEADDR(BASEADDR_SEG),
      .BASEADDR_WIDTH(BASEADDR_WIDTH),
      .SLAVEADDR_WIDTH(ADDRWIDTH_SEG) 
  ) u_wbus_seg_show (
      .dmem_wr(dmem_wr),
      .dmem_waddr(dmem_waddr),
      .dmem_wstrb(dmem_wstrb),
      .dmem_wdata(dmem_wdata),

      .slave_wr(seg_wr),
      .slave_waddr(seg_waddr),
      .slave_wstrb(),
      .slave_wdata(seg_wdata)
  );
  
//   // (5) Buzzer Read/Write
//   wire [31:0] buzzer_rdata_mux_in;

//   rbus #(
//       .BASEADDR(BASEADDR_BUZZER),
//       .BASEADDR_WIDTH(BASEADDR_WIDTH),
//       .SLAVEADDR_WIDTH(ADDRWIDTH_BUZZER) 
//   ) u_rbus_buzzer (
//       .clk(clk),
//       .dmem_rd(dmem_rd),
//       .dmem_raddr(dmem_raddr),
//       .dmem_rdata_mux_in(buzzer_rdata_mux_in),

//       .slave_rd(buzzer_rd),
//       .slave_raddr(buzzer_raddr),
//       .slave_rdata(buzzer_rdata)
//   );

//   wbus #(
//       .BASEADDR(BASEADDR_BUZZER),
//       .BASEADDR_WIDTH(BASEADDR_WIDTH),
//       .SLAVEADDR_WIDTH(ADDRWIDTH_BUZZER)
//   ) u_wbus_buzzer(
//       .dmem_wr(dmem_wr),
//       .dmem_waddr(dmem_waddr),
//       .dmem_wstrb(dmem_wstrb),
//       .dmem_wdata(dmem_wdata),

//       .slave_wr(buzzer_wr),
//       .slave_waddr(buzzer_waddr),
//       .slave_wstrb(),
//       .slave_wdata(buzzer_wdata)
//   );

  // Read Channel MUX
  reg [31:0] bus_rdata_mux;
  reg [3:0] slave_sel;

  always @(posedge clk or negedge rstn) 
  begin
    if (~rstn) 
      slave_sel <= 'b0000;
    else
      slave_sel <= {iram_rd, dram_rd, uart_rd,seg_rd};
  end

  always @*
  begin
    case (slave_sel)
      4'b1000:  bus_rdata_mux = iram_rdata_mux_in;
      4'b0100:  bus_rdata_mux = dram_rdata_mux_in;
      4'b0010:  bus_rdata_mux = uart_rdata_mux_in;
      4'b0001:  bus_rdata_mux = seg_rdata_mux_in ;
      default: bus_rdata_mux = 'h0;
    endcase
  end
  
  assign dmem_rdata =  bus_rdata_mux;

endmodule

