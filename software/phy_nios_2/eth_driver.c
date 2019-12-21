#include "eth_driver.h"
#include "system.h"
#include "sys/alt_irq.h"
#include "triple_speed_ethernet_regs.h"
#include "altera_avalon_sgdma.h"
#include "altera_avalon_sgdma_descriptor.h"
#include "altera_avalon_sgdma_regs.h"
#include "altera_avalon_pio_regs.h"
#include "udp_tx_offload_regs.h"
#include "endian_converter_macros.h"
/*#include "image_desc_processor_regs.h"*/
#include "sys/alt_cache.h"
#ifdef ALT_STDIO_DEBUG_MESSAGES
#include "sys/alt_stdio.h"
#endif //ALT_STDIO_DEBUG_MESSAGES
#include "network.h"
#include <errno.h>
//---------------------------------------------------------------------------------------------
alt_sgdma_descriptor *desc = (alt_sgdma_descriptor *) ETH_0_DESC_MEMORY_BASE;
alt_sgdma_dev *sgdma_tx_dev;
alt_sgdma_dev *sgdma_rx_dev;

volatile unsigned char pkt[1562] __attribute__ ((aligned (4)));
extern volatile unsigned char eth_tx_pkt[1518] __attribute__ ((aligned (4)));

int sem;
int udp_sem;
extern mac_addr_t MY_MAC_ADDR;
extern ip4_addr_t MY_IP_ADDR;
alt_u32 p_counter;

