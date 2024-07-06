
module sec_clk #(
    parameter   ADDRWIDTH   =   4
) 
(
    //sys
    input           clk     ,
                    rst_n   ,
    //interface to CPU
    input                   wr      ,
    input   [ADDRWIDTH-1:0] waddr   ,
    input   [31:0]          wdata   ,

    input                   rd      ,
    input   [ADDRWIDTH-1:0] raddr   ,
    output  [31:0]          rdata   
);
    localparam  ADDR_RUN_TIME   =   'h04,
                ADDR_CLR        =   'h08,
                ADDR_INIT_TIME  =   'h0c;


    //Write Logic
    reg     [31:0]  clr ,
                    init_time;
    
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) 
            clr     <=  'h0 ;
        else begin
            if(wr & (waddr == ADDR_CLR) & (clr == 'h0))
                clr         <=  wdata   ;
            else if(wr & (waddr == ADDR_INIT_TIME))
                init_time   <=  wdata   ;
            
            //clr自动复位
            if(clr != 'h0)
                clr <= 'h0;
        end
    end

    //Read Logic
    reg [31:0]  rd_reg  ;
    reg [31:0]  run_time;

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            rd_reg  <=  'h0;
        else begin
            if(rd & (raddr == ADDR_RUN_TIME))
                rd_reg  <=  run_time;
            else if(rd & (raddr == ADDR_INIT_TIME))
                rd_reg  <=  init_time;
            else
                rd_reg  <=  'h0;
        end
    end

    assign  rdata   =   rd_reg  ;

    //second clock
    clk_div #(
        .cnt_width  (25         )   ,
        .div_cnt    ('h17D7840  )   
    )    
    u_clk_1s(
        .clk    (clk    ),
        .rst_n  (rst_n  ),
        .clk_o  (clk_1s )
    );

    localparam   RELOAD_TIME     =   'd86400 ;

    always @(posedge clk_1s or posedge clr or negedge rst_n) begin
        if(~rst_n | (clr == 'h1))
            run_time    <=  'h0;
        else begin
            if(run_time >= RELOAD_TIME - 1)
                run_time    <=  'h0;
            else
                run_time    <=  run_time + 1;    
        end
    end
    
endmodule