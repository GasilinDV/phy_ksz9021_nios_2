module phy_nios_2 (
	//input 			clk_25m,
	//input 			adc_dp1a,
	//input 			adc_dp1b,
	//input 			adc_fclkp,
	
	inout 			sdata,
	
	output 			clkd_csn,
	output 			sclk,
	output 			reset_n,
	
	//nios_2_eth
	inout          phy_mdio, 	//spi_data_eth
   output         phy_mdc,		//spi_clock_eth
	 
   input          enet_rx_clk,    
   input          enet_rx_dv,
   input		[3:0]	enet_rx_d,  
   output         enet_gtx_clk,
   output         enet_tx_en,
   output 	[3:0] enet_tx_d,
	
	//global
   input  			led,
   input     		sys_clk,	//25mhz
	
	//epcs
   //output         epcs_asdi,
   //output         epcs_cs_n,
   //output         epcs_dclk,
   //input          epcs_data0,
	
	//GPIO
	output 			GPIO1,	// VD18
	
	output 			GPIO2,	// VD17
	output 			GPIO3,	// VD16
	output 			GPIO4,	// VD15
	output 			GPIO5 	// VD14
	
);
/****************************************************************************************/
localparam adc_ch_num = 8;
localparam adc_ser_factor = 12;
/****************************************************************************************/
//assign reset_n = 1'b1;

reg [3:0] gpio_in;

//wire reset_n_eth;
wire [11:0] data_to_eth;
/****************************************************************************************/
gpio_test test (
	.clk  (sys_clk),
	.gpio (GPIO1)
);
/*
always @ (posedge sys_clk) begin
	if (!reset_n) begin
		GPIO[1] <= 1'b1;
		GPIO[2] <= 1'b1;
		GPIO[3] <= 1'b1;
	end else if (led == 1'b0) begin
		GPIO[1] <= 1'b0;
		GPIO[2] <= 1'b0;
		GPIO[3] <= 1'b0;
	end
end
*/
/****************************************************************************************/
cd_9516 cd (
	.clk_25m ( sys_clk ), //25mhz
	.sdata ( sdata ),
	.clkd_csn ( clkd_csn ),
	.sclk	(sclk)
);
/****************************************************************************************/
/*
hmcad1520 ad (
	.ADC_DP1A (adc_dp1a),
	.ADC_DP1B (adc_dp1b),
	.ADC_FCLKP (adc_fclkp),
	.data_mix_out (data_to_eth)  // 12 bit 25 mhz
);
*/
/****************************************************************************************/
phy_nios_2_cpu eth_module
(
	.frame_clk_data (adc_fclkp),
	.data_control (data_to_eth),
	.reset_n (reset_n),
	.phy_mdio (phy_mdio),
	.phy_mdc (phy_mdc),
	.enet_rx_clk (enet_rx_clk),    
   .enet_rx_dv (enet_rx_dv),
   .enet_rx_d (enet_rx_d),  
   .enet_gtx_clk (enet_gtx_clk),
   .enet_tx_en (enet_tx_en),
   .enet_tx_d (enet_tx_d),
	
	//global
   .led (led),
   .sys_clk (sys_clk),
	
	//epcs
   //.epcs_asdi (epcs_asdi),
   //.epcs_cs_n (epcs_cs_n),
   //.epcs_dclk (epcs_dclk),
   //.epcs_data0 (epcs_data0),
	
	//gpio
	.gpio({GPIO5, GPIO4, GPIO3, GPIO2})

);

endmodule
