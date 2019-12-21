module mixer (
	input frame_clk,
	input [11:0] data_a,
	input [11:0] data_b,
	
	output [11:0] data_mix_out
);

assign data_mix_out = frame_clk ? data_b : data_a ;

endmodule
