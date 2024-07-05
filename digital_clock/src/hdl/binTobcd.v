module binTobcd(
    input     wire         [7:0]     bin,
    output    wire         [11:0]    bcd
);

    wire         [19:0]    part_0;
    wire         [19:0]    part_1;
    wire         [19:0]    part_2;
    wire         [19:0]    part_3;
    wire         [19:0]    part_4;
    wire         [19:0]    part_5;
    wire         [19:0]    part_6;
    wire         [19:0]    part_7;

    adjust_shift adjust_shift_inst0(.idata    ({12'd0, bin}),   .odata(part_0));
    adjust_shift adjust_shift_inst1(.idata    (part_0),         .odata(part_1));
    adjust_shift adjust_shift_inst2(.idata    (part_1),         .odata(part_2));
    adjust_shift adjust_shift_inst3(.idata    (part_2),         .odata(part_3));
    adjust_shift adjust_shift_inst4(.idata    (part_3),         .odata(part_4));
    adjust_shift adjust_shift_inst5(.idata    (part_4),         .odata(part_5));
    adjust_shift adjust_shift_inst6(.idata    (part_5),         .odata(part_6));
    adjust_shift adjust_shift_inst7(.idata    (part_6),         .odata(part_7));

    assign bcd = part_7[19:8];

endmodule