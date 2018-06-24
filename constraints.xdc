## Arty Board Constraints
## Based on https://github.com/Digilent/digilent-xdc/blob/master/Arty-Master.xdc

## Clock
set_property -dict {PACKAGE_PIN E3  IOSTANDARD LVCMOS33} [get_ports {CLK}];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {CLK}];

## Reset Button (active low)
set_property -dict {PACKAGE_PIN C2  IOSTANDARD LVCMOS33} [get_ports {RST_BTN}];

## VGA Pmod Header JB
set_property -dict {PACKAGE_PIN E15 IOSTANDARD LVCMOS33} [get_ports {VGA_R[0]}];
set_property -dict {PACKAGE_PIN E16 IOSTANDARD LVCMOS33} [get_ports {VGA_R[1]}];
set_property -dict {PACKAGE_PIN D15 IOSTANDARD LVCMOS33} [get_ports {VGA_R[2]}];
set_property -dict {PACKAGE_PIN C15 IOSTANDARD LVCMOS33} [get_ports {VGA_R[3]}];
set_property -dict {PACKAGE_PIN J17 IOSTANDARD LVCMOS33} [get_ports {VGA_B[0]}];
set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports {VGA_B[1]}];
set_property -dict {PACKAGE_PIN K15 IOSTANDARD LVCMOS33} [get_ports {VGA_B[2]}];
set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports {VGA_B[3]}];

## VGA Pmod Header JC
set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports {VGA_G[0]}];
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports {VGA_G[1]}];
set_property -dict {PACKAGE_PIN V10 IOSTANDARD LVCMOS33} [get_ports {VGA_G[2]}];
set_property -dict {PACKAGE_PIN V11 IOSTANDARD LVCMOS33} [get_ports {VGA_G[3]}];
set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports {VGA_HS_O}];
set_property -dict {PACKAGE_PIN V14 IOSTANDARD LVCMOS33} [get_ports {VGA_VS_O}];