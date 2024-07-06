module  button_single(
    input       clk_1k      ,
                rst_n       ,
                button_pin  ,
    output      out_level_n   
);

    reg [7:0]   filter_cnt  ;
    reg         out_reg     ,
                pre_level   ;
    always @(posedge clk_1k or negedge rst_n) begin
        if(~rst_n) begin
            out_reg     <=  'h1;
            filter_cnt  <=  'h0;
            pre_level   <=  'h0;
        end
        else begin
            if(button_pin != pre_level) begin
                pre_level   <=  button_pin;
                filter_cnt  <=  'h0;
            end
            else if(filter_cnt >= 'd50) begin
                out_reg     <=  button_pin;
            end
            else begin
                filter_cnt  <=   filter_cnt + 1;
            end
        end
    end

    assign out_level_n = out_reg;

endmodule