`timescale 1ns/100ps

module buzzer_tb(

);

    reg         clk     ,
                rst_n   ,
                wr      ,
                buz_pin ;
    reg [31:0]  waddr   ,
                wdata   ;

    buzzer u_buzzer(
        .clk      (clk)   ,
        .rst_n    (rst_n) ,
        
        // interface to CPU
        .wr       (wr)    ,
        .waddr    (waddr) ,
        .wdata    (wdata) ,
        
        .rd          ,
        .raddr       ,
        .rdata       , 

        // pin 
        .output buzzer_pin(buz_pin)
    );

    initial begin
        clk = 'h0;
        rst_n = 'h1;
        wr = 'h0;
        waddr = 'h0;
        wdata = 'h0;
    end

endmodule