module phy_nios_2_cpu
(
	 input						 frame_clk_data,
    input          	[11:0] data_control,		 
/* control */
    output  wire            reset_n,
/* eth */
    inout                   phy_mdio,
    output                  phy_mdc,
    input                   enet_rx_clk,    
    input                   enet_rx_dv,
    input             [3:0] enet_rx_d,  
    output                  enet_gtx_clk,
    output                  enet_tx_en,
    output            [3:0] enet_tx_d,
/* global */
    input             		 led,
    input                   sys_clk,
/* epcs */
    //output                  epcs_asdi,
    //output                  epcs_cs_n,
    //output                  epcs_dclk,
    //input                   epcs_data0,

/* gpio */
	 output 			 [3:0] gpio
	 
	 //output reg mdio_my
);

/****************************************************************************************/
wire            mac_mdi;
wire            mac_mdo;
wire            mac_oe;
wire            enet_link1000;
wire            enet_link10;
wire            tx_clk;
wire            enet_tx_125;
wire            enet_tx_25;
wire            enet_tx_2p5;
wire            gtx_pll_ref;
wire            gtx_pll_125;
wire            gtx_pll_25;
wire            gtx_pll_2p5;
wire            ena_10;
wire            eth_mode;
wire            [1:0] sel;
wire            enet_pll_locked;

/****************************************************************************************/
//assign tx_clk       =   (eth_mode) ? (enet_tx_125) :       // GbE Mode = 125MHz clock
//                        (ena_10) ? (enet_tx_2p5) :         // 10Mb Mode = 2.5MHz clock
//                        (enet_tx_25);                      // 100Mb Mode = 25MHz clock
assign tx_clk = enet_tx_125;

//assign enet_gtx_clk = tx_clk;
//assign enet_gtx_clk =   (eth_mode) ? (gtx_pll_125) :       // GbE Mode = 125MHz clock
//                        (ena_10) ? (gtx_pll_25) :          // 10Mb Mode = 2.5MHz clock
//                        (gtx_pll_2p5);                     // 100Mb Mode = 25MHz clock
/****************************************************************************************/
// (* keep *) reg mdio_reg;
// always @ (posedge phy_mdc) begin
// mdio_reg <= mac_mdo /* synthesis preserve */;
//	mdio_my <= phy_mdio /* synthesis keep */;
// end
/****************************************************************************************/
cpu u0
(
    .eth_0_tse_conduit_rgmii_in(enet_rx_d),
    .eth_0_tse_conduit_rgmii_out(enet_tx_d),
    .eth_0_tse_conduit_rx_control(enet_rx_dv),
    .eth_0_tse_conduit_tx_control(enet_tx_en),
    .eth_0_tse_conduit_tx_clk(tx_clk),
    .eth_0_tse_conduit_rx_clk(enet_rx_clk),
    .eth_0_tse_conduit_set_10(1'b0),//enet_link10),
    .eth_0_tse_conduit_set_1000(1'b1),//enet_link1000),
    .eth_0_tse_conduit_ena_10(ena_10),
    .eth_0_tse_conduit_eth_mode(eth_mode),
    .eth_0_tse_conduit_mdio_out(mac_mdo),
    .eth_0_tse_conduit_mdio_oen(mac_oe),
    .eth_0_tse_conduit_mdio_in(mac_mdi),
    .eth_0_tse_conduit_mdc(phy_mdc),
    .pio_0_export(reset_n),

    .clk_clk(sys_clk),
	 .leds_export(gpio)
	 
	 //.epcs_0_external_dclk(epcs_dclk),
    //.epcs_0_external_sce(epcs_cs_n),
    //.epcs_0_external_sdo(epcs_asdi),
    //.epcs_0_external_data0(epcs_data0)
);

/****************************************************************************************/
/*
ALT_IOBUF u2
(
    .i(spi_dout),
    .oe(spi_csn[5]),
    .o(spi_din),
    .io(sdata)
);
*/
/****************************************************************************************/
/*
ALT_IOBUF u5
(
    .i(mac_mdo),
    .oe(!mac_oe),
    .o(mac_mdi),
    .io(phy_mdio)
);
defparam u5.io_standard = "2.5V";
defparam u5.current_strength = "minimum current";
defparam u5.enable_bus_hold = "on";
defparam u5.weak_pull_up_resistor = "off";
*/
/****************************************************************************************/
ALT_IOBUF2_iobuf_bidir_oto u5
(
	.datain(mac_mdo),
	.oe(!mac_oe),
	.dataout(mac_mdi),
	.dataio(phy_mdio)
);
/****************************************************************************************/
enet_pll u7
(
	.inclk0(sys_clk),
	.c0(enet_tx_125),
   .c1(enet_gtx_clk),
//	.c1(enet_tx_25),
//	.c2(enet_tx_2p5),
//    .c3(gtx_pll_ref),
   .locked(enet_pll_locked)
);

/****************************************************************************************/
endmodule
