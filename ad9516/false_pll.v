module false_pll (
		input clk,
		output sig,
		output _sig
	);
	
reg [20:0] counter = 0;

assign sig  = counter[9];
assign _sig = ~sig;

always @(posedge clk)
	if (counter!= 1048576) //<<1'b1
		counter <= counter + 1'b1;
	else
		counter <= 0;
endmodule
