module seg_leds(
  input clk,
  input rstn,
  
  // interface to CPU
  input wr,
  input [31:0] waddr,
  input [31:0] wdata,
  
  input rd,
  input [31:0] raddr,
  output [31:0] rdata,
  
  // pin
  output [7:0] seg_leds_pin
);

  localparam ADDR_VER = 'd0,  ADDR_DATA = 'd4;
  localparam HW_VER = 32'h01;
  
  ////////  Write Logic ///////
  reg [31:0] seg_leds_data;
  
  always @(posedge clk or negedge rstn)
  begin
  	if (~rstn)
  	  seg_leds_data <= 'd0;
  	else if (wr & (waddr == ADDR_DATA))
  	  seg_leds_data <= wdata;
  end

  assign seg_leds_pin = seg_leds_data[7:0];
  
  
  ////////  Read Logic ///////
  reg [31:0] rd_reg;
  
  always @(posedge clk or negedge rstn)
  begin
  	if (~rstn)
  	  rd_reg <= 'h0;
  	else if (rd)
  	  case (raddr)
        ADDR_VER:  rd_reg <= HW_VER;
        ADDR_DATA: rd_reg <= seg_leds_data;
        default:   rd_reg <= 32'h00;
    endcase
  end
  
  assign rdata = rd_reg;
  
endmodule

