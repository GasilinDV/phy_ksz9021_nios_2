//
//  udp_payload_inserter
//
//  This component inserts a predefined raw packet payload into a fully framed
//  UDP packet for transport via Ethernet.  This means that the MAC header, IP
//  header and UDP header are all manufactured and prepended to the raw payload
//  data of the incoming packet.  The input and output for the packet data
//  streamed thru this component are provided by an Avalon ST sink and source
//  interface.  Configuration of this component is provided by an Avalon MM
//  slave interface.
//
//  The standard format of each of the header layers is illustrated below, you
//  can think of each layer being wrapped in the payload section of the layer
//  above it, with the Ethernet packet layout being the outer most wrapper.
//  
//  Standard Ethernet Packet Layout
//  |-------------------------------------------------------|
//  |                Destination MAC Address                |
//  |                           ----------------------------|
//  |                           |                           |
//  |----------------------------                           |
//  |                  Source MAC Address                   |
//  |-------------------------------------------------------|
//  |         EtherType         |                           |
//  |----------------------------                           |
//  |                                                       |
//  |                   Ethernet Payload                    |
//  |                                                       |
//  |-------------------------------------------------------|
//
//  Standard IP Packet Layout
//  |-------------------------------------------------------|
//  | VER  | HLEN |     TOS     |       Total Length        |
//  |-------------------------------------------------------|
//  |       Identification      | FLGS |    FRAG OFFSET     |
//  |-------------------------------------------------------|
//  |     TTL     |    PROTO    |      Header Checksum      |
//  |-------------------------------------------------------|
//  |                   Source IP Address                   |
//  |-------------------------------------------------------|
//  |                Destination IP Address                 |
//  |-------------------------------------------------------|
//  |                                                       |
//  |                      IP Payload                       |
//  |                                                       |
//  |-------------------------------------------------------|
//
//  Standard UDP Packet Layout
//  |-------------------------------------------------------|
//  |      Source UDP Port      |   Destination UDP Port    |
//  |-------------------------------------------------------|
//  |    UDP Message Length     |       UDP Checksum        |
//  |-------------------------------------------------------|
//  |                                                       |
//  |                      UDP Payload                      |
//  |                                                       |
//  |-------------------------------------------------------|
//
//  Proprietary RAW Input Packet Layout
//  |-------------------------------------------------------|
//  |       Packet Length       |                           |
//  |----------------------------                           |
//  |                                                       |
//  |                    Packet Payload                     |
//  |                                                       |
//  |-------------------------------------------------------|
//
//  The general packet assembly flows like this:
//  
//  This component begins by receiving the RAW input packet on its Avalon ST
//  interface, extracting and discarding the Packet Length field after
//  providing the length value to the UDP header layer such that the UDP
//  Message Length is now known.  The UDP Checksum field is zero'ed as this
//  component does not compute the UDP Checksum.  The Source UDP Port and
//  Destination UDP Port are known from user programmable registers within the
//  component.  Once the UDP Message Length is known, this is communicated
//  to the IP header so that the Total Length value is known.  Once the Total
//  Length value is known, the IP Header Checksum is computed.  The Source IP
//  Address and Destination IP Address are known from user programmable
//  registers within the component.  The Protocol field is set to UDP, the TTL
//  field is set to 255, the Fragment Offset field is set to ZERO, the Flags
//  are set to "do not fragment", the Identification field is set to ZERO, the
//  TOS field is set to ZERO, the Header Length field is set to 5, and the
//  Version field is set to 4.  At the MAC layer, the Destination MAC Address
//  and Source MAC Address are known from user programmable registers within
//  the component, and the EtherType field is set to 0x0800 for IPV4.
//  
//  The Ethernet Frame is transmitted out the Avalon ST source interface with
//  the Ethernet MAC header followed by the IP header, followed by the UDP
//  header and finally the RAW input packet payload.  The minimum size of an
//  Ethernet packet is 46 payload bytes, the IP header and UDP header consume
//  28 bytes, so if there are not at least 18 bytes of RAW packet payload, the
//  output packet is padded with up to 18 bytes of UDP Payload such that a
//  valid minimum sized Ethernet packet is transmitted.  The maximum size of
//  the Ethernet payload is 1500 bytes, so the largest valid size for the RAW
//  input packet payload is 1472 bytes, anything larger would result in an
//  invalid Ethernet packet length.  There are no checks built into the
//  hardware of this component that ensure the input packet length is within
//  proper limits, so the user should take care not to exceed packet lengths of
//  1472 bytes for input packet payload.  The minimum valid packet length is
//  ZERO, for the RAW input packet payload.
//
//  ---------------------------------------------------------------------------
//  Register Map
//  ---------------------------------------------------------------------------
//  
//  The slave interface for the udp_payload_inserter is broken up into eight
//  32-bit registers with the following layout:
//  
//  Register 0 - Status Register
//      Bit 0 - R/W - GO control and status bit.  Set this bit to 1 to enable
//                  the payload inserter, and clear it to disable it.
//      Bit 1 - RO  - Running status bit.  This bit indicates whether the
//                  peripheral is currently running or not.  After clearing the
//                  GO bit, you can monitor this status bit to tell when the
//                  inserter is actually stopped.
//      Bit 2 - RO  - Error status bit.  This bit indicates that an error
//                  occurred in the component.  There is only one error
//                  detected by this component, an Avalon ST protocol violation.
//                  When this component is enabled, it expect the first Avalon
//                  ST word that it receives on its sink interface to be the
//                  startofpacket, and when it receives an endofpacket word, it
//                  expects the next word to be the startofpacket for the next
//                  packet.  If this sequencing is not observed, then the Error
//                  status is asserted and the component's GO bit must be
//                  cleared to reset the error condition.
//      
//  Register 1 - Destination MAC HI Register
//      Bits [31:0] - R/W - these are the 32 most significant bits of the
//                  destination MAC address.  MAC bits [47:16] in reversed order (see TSE).
//                  
//  Register 2 - Destination MAC LO Register
//      Bits [15:0] - R/W - these are the 16 least significant bits of the
//                  destination MAC address.  MAC bits [15:0] in reversed order (see TSE).
//                  
//  Register 3 - Source MAC HI Register
//      Bits [31:0] - R/W - these are the 32 most significant bits of the
//                  source MAC address.  MAC bits [47:16] in reversed order (see TSE).
//                  
//  Register 4 - Source MAC LO Register
//      Bits [15:0] - R/W - these are the 16 least significant bits of the
//                  source MAC address.  MAC bits [15:0] in reversed order (see TSE).
//                  
//  Register 5 - Source IP Address Register
//      Bits [31:0] - R/W - this is the source IP adddress for the IP header
//                  
//  Register 6 - Destination IP Address Register
//      Bits [31:0] - R/W - this is the destination IP adddress for the IP header
//                  
//  Register 7 - UDP Ports Register
//      Bits [15:0]  - R/W - this is the destination UDP port for the UDP header
//      Bits [31:16] - R/W - this is the source UDP port for the UDP header
//                  
//  Register 8 - Packet Count Register
//      Bits [31:0] - R/WC - this is the number of packets that have been
//                  processed since the last reset or clearing of this register.
//                  
//  Register 9 - IP Header HI Register
//      Bits [23:16] - R/W - IP DSCP
//      Bits [15:0]  - R/W - IP IDENT
//                  
//  Register 10 - IP Header LO Register
//      Bits [31:29] - R/W - IP FLAGS
//      Bits [28:16] - R/W - IP OFFSET
//      Bits [15:8]  - R/W - IP TTL
//      Bits [7:0]   - R/W - IP PROTO
//                  
//  Register 11 - Packet Length Register
//      Bits [31:0] - R/W - length of UDP payload.
//                  
//  Register 12 - Aux Config Register
//      Bits [15:0] - R/W - Ethernet frame type
//                  
//  R - Readable
//  W - Writeable
//  RO - Read Only
//  WC - Clear on Write
//
/*************************************************************************************************/
module udp_tx_offload
(
    // clock interface
    input           csi_clock_clk,
    input           csi_clock_reset,
    
    // slave interface
    input           avs_s0_write,
    input           avs_s0_read,
    input   [3:0]   avs_s0_address,
    input   [3:0]   avs_s0_byteenable,
    input   [31:0]  avs_s0_writedata,
    output  [31:0]  avs_s0_readdata,
    
    // source interface
    output              aso_src0_valid,
    input               aso_src0_ready,
    output  reg [31:0]  aso_src0_data,
    output  reg [1:0]   aso_src0_empty,
    output  reg         aso_src0_error,
    output  reg         aso_src0_startofpacket,
    output  reg         aso_src0_endofpacket,
    
    // sink interface
    input           asi_snk0_valid,
    output          asi_snk0_ready,
    input   [31:0]  asi_snk0_data,
    input   [1:0]   asi_snk0_empty,
    input           asi_snk0_error,
    input           asi_snk0_startofpacket,
    input           asi_snk0_endofpacket
);
/*************************************************************************************************/
localparam [4:0] IDLE           = 5'd0;
localparam [4:0] STATE_PW_0     = 5'd1;
localparam [4:0] STATE_PW_1     = 5'd2;
localparam [4:0] STATE_PW_2     = 5'd3;
localparam [4:0] STATE_PW_3     = 5'd4;
localparam [4:0] STATE_PW_4     = 5'd5;
localparam [4:0] STATE_PW_5     = 5'd6;
localparam [4:0] STATE_PW_6     = 5'd7;
localparam [4:0] STATE_PW_7     = 5'd8;
localparam [4:0] STATE_PW_8     = 5'd9;
localparam [4:0] STATE_PW_9     = 5'd10;
localparam [4:0] STATE_PW_10    = 5'd11;
localparam [4:0] STATE_PW_11    = 5'd12;
localparam [4:0] STATE_PW_12    = 5'd13;
localparam [4:0] STATE_PW_13    = 5'd14;
localparam [4:0] STATE_PW_14    = 5'd15;
localparam [4:0] STATE_PW_N     = 5'd16;
localparam [4:0] STATE_PW_EOP   = 5'd17;
localparam [4:0] STATE_SOP_ERR  = 5'd18;

