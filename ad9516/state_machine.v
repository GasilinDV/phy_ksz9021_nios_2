module statemachine ( 
		input 		clock,
		input [6:0] data_addr,
		input 		cs_spi,
		output reg 	cs_ad,
		output reg 	data_end 
	);
	
	always @(posedge clock )
   begin
		if(data_addr < 65 )
      begin
			data_end <= 0;
			cs_ad <= cs_spi;
		end
		
		else
		if(data_addr < 72 )	// delay
      begin
			data_end <= 0;
			cs_ad <= 0;
		end
		
		else
		begin
			data_end <= 1;
			cs_ad <= 0;
		end
	end

endmodule
