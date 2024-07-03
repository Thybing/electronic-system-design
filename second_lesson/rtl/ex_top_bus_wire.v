`timescale 1ns/100ps

module top (
    input clk,        // 时钟信号
    input rstn,       // 复位信号（低电平有效）

    output tx_pin,    // UART 发送引脚
    input  rx_pin     // UART 接收引脚
);

  // 定义基地址掩码和偏移地址掩码
  localparam BASEADDR_MASK = 32'hFF00_0000;
  localparam OFFADDR_MASK  = 32'h00FF_FFFF;

  // 定义外设的基地址
  localparam BASEADDR_IRAM = 32'h0000_0000;   // 指令内存基地址（不可更改）
  localparam BASEADDR_DRAM = 32'h0100_0000;   // 数据内存基地址
  localparam BASEADDR_UART = 32'h0200_0000;   // UART 基地址

  // 定义各内存的地址宽度
  localparam IRAM_ADDR_WIDTH = 12;  // 指令内存：2^12 = 4KB
  localparam DRAM_ADDR_WIDTH = 14;  // 数据内存：2^14 = 16KB
  localparam UART_ADDR_WIDTH = 8;   // UART 映射范围：2^8 = 256Bytes

  // CPU 指令 RAM 的接口信号
  wire imem_rd;
  wire [31:0] imem_addr;
  wire [31:0] imem_rdata;

  // CPU 数据总线的接口信号
  wire dmem_wr;
  wire [31:0] dmem_waddr;
  wire [31:0] dmem_wdata;
  wire [3:0] dmem_wstrb;

  wire dmem_rd;
  wire [31:0] dmem_raddr;
  wire [31:0] dmem_rdata;

  // 内部信号
  wire instr_rd, iram_rd;
  wire [IRAM_ADDR_WIDTH-1:0] instr_raddr, iram_raddr;
  wire [31:0] instr_rdata, iram_rdata;

  wire dram_wr, dram_rd;
  wire [DRAM_ADDR_WIDTH-1:0] dram_raddr, dram_waddr;
  wire [31:0] dram_rdata, dram_wdata;
  wire [3:0] dram_wstrb;

  wire uart_wr, uart_rd;
  wire [UART_ADDR_WIDTH-1:0] uart_raddr, uart_waddr;
  wire [31:0] uart_rdata, uart_wdata;

  ///////////////  Risc-v Processor ///////////////
  // 实例化 RISC-V 处理器
  riscv #(
    .RV32M(0) // 配置 RISC-V 处理器不支持乘除指令
  ) u_riscv (
      .clk (clk),
      .rstn(rstn),

      .stall    (1'b0),    // 无停顿信号
      .exception(),
      .timer_en (),

      .timer_irq(1'b0),   // 无定时器中断
      .sw_irq   (1'b0),   // 无软件中断
      .interrupt(1'b0),   // 无外部中断

      .imem_rd(imem_rd),        // 指令内存读使能
      .imem_addr (imem_addr),   // 指令内存读地址
      .imem_rdata(imem_rdata),  // 指令内存读数据

      .dmem_wr(dmem_wr),        // 数据内存写使能
      .dmem_waddr (dmem_waddr), // 数据内存写地址
      .dmem_wdata (dmem_wdata), // 数据内存写数据
      .dmem_wstrb (dmem_wstrb), // 数据内存写字节选择信号

      .dmem_rd(dmem_rd),        // 数据内存读使能
      .dmem_raddr (dmem_raddr), // 数据内存读地址
      .dmem_rdata (dmem_rdata)  // 数据内存读数据
  );

  ///////////////  Risc-v Instr MEM  ///////////////
  // 实例化指令内存
  ram2port #(
      .ADDRESS_WIDTH(IRAM_ADDR_WIDTH), 
      .FILE("imem.txt") // 指令内存初始化文件 
  ) u_iram (
      .clk(clk),
      .addra(instr_raddr),  // 端口 A 地址（从 CPU 读取指令）
      .rena(instr_rd),      // 端口 A 读使能
      .douta(instr_rdata),  // 端口 A 读数据
      .wena(1'b0),          // 端口 A 写使能（禁用）
      .wstrba(4'b0000),     // 端口 A 写字节选择信号（禁用）
      .dina(32'h0),         // 端口 A 写数据（无效）

      .addrb(iram_raddr),   // 端口 B 地址（从数据总线读取指令）
      .renb(iram_rd),       // 端口 B 读使能
      .doutb(iram_rdata)    // 端口 B 读数据
  );

  // 将 CPU 的指令内存接口连接到指令内存模块
  assign instr_raddr = imem_addr[IRAM_ADDR_WIDTH-1:0];
  assign instr_rd = imem_rd;
  assign imem_rdata = instr_rdata;

  /////////////// Risc-v DATA MEM ///////////////
  // 实例化数据内存
  ram2port #(
      .ADDRESS_WIDTH(DRAM_ADDR_WIDTH), 
      .FILE("") // 数据内存初始化文件为空 
  ) u_dram (
      .clk(clk),

      .addra(dram_waddr),  // 端口 A 地址（从 CPU 写数据）
      .rena(1'b0),         // 端口 A 读使能（禁用）
      .douta(),            // 端口 A 读数据（无效）
      .wena(dram_wr),      // 端口 A 写使能
      .wstrba(dram_wstrb), // 端口 A 写字节选择信号
      .dina(dram_wdata),   // 端口 A 写数据

      .addrb(dram_raddr),  // 端口 B 地址（从数据总线读取数据）
      .renb(dram_rd),      // 端口 B 读使能
      .doutb(dram_rdata)   // 端口 B 读数据
  );

  ///////////////       UART       ///////////////
  // 实例化 UART 模块
  uart u_uart(
      .clk(clk), 
      .rstn(rstn), 

      .i_we(uart_wr),       // UART 写使能
      .i_waddr(uart_waddr), // UART 写地址
      .i_wdata(uart_wdata), // UART 写数据

      .i_raddr(uart_raddr), // UART 读地址
      .o_rdata(uart_rdata), // UART 读数据

      .tx_pin(tx_pin),      // UART 发送引脚
      .rx_pin(rx_pin)       // UART 接收引脚
  );

  ///////////////  Data BUS interconnect  ///////////////
  // 数据总线互连逻辑

  // (1) IRAM 只读
  wire raddr_within_iram;
  assign raddr_within_iram = ((dmem_raddr & BASEADDR_MASK) == BASEADDR_IRAM); // 判断地址是否在指令内存范围内
  assign iram_rd = dmem_rd & raddr_within_iram; // 若地址在指令内存范围内且读使能有效，则启用指令内存读操作
  assign iram_raddr = dmem_raddr[IRAM_ADDR_WIDTH-1:0]; // 指令内存读地址

  // (2) DRAM 写/读
  wire waddr_within_dram, raddr_within_dram;

  assign waddr_within_dram =  ((dmem_waddr & BASEADDR_MASK) == BASEADDR_DRAM); // 判断地址是否在数据内存范围内
  assign dram_wr = dmem_wr & waddr_within_dram; // 若地址在数据内存范围内且写使能有效，则启用数据内存写操作
  assign dram_waddr = dmem_waddr[DRAM_ADDR_WIDTH-1:0]; // 数据内存写地址
  assign dram_wstrb = dmem_wstrb; // 数据内存写字节选择信号
  assign dram_wdata = dmem_wdata; // 数据内存写数据

  assign raddr_within_dram = ((dmem_raddr & BASEADDR_MASK) == BASEADDR_DRAM); // 判断地址是否在数据内存范围内
  assign dram_rd = dmem_rd & raddr_within_dram; // 若地址在数据内存范围内且读使能有效，则启用数据内存读操作
  assign dram_raddr = dmem_raddr[DRAM_ADDR_WIDTH-1:0]; // 数据内存读地址

  // (3) UART 写/读
  wire waddr_within_uart, raddr_within_uart;

  assign waddr_within_uart =  ((dmem_waddr & BASEADDR_MASK) == BASEADDR_UART); // 判断地址是否在 UART 范围内
  assign uart_wr = dmem_wr & waddr_within_uart; // 若地址在 UART 范围内且写使能有效，则启用 UART 写操作
  assign uart_waddr = dmem_waddr[UART_ADDR_WIDTH-1:0]; // UART 写地址
  assign uart_wdata = dmem_wdata; // UART 写数据

  assign raddr_within_uart = ((dmem_raddr & BASEADDR_MASK) == BASEADDR_UART); // 判断地址是否在 UART 范围内
  assign uart_rd = dmem_rd & raddr_within_uart; // 若地址在 UART 范围内且读使能有效，则启用 UART 读操作
  assign uart_raddr = dmem_raddr[UART_ADDR_WIDTH-1:0]; // UART 读地址

  // 读通道多路复用器
  reg [31:0] bus_rdata_mux; // 总线读数据多路复用信号
  reg [2:0] slave_sel; // 从设备选择信号

  always @(posedge clk or negedge rstn) 
  begin
    if (~rstn) 
      slave_sel <= 'b000; // 复位时，清空从设备选择信号
    else
      slave_sel <= {iram_rd, dram_rd, uart_rd}; // 根据读使能信号选择从设备
  end

  always @*
  begin
    case (slave_sel)
      3'b100:  bus_rdata_mux = iram_rdata; // 选择指令内存读数据
      3'b010:  bus_rdata_mux = dram_rdata; // 选择数据内存读数据
      3'b001:  bus_rdata_mux = uart_rdata; // 选择 UART 读数据
      default: bus_rdata_mux = 'h0; // 默认情况下，读数据为 0
    endcase
  end
  
  assign dmem_rdata = bus_rdata_mux; // 将总线读数据输出到 CPU

endmodule
