`timescale 1ns/100ps

module buzzer_tb(

);

    reg         clk     ,
                rst_n   ,
                wr      ,
                rd      ;
    wire        buz_pin ;
    reg [31:0]  waddr   ,
                wdata   ,
                raddr   ;
    wire[31:0]  rdata   ;

    buzzer #(
        .ADDRWIDTH(8)
    )
    u_buzzer(
        .clk      (clk)     ,
        .rst_n    (rst_n)   ,
        
        // interface to CPU
        .wr       (wr)      ,
        .waddr    (waddr)   ,
        .wdata    (wdata)   ,
        
        .rd       (rd)      ,
        .raddr    (raddr)   ,
        .rdata    (rdata)   , 

        // pin 
        .buzzer_pin(buz_pin)
    );

    initial begin
        clk = 'h0;
        rst_n = 'h1;
        wr = 'h0;
        waddr = 'h0;
        wdata = 'h0;

        rd = 'h0;
        raddr = 'h0;
        
        #5
        rst_n = 'h0;
        #5
        rst_n = 'h1;

        #5
        wr = 'h1;
        waddr = 'h04;
        wdata = 'h01;
        #5
        wr <= 'h0;
        #5
        wr = 'h1;
        waddr = 'h08;
        wdata = 'd6;
        #5
        wr = 'h0;
        #5
        wr = 'h1;
        waddr = 'h0c;
        wdata = 20;
        #5
        wr = 'h0;
        #300
        wr <= 'h1;
        waddr <= 'h14;
        wdata <= 'h01;
        #5
        #5
        wr = 'h0;
        #5
        rd = 1;
        raddr = 'h4;
        #5
        rd = 0;
        #45
        rd = 1;
        raddr = 'h10;
        #5
        rd = 0;
    end

    always #5 clk = ~clk;

endmodule