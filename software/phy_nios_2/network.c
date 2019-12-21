#include "network.h"
#include "eth_driver.h"
#include "alt_types.h"
//#include "epcs_commands.h"
#include "system.h"
#include "endian_converter_macros.h"
#include "udp_tx_offload_regs.h"
//#include "udp_payload_inserter_regs.h"
#ifdef ALT_STDIO_DEBUG_MESSAGES
#include "sys/alt_stdio.h"
#endif //ALT_STDIO_DEBUG_MESSAGES
//#include "stream_cap_regs.h"
#include "io.h"
#include <string.h>
//---------------------------------------------------------------------------------------------
volatile unsigned char eth_tx_pkt[1518] __attribute__ ((aligned (4)));
//volatile unsigned char udp_tx_pkt[MAX_UDP_PAYLOAD_SIZE+2] __attribute__ ((aligned (4)));
//unsigned char MYMAC_ADDR[6]={0x00,0x07,0xAB,0xF0,0x0D,0xBA};
//unsigned char IP4_ADDR[4]={192,168,0,3};
//alt_u32 MY_IP, HOST_IP, HOST_MAC_HI, HOST_MAC_LO;
mac_addr_t	MY_MAC_ADDR;
ip4_addr_t	MY_IP_ADDR;
mac_addr_t  HOST_MAC_ADDR;
ip4_addr_t  HOST_IP_ADDR;
extern unsigned char EPCS_buffer[256];
extern volatile alt_u32 c_time;
const unsigned short Crc16Table[256] = {
    0x0000, 0x1021, 0x2042, 0x3063, 0x4084, 0x50A5, 0x60C6, 0x70E7,
    0x8108, 0x9129, 0xA14A, 0xB16B, 0xC18C, 0xD1AD, 0xE1CE, 0xF1EF,
    0x1231, 0x0210, 0x3273, 0x2252, 0x52B5, 0x4294, 0x72F7, 0x62D6,
    0x9339, 0x8318, 0xB37B, 0xA35A, 0xD3BD, 0xC39C, 0xF3FF, 0xE3DE,
    0x2462, 0x3443, 0x0420, 0x1401, 0x64E6, 0x74C7, 0x44A4, 0x5485,
    0xA56A, 0xB54B, 0x8528, 0x9509, 0xE5EE, 0xF5CF, 0xC5AC, 0xD58D,
    0x3653, 0x2672, 0x1611, 0x0630, 0x76D7, 0x66F6, 0x5695, 0x46B4,
    0xB75B, 0xA77A, 0x9719, 0x8738, 0xF7DF, 0xE7FE, 0xD79D, 0xC7BC,
    0x48C4, 0x58E5, 0x6886, 0x78A7, 0x0840, 0x1861, 0x2802, 0x3823,
    0xC9CC, 0xD9ED, 0xE98E, 0xF9AF, 0x8948, 0x9969, 0xA90A, 0xB92B,
    0x5AF5, 0x4AD4, 0x7AB7, 0x6A96, 0x1A71, 0x0A50, 0x3A33, 0x2A12,
    0xDBFD, 0xCBDC, 0xFBBF, 0xEB9E, 0x9B79, 0x8B58, 0xBB3B, 0xAB1A,
    0x6CA6, 0x7C87, 0x4CE4, 0x5CC5, 0x2C22, 0x3C03, 0x0C60, 0x1C41,
    0xEDAE, 0xFD8F, 0xCDEC, 0xDDCD, 0xAD2A, 0xBD0B, 0x8D68, 0x9D49,
    0x7E97, 0x6EB6, 0x5ED5, 0x4EF4, 0x3E13, 0x2E32, 0x1E51, 0x0E70,
    0xFF9F, 0xEFBE, 0xDFDD, 0xCFFC, 0xBF1B, 0xAF3A, 0x9F59, 0x8F78,
    0x9188, 0x81A9, 0xB1CA, 0xA1EB, 0xD10C, 0xC12D, 0xF14E, 0xE16F,
    0x1080, 0x00A1, 0x30C2, 0x20E3, 0x5004, 0x4025, 0x7046, 0x6067,
    0x83B9, 0x9398, 0xA3FB, 0xB3DA, 0xC33D, 0xD31C, 0xE37F, 0xF35E,
    0x02B1, 0x1290, 0x22F3, 0x32D2, 0x4235, 0x5214, 0x6277, 0x7256,
    0xB5EA, 0xA5CB, 0x95A8, 0x8589, 0xF56E, 0xE54F, 0xD52C, 0xC50D,
    0x34E2, 0x24C3, 0x14A0, 0x0481, 0x7466, 0x6447, 0x5424, 0x4405,
    0xA7DB, 0xB7FA, 0x8799, 0x97B8, 0xE75F, 0xF77E, 0xC71D, 0xD73C,
    0x26D3, 0x36F2, 0x0691, 0x16B0, 0x6657, 0x7676, 0x4615, 0x5634,
    0xD94C, 0xC96D, 0xF90E, 0xE92F, 0x99C8, 0x89E9, 0xB98A, 0xA9AB,
    0x5844, 0x4865, 0x7806, 0x6827, 0x18C0, 0x08E1, 0x3882, 0x28A3,
    0xCB7D, 0xDB5C, 0xEB3F, 0xFB1E, 0x8BF9, 0x9BD8, 0xABBB, 0xBB9A,
    0x4A75, 0x5A54, 0x6A37, 0x7A16, 0x0AF1, 0x1AD0, 0x2AB3, 0x3A92,
    0xFD2E, 0xED0F, 0xDD6C, 0xCD4D, 0xBDAA, 0xAD8B, 0x9DE8, 0x8DC9,
    0x7C26, 0x6C07, 0x5C64, 0x4C45, 0x3CA2, 0x2C83, 0x1CE0, 0x0CC1,
    0xEF1F, 0xFF3E, 0xCF5D, 0xDF7C, 0xAF9B, 0xBFBA, 0x8FD9, 0x9FF8,
    0x6E17, 0x7E36, 0x4E55, 0x5E74, 0x2E93, 0x3EB2, 0x0ED1, 0x1EF0
};
//extern unsigned char PAGE_BUF[EPCS_BLOCK_SIZE];
volatile alt_u32 c_time;
rx_channel_cfg_t lb_rx_cfg;
rx_channel_cfg_t hb_rx_cfg;
alt_u32 first_desc = 0;
extern unsigned char *PAGE_BUF;
extern alt_u32 PAGE_NUM;
extern alt_u32 b_counter;
//extern rx_channel_cfg_t lb_rx_cfg;
//extern rx_channel_cfg_t hb_rx_cfg;
//---------------------------------------------------------------------------------------------
int CheckPacket(unsigned char* packet, int length)
{
    unsigned short s,l;
    alt_u32 t;
    //int len;
    int eth_pld_bias = ETH_HDR_SZ + ETHHDR_BIAS;
    int ip_pld_bias;
    eth_hdr_t* p1 = (eth_hdr_t*) (packet + ETHHDR_BIAS);
    arp_pld_t* p2;
    ip_hdr_t* p3;
    mac_addr_t target;

    for (t=0;t<6;++t)
    {
    	target.mac_arr[t] = p1->src_mac[t];
    	HOST_MAC_ADDR.mac_arr[t] = p1->src_mac[t];
    }
    UDP_TX_OFFLOAD_WR_MAC_DST_HI(ETH_0_UDP_TX_OFFLOAD_BASE, target.mac_addr.mac_hi);
    UDP_TX_OFFLOAD_WR_MAC_DST_LO(ETH_0_UDP_TX_OFFLOAD_BASE, target.mac_addr.mac_lo);

    if (ENDIAN_SWAP_16(p1->type) == ARP_PROTO)
    {
    	p2 = (arp_pld_t*) (packet + eth_pld_bias);
        if (ENDIAN_SWAP_32(p2->target_ip) == MY_IP_ADDR.addr)
    	{
#ifdef ALT_STDIO_DEBUG_MESSAGES
            alt_printf("Sending ARP reply\n");
#endif //ALT_STDIO_DEBUG_MESSAGES
            SendARPAns(packet);
            return 1000;
        }
    }
    else
    {
    	p3 = (ip_hdr_t*) (packet + eth_pld_bias);
        if ((ENDIAN_SWAP_16(p1->type) == IP_PROTO)&&(ENDIAN_SWAP_32(p3->destination.addr) == MY_IP_ADDR.addr))
        {
            HOST_IP_ADDR.addr = ENDIAN_SWAP_32(p3->destination.addr);
            UDP_TX_OFFLOAD_WR_IP_DST(ETH_0_UDP_TX_OFFLOAD_BASE, ENDIAN_SWAP_32(p3->source.addr));
            s = ((p3->offset_msb)<<8) + p3->offset_lsb;
            UDP_TX_OFFLOAD_WR_IP_HDR_HI(ETH_0_UDP_TX_OFFLOAD_BASE, ((p3->dscp)<<UDP_TX_OFFLOAD_DSCP_OFST)|(ENDIAN_SWAP_16(p3->ident)));
            UDP_TX_OFFLOAD_WR_IP_HDR_LO(ETH_0_UDP_TX_OFFLOAD_BASE, 	((p3->flags)<<UDP_TX_OFFLOAD_FLAGS_OFST) |
            															(s<<UDP_TX_OFFLOAD_OFFSET_OFST) |
            															((p3->ttl)<<UDP_TX_OFFLOAD_TTL_OFST) |
            															(p3->proto)
            							);
#ifdef ALT_STDIO_DEBUG_MESSAGES
        	alt_printf("This IP packet is for me\n");
#endif //ALT_STDIO_DEBUG_MESSAGES
        	l = (p3->hlen)<<2;
        	s = checksum(packet + eth_pld_bias, l);
        	ip_pld_bias = eth_pld_bias + l;
        	if (s)
        	{
#ifdef ALT_STDIO_DEBUG_MESSAGES
                alt_printf("Bad IP-header checksum, packet dropped\n");
#endif //ALT_STDIO_DEBUG_MESSAGES
                return 2000;
        	}
        	HOST_IP_ADDR.addr = ENDIAN_SWAP_32(p3->source.addr);
        	switch (p3->proto)
        	{
        		case IP_ICMP_PROTO:
        			ProcessICMPMess(packet, ENDIAN_SWAP_16(p3->length));
        			break;
        		case IP_UDP_PROTO:
        			Process_UDP_Message(packet+UDP_MESS_BIAS+ETHHDR_BIAS);
        			break;
        		default:
        			break;
        	}
        }
    }
    return 0;
}
//---------------------------------------------------------------------------------------------
void SendARPAns(unsigned char* packet)
{
    alt_u32 t;
    t = ETHHDR_BIAS + ETH_HDR_SZ;
    arp_pld_t* p2 = (arp_pld_t*) (packet + t);
    t = ETH_HDR_SZ;
    arp_pld_t* p4 = (arp_pld_t*) (eth_tx_pkt);
    p4->opcode = ENDIAN_SWAP_16(ARP_ANS);
    p4->hw_type = p2->hw_type;
    p4->h_syze = p2->h_syze;
    p4->p_syze = p2->p_syze;
    p4->p_type = p2->p_type;
    //mac_addr_t target;
    for (t=0;t<6;++t)
    {
    	p4->target_mac[t] = p2->sender_mac[t];
    	p4->sender_mac[t] = MY_MAC_ADDR.mac_arr[t];
    }
    p4->target_ip = p2->sender_ip;
    p4->sender_ip = ENDIAN_SWAP_32(MY_IP_ADDR.addr);
    t = ARP_PLD_SZ;
    UDP_TX_OFFLOAD_WR_AUX_CONFIG(ETH_0_UDP_TX_OFFLOAD_BASE, ARP_PROTO);
	UDP_TX_OFFLOAD_WR_CSR(ETH_0_UDP_TX_OFFLOAD_BASE, UDP_TX_OFFLOAD_CSR_GO_BIT_MASK|UDP_TX_OFFLOAD_BYP_BIT_MASK);
    tse_mac_raw_send(eth_tx_pkt , t);
}
//---------------------------------------------------------------------------------------------
void ProcessICMPMess(unsigned char* packet, int ip_len)
{
   	alt_u32 t;
   	unsigned short s;
   	//alt_u32 q;
   	//eth_hdr_t* p1 = (eth_hdr_t*) (packet + ETHHDR_BIAS);
   	t = ETH_HDR_SZ + ETHHDR_BIAS;
   	ip_hdr_t* p3 = (ip_hdr_t*) (packet + t);
    t += (p3->hlen)<<2;
    icmp_pld_t* p5;
	p5 = (icmp_pld_t*) (packet + t);
    icmp_pld_t* p6;
    p6 = (icmp_pld_t*) (eth_tx_pkt);
    t = ENDIAN_SWAP_16(p3->length) - ((p3->hlen)<<2);
    UDP_TX_OFFLOAD_WR_PACKET_LEN(ETH_0_UDP_TX_OFFLOAD_BASE, t);
    t -= 4;

    if (p5->type == ICMP_ECHO_RQ)
	{
    	p6->type = ICMP_ECHO_ANS;
    	p6->code = 0;
    	p6->checksum = 0;
    	while (t>0)
    	{
    		t--;
    		//alt_printf("p5->data[0x%x]=0x%x\n",t, p5->data[t]);
    		p6->data[t] = p5->data[t];
    	}
    	t = ENDIAN_SWAP_16(p3->length) - ((p3->hlen)<<2);
    	s = checksum(p6, t);
    	p6->checksum = s;//ENDIAN_SWAP_16(s);
#ifdef ALT_STDIO_DEBUG_MESSAGES
    	alt_printf("ICMP checksum:0x%x\n",s);
    	alt_printf("Sending echo answer\n");
#endif //ALT_STDIO_DEBUG_MESSAGES
	}
    UDP_TX_OFFLOAD_WR_AUX_CONFIG(ETH_0_UDP_TX_OFFLOAD_BASE, IP_PROTO);
	UDP_TX_OFFLOAD_WR_CSR(ETH_0_UDP_TX_OFFLOAD_BASE, UDP_TX_OFFLOAD_CSR_GO_BIT_MASK);
    tse_mac_raw_send(eth_tx_pkt, t);
}
//---------------------------------------------------------------------------------------------
unsigned short checksum(void *b, int len)
{
    unsigned short *buf = b, result;
    unsigned int sum=0;
    for ( sum = 0; len > 1; len -= 2 ) /* Sum all 16b words */
        sum += *buf++;
    if ( len == 1 )
    /* If any stray bytes, */
    sum += *(unsigned char*)buf;
    /* add to sum */
    sum = (sum >> 16) + (sum & 0xFFFF);
    /* Add the carry */
    sum += (sum >> 16);
    /* (again) */
    result = ~sum;
    /* Take the one's complement */
    return result;
    /* Return 16b value */
}
//---------------------------------------------------------------------------------------------

