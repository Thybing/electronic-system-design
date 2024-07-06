module alarm #(
    parameter   ADDRWIDTH   =   4
)
(
    input               clk     ,
                        rst_n   ,

    input                   wr      ,
    input   [ADDRWIDTH-1:0] waddr   ,
    input   [31:0]          wdata   ,

    input                   rd      ,
    input   [ADDRWIDTH-1:0] raddr   ,
    output  [31:0]          rdata    
);
    localparam  ADDR_STATUS     =   'h04,
                ADDR_TIME       =   'h08;

    //Write Logic
    reg [31:0]      status,
                    tar_time,

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            status      <=  'h0;
            tar_time    <=  'h0;
        end
        else if(wr) begin
            if(waddr == ADDR_STATUS)
                status      <=  wdata;
            else if (waddr == ADDR_TIME)
                tar_time    <=  wdata;
        end 
    end

    //Read Logic
    reg [31:0]      rd_reg;
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            rd_reg      <=  'h0;
        else if(rd) begin
            if(raddr == ADDR_STATUS)
                rd_reg  <=  status  ;
            else if(raddr   ==  ADDR_TIME)
                rd_reg  <=  tar_time;
            else
                rd_reg  <=  'h0;
        end
    end
    assign  rdata   =   rd_reg;


endmodule