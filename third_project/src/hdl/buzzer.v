`timescale 1ns/100ps

module buzzer #(
    parameter   ADDRWIDTH   =   5  
)
(
    //sys
    input                   clk         ,
                            rst_n       ,
    //interface to CPU
    input                   rd          ,
    input   [ADDRWIDTH-1:0] raddr       ,
    output  [31:0]          rdata       , 

    input                   wr          ,
    input   [ADDRWIDTH-1:0] waddr       ,
    input   [31:0]          wdata       ,

    //output_pin
    output                  buzzer_pin  );

    //reg addr
    localparam  ADDR_VER        =   'h00    ,
                ADDR_STATUS     =   'h04    , 
                ADDR_DIVTAR     =   'h08    ,
                ADDR_DELAY_TAR  =   'h0c    ,
                ADDR_DELAY_CNT  =   'h10    ,
                ADDR_DELAY_CLR  =   'h14    ;
    //version
    localparam  HW_VER          =   'h00    ;

    //Write Logic
    reg [31:0]          status      ,
                        divtar      ,
                        delay_tar   ,
                        delay_clr   ;


    always@(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            status      <=      'h0;
            divtar      <=      'h0;
            delay_tar   <=      'h0;
            delay_clr   <=      'h0;
        end
        else begin
            if (wr) begin
                if      (waddr == ADDR_STATUS       )
                    status      <=  wdata;
                else if (waddr == ADDR_DIVTAR       )
                    divtar      <=  wdata;
                else if (waddr == ADDR_DELAY_TAR    )
                    delay_tar   <=  wdata;
                else if (waddr == ADDR_DELAY_CLR    )
                    if  (delay_clr == 'h0   )
                        delay_clr   <=  wdata;
            end
            //延时清空寄存器自动复位
            if (delay_clr != 'h0)
                delay_clr   <=  'h0;
        end
    end

    //Read Logic
    reg [31:0]          rd_reg;

    always@(posedge clk or negedge rst_n) begin
        if(~rst_n) begin 
            rd_reg      <=      'h0;
        end
        else if(rd) begin
            if      (raddr == ADDR_VER          )
                rd_reg  <=  HW_VER      ;
            else if (raddr == ADDR_STATUS       )
                rd_reg  <=  status      ;
            else if (raddr == ADDR_DELAY_CNT    )
                rd_reg  <=  delay_cnt   ;
            else 
                rd_reg  <=  'h0         ;
        end
    end

    assign  rdata   =   rd_reg  ;

    //private reg
    reg [31:0]      divcnt      ,
                    delay_cnt   ;
    reg             toggle_out  ,
                    delay_out   ;

    always@(posedge clk or posedge delay_clr[0] or negedge rst_n) begin
        if(~rst_n) begin
            divcnt      <=      'h0;
            delay_cnt   <=      'h0;
            toggle_out  <=      'h0;
            delay_out   <=      'h0;
        end
        else begin
            if  (divcnt >= (divtar >> 1) - 1)  begin
                toggle_out  <=  ~toggle_out ;
                divcnt      <=  'h0         ;
            end
            else 
                divcnt      <=  divcnt + 1  ;
            
            if          (delay_clr[0]           )
                delay_cnt   <=  'h0;
            else if     (delay_cnt >= delay_tar )    
                delay_out   <=  'h0             ;
            else begin
                delay_out   <=  'h1             ;
                delay_cnt   <=  delay_cnt + 1   ;
            end
        end 
    end
    
    assign  buzzer_pin  =   status[0] & toggle_out & delay_out;

endmodule