//localparam [15:0]   MAC_TYPE            = 16'h0800;

localparam [3:0]    IP_VERSION          = 4;
localparam [3:0]    IP_HEADER_LENGTH    = 5;
//localparam [7:0]    IP_TOS              = 0;
//localparam [15:0]   IP_IDENT            = 0;
//localparam [2:0]    IP_FLAGS            = 2;
//localparam [12:0]   IP_FRAGMENT_OFFSET  = 0;
//localparam [7:0]    IP_TTL              = 255;
//localparam [7:0]    IP_PROTOCOL         = 17;


localparam [7:0]    UDP_PROTO_NUM       = 17;

localparam [15:0]   UDP_CHECKSUM        = 0;
/*************************************************************************************************/
reg     [47:0]  mac_dst;            // user register
reg     [47:0]  mac_src;            // user register

reg     [31:0]  ip_src_addr;        // user register
reg     [31:0]  ip_dst_addr;        // user register
wire    [15:0]  ip_total_length;
wire    [15:0]  ip_header_checksum;

reg     [15:0]  udp_src_port;       // user register
reg     [15:0]  udp_dst_port;       // user register
wire    [15:0]  udp_length;

wire    [31:0]  ip_word_0;
wire    [31:0]  ip_word_1;
wire    [31:0]  ip_word_2;
wire    [31:0]  ip_word_3;
wire    [31:0]  ip_word_4;
wire    [31:0]  udp_word_0;
wire    [31:0]  udp_word_1;

