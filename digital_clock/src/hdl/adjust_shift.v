module adjust_shift(
    input     wire         [19:0]    idata,
    output    wire         [19:0]    odata
);

    wire     [19:0]        adjust_data;

    assign adjust_data[19:16]       = idata[19:16] > 4'd4 ? idata[19:16] + 4'd3 : idata[19:16];
    assign adjust_data[15:12]       = idata[15:12] > 4'd4 ? idata[15:12] + 4'd3 : idata[15:12];
    assign adjust_data[11:8]        = idata[11:8] > 4'd4 ? idata[11:8] + 4'd3 : idata[11:8];
    assign adjust_data[7:0]         = idata[7:0];

    assign odata    = adjust_data << 1'b1;

endmodule