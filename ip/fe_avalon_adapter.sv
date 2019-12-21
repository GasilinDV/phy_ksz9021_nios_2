module fe_avalon_adapter
/****************************************************************************************/
#(parameter dw = 12, base_count = 3)
/****************************************************************************************/
(
    output  reg [dw - 1:0]              shift_table[base_count],
    // clock interface
    input                               csi_clock_clk,
    input                               csi_clock_reset,
    // csr slave interface
    input                               avs_s1_write,
    input                               avs_s1_read,
    input   [$clog2(base_count) - 1:0]  avs_s1_address,
    input   [31:0]                      avs_s1_writedata,
    output  reg [31:0]                  avs_s1_readdata
);
/****************************************************************************************/
integer i;
/****************************************************************************************/
always_ff @(posedge csi_clock_clk) begin
    if (csi_clock_reset) begin
        for(i = 0; i < base_count; i++)
            shift_table[i] = '0;
    end
    else begin
        if(avs_s1_write) begin
            shift_table[avs_s1_address] = avs_s1_writedata[dw - 1:0];
        end
    end
end
/****************************************************************************************/
always_ff @(posedge csi_clock_clk or posedge csi_clock_reset) begin
    if (csi_clock_reset) begin
        avs_s1_readdata = '0;
    end
    else begin
        if(avs_s1_read) begin
            avs_s1_readdata = {{(32 - dw){1'b0}}, shift_table[avs_s1_address]};
        end
    end
end
/****************************************************************************************/
endmodule