void Process_UDP_Message(unsigned char* mess)
{
//    alt_u32 seg_size, seg_offset , i ,l ,j;
    alt_u32 i, s0_base; //, s1_base;
    alt_u32* p;
    //unsigned short c;
    //alt_u8 b,cs;
    rx_channel_cfg_t* ptr;
    rx_channel_cfg_t tmp_cfg;
    //l = mess[1];
    //c = Crc16(mess,l+4);
    //if (c)
    //{
#ifdef ALT_STDIO_DEBUG_MESSAGES
    //    alt_printf("Warning! Wrong checksum. Command dropped.\n");
#endif //ALT_STDIO_DEBUG_MESSAGES
    //    return;
    //}
    switch (mess[0])
    {
        case GET_SNAPSHOT:
            eth_tx_pkt[0] = GET_SNAPSHOT_REPLY;
            for(i=1;i<4;i++)
            {
                eth_tx_pkt[i] = mess[i];
            }
            p = &(eth_tx_pkt[4]);

            for(i=0;i<(MAX_UDP_PAYLOAD_SIZE-PROTO_HDR_SIZE)>>2;i++)
            {
                //*p = i;
                *p = IORD(s0_base, i);
                p++;
            }

            UDP_TX_OFFLOAD_WR_PACKET_LEN(ETH_0_UDP_TX_OFFLOAD_BASE, MAX_UDP_PAYLOAD_SIZE);
            UDP_TX_OFFLOAD_WR_AUX_CONFIG(ETH_0_UDP_TX_OFFLOAD_BASE, IP_PROTO);
            UDP_TX_OFFLOAD_WR_UDP_PORTS(ETH_0_UDP_TX_OFFLOAD_BASE, (UDP_IMAGE_PORT<<16)|UDP_IMAGE_PORT);
            UDP_TX_OFFLOAD_WR_CSR(ETH_0_UDP_TX_OFFLOAD_BASE, UDP_TX_OFFLOAD_CSR_GO_BIT_MASK);
            tse_mac_raw_send((unsigned char*)eth_tx_pkt, MAX_UDP_PAYLOAD_SIZE);
            break;
        case GET_RX_CHANNEL_CFG:
            eth_tx_pkt[0] = GET_RX_CHANNEL_CFG_REPLY;
            ptr = (mess[1]) ? &hb_rx_cfg : &lb_rx_cfg;
            for(i=1;i<4;i++)
            {
                eth_tx_pkt[i] = mess[i];
            }
            memcpy(&(eth_tx_pkt[4]), ptr, sizeof(rx_channel_cfg_t));
            UDP_TX_OFFLOAD_WR_PACKET_LEN(ETH_0_UDP_TX_OFFLOAD_BASE, MAX_UDP_PAYLOAD_SIZE);
            UDP_TX_OFFLOAD_WR_AUX_CONFIG(ETH_0_UDP_TX_OFFLOAD_BASE, IP_PROTO);
            UDP_TX_OFFLOAD_WR_UDP_PORTS(ETH_0_UDP_TX_OFFLOAD_BASE, (UDP_IMAGE_PORT<<16)|UDP_IMAGE_PORT);
            UDP_TX_OFFLOAD_WR_CSR(ETH_0_UDP_TX_OFFLOAD_BASE, UDP_TX_OFFLOAD_CSR_GO_BIT_MASK);
            tse_mac_raw_send((unsigned char*)eth_tx_pkt, MAX_UDP_PAYLOAD_SIZE);
            break;
        case SET_RX_CHANNEL_CFG:
            memcpy(&tmp_cfg, &(mess[4]), sizeof(rx_channel_cfg_t));
            ptr = (mess[1]) ? &hb_rx_cfg : &lb_rx_cfg;
            ptr->trigger_level = tmp_cfg.trigger_level;
            ptr->timer_period = tmp_cfg.timer_period;
            ptr->mod_period = tmp_cfg.mod_period;
            ptr->mod_pwidth = tmp_cfg.mod_pwidth;
            ptr->control = tmp_cfg.control;
            break;
        default : break;
    }

}
//---------------------------------------------------------------------------------------------
unsigned short Crc16(unsigned char * pcBlock, unsigned short len)
{
    unsigned short crc = 0xFFFF;

    while (len--)
        crc = (crc << 8) ^ Crc16Table[(crc >> 8) ^ *pcBlock++];

    return crc;
}
//---------------------------------------------------------------------------------------------
void SendPDW(alt_u32* buf_ptr, int len)
{
    alt_u32 t;
    alt_u32 *p;
#ifdef ALT_STDIO_DEBUG_MESSAGES
    //alt_printf("Sending PD packet. Buffer #0x%x, pulse count: 0x%x.\n", buf_ptr, len);
#endif //ALT_STDIO_DEBUG_MESSAGES
    UDP_TX_OFFLOAD_WR_MAC_DST_HI(ETH_0_UDP_TX_OFFLOAD_BASE, HOST_MAC_ADDR.mac_addr.mac_hi);
    UDP_TX_OFFLOAD_WR_MAC_DST_LO(ETH_0_UDP_TX_OFFLOAD_BASE, HOST_MAC_ADDR.mac_addr.mac_lo);
    UDP_TX_OFFLOAD_WR_IP_DST(ETH_0_UDP_TX_OFFLOAD_BASE, HOST_IP_ADDR.addr);
    UDP_TX_OFFLOAD_WR_IP_HDR_HI(ETH_0_UDP_TX_OFFLOAD_BASE, 0x0);
    UDP_TX_OFFLOAD_WR_IP_HDR_LO(ETH_0_UDP_TX_OFFLOAD_BASE, 0x40004011);
    UDP_TX_OFFLOAD_WR_AUX_CONFIG(ETH_0_UDP_TX_OFFLOAD_BASE, IP_PROTO);
    UDP_TX_OFFLOAD_WR_UDP_PORTS(ETH_0_UDP_TX_OFFLOAD_BASE, (UDP_IMAGE_PORT<<16)|UDP_IMAGE_PORT);
    UDP_TX_OFFLOAD_WR_PACKET_LEN(ETH_0_UDP_TX_OFFLOAD_BASE, (len<<4) + PD_HDR_SIZE);
    p = (alt_u32*) eth_tx_pkt;
    *p = PD_PACKET | (len<< 16);
    p++;
    *p = c_time;
    for (t = 0; t < ((len*PULSE_DET_PDW_SIZE)>>2); t++)
    {
        p++;
        *p = *(buf_ptr + t);
        //*p = IORD(buf_ptr, t);
#ifdef ALT_STDIO_DEBUG_MESSAGES
        //alt_printf("Copying buffer. Address: #0x%x, data: 0x%x.\n", buf_ptr + t, *p);
#endif //ALT_STDIO_DEBUG_MESSAGES
    }
    UDP_TX_OFFLOAD_WR_CSR(ETH_0_UDP_TX_OFFLOAD_BASE, UDP_TX_OFFLOAD_CSR_GO_BIT_MASK);
    tse_mac_raw_send(&(eth_tx_pkt) , (len<<4) + PD_HDR_SIZE);
    p=0;
}
//---------------------------------------------------------------------------------------------
//EOF
