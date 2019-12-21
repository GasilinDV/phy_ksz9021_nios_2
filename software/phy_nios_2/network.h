#ifndef NETWORK_H_
#define NETWORK_H_
#include "alt_types.h"
#include "sys/alt_irq.h"
/*************************************************************************************************/
#define UDP_MESS_BIAS           42
#define MAX_UDP_PAYLOAD_SIZE    1028
#define PROTO_HDR_SIZE          4
#define PD_HDR_SIZE             8
/*************************************************************************************************/
#define GET_SNAPSHOT                0x0C
#define GET_SNAPSHOT_REPLY          0x8C
#define GET_SNAPSHOT                0x0C
#define PD_PACKET                   0x8D
#define GET_RX_CHANNEL_CFG          0x10
#define SET_RX_CHANNEL_CFG          0x11
#define GET_RX_CHANNEL_CFG_REPLY    0x90
/*************************************************************************************************/
#define WR_SREC                 0xA0
#define WR_FWARE                0xA1
#define SREC_INCORRECT          0xA2
/*************************************************************************************************/
#define	ARP_ANS					0x0002
#define	IP_ICMP_PROTO			0x01
#define IP_UDP_PROTO			0x11
#define ICMP_ECHO_RQ			8
#define ICMP_ECHO_ANS			0
/*************************************************************************************************/
#define     PULSE_DET_PDW_SIZE              16// bytes/PDW
/*************************************************************************************************/
typedef union
{
	unsigned int	addr;
	unsigned char	ad_arr[4];
} ip4_addr_t;
//---------------------------------------------------------------------------------------------
struct rx_channel_cfg
{
    alt_16          trigger_level;
    alt_u32         timer_period;
    alt_u32         mod_period;
    alt_u32         mod_pwidth;
    alt_u32         det_base;
    alt_u32         buf_base;
    alt_u32         ic_id;
    alt_u32         irq;
    alt_isr_func    isr;
    void*           context;
    alt_u32         control;
} __attribute__((__packed__));
typedef struct rx_channel_cfg rx_channel_cfg_t;
/*************************************************************************************************/
struct ip_hdr
{
	unsigned int 	hlen:4;
	unsigned int	version:4;
	unsigned char 	dscp;
	unsigned short 	length;
	unsigned short	ident;
	unsigned int	offset_msb:5;
	unsigned int	flags:3;
	unsigned char 	offset_lsb;
	unsigned char	ttl;
	unsigned char	proto;
	unsigned short	checksum;
	ip4_addr_t		source;
	ip4_addr_t		destination;
} __attribute__((__packed__));
/*************************************************************************************************/
typedef struct ip_hdr ip_hdr_t;
#define IP_HDR_SZ  sizeof(ip_hdr_t);
/*************************************************************************************************/
struct arp_payload
{
	unsigned short 	hw_type;
	unsigned short 	p_type;
	unsigned char 	h_syze;
	unsigned char 	p_syze;
	unsigned short 	opcode;
	unsigned char 	sender_mac[6];
	unsigned int	sender_ip;
	unsigned char 	target_mac[6];
	unsigned int	target_ip;
} __attribute__((__packed__));
typedef struct arp_payload arp_pld_t;
#define ARP_PLD_SZ  sizeof(arp_pld_t);
/*************************************************************************************************/
struct icmp_payload
{
	unsigned char	type;
	unsigned char	code;
	unsigned short	checksum;
	unsigned char	data[];
} __attribute__((__packed__));
typedef struct icmp_payload icmp_pld_t;
/*************************************************************************************************/
int CheckPacket(unsigned char* packet, int length);
void SendARPAns(unsigned char* packet);
void ProcessICMPMess(unsigned char* packet, int ip_len);
unsigned short checksum(void *b, int len);
void Process_UDP_Message(unsigned char* mess);
unsigned short Crc16(unsigned char * pcBlock, unsigned short len);
void SendPDW(alt_u32* buf_ptr, int len);
/*************************************************************************************************/
#endif /*NETWORK_H_*/
