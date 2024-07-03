
`timescale 1ns/100ps

module rom #(
  parameter  DATA_WIDTH = 32,
  parameter  ADDRESS_WIDTH = 5,
  parameter  FILE  = "mem.txt"
) (
  input                               clk,
  input                               en,
  input       [(ADDRESS_WIDTH-1):0]   addr,
  output  reg [(DATA_WIDTH-1):0]      dout
);

  localparam ADDR_WIDTH = ADDRESS_WIDTH-2;

  wire [ADDR_WIDTH-1:0] ram_addr;
  assign ram_addr = addr[ADDRESS_WIDTH-1:2];

  (* ram_style = "block" *)
  reg         [(DATA_WIDTH-1):0]      m_ram[0:((2**ADDR_WIDTH)-1)];

  always @(posedge clk) begin
    if (en == 1'b1) begin
      dout <= m_ram[ram_addr];
    end
  end


  initial begin
    $readmemh(FILE, m_ram);
  end
   

endmodule
