`timescale 1ns/100ps

module tiny_riscv0(
  input clk,             // 时钟信号
  input rstn,            // 复位信号（低电平有效）

  // 指令RAM接口
  output        imem_rd,     // 指令RAM读取信号
  output [31:0] imem_addr,   // 指令RAM地址
  input  [31:0] imem_rdata,  // 从指令RAM读取的数据

  // 数据RAM接口
  output        dmem_wr,     // 数据RAM写入信号
  output [31:0] dmem_waddr,  // 数据RAM写入地址
  output [31:0] dmem_wdata,  // 数据RAM写入数据

  output        dmem_rd,     // 数据RAM读取信号
  output [31:0] dmem_raddr,  // 数据RAM读取地址
  input  [31:0] dmem_rdata   // 从数据RAM读取的数据
);

  // 指令字段定义
  `define OPCODE 6:0      // 操作码字段（指令[6:0]）
  `define FUNC3 14:12     // 功能码字段（指令[14:12]）
  `define FUNC7 31:25     // 功能码字段（指令[31:25]）
  `define SUBTYPE 30      // 子类型字段（指令[30]）
  `define RD 11:7         // 目的寄存器字段（指令[11:7]）
  `define RS1 19:15       // 源寄存器1字段（指令[19:15]）
  `define RS2 24:20       // 源寄存器2字段（指令[24:20]）
  `define IMM12 31:20     // 12位立即数字段（指令[31:20]）

  localparam [31:0] RESETVEC = 32'h0000_0000; // 复位向量地址

  localparam [31:0] NOP = 32'h0000_0013;  // NOP指令（addi x0, x0, 0）

  // 操作码定义（指令[6:0]）
  localparam [6:0]  OP_LUI = 7'b0110111,    // U型指令 //LUI
                    OP_JAL = 7'b1101111,    // J型指令 //JAL
                    OP_BRANCH = 7'b1100011, // B型指令 //BEQ
                    OP_LOAD = 7'b0000011,   // I型指令 //LW
                    OP_STORE = 7'b0100011,  // S型指令 //SW
                    OP_ARITHI = 7'b0010011, // I型算术指令 //ADDI
                    OP_ARITHR = 7'b0110011; // R型算术指令 // ADD or STL 由fun3确定

  // 功能码定义（指令[14:12]）
  localparam [2:0]  OP_BRANCH_BEQ  = 3'b000;     // 分支指令中的BEQ
  localparam [2:0]  OP_ARITH_ADD   = 3'b000,     // 算术指令中的ADD
                    OP_ARITH_SLT   = 3'b010;     // 算术指令中的SLT

  // 程序计数器（PC）
  reg  [31:0] fetch_pc; // 当前取指令的PC

  // 寄存器文件
  reg  [31:0] regs [31:1]; // 寄存器数组，寄存器0通常固定为0
  wire [31:0] reg_rdata1, reg_rdata2; // 寄存器读取数据1和2

  ////////////////////////////////////////////////////////////
  // 取指/译码  执行  写回
  //      取指/译码  执行  写回
  //          取指/译码  执行  写回
  //              取指/译码 执行 写回
  ////////////////////////////////////////////////////////////

  // 第1阶段：取指和译码
  ////////////////////////////////////////////////////////////
  
  // 取指PC
  reg  [31:0] if_pc;
  always @(posedge clk or negedge rstn) 
  begin
    if (!rstn) 
      if_pc <= RESETVEC; // 复位时，PC设置为复位向量地址
    else  
      if_pc <= fetch_pc; // 否则，PC更新为当前取指PC
  end

  // 取指指令
  wire [31:0] if_insn;
  assign if_insn = imem_rdata; // 从指令RAM读取的指令

  // 立即数解码
  reg [31:0] imm;
  always @* 
  begin
    case (if_insn[`OPCODE])
      OP_LUI: imm = {if_insn[31:12], 12'd0};  // U型指令立即数解码
      OP_JAL: imm = {{12{if_insn[31]}}, if_insn[19:12], if_insn[20], if_insn[30:21], 1'b0};  // J型指令立即数解码
      OP_BRANCH: imm = {{20{if_insn[31]}}, if_insn[7], if_insn[30:25], if_insn[11:8], 1'b0}; // B型指令立即数解码
      OP_LOAD: imm = {{20{if_insn[31]}}, if_insn[31:20]}; // I型指令立即数解码
      OP_STORE: imm = {{20{if_insn[31]}}, if_insn[31:25], if_insn[11:7]}; // S型指令立即数解码
      OP_ARITHI: imm = {{20{if_insn[31]}}, if_insn[31:20]}; // I型算术指令立即数解码
      OP_ARITHR: imm = 'd0; // R型指令没有立即数
      default: imm = 'd0; // 默认立即数为0
    endcase
  end

  // 寄存器解码
  wire [4:0] if_src1_sel, if_src2_sel;
  assign if_src1_sel = if_insn[`RS1]; // 源寄存器1选择
  assign if_src2_sel = if_insn[`RS2]; // 源寄存器2选择

  // 读取寄存器文件
  assign reg_rdata1[31: 0] = (if_src1_sel == 5'h0) ? 32'h0 : regs[if_src1_sel]; // 如果源寄存器1是x0，则返回0，否则返回对应寄存器的值
  assign reg_rdata2[31: 0] = (if_src2_sel == 5'h0) ? 32'h0 : regs[if_src2_sel]; // 如果源寄存器2是x0，则返回0，否则返回对应寄存器的值

  // ALU操作数解码
  reg [31:0] if_alu_oprand1;
  reg [31:0] if_alu_oprand2;
  always @* 
  begin
    case (if_insn[`OPCODE])
      OP_LUI: if_alu_oprand1 = 'd0; // U型指令操作数1为0
      default: if_alu_oprand1 = reg_rdata1; // 其他指令操作数1为源寄存器1的值
    endcase
  end

  always @* 
  begin
    case (if_insn[`OPCODE])
      OP_ARITHI, OP_STORE, OP_LUI: if_alu_oprand2 = imm; // I型算术指令、S型指令和U型指令操作数2为立即数
      OP_ARITHR, OP_BRANCH: if_alu_oprand2 = reg_rdata2; // R型指令和B型指令操作数2为源寄存器2的值
      default: if_alu_oprand2 = 'd0; // 默认操作数2为0
    endcase
  end

  // 处理“加载”指令，发送数据RAM地址
  assign dmem_raddr = reg_rdata1 + imm; // 数据RAM读取地址为源寄存器1的值加立即数
  assign dmem_rd = (if_insn[`OPCODE] == OP_LOAD); // 当指令为加载指令时，发出数据RAM读取信号

  ////////////////////////////////////////////////////////////
  // 第2阶段：执行
  ////////////////////////////////////////////////////////////
  reg [31:0] ex_insn; // 执行阶段的指令
  reg [31:0] ex_imm; // 执行阶段的立即数
  wire [2:0] ex_insn_func3; // 执行阶段的功能码字段
  reg [31:0] ex_alu_oprand1; // 执行阶段的ALU操作数1
  reg [31:0] ex_alu_oprand2; // 执行阶段的ALU操作数2
  reg [31:0] ex_reg_rdata2; // 执行阶段的寄存器数据2，用于存储指令
  wire [31:0] ex_memaddr; // 执行阶段的内存地址
  reg [31:0] ex_pc; // 执行阶段的PC

  always @(posedge clk or negedge rstn)
  begin
    if (!rstn) begin
      ex_imm <= 32'h0; // 复位时立即数清零
      ex_alu_oprand1 <= 32'h0; // 复位时操作数1清零
      ex_alu_oprand2 <= 32'h0; // 复位时操作数2清零
      ex_reg_rdata2 <= 32'h0; // 复位时寄存器数据2清零
      ex_pc <= RESETVEC; // 复位时PC设置为复位向量地址
      ex_insn <= NOP; // 复位时指令设置为NOP
    end else begin
      ex_imm <= imm; // 否则，立即数更新为解码阶段的立即数
      ex_alu_oprand1 <= if_alu_oprand1; // 操作数1更新为解码阶段的操作数1
      ex_alu_oprand2 <= if_alu_oprand2; // 操作数2更新为解码阶段的操作数2
      ex_reg_rdata2 <= reg_rdata2; // 寄存器数据2更新为解码阶段的寄存器数据2
      ex_pc <= if_pc; // PC更新为解码阶段的PC
      ex_insn <= if_insn; // 指令更新为解码阶段的指令
    end
  end

  assign ex_insn_func3 = ex_insn[`FUNC3]; // 提取执行阶段指令的功能码字段

  // ALU运算
  reg [31:0] alu_ret;
  always @* 
  begin
    case (ex_insn[`OPCODE])
      OP_LUI, OP_STORE: alu_ret = ex_alu_oprand1 + ex_alu_oprand2; // U型指令和S型指令的ALU运算为操作数1加操作数2
      OP_ARITHI: case (ex_insn[`FUNC3])
        OP_ARITH_ADD: alu_ret = ex_alu_oprand1 + ex_alu_oprand2; // I型算术指令中的ADD运算
        default: alu_ret = 'd0; // 其他运算默认为0
      endcase
      OP_ARITHR: case (ex_insn[`FUNC3])
        OP_ARITH_ADD: alu_ret = ex_alu_oprand1 + ex_alu_oprand2; // R型算术指令中的ADD运算
        OP_ARITH_SLT: alu_ret = ($signed(ex_alu_oprand1) < $signed(ex_alu_oprand2)) ? 'd1 : 'd0; // R型算术指令中的SLT运算
        default: alu_ret = 'd0; // 其他运算默认为0
      endcase
      OP_BRANCH: case (ex_insn[`FUNC3])
        OP_BRANCH_BEQ: alu_ret = (ex_alu_oprand1 == ex_alu_oprand2) ? 'd1 : 'd0; // B型指令中的BEQ运算
        default: alu_ret = 'd0; // 其他运算默认为0
      endcase
      default: alu_ret = 'd0; // 其他指令的运算结果默认为0
    endcase
  end

  // 计算下一条指令的PC
  reg [31:0] next_pc;
  always @* 
  begin
    if (ex_insn[`OPCODE] == OP_JAL)
      next_pc = ex_pc + ex_imm; // J型指令的下一条PC为当前PC加立即数
    else if ((ex_insn[`OPCODE] == OP_BRANCH) && alu_ret[0])
      next_pc = (ex_pc + ex_imm); // B型指令且条件满足时，下一条PC为当前PC加立即数
    else 
      next_pc = (fetch_pc + 'd4); // 其他情况，下一条PC为当前取指PC加4
  end

  // 准备写回
  wire ex_reg_update; // 是否更新寄存器
  wire [4:0] ex_reg_destsel; // 目标寄存器选择
  wire [31:0] ex_reg_wdata; // 写回寄存器的数据
  wire ex_dmem_update; // 是否更新数据RAM
  wire [31:0] ex_dmem_wdata; // 写回数据RAM的数据
  
  assign ex_reg_destsel = ex_insn[`RD]; // 提取目标寄存器
  assign ex_reg_update = (ex_insn[`OPCODE] == OP_LUI) || (ex_insn[`OPCODE] == OP_LOAD) || (ex_insn[`OPCODE] == OP_ARITHI) || (ex_insn[`OPCODE] == OP_ARITHR) || (ex_insn[`OPCODE] == OP_JAL); // 判断是否需要更新寄存器
  assign ex_reg_wdata = (ex_insn[`OPCODE] == OP_LOAD) ? dmem_rdata : ((ex_insn[`OPCODE] == OP_JAL) ? (ex_pc + 'd4) : alu_ret); // 根据指令类型选择写回寄存器的数据

  assign ex_dmem_update = (ex_insn[`OPCODE] == OP_STORE); // 判断是否需要更新数据RAM
  assign ex_dmem_wdata = ex_reg_rdata2; // 写回数据RAM的数据为寄存器数据2

  ////////////////////////////////////////////////////////////
  // 第3阶段：写回
  ////////////////////////////////////////////////////////////

  always @(posedge clk or negedge rstn) 
  begin
    if (!rstn)
      fetch_pc <= RESETVEC; // 复位时，PC设置为复位向量地址
    else 
      fetch_pc <= {next_pc[31:1], 1'b0}; // 否则，PC更新为下一条PC，最低位设置为0（对齐）
  end

  assign imem_rd = 1'b1; // 始终允许读取指令RAM
  assign imem_addr = fetch_pc; // 指令RAM地址为取指PC

  assign dmem_waddr = alu_ret; // 数据RAM写入地址为ALU运算结果
  assign dmem_wr = ex_dmem_update; // 数据RAM写入信号
  assign dmem_wdata = ex_dmem_wdata; // 数据RAM写入数据

  // 寄存器文件
  integer i;
  always @(posedge clk or negedge rstn) 
  begin
    if (!rstn) begin
      for (i = 1; i < 32; i = i + 1) regs[i] <= 32'h0; // 复位时，将所有寄存器清零
    end else if (ex_reg_update) begin
      regs[ex_reg_destsel] <= ex_reg_wdata; // 更新目标寄存器
    end
  end

endmodule
