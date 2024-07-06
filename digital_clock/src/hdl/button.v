
module button #(
    parameter   ADDRWIDTH   =   4
)
(
    input       clk     ,
                rst_n   ,
    
    // input                   wr      ,
    // input   [ADDRWIDTH-1:0] waddr   ,
    // input   [31:0]          wdata   ,

    input                   rd      ,
    input   [ADDRWIDTH-1:0] raddr   ,
    output  [31:0]          rdata   ,

    input   [7:0]   button_pin  
);
    localparam  ADDR_LEVEL  =   'h04;

    wire [7:0] out_level;

    //Read Logic
    reg [31:0] rd_reg;

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            rd_reg  <=  'h0;
        else if(rd) begin
            if(raddr == ADDR_LEVEL)
                rd_reg  <=  {24'h0,out_level};
            else
                rd_reg  <=  'h0;
        end
    end

    assign  rdata   =   rd_reg;

    //filter
    wire        filter_clk; //1khz

    button_single button_0(
        .clk_1k(filter_clk),
        .rst_n(rst_n),
        .button_pin(button_pin[0]),
        .out_level_n(out_level[0])
    );
    button_single button_1(
        .clk_1k(filter_clk),
        .rst_n(rst_n),
        .button_pin(button_pin[1]),
        .out_level_n(out_level[1])
    );
    button_single button_2(
        .clk_1k(filter_clk),
        .rst_n(rst_n),
        .button_pin(button_pin[2]),
        .out_level_n(out_level[2])
    );
    button_single button_3(
        .clk_1k(filter_clk),
        .rst_n(rst_n),
        .button_pin(button_pin[3]),
        .out_level_n(out_level[3])
    );
    button_single button_4(
        .clk_1k(filter_clk),
        .rst_n(rst_n),
        .button_pin(button_pin[4]),
        .out_level_n(out_level[4])
    );
    button_single button_5(
        .clk_1k(filter_clk),
        .rst_n(rst_n),
        .button_pin(button_pin[5]),
        .out_level_n(out_level[5])
    );
    button_single button_6(
        .clk_1k(filter_clk),
        .rst_n(rst_n),
        .button_pin(button_pin[6]),
        .out_level_n(out_level[6])
    );
    button_single button_7(
        .clk_1k(filter_clk),
        .rst_n(rst_n),
        .button_pin(button_pin[7]),
        .out_level_n(out_level[7])
    );


    clk_div #(
        .cnt_width  (16),
        .div_cnt    (25000)
    )
    u_filter_clk (
        .clk    (clk        )   ,
        .rst_n  (rst_n      )   ,
        .clk_o  (filter_clk )
    );

endmodule