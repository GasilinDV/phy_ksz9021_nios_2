module deserializer (
		input	CLOCK,
		input [15:0] DATA_IN,
		input DATA_READY,
		output reg [11:0] DATA_OUT // 15:0
	);			
		
always @(posedge CLOCK )
begin
	if (DATA_READY )
	begin 
		DATA_OUT <= { 
							DATA_IN[08],DATA_IN[09],DATA_IN[10],DATA_IN[11],
							DATA_IN[00],DATA_IN[01],DATA_IN[02],DATA_IN[03],
							DATA_IN[04],DATA_IN[05],DATA_IN[06],DATA_IN[07] 
						};
	end
end

endmodule
