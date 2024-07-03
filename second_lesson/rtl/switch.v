module switch(
  input clk,
  input rstn,
  
  // interface to CPU
  input rd,
  input [31:0] raddr,
  output [31:0] rdata,
  
  // pin
  input [3:0] switch_pin
);
  
  localparam ADDR_VER='d0, ADDR_STATUS = 'd4;
  localparam HW_VER = 32'h01;
  
  reg [31:0] rd_reg;
  always @(posedge clk or negedge rstn)
  begin
  	if (~rstn)
  	  rd_reg <= 32'h0;
  	else if (rd) 
  	  case(raddr)
  	  	ADDR_VER:      rd_reg <= HW_VER;
  	  	ADDR_STATUS:   rd_reg <= {28'h0, switch_pin};
  	  	default:       rd_reg <= 32'h0;
  	  endcase
  end
  	  	
  assign rdata = rd_reg;
  

endmodule

