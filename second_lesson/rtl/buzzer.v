module buzzer(
  input clk,
  input rstn,
  
  // interface to CPU
  input wr,
  input [31:0] waddr,
  input [31:0] wdata,
  
  // pin 
  output buzzer_pin);
  
  localparam ADDR_VER='d0, ADDR_STATUS = 'd4;
  localparam HW_VER = 32'h01;
  
  reg [31:0] buzzer_reg;
  reg [31:0] buzzer_psc;
  reg buzzer_output;
  always @(posedge clk or negedge rstn)
  begin
  	if (~rstn) begin
  	  buzzer_reg <= 32'h0;
      buzzer_psc <= 32'h0;
      buzzer_output <= 1'b0;
    end
    else begin
      buzzer_psc = buzzer_psc + 1;
      if(buzzer_psc > 'b01111010000100100) begin
        buzzer_output <= ~buzzer_output;
        buzzer_psc <= 32'h0;
      end
      if (wr & (waddr == ADDR_STATUS)) 
        buzzer_reg <= wdata; 
    end
  end

  assign buzzer_pin = buzzer_output & buzzer_reg[0];	  	
  
endmodule
