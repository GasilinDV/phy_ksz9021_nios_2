module gpio_test (
	input  				clk,
	output reg 			gpio
);
reg [26:0] counter;

always @ (posedge clk) begin
	if (counter[26] == 1'b1)
		gpio <= 1'b0;
	else begin
		gpio <= 1'b1;
	end
	counter <= counter + 1'b1;
end
endmodule
