`timescale 1ns/100ps

module top (
    input clk,
    input rstn,

    output tx_pin,
    input  rx_pin,
    
    output [7:0] segled_pin
);

  localparam    BASEADDR_WIDTH    =  8;

  localparam    BASEADDR_IRAM     =  32'h0000_0000;   // should not be change!
  localparam    BASEADDR_DRAM     =  32'h0100_0000;
  localparam    BASEADDR_UART     =  32'h0200_0000;
  localparam    BASEADDR_SEGLED   =  32'h0300_0000;
  localparam    BASEADDR_BUZZER   =  32'h0400_0000;

  localparam    ADDRWIDTH_IRAM    =   14;  // Instr MEM: 2^14 = 16KB
  localparam    ADDRWIDTH_DRAM    =   14;  // Data MEM: 2^14 = 16KB
  localparam    ADDRWIDTH_UART    =   8;   // UART MAP RANGE: 2^8 = 256Bytes
  localparam    ADDRWIDTH_SEGLED  =   8;   // Segment LEDs MAP RANGE: 2^8 = 256Bytes
  localparam    ADDRWIDTH_BUZZER  =   8;   // BUZZER MAP RANGE: 2^8 = 256Bytes

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

  wire segled_wr;
  wire [ADDRWIDTH_SEGLED-1:0] segled_waddr;
  wire [31:0] segled_wdata;

  wire buzzer_wr;
  wire [ADDRWIDTH_BUZZER-1:0] buzzer_waddr;
  wire [31:0] buzzer_wdata;

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
      .FILE("ex_app.txt") 
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
  segled #(
    .ADDRESS_WIDTH(ADDRWIDTH_SEGLED)
  ) u_segled (
      .clk(clk), 
      .rstn(rstn), 

      .wr(segled_wr),
      .waddr(segled_waddr),
      .wdata(segled_wdata),

      .segled_pin(segled_pin)
  );



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
  wbus #(
      .BASEADDR(BASEADDR_SEGLED),
      .BASEADDR_WIDTH(BASEADDR_WIDTH),
      .SLAVEADDR_WIDTH(ADDRWIDTH_SEGLED) 
  ) u_wbus_segled (
      .dmem_wr(dmem_wr),
      .dmem_waddr(dmem_waddr),
      .dmem_wstrb(dmem_wstrb),
      .dmem_wdata(dmem_wdata),

      .slave_wr(segled_wr),
      .slave_waddr(segled_waddr),
      .slave_wstrb(),
      .slave_wdata(segled_wdata)
  );

  // Read Channel MUX
  reg [31:0] bus_rdata_mux;
  reg [2:0] slave_sel;

  always @(posedge clk or negedge rstn) 
  begin
    if (~rstn) 
      slave_sel <= 'b000;
    else
      slave_sel <= {iram_rd, dram_rd, uart_rd};
  end

  always @*
  begin
    case (slave_sel)
      3'b100:  bus_rdata_mux = iram_rdata_mux_in;
      3'b010:  bus_rdata_mux = dram_rdata_mux_in;
      3'b001:  bus_rdata_mux = uart_rdata_mux_in;
      default: bus_rdata_mux = 'h0;
    endcase
  end
  
  assign dmem_rdata =  bus_rdata_mux;

endmodule

