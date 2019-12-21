module hmcad1520 (
	//input wire 	CLK_50MHz,
	input wire		ADC_DP1A ,
	input wire		ADC_DP1B ,
	input wire		ADC_FCLKP,
	output [11:0]	data_mix_out
);

wire				c1_75_mhz_180_deg ;
wire				data_ready_a1 ;
wire	[15:0] 	data_vector_b1 ;
wire	[11:0] 	data_out_ch_a1 ;
wire	[11:0] 	data_out_ch_b1 ;
wire				c0_150_mhz;
wire	[7:0] 	lvds_fr_out ;
wire	[7:0] 	lvds_rx_out_ch_a1 ;
wire				data_ready_b1 ;
wire	[15:0] 	data_vector_a1 ;
wire	[7:0] 	lvds_rx_out_ch_b1 ;

deserializer des_ch_b1 (
		.CLOCK ( c1_75_mhz_180_deg ),
		.DATA_READY ( data_ready_b1 ),
		.DATA_IN ( data_vector_b1 ),
		.DATA_OUT ( data_out_ch_b1 )
	);

mixer	mix_ch_a_b (
		.frame_clk ( ADC_FCLKP ),
		.data_a ( data_out_ch_a1 ),
		.data_b ( data_out_ch_b1 ),
		.data_mix_out (data_mix_out)
	);

ALTLVDS_RX lvds_rx_ch_a1 (
		.rx_inclock (c0_150_mhz),
		.rx_in (ADC_DP1A),
		.rx_out ( lvds_rx_out_ch_a1 )
	);
defparam		lvds_rx_ch_a1.buffer_implementation = "RAM";
defparam		lvds_rx_ch_a1.common_rx_tx_pll = "OFF";
defparam		lvds_rx_ch_a1.data_align_rollover = 4;
defparam		lvds_rx_ch_a1.data_rate = "150.0 Mbps";
defparam		lvds_rx_ch_a1.deserialization_factor = 8;
defparam		lvds_rx_ch_a1.dpa_initial_phase_value = 0;
defparam		lvds_rx_ch_a1.dpll_lock_count = 0;
defparam		lvds_rx_ch_a1.dpll_lock_window = 0;
defparam		lvds_rx_ch_a1.enable_dpa_align_to_rising_edge_only = "OFF";
defparam		lvds_rx_ch_a1.enable_dpa_calibration = "ON";
defparam		lvds_rx_ch_a1.enable_dpa_initial_phase_selection = "OFF";
defparam		lvds_rx_ch_a1.enable_dpa_mode = "OFF";
defparam		lvds_rx_ch_a1.enable_dpa_pll_calibration = "OFF";
defparam		lvds_rx_ch_a1.enable_soft_cdr_mode = "OFF";
defparam		lvds_rx_ch_a1.implement_in_les = "ON";
defparam		lvds_rx_ch_a1.inclock_boost = 0;
defparam		lvds_rx_ch_a1.inclock_data_alignment = "EDGE_ALIGNED";
defparam		lvds_rx_ch_a1.inclock_period = 5000;
defparam		lvds_rx_ch_a1.inclock_phase_shift = 0;
defparam		lvds_rx_ch_a1.input_data_rate = 150;
defparam		lvds_rx_ch_a1.intended_device_family = "Cyclone IV E";
defparam		lvds_rx_ch_a1.lose_lock_on_one_change = "UNUSED";
defparam		lvds_rx_ch_a1.lpm_hint = "CBX_MODULE_PREFIX=lvds_rx_ch_a1";
defparam		lvds_rx_ch_a1.lpm_type = "ALTLVDS_RX";
defparam		lvds_rx_ch_a1.number_of_channels = 1;
defparam		lvds_rx_ch_a1.outclock_resource = "AUTO";
defparam		lvds_rx_ch_a1.registered_output = "OFF";
defparam		lvds_rx_ch_a1.sim_dpa_is_negative_ppm_drift = "OFF";
defparam		lvds_rx_ch_a1.sim_dpa_net_ppm_variation = 0;
defparam		lvds_rx_ch_a1.sim_dpa_output_clock_phase_shift = 0;
defparam		lvds_rx_ch_a1.use_coreclock_input = "OFF";
defparam		lvds_rx_ch_a1.use_dpll_rawperror = "OFF";
defparam		lvds_rx_ch_a1.use_external_pll = "ON";
defparam		lvds_rx_ch_a1.use_no_phase_shift = "ON";
defparam		lvds_rx_ch_a1.x_on_bitslip = "ON";
defparam		lvds_rx_ch_a1.clk_src_is_pll = "off";

