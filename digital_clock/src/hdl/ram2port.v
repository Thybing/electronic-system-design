
`timescale 1ns/100ps

// A port/B port: Write after Read
module ram2port #(
  parameter  ADDRESS_WIDTH = 5,
  parameter  FILE  = "mem.txt"
) (

  input                               clk,
  input       [(ADDRESS_WIDTH-1):0]   addra,
  input                               rena,
  output  reg             [31:0]      douta,
  input                               wena,
  input                    [3:0]      wstrba,
  input                   [31:0]      dina,

  input       [(ADDRESS_WIDTH-1):0]   addrb,
  input                               renb,
  output                [31:0]        doutb
);

  localparam  ADDR_WIDTH = (ADDRESS_WIDTH - 2);


  (* ram_style = "block" *)
  reg         [31:0]      m_ram[0:((2**ADDR_WIDTH)-1)];

  wire addreq;
  wire [(ADDR_WIDTH-1):0] addra_trunc, addrb_trunc;
  integer i;

  assign addra_trunc = addra[ADDRESS_WIDTH-1:2];
  assign addrb_trunc = addrb[ADDRESS_WIDTH-1:2];

  always @(posedge clk) begin
    if (wena == 1'b1) begin
      for(i=0; i<4; i=i+1) begin
        if (wstrba[i]) begin
          m_ram[addra_trunc][i*8+:8] <=  dina[i*8+:8];
        end
      end
    end
  end

  always @(posedge clk) begin
    if (rena == 1'b1) begin
      for(i=0; i<4; i=i+1) begin
        douta[i*8+:8] <= m_ram[addra_trunc][i*8+:8];
        //douta[i*8+:8] <= (wstrba[i] & wena)? dina[i*8+:8] : m_ram[addra_trunc][i*8+:8];
      end 
    end
  end

  reg [31:0]  doutb_ram;
  always @(posedge clk) begin
    if (renb == 1'b1) begin
      doutb_ram <= m_ram[addrb_trunc];
      //for(i=0; i<4; i=i+1) begin
      //  doutb[i*8+:8] <= (addreq & wstrba[i] & wena)? dina[i*8+:8] : m_ram[addrb_trunc][i*8+:8];
      //end 
    end
  end

  reg [3:0] wr_col = 4'b0000;
  always @(posedge clk) begin
    wr_col <= (addreq & wena & renb) ? wstrba : 4'b0000;
  end

  reg [31:0] dina_r = 32'h00;
  always @(posedge clk) begin
    dina_r <= dina;
  end

  assign doutb[7:0]   =  wr_col[0] ?  dina_r[7:0]  : doutb_ram[7:0];
  assign doutb[15:8]  =  wr_col[1] ?  dina_r[15:8] : doutb_ram[15:8];
  assign doutb[23:16] =  wr_col[2] ?  dina_r[23:16] : doutb_ram[23:16];
  assign doutb[31:24] =  wr_col[3] ?  dina_r[31:24] : doutb_ram[31:24];

  assign addreq = (addrb_trunc == addra_trunc);

  initial begin
    $readmemh(FILE, m_ram);
  end
   

endmodule
