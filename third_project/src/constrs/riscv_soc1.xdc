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

## LEDs
set_property PACKAGE_PIN P14 [get_ports {segled_pin[0]}]
set_property PACKAGE_PIN U18 [get_ports {segled_pin[1]}]
set_property PACKAGE_PIN U17 [get_ports {segled_pin[2]}]
set_property PACKAGE_PIN AB18 [get_ports {segled_pin[3]}]

set_property PACKAGE_PIN AA18 [get_ports {segled_pin[4]}]
set_property PACKAGE_PIN W17 [get_ports {segled_pin[5]}]
set_property PACKAGE_PIN V17 [get_ports {segled_pin[6]}]
set_property PACKAGE_PIN AB20 [get_ports {segled_pin[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports {segled_pin[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {segled_pin[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {segled_pin[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {segled_pin[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {segled_pin[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {segled_pin[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {segled_pin[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {segled_pin[7]}]


set_property IOSTANDARD LVCMOS33 [get_ports buzzer_pin]
set_property PACKAGE_PIN P20 [get_ports buzzer_pin]