DataRegen dataregen_a1 (
		.DivClk ( c1_75_mhz_180_deg ),
		.FrameVector ( lvds_fr_out ),
		.RawData ( lvds_rx_out_ch_a1 ),
		.DataReady ( data_ready_a1 ),
		.DataVector ( data_vector_a1 )
	);
	
ALTLVDS_RX lvds_fr_all_ch (
		.rx_inclock (c0_150_mhz),
		.rx_in(ADC_FCLKP),
		.rx_out( lvds_fr_out )
	);
defparam		lvds_fr_all_ch.buffer_implementation = "RAM";
defparam		lvds_fr_all_ch.common_rx_tx_pll = "OFF";
defparam		lvds_fr_all_ch.data_align_rollover = 4;
defparam		lvds_fr_all_ch.data_rate = "800.0 Mbps";
defparam		lvds_fr_all_ch.deserialization_factor = 8;
defparam		lvds_fr_all_ch.dpa_initial_phase_value = 0;
defparam		lvds_fr_all_ch.dpll_lock_count = 0;
defparam		lvds_fr_all_ch.dpll_lock_window = 0;
defparam		lvds_fr_all_ch.enable_dpa_align_to_rising_edge_only = "OFF";
defparam		lvds_fr_all_ch.enable_dpa_calibration = "ON";
defparam		lvds_fr_all_ch.enable_dpa_initial_phase_selection = "OFF";
defparam		lvds_fr_all_ch.enable_dpa_mode = "OFF";
defparam		lvds_fr_all_ch.enable_dpa_pll_calibration = "OFF";
defparam		lvds_fr_all_ch.enable_soft_cdr_mode = "OFF";
defparam		lvds_fr_all_ch.implement_in_les = "ON";
defparam		lvds_fr_all_ch.inclock_boost = 0;
defparam		lvds_fr_all_ch.inclock_data_alignment = "EDGE_ALIGNED";
defparam		lvds_fr_all_ch.inclock_period = 5000;
defparam		lvds_fr_all_ch.inclock_phase_shift = 0;
defparam		lvds_fr_all_ch.input_data_rate = 800;
defparam		lvds_fr_all_ch.intended_device_family = "Cyclone IV E";
defparam		lvds_fr_all_ch.lose_lock_on_one_change = "UNUSED";
defparam		lvds_fr_all_ch.lpm_hint = "CBX_MODULE_PREFIX=lvds_fr_all_ch";
defparam		lvds_fr_all_ch.lpm_type = "ALTLVDS_RX";
defparam		lvds_fr_all_ch.number_of_channels = 1;
defparam		lvds_fr_all_ch.outclock_resource = "AUTO";
defparam		lvds_fr_all_ch.registered_output = "OFF";
defparam		lvds_fr_all_ch.sim_dpa_is_negative_ppm_drift = "OFF";
defparam		lvds_fr_all_ch.sim_dpa_net_ppm_variation = 0;
defparam		lvds_fr_all_ch.sim_dpa_output_clock_phase_shift = 0;
defparam		lvds_fr_all_ch.use_coreclock_input = "OFF";
defparam		lvds_fr_all_ch.use_dpll_rawperror = "OFF";
defparam		lvds_fr_all_ch.use_external_pll = "ON";
defparam		lvds_fr_all_ch.use_no_phase_shift = "ON";
defparam		lvds_fr_all_ch.x_on_bitslip = "ON";
defparam		lvds_fr_all_ch.clk_src_is_pll = "off";	
	

