`timescale 1ns/100ps


module tiny_riscv0(
  input clk,
  input rstn,

  // interface of instruction RAM
  output        imem_rd,
  output [31:0] imem_addr,
  input  [31:0] imem_rdata,

  // interface of data RAM
  output        dmem_wr,
  output [31:0] dmem_waddr,
  output [31:0] dmem_wdata,

  output        dmem_rd,
  output [31:0] dmem_raddr,
  input  [31:0] dmem_rdata
);

  // Instr Field Definition
  `define OPCODE 6:0
  `define FUNC3 14:12
  `define FUNC7 31:25
  `define SUBTYPE 30
  `define RD 11:7
  `define RS1 19:15
  `define RS2 24:20
  `define IMM12 31:20

  localparam [31:0] RESETVEC = 32'h0000_0000;

  localparam [31:0] NOP = 32'h0000_0013;  // addi x0, x0, 0

  // OPCODE, INST[6:0]
  localparam [6:0]  OP_LUI = 7'b0110111,  // U-type
                    OP_JAL = 7'b1101111,  // J-type
                    OP_BRANCH = 7'b1100011,  // B-type
                    OP_LOAD = 7'b0000011,  // I-type
                    OP_STORE = 7'b0100011,  // S-type
                    OP_ARITHI = 7'b0010011,  // I-type
                    OP_ARITHR = 7'b0110011;  // R-type

  // FUNC3, INST[14:12]
  localparam [2:0]  OP_BRANCH_BEQ  = 3'b000;     // for OP_BRANCH
  localparam [2:0]  OP_ARITH_ADD   = 3'b000, 
                    OP_ARITH_SLT   = 3'b010,
                    OP_ARITH_SLL   = 3'b001,
                    OP_ARITH_SRL   = 3'b101;      // OP_ARITHI or OP_ARITHR


  // PC 
  reg  [31:0] fetch_pc;

  // register files
  reg  [31:0] regs     [31:1];
  wire [31:0] reg_rdata1, reg_rdata2;

  ////////////////////////////////////////////////////////////
  //      F/D  E   W
  //          F/D  E   W
  //              F/D  E  W
  //                  F/D E  w
  ////////////////////////////////////////////////////////////
  // stage 1: fetch/decode
  ////////////////////////////////////////////////////////////
  
  // if PC
  reg  [31:0] if_pc;
  always @(posedge clk or negedge rstn) 
  begin
    if (!rstn) 
      if_pc <= RESETVEC;
    else  
      if_pc <= fetch_pc;
  end

  // fetching Instr
  wire [31:0] if_insn;
  assign if_insn    = imem_rdata;      // read by fetch_pc

  // Imm decode
  reg [31:0] imm;

  always @* 
  begin
    case (if_insn[`OPCODE])
      OP_LUI: imm = {if_insn[31:12], 12'd0};  // U-type
      OP_JAL: imm = {{12{if_insn[31]}}, if_insn[19:12], if_insn[20], if_insn[30:21], 1'b0};  // J-type
      OP_BRANCH: imm = {{20{if_insn[31]}}, if_insn[7], if_insn[30:25], if_insn[11:8], 1'b0};  // B-type
      OP_LOAD: imm = {{20{if_insn[31]}}, if_insn[31:20]};  // I-type
      OP_STORE: imm = {{20{if_insn[31]}}, if_insn[31:25], if_insn[11:7]};  // S-type
      OP_ARITHI: imm = {{20{if_insn[31]}}, if_insn[31:20]}; // I-type
      OP_ARITHR: imm = 'd0;  // R-type
      default: imm = 'd0;
    endcase
  end

  // Register decode
  wire [4:0] if_src1_sel, if_src2_sel;

  assign if_src1_sel = if_insn[`RS1];
  assign if_src2_sel = if_insn[`RS2];

  // Read Register file
  assign reg_rdata1[31: 0]   =  (if_src1_sel == 5'h0) ? 32'h0 : regs[if_src1_sel];
  assign reg_rdata2[31: 0]   =  (if_src2_sel == 5'h0) ? 32'h0 : regs[if_src2_sel];

  // ALU Oprand decode
  reg [31:0] if_alu_oprand1;
  reg [31:0] if_alu_oprand2;

  always @* 
  begin
    case (if_insn[`OPCODE])
      OP_LUI:   if_alu_oprand1 = 'd0;
      default: if_alu_oprand1 = reg_rdata1;
    endcase
  end

  always @* 
  begin
    case (if_insn[`OPCODE])
      OP_ARITHI, OP_STORE, OP_LUI:         if_alu_oprand2 = imm;
      OP_ARITHR, OP_BRANCH:                if_alu_oprand2 = reg_rdata2;
      default: if_alu_oprand2 = 'd0;
    endcase
  end


  // Intr "Load" , Send Dmem Addr out
  assign dmem_raddr = reg_rdata1 + imm;
  assign dmem_rd    = (if_insn[`OPCODE] == OP_LOAD);


  ////////////////////////////////////////////////////////////
  // stage 2: execute
  ////////////////////////////////////////////////////////////
  reg     [31:0] ex_insn;
  reg     [31:0] ex_imm;
  wire    [ 2:0] ex_insn_func3;
  reg     [31:0] ex_alu_oprand1;
  reg     [31:0] ex_alu_oprand2;
  reg     [31:0] ex_reg_rdata2;     // for store instr
  wire    [31:0] ex_memaddr;
  reg     [31:0] ex_pc;

  always @(posedge clk or negedge rstn)
  begin
    if (!rstn) begin
      ex_imm         <= 32'h0;
      ex_alu_oprand1 <= 32'h0;
      ex_alu_oprand2 <= 32'h0;
      ex_reg_rdata2  <= 32'h0;
      ex_pc          <= RESETVEC;
      ex_insn        <= NOP;
    end else begin
      ex_imm         <= imm;
      ex_alu_oprand1 <= if_alu_oprand1;
      ex_alu_oprand2 <= if_alu_oprand2;
      ex_reg_rdata2  <= reg_rdata2;
      ex_pc          <= if_pc;
      ex_insn        <= if_insn;
    end
  end

  assign ex_insn_func3 = ex_insn[`FUNC3];

  // ALU
  reg [31:0] alu_ret;
  always @* 
  begin
    case (ex_insn[`OPCODE])
      OP_LUI, OP_STORE: 
                        alu_ret = ex_alu_oprand1 + ex_alu_oprand2;
      
      OP_ARITHI:  case (ex_insn[`FUNC3])
        OP_ARITH_ADD:   alu_ret = ex_alu_oprand1 + ex_alu_oprand2;
        default:        alu_ret = 'd0;
      endcase

      OP_ARITHR:  case (ex_insn[`FUNC3])
        OP_ARITH_ADD:   alu_ret = ex_alu_oprand1 + ex_alu_oprand2;
        OP_ARITH_SLT:   alu_ret = ($signed(ex_alu_oprand1) < $signed(ex_alu_oprand2))? 'd1 : 'd0;
        OP_ARITH_SLL:   alu_ret = ex_alu_oprand1 << ex_alu_oprand2;
        OP_ARITH_SRL:   alu_ret = ex_alu_oprand1 >> ex_alu_oprand2;
        default:        alu_ret = 'd0;
      endcase

      OP_BRANCH:  case (ex_insn[`FUNC3])
        OP_BRANCH_BEQ:    alu_ret = (ex_alu_oprand1 == ex_alu_oprand2)? 'd1 : 'd0;
        default:        alu_ret = 'd0;
      endcase

      default:          alu_ret = 'd0;
    endcase
  end

  // next pc
  reg [31:0] next_pc;
  always @* 
  begin
    if (ex_insn[`OPCODE] == OP_JAL)
      next_pc = ex_pc + ex_imm;
    else if ((ex_insn[`OPCODE] == OP_BRANCH) && alu_ret[0])
      next_pc = (ex_pc + ex_imm);
    else 
      next_pc = (fetch_pc + 'd4);
  end

  // prepare to write back
  wire ex_reg_update;
  wire [ 4:0] ex_reg_destsel;
  wire [31:0] ex_reg_wdata;
  wire ex_dmem_update;
  wire [31:0] ex_dmem_wdata;
  
  assign ex_reg_destsel = ex_insn[`RD];
  assign ex_reg_update  = (ex_insn[`OPCODE] == OP_LUI) || (ex_insn[`OPCODE] == OP_LOAD) 
                         || (ex_insn[`OPCODE] == OP_ARITHI) || (ex_insn[`OPCODE] == OP_ARITHR) 
                         || (ex_insn[`OPCODE] == OP_JAL);
  assign ex_reg_wdata   = (ex_insn[`OPCODE] == OP_LOAD)? dmem_rdata : 
                          ((ex_insn[`OPCODE] == OP_JAL)? (ex_pc + 'd4) : alu_ret);

  assign ex_dmem_update = (ex_insn[`OPCODE] == OP_STORE); 
  assign ex_dmem_wdata  = ex_reg_rdata2;


  ////////////////////////////////////////////////////////////
  // stage 3: write back
  ////////////////////////////////////////////////////////////

  always @(posedge clk or negedge rstn) 
  begin
    if (!rstn)
      fetch_pc <= RESETVEC;
    else 
      fetch_pc <= {next_pc[31:1], 1'b0};
  end

  assign imem_rd = 1'b1;
  assign imem_addr = fetch_pc;

  assign dmem_waddr = alu_ret;
  assign dmem_wr    = ex_dmem_update;
  assign dmem_wdata = ex_dmem_wdata;


  // Register file
  integer        i;
  always @(posedge clk or negedge rstn) 
  begin
    if (!rstn) begin
      for (i = 1; i < 32; i = i + 1)  regs[i] <= 32'h0;
    end else if (ex_reg_update) begin
      regs[ex_reg_destsel] <= ex_reg_wdata;
    end
  end


endmodule

