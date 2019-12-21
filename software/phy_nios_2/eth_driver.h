#ifndef ETH_DRIVER_H_
#define ETH_DRIVER_H_
/*************************************************************************************************/
#include "alt_types.h"
/*************************************************************************************************/
//#define PHY 0x1
#define PHY 0x1F
/*************************************************************************************************/
/*FOR ALTERA TSE*/
#define ALTERA_TSE_FIRST_TX_SGDMA_DESC_OFST     0
#define ALTERA_TSE_SECOND_TX_SGDMA_DESC_OFST    1
#define ALTERA_TSE_FIRST_RX_SGDMA_DESC_OFST     2
#define ALTERA_TSE_SECOND_RX_SGDMA_DESC_OFST    3
#define IORD_ALTERA_TSE_SGDMA_DESC_READ_ADDR(base)                      (IORD(base, 0x0) & 0xFFFFFFFF)
#define IOWR_ALTERA_TSE_SGDMA_DESC_READ_ADDR(base, data)                IOWR(base, 0x0, data)
#define IORD_ALTERA_TSE_SGDMA_DESC_WRITE_ADDR(base)                     (IORD(base, 0x2) & 0xFFFFFFFF)
#define IOWR_ALTERA_TSE_SGDMA_DESC_WRITE_ADDR(base, data)               IOWR(base, 0x2, data)
#define IORD_ALTERA_TSE_SGDMA_DESC_NEXT(base)                           (IORD(base, 0x4) & 0xFFFFFFFF)
#define IOWR_ALTERA_TSE_SGDMA_DESC_NEXT(base, data)                     IOWR(base, 0x4, data)

#define IORD_ALTERA_TSE_SGDMA_DESC_BYTES_TO_TRANSFER(base)              (IORD(base, 0x6) & 0xFFFF)
#define IOWR_ALTERA_TSE_SGDMA_DESC_BYTES_TO_TRANSFER(base, data)        IOWR(base, 0x6, ((IORD(base, 0x6) & 0xFFFF0000) | data))
#define IORD_ALTERA_TSE_SGDMA_DESC_READ_BURST(base)                     (((IORD(base, 0x6)) >> 16) & 0xFF)
#define IOWR_ALTERA_TSE_SGDMA_DESC_READ_BURST(base, data)               IOWR(base, 0x6, (IORD(base, 0x6) & 0xFF00FFFF) | (data << 16))
#define IORD_ALTERA_TSE_SGDMA_DESC_WRITE_BURST(base)                    (((IORD(base, 0x6)) >> 24) & 0xFF)
#define IOWR_ALTERA_TSE_SGDMA_DESC_WRITE_BURST(base, data)              IOWR(base, 0x6, ((IORD(base, 0x6) & 0x00FFFFFF) | (data << 24)))

#define IORD_ALTERA_TSE_SGDMA_DESC_ACTUAL_BYTES_TRANSFERRED(base)       (IORD(base, 0x7) & 0xFFFF)
#define IOWR_ALTERA_TSE_SGDMA_DESC_ACTUAL_BYTES_TRANSFERRED(base, data) IOWR(base, 0x7, ((IORD(base, 0x7) & 0xFFFF0000) | data))
#define IORD_ALTERA_TSE_SGDMA_DESC_STATUS(base)                         (((IORD(base, 0x7)) >> 16) & 0xFF)
#define IOWR_ALTERA_TSE_SGDMA_DESC_STATUS(base, data)                   IOWR(base, 0x7, (IORD(base, 0x7) & 0xFF00FFFF) | (data << 16))
#define IORD_ALTERA_TSE_SGDMA_DESC_CONTROL(base)                        (((IORD(base, 0x7)) >> 24) & 0xFF)
#define IOWR_ALTERA_TSE_SGDMA_DESC_CONTROL(base, data)                  IOWR(base, 0x7, ((IORD(base, 0x7) & 0x00FFFFFF) | (data << 24)))

#define ALTERA_TSE_MIN_MTU_SIZE                 4
#define ALTERA_TSE_MAC_MAX_FRAME_LENGTH         1518
#define ALTERA_TSE_PKT_INIT_LEN                 1528
#define ALTERA_TSE_SGDMA_INTR_MASK              ALTERA_AVALON_SGDMA_CONTROL_IE_CHAIN_COMPLETED_MSK | ALTERA_AVALON_SGDMA_CONTROL_IE_GLOBAL_MSK | ALTERA_AVALON_SGDMA_CONTROL_IE_EOP_ENCOUNTERED_MSK | ALTERA_AVALON_SGDMA_CONTROL_IE_ERROR_MSK | ALTERA_AVALON_SGDMA_CONTROL_IE_DESC_COMPLETED_MSK

#define ALTERA_TSE_SGDMA_BUSY_TIME_OUT_CNT      100000
/*************************************************************************************************/
//see ipport.h
#define ETHHDR_BIAS  (0)
/*************************************************************************************************/
#define UDP_COMMAND_PORT    0xE000
#define UDP_IMAGE_PORT      0xE001
//---------------------------------------------------------------------------------------------
/*************************************************************************************************/
#define	ARP_PROTO				0x0806
#define	IP_PROTO				0x0800
/*************************************************************************************************/
struct eth_hdr
{
	unsigned char	dest_mac[6];
	unsigned char 	src_mac[6];
	unsigned short 	type;
} __attribute__((__packed__));
typedef struct eth_hdr eth_hdr_t;
/*************************************************************************************************/
#define ETH_HDR_SZ sizeof(eth_hdr_t);
/*************************************************************************************************/
struct mac_struct
{
	/* EXAMPLE
	 * 00-1C-23-17-4A-CB
	 * mac_hi = 0x17231c00
	 * mac_lo = 0x0000CB4a
	 * */
	unsigned int	mac_hi;
	unsigned int	mac_lo;
};
/*************************************************************************************************/
typedef union
{
	struct mac_struct	mac_addr;
	unsigned char 		mac_arr[6];
} mac_addr_t;
/*************************************************************************************************/
void Delay(alt_u32 count);
int MAC_init_vdr();
int PHY_init();
int MAC_init();
int tse_sgdmaRx_isr(void * context, alt_u32 irqnum);
int tse_mac_raw_send(unsigned char * data, unsigned data_bytes);
int xMII_test();
//int tse_mac_chain_send(unsigned char * data, unsigned data_bytes, alt_u32 chain_size);
/*************************************************************************************************/
#endif /*ETH_DRIVER_H_*/