deserializer des_ch_a1 (
		.CLOCK ( c1_75_mhz_180_deg ),
		.DATA_READY ( data_ready_a1 ),
		.DATA_IN ( data_vector_a1 ),
		.DATA_OUT ( data_out_ch_a1 )
	);

pll_rx pll_rx_all_ch (
		.inclk0 ( ADC_FCLKP ),
		.c0 ( c0_150_mhz ),
		.c1 ( c1_75_mhz_180_deg )
	);

ALTLVDS_RX lvds_rx_ch_b1 (
		.rx_inclock ( c0_150_mhz ),
		.rx_in ( ADC_DP1B ),
		.rx_out ( lvds_rx_out_ch_b1 )
	);
defparam		lvds_rx_ch_b1.buffer_implementation = "RAM";
defparam		lvds_rx_ch_b1.common_rx_tx_pll = "OFF";
defparam		lvds_rx_ch_b1.data_align_rollover = 4;
defparam		lvds_rx_ch_b1.data_rate = "150.0 Mbps";
defparam		lvds_rx_ch_b1.deserialization_factor = 8;
defparam		lvds_rx_ch_b1.dpa_initial_phase_value = 0;
defparam		lvds_rx_ch_b1.dpll_lock_count = 0;
defparam		lvds_rx_ch_b1.dpll_lock_window = 0;
defparam		lvds_rx_ch_b1.enable_dpa_align_to_rising_edge_only = "OFF";
defparam		lvds_rx_ch_b1.enable_dpa_calibration = "ON";
defparam		lvds_rx_ch_b1.enable_dpa_initial_phase_selection = "OFF";
defparam		lvds_rx_ch_b1.enable_dpa_mode = "OFF";
defparam		lvds_rx_ch_b1.enable_dpa_pll_calibration = "OFF";
defparam		lvds_rx_ch_b1.enable_soft_cdr_mode = "OFF";
defparam		lvds_rx_ch_b1.implement_in_les = "ON";
defparam		lvds_rx_ch_b1.inclock_boost = 0;
defparam		lvds_rx_ch_b1.inclock_data_alignment = "EDGE_ALIGNED";
defparam		lvds_rx_ch_b1.inclock_period = 5000;
defparam		lvds_rx_ch_b1.inclock_phase_shift = 0;
defparam		lvds_rx_ch_b1.input_data_rate = 150;
defparam		lvds_rx_ch_b1.intended_device_family = "Cyclone IV E";
defparam		lvds_rx_ch_b1.lose_lock_on_one_change = "UNUSED";
defparam		lvds_rx_ch_b1.lpm_hint = "CBX_MODULE_PREFIX=lvds_rx_ch_b1";
defparam		lvds_rx_ch_b1.lpm_type = "ALTLVDS_RX";
defparam		lvds_rx_ch_b1.number_of_channels = 1;
defparam		lvds_rx_ch_b1.outclock_resource = "AUTO";
defparam		lvds_rx_ch_b1.registered_output = "OFF";
defparam		lvds_rx_ch_b1.sim_dpa_is_negative_ppm_drift = "OFF";
defparam		lvds_rx_ch_b1.sim_dpa_net_ppm_variation = 0;
defparam		lvds_rx_ch_b1.sim_dpa_output_clock_phase_shift = 0;
defparam		lvds_rx_ch_b1.use_coreclock_input = "OFF";
defparam		lvds_rx_ch_b1.use_dpll_rawperror = "OFF";
defparam		lvds_rx_ch_b1.use_external_pll = "ON";
defparam		lvds_rx_ch_b1.use_no_phase_shift = "ON";
defparam		lvds_rx_ch_b1.x_on_bitslip = "ON";
defparam		lvds_rx_ch_b1.clk_src_is_pll = "off";
	
DataRegen dataregen_b1 (
		.DivClk ( c1_75_mhz_180_deg ),
		.FrameVector ( lvds_fr_out ),
		.RawData ( lvds_rx_out_ch_b1 ),
		.DataReady ( data_ready_b1 ),
		.DataVector ( data_vector_b1 )
	);

endmodule
