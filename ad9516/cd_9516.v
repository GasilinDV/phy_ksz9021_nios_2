// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //
// top module                                                          //
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //
module cd_9516 (
	// - - - - - - - - - - - - - - - - //
	// external clock                  //
	// - - - - - - - - - - - - - - - - //
	input			clk_25m,

	// - - - - - - - - - - - - - - - - //
	// ad9516-0 clock distribution     //
	// - - - - - - - - - - - - - - - - //
	output		clkd_csn,
		
	// - - - - - - - - - - - - - - - - //
	// s25fl128 flash memory           //
	// - - - - - - - - - - - - - - - - //
	
	// - - - - - - - - - - - - - - - - //
	// other for all                   //
	// - - - - - - - - - - - - - - - - //
	inout			sdata,
	output		sclk
);

wire				sys_clk;
wire 	[15:0]	command;
wire 	[7:0]		data;
wire 				ref_clk, _ref_clk;
wire	[7:0] 	led;
wire 				spi_cs;
wire 				data_end;
wire 				hmend;
wire 				ksend;
wire 				hmini;
wire 				ksini;
wire 				cwork;
wire 	[6:0] 	data_addr;
wire 	[23:0] 	data_to_spi;

// assign reset_n = 1;

false_pll pll ( 	//divider clock on 1024
		.clk (clk_25m),
		.sig (ref_clk),
		._sig (_ref_clk)
	); 

statemachine sm (
		.clock (clk_25m), 
		.data_addr (data_addr), 
		.cs_spi (spi_cs), 
		.cs_ad (clkd_csn),
		.data_end (data_end)
	);
	
adhmrom romini (
	.address( data_addr ),
	.clock(clk_25m),
	.q( data_to_spi )
);

ad9516 spi(
		.clk (ref_clk), 
		.clk_spi (_ref_clk), 
		.adend (data_end),
		.data_to_spi (data_to_spi),
		.spi_miso (sdata),
		.spi_mosi (sdata),
		.spi_clk (sclk), 
		.spi_le (spi_cs), 
		.led (led), 
		.data_addr (data_addr)
	);
	
endmodule