reg             go_bit;
reg             byp_bit;
wire            running_bit;
reg     [31:0]  sink_data;
reg     [31:0]  sink_data_p1;
reg             sink_eop;
reg     [1:0]   sink_empty;
wire    [15:0]  first_two_bytes;
reg     [4:0]   state;
wire            error_bit;
reg             count_packet;
reg             clear_packet_count;
reg     [31:0]  packet_count;
reg     [15:0]  mac_type;
reg     [16:0]  ip_header_sum_0;
reg     [16:0]  ip_header_sum_1;
reg     [16:0]  ip_header_sum_2;
reg     [16:0]  ip_header_sum_3;
reg     [16:0]  ip_header_sum_4;
reg     [17:0]  ip_header_sum_a;
reg     [17:0]  ip_header_sum_b;
reg     [18:0]  ip_header_sum_c;
reg     [19:0]  ip_header_sum_d;
reg     [7:0]   dscp_reg;
reg     [15:0]  ident_reg;
reg     [2:0]   flags_reg;
reg     [12:0]  offset_reg;
reg     [7:0]   ttl_reg;
reg     [7:0]   proto_reg;
reg     [31:0]  packet_len;
reg     eop_flag;
wire    [15:0]  ip_header_carry_sum;
wire    [31:0]  packet_word_0;
wire    [31:0]  packet_word_1;
wire    [31:0]  packet_word_2;
wire    [31:0]  packet_word_3;
wire    [31:0]  packet_word_4;
wire    [31:0]  packet_word_5;
wire    [31:0]  packet_word_6;
wire    [31:0]  packet_word_7;
wire    [31:0]  packet_word_8;
wire    [31:0]  packet_word_9;
wire    [31:0]  packet_word_10;
wire    [31:0]  packet_word_n;
wire    [31:0]  packet_word_eop;

