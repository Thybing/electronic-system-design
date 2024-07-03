`timescale 1ns/100ps


module top (
  input clk,
  input rstn,

  input[3:0] switch_pin,
  output[7:0] static_segled_pin,
  output buzzer_pin
);

  // 定义基地址掩码和偏移地址掩码
  localparam BASEADDR_MASK = 32'hFF00_0000;
  localparam OFFADDR_MASK  = 32'h00FF_FFFF;

  // 定义外设的基地址
  localparam BASEADDR_IRAM = 32'h0000_0000;   // 指令内存基地址（不可更改）
  localparam BASEADDR_DRAM = 32'h0100_0000;   // 数据内存基地址
  localparam BASEADDR_SWITCH = 32'h0200_0000;   // switch 基地址
  localparam BASEADDR_BUZZER = 32'h0300_0000;   // buzzer 基地址
  localparam BASEADDR_STATIC_SEGLED = 32'h0400_0000;   // static_segled 基地址

  // 定义各内存的地址宽度
  localparam IRAM_ADDR_WIDTH = 12;  // 指令内存：2^12 = 4KB
  localparam DRAM_ADDR_WIDTH = 14;  // 数据内存：2^14 = 16KB
  localparam SWITCH_ADDR_WIDTH = 3;   // switch 映射范围：2^3 = 8Bytes
  localparam BUZZER_ADDR_WIDTH = 3;   // buzzer 映射范围：2^3 = 8Bytes
  localparam STATIC_SEGLED_ADDR_WIDTH = 3;   // static_segled 映射范围：2^3 = 8Bytes

  // CPU 指令 RAM 的接口信号
  wire imem_rd;
  wire [31:0] imem_addr, imem_rdata;

  // CPU 数据总线的接口信号
  wire dmem_wr, dmem_rd;
  wire [31:0] dmem_waddr, dmem_wdata;
  wire [31:0] dmem_raddr, dmem_rdata;

  //内部信号
  //开关内部信号
  wire switch_rd;
  wire [SWITCH_ADDR_WIDTH-1:0] switch_raddr;
  wire [31:0] switch_rdata;
  
  //蜂鸣器内部信号
  wire buzzer_wr;
  wire [BUZZER_ADDR_WIDTH-1:0] buzzer_waddr;
  wire [31:0]  buzzer_wdata;

  //静态数码管内部信号
  wire static_segled_wr;
  wire [STATIC_SEGLED_ADDR_WIDTH-1:0] static_segled_waddr;
  wire [31:0]  static_segled_wdata;

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
    .FILE("cnt_watch.txt")
  ) u_instr_mem (
    .clk(clk),
    .en(imem_rd),
    .addr(instr_mem_addr),
    .dout(imem_rdata)
  );

  assign instr_mem_addr = imem_addr[11:0];


  //实例化外设

  switch obj_switch(
    .clk(clk),
    .rstn(rstn), 
    // interface to CPU
    .rd(switch_rd),
    .raddr({29'h0,switch_raddr}),
    .rdata(switch_rdata), 
    // pin
    .switch_pin(switch_pin)
  );

  seg_leds obj_seg_leds(
    .clk(clk),
    .rstn(rstn), 
    // interface to CPU
    .wr(static_segled_wr),
    .waddr({29'h0,static_segled_waddr}),
    .wdata(static_segled_wdata),
    
    .rd(1'b0),
    .raddr(32'b0),
    // pin
    .seg_leds_pin(static_segled_pin)
  );

  buzzer obj_buzzer(
    .clk(clk),
    .rstn(rstn), 
    // interface to CPU
    .wr(buzzer_wr),
    .waddr({29'h0,buzzer_waddr}),
    .wdata(buzzer_wdata),   
    // pin 
    .buzzer_pin(buzzer_pin)
  );

  ///////////////  Data BUS interconnect  ///////////////
  // 数据总线互连逻辑
  //buzzer写
  wire waddr_within_buzzer;

  assign waddr_within_buzzer = ((dmem_waddr & BASEADDR_MASK) == BASEADDR_BUZZER);
  assign buzzer_wr = dmem_wr & waddr_within_buzzer;
  assign buzzer_waddr = dmem_waddr[BUZZER_ADDR_WIDTH-1:0];
  assign buzzer_wdata = dmem_wdata;

  //switch读
  wire raddr_within_switch;
  assign raddr_within_switch = ((dmem_raddr & BASEADDR_MASK) == BASEADDR_SWITCH);
  assign switch_rd = dmem_rd & raddr_within_switch;
  assign switch_raddr = dmem_raddr[SWITCH_ADDR_WIDTH-1:0];

  //static_segled写
  wire waddr_within_static_segled;
  assign waddr_within_static_segled = ((dmem_waddr & BASEADDR_MASK) == BASEADDR_STATIC_SEGLED);
  assign static_segled_wr = dmem_wr & waddr_within_static_segled;
  assign static_segled_waddr = dmem_waddr[STATIC_SEGLED_ADDR_WIDTH-1:0];
  assign static_segled_wdata = dmem_wdata;

  // 读通道多路复用器
  reg [31:0] bus_rdata_mux; // 总线读数据多路复用信号
  reg [0:0] slave_sel; // 从设备选择信号

  always @(posedge clk or negedge rstn) 
  begin
    if (~rstn) 
      slave_sel <= 'b0; // 复位时，清空从设备选择信号
    else
      slave_sel <= {switch_rd}; // 根据读使能信号选择从设备
  end

  always @*
  begin
    case (slave_sel)
      1'b1:  bus_rdata_mux = switch_rdata; // 选择 switch 读数据
      default: bus_rdata_mux = 'h0; // 默认情况下，读数据为 0
    endcase
  end
  
  assign dmem_rdata = bus_rdata_mux; // 将总线读数据输出到 CPU

endmodule

