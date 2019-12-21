module ad9516 (
		input clk, 
		input clk_spi, 
		input adend,
		input [23:0] data_to_spi,
		input spi_miso, 
		
		output reg spi_mosi,
		output spi_clk, 
		output spi_le, 
		output [7:0] led, 
		output reg [6:0] data_addr
 );

// AD9516-0 Register setup

// Module state
localparam	SM_IDLE		  =	 8'd00,
				SM_WAIT       =    8'd73,
				SM_CONFIG     =    8'd74,
				SM_STOP       =    8'd75,
				SM_READ       =    8'd76,
				SM_ADDR       =    8'd77;
	
	reg[23:0] spi_data;
	
   reg[7:0]  sm = 8'h00;
   reg[7:0]  sm_next;
   reg[7:0]  config_count;
   reg       spi_le_wr;
   reg       spi_clken;
    
   reg[7:0] led_r = 8'hff;
               
   assign spi_clk   = spi_clken ? clk_spi : 1'b0;
   assign spi_le    = spi_le_wr;
    
   assign led[7:0]  = led_r[7:0];
	

	always @(posedge spi_clk )
   begin
   if(sm == SM_READ)
   begin
		if(config_count > 16 && config_count <= 24)
			begin
				led_r[0] <= spi_miso;
				led_r[7:1] <= led_r[6:0];
			end
	end
   end
     
	always@( posedge clk )
	case(sm)
		SM_CONFIG:
			if(config_count >= 128)
				begin
					config_count <= 8'h0;
					sm <= sm_next;
            end
        else if(config_count >= 24)
            begin
					spi_clken <= 1'b0;
					config_count <= config_count + 1'b1;
					spi_le_wr <= 1'b1;
            end
        else    
            begin
					spi_clken <= 1'b1;
					spi_le_wr <= 1'b0;
					config_count <= config_count+1'b1;
					spi_mosi <= spi_data[23];
					spi_data <= spi_data << 1'b1;
            end
		SM_READ:
			if(config_count >= 128)
            begin
					config_count <= 8'h0;
					sm <= sm_next;
				end
			else if(config_count >= 24)
				begin
					spi_clken <= 1'b0;
               config_count <= config_count + 1'b1;
               spi_le_wr <= 1'b1;
				end
			else
				begin
					spi_clken <= 1'b1;
               spi_le_wr <= 1'b0;
               config_count <= config_count + 1'b1;
               spi_mosi <= spi_data[23];
               spi_data <= spi_data << 1'b1;
				end
				
		SM_WAIT:
			begin
				if(spi_data >= 300) //1s
                sm <= sm_next;
            else
                spi_data <= spi_data + 1'b1;
			end
            
		SM_IDLE:
			begin
            sm <= SM_ADDR; // 0
            config_count <= 8'h00;
				data_addr <= 7'h00;
			end
			
		SM_ADDR:
			begin
            spi_data <= data_to_spi;
            sm <= SM_CONFIG;
            sm_next <= SM_ADDR;
				data_addr <= data_addr + 1'b1;
				if( adend )
            begin
					sm <= SM_WAIT;
					sm_next <= SM_STOP; 
				end
			end
     
		SM_STOP:
			begin
            sm <= sm_next;
			end
		default:
			sm <= SM_IDLE;
    endcase

endmodule