wire            pipe_src0_ready;
wire            pipe_src0_valid;
wire    [31:0]  pipe_src0_data;
wire            pipe_src0_startofpacket;
wire            pipe_src0_endofpacket;
wire    [1:0]   pipe_src0_empty;
wire            pipe_src0_error;
reg     [36:0]  in_payload;
wire    [36:0]  out_payload;
/*************************************************************************************************/
//
// misc computations
//
assign udp_length           = packet_len + 8;
assign first_two_bytes      = sink_data[15:0];
assign ip_total_length      = (proto_reg == UDP_PROTO_NUM) ? (udp_length + 20) : (packet_len + 20);
assign ip_header_carry_sum  = (ip_header_sum_d[15:0]) + ({{12{1'b0}}, ip_header_sum_d[19:16]});
assign ip_header_checksum   = ~ip_header_carry_sum;
/*************************************************************************************************/
always @ (posedge csi_clock_clk or posedge csi_clock_reset)
begin
    if(csi_clock_reset)
    begin
        ip_header_sum_0 <= 0;
        ip_header_sum_1 <= 0;
        ip_header_sum_2 <= 0;
        ip_header_sum_3 <= 0;
        ip_header_sum_4 <= 0;

        ip_header_sum_a <= 0;
        ip_header_sum_b <= 0;

        ip_header_sum_c <= 0;

        ip_header_sum_d <= 0;
    end
    else
    begin
        // stage 1 of header checksum pipeline
        ip_header_sum_0 <= ip_word_0[31:16] + ip_word_0[15:0];
        ip_header_sum_1 <= ip_word_1[31:16] + ip_word_1[15:0];
        ip_header_sum_2 <= ip_word_2[31:16] + 0;
        ip_header_sum_3 <= ip_word_3[31:16] + ip_word_3[15:0];
        ip_header_sum_4 <= ip_word_4[31:16] + ip_word_4[15:0];

        // stage 2 of header checksum pipeline
        ip_header_sum_a <= ip_header_sum_0 + ip_header_sum_1;
        ip_header_sum_b <= ip_header_sum_3 + ip_header_sum_4;

        // stage 3 of header checksum pipeline
        ip_header_sum_c <= ip_header_sum_a + ip_header_sum_b;

        // stage 4 of header checksum pipeline
        ip_header_sum_d <= ip_header_sum_2 + ip_header_sum_c;
    end
end
/*************************************************************************************************/
//
// IP and UDP header layout
//
assign ip_word_0    = {IP_VERSION, IP_HEADER_LENGTH, dscp_reg, ip_total_length};
assign ip_word_1    = {ident_reg, flags_reg, offset_reg};
assign ip_word_2    = {ttl_reg, proto_reg, ip_header_checksum};
assign ip_word_3    = ip_src_addr;
assign ip_word_4    = ip_dst_addr;
assign udp_word_0   = {udp_src_port, udp_dst_port};
assign udp_word_1   = {udp_length, UDP_CHECKSUM};
/*************************************************************************************************/
//
// packet word layout
//
assign packet_word_0    = {mac_dst[23:16], mac_dst[31:24], mac_dst[39:32], mac_dst[47:40]}/*mac_dst[47:16]*/;
assign packet_word_1    = {mac_dst[7:0], mac_dst[15:8], mac_src[39:32], mac_src[47:40]}/*{mac_dst[15:0], mac_src[47:32]}*/;
assign packet_word_2    = {mac_src[7:0], mac_src[15:8], mac_src[23:16], mac_src[31:24]}/*mac_src[31:0]*/;
assign packet_word_3    = byp_bit ? {mac_type, sink_data[31:16]} : {mac_type, ip_word_0[31:16]};
assign packet_word_4    = {ip_word_0[15:0], ip_word_1[31:16]};
assign packet_word_5    = {ip_word_1[15:0], ip_word_2[31:16]};
assign packet_word_6    = {ip_word_2[15:0], ip_word_3[31:16]};
assign packet_word_7    = {ip_word_3[15:0], ip_word_4[31:16]};
assign packet_word_8    = (proto_reg == UDP_PROTO_NUM) ? {ip_word_4[15:0], udp_word_0[31:16]} : {ip_word_4[15:0], sink_data[31:16]};
assign packet_word_9    = {udp_word_0[15:0], udp_word_1[31:16]};
assign packet_word_10   = {udp_word_1[15:0], sink_data[31:16]};
assign packet_word_eop  = {sink_data[15:0], 16'h0};
assign packet_word_n    = {sink_data_p1[15:0], sink_data[31:16]};//sink_data;
/*************************************************************************************************/
//
// packet transmit state machine
//
assign pipe_src0_data = (state == STATE_PW_0)   ? (packet_word_0)   :
                        (state == STATE_PW_1)   ? (packet_word_1)   :
                        (state == STATE_PW_2)   ? (packet_word_2)   :
                        (state == STATE_PW_3)   ? (packet_word_3)   :
                        (state == STATE_PW_4)   ? (packet_word_4)   :
                        (state == STATE_PW_5)   ? (packet_word_5)   :
                        (state == STATE_PW_6)   ? (packet_word_6)   :
                        (state == STATE_PW_7)   ? (packet_word_7)   :
                        (state == STATE_PW_8)   ? (packet_word_8)   :
                        (state == STATE_PW_9)   ? (packet_word_9)   :
                        (state == STATE_PW_10)  ? (packet_word_10)  :
                        ((state == STATE_PW_EOP)&&eop_flag) ? (packet_word_eop) :
                        (packet_word_n);

assign pipe_src0_valid =    (state == STATE_PW_0)   ? (asi_snk0_ready) :
                            ((state == STATE_PW_3)&&byp_bit)   ? (asi_snk0_ready) :
                            ((state == STATE_PW_8)&&(proto_reg != UDP_PROTO_NUM))   ? (asi_snk0_ready) :
                            ((state > STATE_PW_0) && (state < STATE_PW_10)) ? (1'b1) :
                            (state == STATE_PW_EOP) ? (1'b1) :
                            ((state >= STATE_PW_10) && (state <= STATE_PW_N))   ? ((!sink_eop & asi_snk0_ready) | (sink_eop)) :
                            (1'b0);

assign pipe_src0_empty =    (sink_eop) ? (sink_empty) :
                        (2'h0);

assign pipe_src0_startofpacket = (state == STATE_PW_0)  ? (1'b1) : (1'b0);

assign pipe_src0_endofpacket =  ((state == STATE_PW_14) || (state == STATE_PW_EOP))   ? (sink_eop) : 
                                (1'b0);

assign asi_snk0_ready = (state == IDLE)         ? (1'b0) :
                        ((state == STATE_PW_3)&&byp_bit) ? (pipe_src0_ready & asi_snk0_valid & !sink_eop) :
                        ((state == STATE_PW_8)&&(proto_reg != UDP_PROTO_NUM)) ? (pipe_src0_ready & asi_snk0_valid & !sink_eop) :
                        (state == STATE_PW_0)   ? (go_bit & pipe_src0_ready & asi_snk0_valid & asi_snk0_startofpacket) :
                        ((state >= STATE_PW_10) && (state <= STATE_PW_N))   ? (pipe_src0_ready & asi_snk0_valid & !sink_eop) :
                        (1'b0);
/*************************************************************************************************/
always @ (posedge csi_clock_clk or posedge csi_clock_reset)
begin
    if(csi_clock_reset)
    begin
        state           <= IDLE;
        sink_data       <= 0;
        sink_data_p1    <= 0;
        sink_eop        <= 0;
        sink_empty      <= 0;
        count_packet    <= 0;
        eop_flag        <= 1'b0;
    end
    else
    begin
        case(state)
        IDLE:
        begin
            if(go_bit)
            begin
                state <= STATE_PW_0;
            end
        end
        STATE_PW_0:
        begin
            count_packet    <= 1'b0;
            if(!go_bit)
            begin
                state <= IDLE;
            end
            else if(asi_snk0_valid & asi_snk0_ready & asi_snk0_startofpacket)
            begin
                state <= STATE_PW_1;
                sink_data   <= asi_snk0_data;
                sink_eop    <= asi_snk0_endofpacket;
                sink_empty  <= asi_snk0_empty;
            end
            else if(asi_snk0_valid & !asi_snk0_startofpacket)
            begin
                state <= STATE_SOP_ERR;
            end
        end
        STATE_PW_1:
        begin
            if(pipe_src0_valid & pipe_src0_ready)
            begin
                state <= STATE_PW_2;
            end
        end
        STATE_PW_2:
        begin
            if(pipe_src0_valid & pipe_src0_ready)
            begin
                //if (byp_bit)
                //    state <= STATE_PW_11;//state <= STATE_PW_N;
                //else
                state <= STATE_PW_3;
            end
        end
        STATE_PW_3:
        begin
            if(pipe_src0_valid & pipe_src0_ready)
            begin
                if (byp_bit)
                begin
                    sink_data       <= asi_snk0_data;
                    sink_data_p1    <= sink_data;
                    sink_eop        <= asi_snk0_endofpacket;
                    sink_empty      <= asi_snk0_empty;
                    state           <= STATE_PW_11;
                end
                else
                    state <= STATE_PW_4;
            end
        end
        STATE_PW_4:
        begin
            if(pipe_src0_valid & pipe_src0_ready)
            begin
                state <= STATE_PW_5;
            end
        end
        STATE_PW_5:
        begin
            if(pipe_src0_valid & pipe_src0_ready)
            begin
                state <= STATE_PW_6;
            end
        end
        STATE_PW_6:
        begin
            if(pipe_src0_valid & pipe_src0_ready)
            begin
                state <= STATE_PW_7;
            end
        end
        STATE_PW_7:
        begin
            if(pipe_src0_valid & pipe_src0_ready)
            begin
                state <= STATE_PW_8;
            end
        end
        STATE_PW_8:
        begin
            if(pipe_src0_valid & pipe_src0_ready)
            begin
                if (proto_reg == UDP_PROTO_NUM)
                    state <= STATE_PW_9;
                else begin
                    state <= STATE_PW_11;
                    sink_data       <= asi_snk0_data;
                    sink_data_p1    <= sink_data;
                    sink_eop        <= asi_snk0_endofpacket;
                    sink_empty      <= asi_snk0_empty;
                end
            end
        end
        STATE_PW_9:
        begin
            if(pipe_src0_valid & pipe_src0_ready)
            begin
                state <= STATE_PW_10;
            end
        end
        STATE_PW_10:
        begin
            if(pipe_src0_valid & pipe_src0_ready)
            begin
                state <= STATE_PW_11;
                if(!sink_eop)
                begin
                    sink_data       <= asi_snk0_data;
                    sink_data_p1    <= sink_data;
                    sink_eop        <= asi_snk0_endofpacket;
                    sink_empty      <= asi_snk0_empty;
                end
            end
        end
        STATE_PW_11:
        begin
            if(pipe_src0_valid & pipe_src0_ready)
            begin
                sink_data       <= asi_snk0_data;
                sink_data_p1    <= sink_data;
                if (asi_snk0_endofpacket) begin
                    state <= STATE_PW_EOP;
                    if (asi_snk0_empty[1]) begin
                        sink_eop        <= 1'b1;
                        sink_empty      <= asi_snk0_empty + 2'd2;
                    end
                end
                else
                    state <= STATE_PW_12;
                /*state <= STATE_PW_12;
                if(!sink_eop)
                begin
                    sink_data       <= asi_snk0_data;
                    sink_data_p1    <= sink_data;
                    sink_eop        <= asi_snk0_endofpacket;
                    sink_empty      <= asi_snk0_empty;
                end*/
            end
        end
        STATE_PW_12:
        begin
            if(pipe_src0_valid & pipe_src0_ready)
            begin
                sink_data       <= asi_snk0_data;
                sink_data_p1    <= sink_data;
                if (asi_snk0_endofpacket) begin
                    state <= STATE_PW_EOP;
                    if (asi_snk0_empty[1]) begin
                        sink_eop        <= 1'b1;
                        sink_empty      <= asi_snk0_empty + 2'd2;
                    end
                end
                else
                    state <= STATE_PW_13;
                /*state <= STATE_PW_13;
                if(!sink_eop)
                begin
                    sink_data       <= asi_snk0_data;
                    sink_data_p1    <= sink_data;
                    sink_eop        <= asi_snk0_endofpacket;
                    sink_empty      <= asi_snk0_empty;
                end*/
            end
        end
        STATE_PW_13:
        begin
            if(pipe_src0_valid & pipe_src0_ready)
            begin
                sink_data       <= asi_snk0_data;
                sink_data_p1    <= sink_data;
                if (asi_snk0_endofpacket) begin
                    state <= STATE_PW_EOP;
                    if (asi_snk0_empty[1]) begin
                        sink_eop        <= 1'b1;
                        sink_empty      <= asi_snk0_empty + 2'd2;
                    end
                end
                else
                    state <= STATE_PW_14;
                /*state <= STATE_PW_14;
                if(!sink_eop)
                begin
                    sink_data       <= asi_snk0_data;
                    sink_data_p1    <= sink_data;
                    sink_eop        <= asi_snk0_endofpacket;
                    sink_empty      <= asi_snk0_empty;
                end*/
            end
        end
        STATE_PW_14:
        begin
            if(pipe_src0_valid & pipe_src0_ready)
            begin
                //if(!sink_eop)
                //begin
                sink_data       <= asi_snk0_data;
                sink_data_p1    <= sink_data;
                if (asi_snk0_endofpacket) begin
                    state <= STATE_PW_EOP;
                    if (asi_snk0_empty[1]) begin
                        sink_eop        <= 1'b1;
                        sink_empty      <= asi_snk0_empty + 2'd2;
                    end
                end
                else
                    state <= STATE_PW_N;
                //end
                /*
                else
                begin
                    state           <= STATE_PW_0;
                    count_packet    <= 1'b1;
                end
                */
            end
        end
        STATE_PW_N:
        begin
            if(pipe_src0_valid & pipe_src0_ready)
            begin
                sink_data       <= asi_snk0_data;
                sink_data_p1    <= sink_data;
                if (asi_snk0_endofpacket) begin
                    state <= STATE_PW_EOP;
                    if (asi_snk0_empty[1]) begin
                        sink_eop        <= 1'b1;
                        sink_empty      <= asi_snk0_empty + 2'd2;
                    end
                end
            end
        end
        STATE_PW_EOP:
        begin
            if(pipe_src0_valid & pipe_src0_ready)
            begin
                if (asi_snk0_empty[1]) begin
                    state           <= STATE_PW_0;
                    count_packet    <= 1'b1;
                end
                else begin
                    if(!eop_flag) begin
                        eop_flag <= 1'b1;
                        sink_eop        <= 1'b1;
                        sink_empty      <= asi_snk0_empty + 2'd2;
                    end
                    else begin
                        eop_flag <= 1'b0;
                        sink_eop        <= 1'b1;
                        sink_empty      <= asi_snk0_empty + 2'd2;
                        state           <= STATE_PW_0;
                        count_packet    <= 1'b1;
                    end
                end
            end
        end
        STATE_SOP_ERR:
        begin
            if(!go_bit)
            begin
                state <= IDLE;
            end
        end
        default:
        begin
            state <= IDLE;
        end
        endcase
    end
end
/*************************************************************************************************/
//
// packet_count state machine
//
always @ (posedge csi_clock_clk or posedge csi_clock_reset)
begin
    if(csi_clock_reset)
    begin
        packet_count    <= 0;
    end
    else if(clear_packet_count)
    begin
        packet_count    <= 0;
    end
    else if(count_packet)
    begin
        packet_count    <= packet_count + 1;
    end
end
/*************************************************************************************************/
//
// slave read mux
//
assign running_bit  = (state == IDLE)           ? (1'b0) : (1'b1);
assign error_bit    = (state == STATE_SOP_ERR)  ? (1'b1) : (1'b0);

assign avs_s0_readdata =    (avs_s0_address == 4'h0) ?  ({{29{1'b0}}, error_bit, running_bit, go_bit}) :
                            (avs_s0_address == 4'h1) ?  (mac_dst[47:16]) :
                            (avs_s0_address == 4'h2) ?  ({{16{1'b0}}, mac_dst[15:0]}) :
                            (avs_s0_address == 4'h3) ?  (mac_src[47:16]) :
                            (avs_s0_address == 4'h4) ?  ({{16{1'b0}}, mac_src[15:0]}) :
                            (avs_s0_address == 4'h5) ?  (ip_src_addr) :
                            (avs_s0_address == 4'h6) ?  (ip_dst_addr) :
                            (avs_s0_address == 4'h7) ?  ({udp_src_port, udp_dst_port}) :
                            (avs_s0_address == 4'h9) ?  ({{8{1'b0}}, dscp_reg, ident_reg}) :
                            (avs_s0_address == 4'hA) ?  ({flags_reg, offset_reg, ttl_reg, proto_reg}) :
                            (avs_s0_address == 4'hB) ?  (packet_len) :
                            (avs_s0_address == 4'hC) ?  ({{16{1'b0}}, mac_type}) :
                                                        (packet_count);
/*************************************************************************************************/
//
// slave write demux
//
always @ (posedge csi_clock_clk or posedge csi_clock_reset)
begin
    if(csi_clock_reset)
    begin
        go_bit              <= 1'b0;
        byp_bit             <= 1'b0;
        dscp_reg            <= 0;
        ident_reg           <= 0;
        flags_reg           <= 0;
        offset_reg          <= 0;
        ttl_reg             <= 0;
        proto_reg           <= 0;
        packet_len          <= 0;
        mac_dst             <= 0;
        mac_src             <= 0;
        ip_src_addr         <= 0;
        ip_dst_addr         <= 0;
        udp_src_port        <= 0;
        udp_dst_port        <= 0;
        clear_packet_count  <= 0;
        mac_type            <= 0;
    end
    else
    begin
        if(avs_s0_write)
        begin
            case(avs_s0_address)
            4'h0: begin
                if(avs_s0_byteenable[0] == 1'b1)
                    go_bit      <= avs_s0_writedata[0];
                if(avs_s0_byteenable[2] == 1'b1)
                    byp_bit     <= avs_s0_writedata[16];
            end
            4'h1: begin
                if(avs_s0_byteenable[0] == 1'b1)
                    mac_dst[23:16]<= avs_s0_writedata[7:0];
                if(avs_s0_byteenable[1] == 1'b1)
                    mac_dst[31:24]<= avs_s0_writedata[15:8];
                if(avs_s0_byteenable[2] == 1'b1)
                    mac_dst[39:32]<= avs_s0_writedata[23:16];
                if(avs_s0_byteenable[3] == 1'b1)
                    mac_dst[47:40]<= avs_s0_writedata[31:24];
            end
            4'h2: begin
                if(avs_s0_byteenable[0] == 1'b1)
                    mac_dst[7:0]    <= avs_s0_writedata[7:0];
                if(avs_s0_byteenable[1] == 1'b1)
                    mac_dst[15:8]   <= avs_s0_writedata[15:8];
            end
            4'h3: begin
                if(avs_s0_byteenable[0] == 1'b1)
                    mac_src[23:16]<= avs_s0_writedata[7:0];
                if(avs_s0_byteenable[1] == 1'b1)
                    mac_src[31:24]<= avs_s0_writedata[15:8];
                if(avs_s0_byteenable[2] == 1'b1)
                    mac_src[39:32]<= avs_s0_writedata[23:16];
                if(avs_s0_byteenable[3] == 1'b1)
                    mac_src[47:40]<= avs_s0_writedata[31:24];
            end
            4'h4: begin
                if(avs_s0_byteenable[0] == 1'b1)
                    mac_src[7:0]    <= avs_s0_writedata[7:0];
                if(avs_s0_byteenable[1] == 1'b1)
                    mac_src[15:8]   <= avs_s0_writedata[15:8];
            end
            4'h5: begin
                if(avs_s0_byteenable[0] == 1'b1)
                    ip_src_addr[7:0]    <= avs_s0_writedata[7:0];
                if(avs_s0_byteenable[1] == 1'b1)
                    ip_src_addr[15:8]   <= avs_s0_writedata[15:8];
                if(avs_s0_byteenable[2] == 1'b1)
                    ip_src_addr[23:16]  <= avs_s0_writedata[23:16];
                if(avs_s0_byteenable[3] == 1'b1)
                    ip_src_addr[31:24]  <= avs_s0_writedata[31:24];
            end
            4'h6: begin
                if(avs_s0_byteenable[0] == 1'b1)
                    ip_dst_addr[7:0]    <= avs_s0_writedata[7:0];
                if(avs_s0_byteenable[1] == 1'b1)
                    ip_dst_addr[15:8]   <= avs_s0_writedata[15:8];
                if(avs_s0_byteenable[2] == 1'b1)
                    ip_dst_addr[23:16]  <= avs_s0_writedata[23:16];
                if(avs_s0_byteenable[3] == 1'b1)
                    ip_dst_addr[31:24]  <= avs_s0_writedata[31:24];
            end
            4'h7: begin
                if(avs_s0_byteenable[0] == 1'b1)
                    udp_dst_port[7:0]   <= avs_s0_writedata[7:0];
                if(avs_s0_byteenable[1] == 1'b1)
                    udp_dst_port[15:8]  <= avs_s0_writedata[15:8];
                if(avs_s0_byteenable[2] == 1'b1)
                    udp_src_port[7:0]   <= avs_s0_writedata[23:16];
                if(avs_s0_byteenable[3] == 1'b1)
                    udp_src_port[15:8]  <= avs_s0_writedata[31:24];
            end
            4'h8: clear_packet_count    <= 1'b1;
            4'h9: begin
                if(avs_s0_byteenable[0] == 1'b1)
                    ident_reg[7:0]   <= avs_s0_writedata[7:0];
                if(avs_s0_byteenable[1] == 1'b1)
                    ident_reg[15:8]  <= avs_s0_writedata[15:8];
                if(avs_s0_byteenable[2] == 1'b1)
                    dscp_reg   <= avs_s0_writedata[23:16];
            end
            4'hA: begin
                if(avs_s0_byteenable[0] == 1'b1)
                    proto_reg   <= avs_s0_writedata[7:0];
                if(avs_s0_byteenable[1] == 1'b1)
                    ttl_reg  <= avs_s0_writedata[15:8];
                if(avs_s0_byteenable[2] == 1'b1)
                    offset_reg[7:0]   <= avs_s0_writedata[23:16];
                if(avs_s0_byteenable[3] == 1'b1)
                    {flags_reg, offset_reg[12:8]}  <= avs_s0_writedata[31:24];
            end
            4'hB: begin
                if(avs_s0_byteenable[0] == 1'b1)
                    packet_len[7:0]   <= avs_s0_writedata[7:0];
                if(avs_s0_byteenable[1] == 1'b1)
                    packet_len[15:8]  <= avs_s0_writedata[15:8];
                if(avs_s0_byteenable[2] == 1'b1)
                    packet_len[23:16]   <= avs_s0_writedata[23:16];
                if(avs_s0_byteenable[3] == 1'b1)
                    packet_len[31:24]  <= avs_s0_writedata[31:24];
            end
            4'hC: begin
                if(avs_s0_byteenable[0] == 1'b1)
                    mac_type[7:0]   <= avs_s0_writedata[7:0];
                if(avs_s0_byteenable[1] == 1'b1)
                    mac_type[15:8]  <= avs_s0_writedata[15:8];
            end
            default: ;
            endcase
        end
        else
        begin
            clear_packet_count  <= 0;
        end
    end
end
/*************************************************************************************************/
//
// output Pipeline
//
udp_payload_inserter_1stage_pipeline #( .PAYLOAD_WIDTH( 37 ) ) outpipe (
    .clk            (csi_clock_clk ),
    .reset_n        (~csi_clock_reset),
    .in_ready       (pipe_src0_ready),
    .in_valid       (pipe_src0_valid), 
    .in_payload     (in_payload),
    .out_ready      (aso_src0_ready), 
    .out_valid      (aso_src0_valid), 
    .out_payload    (out_payload)
);
/*************************************************************************************************/
//
// Output Mapping
//
always @* begin
    in_payload <= {pipe_src0_data, pipe_src0_startofpacket, pipe_src0_endofpacket, pipe_src0_empty,pipe_src0_error};
    {aso_src0_data, aso_src0_startofpacket, aso_src0_endofpacket, aso_src0_empty, aso_src0_error} <= out_payload;
end
/*************************************************************************************************/
endmodule
/*************************************************************************************************/
