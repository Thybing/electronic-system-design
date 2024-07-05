module  seg_show    #(
    parameter   ADDRWIDTH   =   4
)    
(
    //sys
    input           clk     ,
                    rst_n   ,

    //interface to CPU
    input                   wr          ,
    input   [ADDRWIDTH-1:0] waddr       ,
    input   [31:0]          wdata       ,

    input                   rd          ,
    input   [ADDRWIDTH-1:0] raddr       ,
    output  [31:0]          rdata       ,

    //output pin
    output  [3:0]           scan_cs     ,
    output  [7:0]           scan_out    ,
    output  [7:0]           static_out  
);

    localparam  ADDR_SCAN_DATA      =   'h04,
                ADDR_STATIC_DATA    =   'h08;

    //Write Logic

    reg [31:0]      scan_data   ,
                    static_data ;
    
    always@(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            scan_data   <=  'h0;
            static_data <=  'h0;
        end
        else if(wr) begin
            if      (waddr == ADDR_SCAN_DATA    )
                scan_data   <=  wdata;
            else if (waddr == ADDR_STATIC_DATA  )
                static_data <=  wdata;
        end
    end

    //Read Logit
    reg [31:0]  rd_reg;

    always@(posedge clk or negedge rst_n) begin
        if(~rst_n) 
            rd_reg  <=  'h0;
        else begin
            if(rd & (raddr == ADDR_SCAN_DATA))
                rd_reg  <=  scan_data;
            else if(rd & (raddr == ADDR_STATIC_DATA))
                rd_reg  <=  static_data;
            else
                rd_reg  <=  'h0;
        end
    end

    assign  rdata   =   rd_reg;

    //cs
    wire    cs_clk  ;

    clk_div #(
        .cnt_width  (16),
        .div_cnt    (25000)
    )
    u_cs_clk (
        .clk    (clk    )   ,
        .rst_n  (rst_n  )   ,
        .clk_o  (cs_clk )
    );

    reg [3:0]   cs_reg  ;
    reg [7:0]   cur_data    ;
    wire[3:0]   cur_status  ,
                cur_num     ;
    assign  cur_status  =   cur_data[7:4];
    assign  cur_num     =   cur_data[3:0];

    always@(posedge cs_clk  or  negedge rst_n) begin
        if(~rst_n)  begin
            cs_reg  <=  4'h1;
            cur_data <= 'h0;
        end
        else begin
            if(cs_reg == 4'h8) begin
                cs_reg  <=  4'h1;
                cur_data<=  scan_data[7:0];
            end else if (cs_reg == 4'h4) begin
                cs_reg  <=  4'h8;
                cur_data<=  scan_data[31:24];
            end else if (cs_reg == 4'h2) begin
                cs_reg  <=  4'h4;
                cur_data<=  scan_data[23:16];
            end else if (cs_reg == 4'h1) begin
                cs_reg  <=  4'h2;
                cur_data<=  scan_data[15:8];
            end
        end
    end

    assign  scan_cs     =   ~cs_reg     ;

    //seg_led
    assign  static_out  =   static_data[7:0];

    reg [6:0]   a_to_g  ;

    always @(cur_data) begin 
        if(cur_status[3] & ~cur_status[1]) begin
            case(cur_num)
                0: a_to_g= 7'b1111110;
                1: a_to_g= 7'b0110000;
                2: a_to_g= 7'b1101101;
                3: a_to_g= 7'b1111001;
                4: a_to_g= 7'b0110011;
                5: a_to_g= 7'b1011011;
                6: a_to_g= 7'b1011111;
                7: a_to_g= 7'b1110000;
                8: a_to_g= 7'b1111111;
                9: a_to_g= 7'b1111011;
                'hA: a_to_g= 7'b1110111;
                'hB: a_to_g= 7'b0011111;
                'hC: a_to_g= 7'b1001110;
                'hD: a_to_g= 7'b0111101;
                'hE: a_to_g= 7'b1001111;
                'hF: a_to_g= 7'b1000111;
                default: a_to_g= 7'b1111110;// 0
            endcase
        end
        else if(cur_status[3] & cur_status[1]) begin
            case(cur_num)
                default: a_to_g= 7'b0000001;// -
            endcase
        end
        else begin
            a_to_g = 7'b0000000;
        end
    end

    assign  scan_out    =   {a_to_g,cur_status[2]};
endmodule