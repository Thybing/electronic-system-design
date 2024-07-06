## CLK
set_property PACKAGE_PIN W19 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 20.000 [get_ports clk]

## RST_N
set_property PACKAGE_PIN AB21 [get_ports rstn]
set_property IOSTANDARD LVCMOS33 [get_ports rstn]


## UART
set_property PACKAGE_PIN Y22 [get_ports tx_pin]
set_property IOSTANDARD LVCMOS33 [get_ports tx_pin]
set_property PACKAGE_PIN Y21 [get_ports rx_pin]
set_property IOSTANDARD LVCMOS33 [get_ports rx_pin]

## SEG_STATIC
set_property PACKAGE_PIN P14 [get_ports {seg_static_pin[0]}]
set_property PACKAGE_PIN U18 [get_ports {seg_static_pin[1]}]
set_property PACKAGE_PIN U17 [get_ports {seg_static_pin[2]}]
set_property PACKAGE_PIN AB18 [get_ports {seg_static_pin[3]}]

set_property PACKAGE_PIN AA18 [get_ports {seg_static_pin[4]}]
set_property PACKAGE_PIN W17 [get_ports {seg_static_pin[5]}]
set_property PACKAGE_PIN V17 [get_ports {seg_static_pin[6]}]
set_property PACKAGE_PIN AB20 [get_ports {seg_static_pin[7]}]

set_property PACKAGE_PIN P17 [get_ports {seg_scan_pin[0]}]
set_property PACKAGE_PIN P15 [get_ports {seg_scan_pin[1]}]
set_property PACKAGE_PIN R16 [get_ports {seg_scan_pin[2]}]
set_property PACKAGE_PIN N13 [get_ports {seg_scan_pin[3]}]
set_property PACKAGE_PIN N14 [get_ports {seg_scan_pin[4]}]
set_property PACKAGE_PIN P16 [get_ports {seg_scan_pin[5]}]
set_property PACKAGE_PIN R17 [get_ports {seg_scan_pin[6]}]
set_property PACKAGE_PIN N15 [get_ports {seg_scan_pin[7]}]
set_property PACKAGE_PIN N17 [get_ports {seg_cs_pin[3]}]
set_property PACKAGE_PIN T18 [get_ports {seg_cs_pin[2]}]
set_property PACKAGE_PIN R18 [get_ports {seg_cs_pin[1]}]
set_property PACKAGE_PIN R14 [get_ports {seg_cs_pin[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports {seg_static_pin[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_static_pin[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_static_pin[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_static_pin[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_static_pin[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_static_pin[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_static_pin[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_static_pin[7]}]

##SEG_SCAN
set_property IOSTANDARD LVCMOS33 [get_ports {seg_scan_pin[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_scan_pin[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_scan_pin[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_scan_pin[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_scan_pin[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_scan_pin[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_scan_pin[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_scan_pin[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_cs_pin[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_cs_pin[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_cs_pin[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_cs_pin[0]}]

##BUZZER
set_property IOSTANDARD LVCMOS33 [get_ports buzzer_pin]
set_property PACKAGE_PIN P20 [get_ports buzzer_pin]

set_property IOSTANDARD LVCMOS33 [get_ports {button_pin[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {button_pin[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {button_pin[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {button_pin[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {button_pin[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {button_pin[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {button_pin[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {button_pin[0]}]
set_property PACKAGE_PIN C2 [get_ports {button_pin[0]}]
set_property PACKAGE_PIN B2 [get_ports {button_pin[1]}]
set_property PACKAGE_PIN E2 [get_ports {button_pin[2]}]
set_property PACKAGE_PIN D2 [get_ports {button_pin[3]}]
set_property PACKAGE_PIN U22 [get_ports {button_pin[4]}]
set_property PACKAGE_PIN V22 [get_ports {button_pin[5]}]
set_property PACKAGE_PIN T21 [get_ports {button_pin[6]}]
set_property PACKAGE_PIN W20 [get_ports {button_pin[7]}]