//---------------------------------------------------------------------------------------------
void Delay(alt_u32 count)
{
    alt_u32 i;
    for (i=0;i<count;++i)
    {}
}
//---------------------------------------------------------------------------------------------
int PHY_init()
{
	// reset phy
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_0_BASE, 0);
	Delay(0xFF);
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_0_BASE, 1);
	alt_printf("Nios II was reset...\n");

    alt_u32 t=0;
    alt_u32 r=0;
    while (1) {
    	IOWR_ALTERA_TSEMAC_MDIO_ADDR1(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE, 0);
        IOWR_ALTERA_TSEMAC_MDIO_ADDR0(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE, t);
#ifdef ALT_STDIO_DEBUG_MESSAGES
        alt_printf("Probing PHY at address %x ...\n", t);
#endif //ALT_STDIO_DEBUG_MESSAGES
        r = IORD_ALTERA_TSEMAC_MDIO(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE, 0, ALTERA_TSEMAC_PHY_ADDR_PHY_ID1);
        if (r == 0x22)/*KSZ9021*/{
#ifdef ALT_STDIO_DEBUG_MESSAGES
            alt_printf("PHY address:%x\n", t);
            alt_printf("PHY_ID1:%x\n", r);
            alt_printf("PHY_ID2:%x\n", IORD_ALTERA_TSEMAC_MDIO(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE, 0, ALTERA_TSEMAC_PHY_ADDR_PHY_ID2));
            while(1) {
                r = IORD_ALTERA_TSEMAC_MDIO(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE, 0, ALTERA_TSEMAC_PHY_ADDR_STATUS);
                alt_printf("Status:%x\n", r);
                Delay(0xFFFF);
                if(r&0x4) {
                    alt_printf("Link up\n");
                    break;
                }
            }
            IOWR_ALTERA_TSEMAC_MDIO(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE, 0, 0xb, 0x0104);
            alt_printf("Skew settings:%x\n", IORD_ALTERA_TSEMAC_MDIO(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE, 0, 0xd));
            IOWR_ALTERA_TSEMAC_MDIO(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE, 0, 0xb, 0x8104);
            IOWR_ALTERA_TSEMAC_MDIO(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE, 0, 0xc, 0x9077);
            IOWR_ALTERA_TSEMAC_MDIO(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE, 0, 0xb, 0x0104);
            alt_printf("Skew settings:%x\n", IORD_ALTERA_TSEMAC_MDIO(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE, 0, 0xd));
            IOWR_ALTERA_TSEMAC_MDIO(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE, 0, 0xb, 0x8105);
            IOWR_ALTERA_TSEMAC_MDIO(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE, 0, 0xc, 0x0);
            /*
            IOWR_ALTERA_TSEMAC_MDIO(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE, 0, 0xb, 0x0106);
            alt_printf("(TXD?)Skew settings:%x\n", IORD_ALTERA_TSEMAC_MDIO(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE, 0, 0xd));
            IOWR_ALTERA_TSEMAC_MDIO(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE, 0, 0xb, 0x8106);
            IOWR_ALTERA_TSEMAC_MDIO(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE, 0, 0xc, 0x0);
            IOWR_ALTERA_TSEMAC_MDIO(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE, 0, 0xb, 0x0106);
            alt_printf("(TXD?)Skew settings:%x\n", IORD_ALTERA_TSEMAC_MDIO(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE, 0, 0xd));
            */
#endif //ALT_STDIO_DEBUG_MESSAGES
            break;
        }
        if (t == 32) {
        	IOWR_ALTERA_AVALON_PIO_DATA(PIO_0_BASE, 0);
        	Delay(0xFF);
        	IOWR_ALTERA_AVALON_PIO_DATA(PIO_0_BASE, 1);
        	alt_printf("Nios II was reset...\n");
            t = 0;
        }
        t++;
    }
    return 0;
}
//---------------------------------------------------------------------------------------------
int MAC_init()
{
    alt_u32 t2=0;
    int status=0;
    p_counter=0;
    
    //PHY and other board peripherial initialization
#ifdef ALT_STDIO_DEBUG_MESSAGES
    alt_printf("TSE_MAC_REV:%x\n", IORD_ALTERA_TSEMAC_REV(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE));
#endif //ALT_STDIO_DEBUG_MESSAGES

    //PHY and other board peripherial initialization
        IOWR_ALTERA_TSEMAC_MDIO_ADDR0(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE, PHY);
        do
        {
            t2=IORD_ALTERA_TSEMAC_MDIO(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE,0,ALTERA_TSEMAC_PHY_ADDR_STATUS); //находимся в цикле пока не считаем нужный статус в переменную t2
        }
        while((t2&0x04)==0);//wait for link-up

    //Get the Rx and Tx SGDMA addresses
    sgdma_rx_dev = alt_avalon_sgdma_open(ETH_0_RX_SGDMA_NAME);
    sgdma_tx_dev = alt_avalon_sgdma_open(ETH_0_TX_SGDMA_NAME);
    IOWR_ALTERA_AVALON_SGDMA_CONTROL(ETH_0_RX_SGDMA_BASE,ALTERA_AVALON_SGDMA_CONTROL_SOFTWARERESET_MSK); //soft reset
    IOWR_ALTERA_AVALON_SGDMA_CONTROL(ETH_0_RX_SGDMA_BASE, 0x0); //send nulls
    
    //reset the mac
    IOWR_ALTERA_TSEMAC_CMD_CONFIG(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE , ALTERA_TSEMAC_CMD_SW_RESET_MSK | ALTERA_TSEMAC_CMD_TX_ENA_MSK | ALTERA_TSEMAC_CMD_RX_ENA_MSK);
    while(IORD_ALTERA_TSEMAC_CMD_CONFIG(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE) & ALTERA_TSEMAC_CMD_SW_RESET_MSK)
    {
    }
#ifdef ALT_STDIO_DEBUG_MESSAGES
    t2 = IORD_ALTERA_TSEMAC_CMD_CONFIG(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE);
    if (t2 & 0x03)
    {
        alt_printf("RX/TX not disabled after reset.\n");
    }
    else
    {
        alt_printf("CMD_CONFIG:%x\n", IORD_ALTERA_TSEMAC_CMD_CONFIG(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE));
    }
#endif //ALT_STDIO_DEBUG_MESSAGES
    // Initialize MAC registers
    IOWR_ALTERA_TSEMAC_FRM_LENGTH(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE, ALTERA_TSE_MAC_MAX_FRAME_LENGTH);
    IOWR_ALTERA_TSEMAC_RX_ALMOST_EMPTY(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE, 8);
    IOWR_ALTERA_TSEMAC_RX_ALMOST_FULL(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE, 8);
    IOWR_ALTERA_TSEMAC_TX_ALMOST_EMPTY(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE, 8);
    IOWR_ALTERA_TSEMAC_TX_ALMOST_FULL(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE,  3);
    IOWR_ALTERA_TSEMAC_TX_SECTION_EMPTY(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE, ETH_0_TRIPLE_SPEED_ETHERNET_0_TRANSMIT_FIFO_DEPTH - 16); //1024/4;
    IOWR_ALTERA_TSEMAC_TX_SECTION_FULL(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE,  0); //32/4; // start transmit when there are 48 bytes
    IOWR_ALTERA_TSEMAC_RX_SECTION_EMPTY(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE, ETH_0_TRIPLE_SPEED_ETHERNET_0_RECEIVE_FIFO_DEPTH - 16); //4000/4);
    IOWR_ALTERA_TSEMAC_RX_SECTION_FULL(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE,  0);
    //IOWR_ALTERA_TSEMAC_TX_CMD_STAT(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE,ALTERA_TSEMAC_TX_CMD_STAT_TXSHIFT16_MSK);
    IOWR_ALTERA_TSEMAC_TX_CMD_STAT(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE,0);
    //IOWR_ALTERA_TSEMAC_RX_CMD_STAT(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE,ALTERA_TSEMAC_RX_CMD_STAT_RXSHIFT16_MSK);
    IOWR_ALTERA_TSEMAC_RX_CMD_STAT(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE,0);
    IOWR_ALTERA_TSEMAC_MAC_0(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE, MY_MAC_ADDR.mac_addr.mac_hi);
    IOWR_ALTERA_TSEMAC_MAC_1(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE, MY_MAC_ADDR.mac_addr.mac_lo);
    IOWR_ALTERA_TSEMAC_CMD_CONFIG(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE,   ALTERA_TSEMAC_CMD_TX_ENA_MSK |
                                                                        ALTERA_TSEMAC_CMD_RX_ENA_MSK |
                                                                        ALTERA_TSEMAC_CMD_TX_ADDR_INS_MSK |
                                                                        ALTERA_TSEMAC_CMD_RX_ERR_DISC_MSK |
                                                                        //ALTERA_TSEMAC_CMD_LOOPBACK_MSK |
                                                                        //ALTERA_TSEMAC_CMD_PROMIS_EN_MSK |
                                                                        ALTERA_TSEMAC_CMD_PAD_EN_MSK //|
                                                                        /*ALTERA_TSEMAC_CMD_CRC_FWD_MSK*/);
    alt_avalon_sgdma_register_callback(sgdma_rx_dev,(alt_avalon_sgdma_callback)&tse_sgdmaRx_isr,(alt_u16)ALTERA_TSE_SGDMA_INTR_MASK,sgdma_rx_dev);
 
    alt_u32 *uncached_packet_payload;
    uncached_packet_payload = (void *)alt_remap_cached ((volatile void*) pkt, 4);
    alt_avalon_sgdma_construct_stream_to_mem_desc(
            (alt_sgdma_descriptor *) &desc[ALTERA_TSE_FIRST_RX_SGDMA_DESC_OFST],  // descriptor I want to work with
            (alt_sgdma_descriptor *) &desc[ALTERA_TSE_SECOND_RX_SGDMA_DESC_OFST],  // pointer to "next"
            uncached_packet_payload,            // starting write_address
            0,                                  // read until EOP
            0);
    while ( (IORD_ALTERA_AVALON_SGDMA_STATUS(ETH_0_RX_SGDMA_BASE) & ALTERA_AVALON_SGDMA_STATUS_BUSY_MSK) );
    t2=alt_avalon_sgdma_do_async_transfer(sgdma_rx_dev, &desc[ALTERA_TSE_FIRST_RX_SGDMA_DESC_OFST]);
    // Clearing busy flags
    sem=0;
    UDP_TX_OFFLOAD_WR_IP_SRC(ETH_0_UDP_TX_OFFLOAD_BASE, MY_IP_ADDR.addr);
    return status;
}
//---------------------------------------------------------------------------------------------
int tse_sgdmaRx_isr(void * context, alt_u32 irqnum)
{
    alt_u32 t2=0;
    alt_u32 *uncached_packet_payload;
    t2=IORD_ALTERA_AVALON_SGDMA_STATUS(ETH_0_RX_SGDMA_BASE);
    if (t2 & (ALTERA_AVALON_SGDMA_STATUS_CHAIN_COMPLETED_MSK | 
                     ALTERA_AVALON_SGDMA_STATUS_DESC_COMPLETED_MSK))
    {
        p_counter++;
        alt_printf("Packet counter:%x\n",p_counter);
        IOWR_ALTERA_AVALON_SGDMA_STATUS(ETH_0_RX_SGDMA_BASE,ALTERA_AVALON_SGDMA_STATUS_CHAIN_COMPLETED_MSK);
        t2=IORD_ALTERA_TSE_SGDMA_DESC_STATUS(&desc[ALTERA_TSE_FIRST_RX_SGDMA_DESC_OFST]);
        /*check status and handle packet*/
        if( (t2 & 
          (ALTERA_AVALON_SGDMA_DESCRIPTOR_STATUS_E_CRC_MSK | 
           ALTERA_AVALON_SGDMA_DESCRIPTOR_STATUS_E_PARITY_MSK | 
           ALTERA_AVALON_SGDMA_DESCRIPTOR_STATUS_E_OVERFLOW_MSK |
           ALTERA_AVALON_SGDMA_DESCRIPTOR_STATUS_E_SYNC_MSK | 
           ALTERA_AVALON_SGDMA_DESCRIPTOR_STATUS_E_UEOP_MSK | 
           ALTERA_AVALON_SGDMA_DESCRIPTOR_STATUS_E_MEOP_MSK | 
           ALTERA_AVALON_SGDMA_DESCRIPTOR_STATUS_E_MSOP_MSK ) ) == 0)
        {
            t2=IORD_16DIRECT(&desc[ALTERA_TSE_FIRST_RX_SGDMA_DESC_OFST].actual_bytes_transferred, 0)-2;
            CheckPacket(pkt,t2);
        }
        else
        {
            alt_printf("RX descriptor reported error. Packet dropped\n");
        }
        uncached_packet_payload = (void *)alt_remap_cached ((volatile void*) pkt, 4);
        alt_avalon_sgdma_construct_stream_to_mem_desc(
            (alt_sgdma_descriptor *) &desc[ALTERA_TSE_FIRST_RX_SGDMA_DESC_OFST],  // descriptor I want to work with
            (alt_sgdma_descriptor *) &desc[ALTERA_TSE_SECOND_RX_SGDMA_DESC_OFST],  // pointer to "next"
            uncached_packet_payload,            // starting write_address
            0,                                  // read until EOP
            0);                                 // don't write to constant address
        t2=alt_avalon_sgdma_do_async_transfer(sgdma_rx_dev, &desc[ALTERA_TSE_FIRST_RX_SGDMA_DESC_OFST]);
    }
    return 0;
}
//---------------------------------------------------------------------------------------------
int tse_mac_raw_send(unsigned char * data, unsigned data_bytes)
{
    alt_u32 *uncached_packet_payload;
    alt_32 timeout;    
    int result;
    //eth_hdr_t* p1 = (eth_hdr_t*) (data);
    //unsigned char* payload;
    if(sem!=0) /* Tx is busy*/
    {
#ifdef ALT_STDIO_DEBUG_MESSAGES
        alt_printf("tse_mac_raw_send: Tx is busy\n");
#endif //ALT_STDIO_DEBUG_MESSAGES
        return -22;
    }
    if(UDP_TX_OFFLOAD_CSR_RUNNING_BIT_MASK&UDP_TX_OFFLOAD_RD_CSR(ETH_0_UDP_TX_OFFLOAD_BASE)) /* UDP offload is busy*/
    {
#ifdef ALT_STDIO_DEBUG_MESSAGES
        //alt_printf("UDP offload is busy\n");
#endif //ALT_STDIO_DEBUG_MESSAGES
        //return -22;
    }
    sem = 1;   
    // clear bit-31 before passing it to SGDMA Driver
    uncached_packet_payload = (alt_u32*)alt_remap_cached ((volatile void*) data, 4);

    /* Write data to Tx FIFO using the DMA */
    if( data_bytes > ALTERA_TSE_MIN_MTU_SIZE )
    {    
        /* make sure there is room in the FIFO.        */
        alt_avalon_sgdma_construct_mem_to_stream_desc(
        		(alt_sgdma_descriptor *) &desc[ALTERA_TSE_FIRST_TX_SGDMA_DESC_OFST], // descriptor I want to work with
        		(alt_sgdma_descriptor *) &desc[ALTERA_TSE_SECOND_TX_SGDMA_DESC_OFST],// pointer to "next"
        		uncached_packet_payload,                     // starting read address
        		(data_bytes),                             		// # bytes
        		0,                                        	// don't read from constant address
        		1,                                        	// generate sop
        		1,                                        	// generate endofpacket signal
        		0);                                       	// atlantic channel (don't know/don't care: set to 0)
        result = 0;


        // Make sure DMA controller is not busy from a former command
        // and TX is able to accept data
        timeout = 0;
        while ( (IORD_ALTERA_AVALON_SGDMA_STATUS(ETH_0_TX_SGDMA_BASE) &
            ALTERA_AVALON_SGDMA_STATUS_BUSY_MSK) )
        {
            if(timeout++ == ALTERA_TSE_SGDMA_BUSY_TIME_OUT_CNT)
            {
#ifdef ALT_STDIO_DEBUG_MESSAGES
                alt_printf("tse_mac_raw_send: WARNING - TX SGDMA Timeout\n");
#endif //ALT_STDIO_DEBUG_MESSAGES
                return -22;  // avoid being stuck here
            }
        }
        // Set up the SGDMA
        // Clear the status and control bits of the SGDMA descriptor
        IOWR_ALTERA_AVALON_SGDMA_CONTROL (ETH_0_TX_SGDMA_BASE, 0);
        IOWR_ALTERA_AVALON_SGDMA_STATUS (ETH_0_TX_SGDMA_BASE, 0xFF);
        // Start SGDMA (blocking call)
        result = alt_avalon_sgdma_do_sync_transfer(
            sgdma_tx_dev, 
            (alt_sgdma_descriptor *) &desc[ALTERA_TSE_FIRST_TX_SGDMA_DESC_OFST]);
    }
    else
    {
        result = -3;
    }

    if(result < 0)   /* SGDMA not available */
    {
#ifdef ALT_STDIO_DEBUG_MESSAGES
        alt_printf("tse_mac_raw_send: SGDMA not available\n");
#endif //ALT_STDIO_DEBUG_MESSAGES
        sem = 0;
        return -22;   /* ENP_RESOURCE and SEND_DROPPED have the same value! */
    }
    else   /* = 0, success */
    {
        sem = 0;
        return 0;  /*success */
    }
}
//---------------------------------------------------------------------------------------------
int xMII_test()
{
    alt_u32 t;
    IOWR_ALTERA_TSEMAC_CMD_CONFIG(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE , ALTERA_TSEMAC_CMD_SW_RESET_MSK | ALTERA_TSEMAC_CMD_TX_ENA_MSK | ALTERA_TSEMAC_CMD_RX_ENA_MSK);
    while(IORD_ALTERA_TSEMAC_CMD_CONFIG(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE) & ALTERA_TSEMAC_CMD_SW_RESET_MSK)
    {
    }
    IOWR_ALTERA_TSEMAC_CMD_CONFIG(ETH_0_TRIPLE_SPEED_ETHERNET_0_BASE,   ALTERA_TSEMAC_CMD_TX_ENA_MSK |
                                                                        ALTERA_TSEMAC_CMD_RX_ENA_MSK |
                                                                        ALTERA_TSEMAC_CMD_TX_ADDR_INS_MSK |
                                                                        /*ALTERA_TSEMAC_CMD_RX_ERR_DISC_MSK |*/
                                                                        ALTERA_TSEMAC_CMD_LOOPBACK_MSK |
                                                                        ALTERA_TSEMAC_CMD_PROMIS_EN_MSK |
                                                                        ALTERA_TSEMAC_CMD_CRC_FWD_MSK |
                                                                        ALTERA_TSEMAC_CMD_PAD_EN_MSK
    );
    UDP_TX_OFFLOAD_WR_MAC_DST_HI(ETH_0_UDP_TX_OFFLOAD_BASE, 0xffffffff);
    UDP_TX_OFFLOAD_WR_MAC_DST_LO(ETH_0_UDP_TX_OFFLOAD_BASE, 0xffff);
    UDP_TX_OFFLOAD_WR_AUX_CONFIG(ETH_0_UDP_TX_OFFLOAD_BASE, ARP_PROTO);
    UDP_TX_OFFLOAD_WR_CSR(ETH_0_UDP_TX_OFFLOAD_BASE, UDP_TX_OFFLOAD_CSR_GO_BIT_MASK|UDP_TX_OFFLOAD_BYP_BIT_MASK);
    for (t=6; t<256; t++)
        eth_tx_pkt[t] = 0x0;
    alt_printf("Sending test packet\n");
    tse_mac_raw_send(&(eth_tx_pkt) , 256);
    return 0;
}
//---------------------------------------------------------------------------------------------
