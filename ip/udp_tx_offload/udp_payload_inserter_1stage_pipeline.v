//  --------------------------------------------------------------------------------
// | single buffered pipeline stage
//  --------------------------------------------------------------------------------
module udp_payload_inserter_1stage_pipeline
#( parameter PAYLOAD_WIDTH = 8 )
(
    input                          clk,
    input                          reset_n,
    output reg                     in_ready,
    input                          in_valid,
    input      [PAYLOAD_WIDTH-1:0] in_payload,
    input                          out_ready,
    output reg                     out_valid,
    output reg [PAYLOAD_WIDTH-1:0] out_payload
);
/*************************************************************************************************/
always @* begin
    in_ready <= out_ready || ~out_valid;
end
/*************************************************************************************************/
always @ (negedge reset_n, posedge clk) begin
    if (!reset_n) begin
        out_valid <= 1'b0;
        out_payload <= 1'b0;
    end
    else begin
        if (in_valid)
            out_valid <= 1'b1;
        else if (out_ready)
            out_valid <= 1'b0;
        if(in_valid && in_ready)
            out_payload <= in_payload;
    end
end
/*************************************************************************************************/
endmodule