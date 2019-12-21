#***************************************************
# Time Information
#***************************************************
set_time_format -unit ns -decimal_places 3

#***************************************************
# Create Clock
#***************************************************
# Clock constraints
create_clock -period 20 [get_ports adc_fclkp]

create_clock -name {altera_reserved_tck} -period 100.000ns -waveform {0.000ns 50.000ns} [get_ports {altera_reserved_tck}]
create_clock -name "sys_clk" -period 40ns [get_ports {sys_clk}] -waveform {0.000ns 20.000ns}
#create_clock -name "enet_rx_clk" -period 8.000ns -waveform {1.800ns 5.800ns} [get_ports {enet_rx_clk}]
create_clock -name "enet_rx_clk" -period 40.000ns -waveform {1.800ns 5.800ns} [get_ports {enet_rx_clk}]
#create_clock -name "virtual_enet_rx_clk" -period 8.000ns
create_clock -name "virtual_enet_rx_clk" -period 8.000ns

derive_pll_clocks -create_base_clocks
#Automatically calculate clock uncertainty to jitter and other effects. 
derive_clock_uncertainty

#**************************************************
set_clock_groups -exclusive -group {altera_reserved_tck}
set_clock_groups -exclusive -group {sys_clk}
#**************************************************
# Define the clocks that can appear on the output of the TX clock mux
create_generated_clock -name enet_gtx_clk -source [get_pins {eth_module|u7|altpll_component|auto_generated|pll1|clk[1]}] [get_ports {enet_gtx_clk}]
set_clock_groups -exclusive \
    -group [get_clocks {eth_module|u7|altpll_component|auto_generated|pll1|clk[0] enet_gtx_clk} ] \
    -group [get_clocks {enet_rx_clk virtual_enet_rx_clk} ]
#**************************************************
# Set Clock Groups
#**************************************************
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}]
#**************************************************
set_multicycle_path -setup 5 -from [ get_registers *|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|altera_tse_altsyncram_dpm_fifo:U_RTSM|altsyncram*] -to [ get_registers *]
set_multicycle_path -setup 5 -from [ get_registers *|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|altera_tse_retransmit_cntl:U_RETR|*] -to [ get_registers *]
set_multicycle_path -setup 5 -from [ get_registers *] -to [ get_registers *|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|altera_tse_retransmit_cntl:U_RETR|*]
set_multicycle_path -hold 5 -from [ get_registers *|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|altera_tse_altsyncram_dpm_fifo:U_RTSM|altsyncram*] -to [ get_registers *]
set_multicycle_path -hold 5 -from [ get_registers *|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|altera_tse_retransmit_cntl:U_RETR|*] -to [ get_registers *]
set_multicycle_path -hold 5 -from [ get_registers *] -to [ get_registers *|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|altera_tse_retransmit_cntl:U_RETR|*]
set_max_delay 7 -from [get_registers *|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|dout_reg_sft*] -to [get_registers *|altera_tse_top_w_fifo:U_MAC|altera_tse_top_1geth:U_GETH|altera_tse_mac_tx:U_TX|*]
set_max_delay 7 -from [get_registers *|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|eop_sft*] -to [get_registers *|altera_tse_top_w_fifo:U_MAC|altera_tse_top_1geth:U_GETH|altera_tse_mac_tx:U_TX|*]
set_max_delay 7 -from [get_registers *|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|sop_reg*] -to [get_registers *|altera_tse_top_w_fifo:U_MAC|altera_tse_top_1geth:U_GETH|altera_tse_mac_tx:U_TX|*]
#**************************************************
set phy_tco_min -0.5
set phy_tco_max 0.5
set phy_tsu 0.8
set phy_th 0.8
#**************************************************
set_input_delay -clock virtual_enet_rx_clk -max $phy_tco_max [get_ports {enet_rx_d*}]
set_input_delay -clock virtual_enet_rx_clk -min $phy_tco_min [get_ports {enet_rx_d*}]
set_input_delay -clock virtual_enet_rx_clk -clock_fall -max $phy_tco_max [get_ports {enet_rx_d*}] -add_delay
set_input_delay -clock virtual_enet_rx_clk -clock_fall -min $phy_tco_min [get_ports {enet_rx_d*}] -add_delay
#*************************************************
set_false_path -setup -fall_from [get_clocks virtual_enet_rx_clk] -rise_to [get_clocks enet_rx_clk]
set_false_path -setup -rise_from [get_clocks virtual_enet_rx_clk] -fall_to [get_clocks enet_rx_clk]
set_false_path -hold -rise_from [get_clocks virtual_enet_rx_clk] -rise_to [get_clocks enet_rx_clk]
set_false_path -hold -fall_from [get_clocks virtual_enet_rx_clk] -fall_to [get_clocks enet_rx_clk]
#*************************************************
# Output Delay Constraints
#*************************************************
set_output_delay -clock enet_gtx_clk -max $phy_tsu [get_ports {enet_tx_d* enet_tx_en}]
set_output_delay -clock enet_gtx_clk -min $phy_th  [get_ports {enet_tx_d* enet_tx_en}]
set_output_delay -clock enet_gtx_clk -clock_fall -max $phy_tsu [get_ports {enet_tx_d* enet_tx_en}] -add_delay
set_output_delay -clock enet_gtx_clk -clock_fall -min $phy_th [get_ports {enet_tx_d* enet_tx_en}] -add_delay

#**************************************************************
# Asynchronous I/O
#**************************************************************
set_false_path -from [get_ports altera_reserved_tdi]
set_false_path -from [get_ports altera_reserved_tms]
set_false_path -from [get_ports phy_mdio]
#**************************************************************
set_false_path -to [get_ports altera_reserved_tdo]
set_false_path -to [get_ports phy_mdc]
set_false_path -to [get_ports phy_mdio]
set_false_path -to [get_ports reset_n]
#**************************************************************
