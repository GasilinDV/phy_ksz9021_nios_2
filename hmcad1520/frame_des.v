module frame_des( CLOCK, DATA_IN_L, DATA_IN_H, DATA_OUT );

	input	CLOCK;
	input [7:0] DATA_IN_L;
	input [7:0] DATA_IN_H;
	output reg [7:0] DATA_OUT;
	
	always @(posedge CLOCK )
   begin
      DATA_OUT <= { DATA_IN_H[3], DATA_IN_H[2], DATA_IN_H[1], DATA_IN_H[0],
		              DATA_IN_L[3], DATA_IN_L[2], DATA_IN_L[1], DATA_IN_L[0]};
	end

endmodule
