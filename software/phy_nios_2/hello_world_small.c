#ifdef ALT_STDIO_DEBUG_MESSAGES
#include "sys/alt_stdio.h"
#endif  //ALT_STDIO_DEBUG_MESSAGES
#include "eth_driver.h"
#include "network.h"

#include "altera_avalon_pio_regs.h"

/*
volatile unsigned char buf[42]  __attribute__ ((aligned (4)))={
        0xff,0xff,0xff,0xff,0xff,0xff,0x00,0x07,0xab,0xf0,0x0d,0xba,0x08,0x06,0x00,0x01,
        0x08,0x00,0x06,0x04,0x00,0x01,0x00,0x07,0xab,0xf0,0x0d,0xba,0xc0,0xa8,0x00,0x02,
        0x00,0x00,0x00,0x00,0x00,0x00,0xc0,0xa8,0x00,0x01
};
*/

extern volatile char pkt[1562];
char *data_ptr = &pkt[0];
volatile char rx_pkt[1562];

extern mac_addr_t   MY_MAC_ADDR;
extern ip4_addr_t   MY_IP_ADDR;
extern mac_addr_t   HOST_MAC_ADDR;
extern ip4_addr_t   HOST_IP_ADDR;

int main()
{
    alt_putstr("Hello from Nios II!\n");
    /* MAC ADDRESS
     * 00-07-AB-F0-0D-BA
     * 00-16-36-DE-58-F6
     */
    MY_MAC_ADDR.mac_addr.mac_hi = 0xDE361600;
    MY_MAC_ADDR.mac_addr.mac_lo = 0x0000F658;
    /* IP ADDRESS
     * 192.168.0.12
     */
    MY_IP_ADDR.ad_arr[3] = 192;
    MY_IP_ADDR.ad_arr[2] = 168;
    MY_IP_ADDR.ad_arr[1] = 0;
    MY_IP_ADDR.ad_arr[0] = 12;
    /* HOST MAC ADDRESS
     * 64-70-02-01-53-01
     * 90-2B-34-17-9C-29
     */
    HOST_MAC_ADDR.mac_addr.mac_hi = 0x34179C29; //why vice versa ?
    HOST_MAC_ADDR.mac_addr.mac_lo = 0x0000902B;
    /* HOST IP ADDRESS
     * 192.168.0.168
     */
    HOST_IP_ADDR.ad_arr[3] = 192;
    HOST_IP_ADDR.ad_arr[2] = 168;
    HOST_IP_ADDR.ad_arr[1] = 0;
    HOST_IP_ADDR.ad_arr[0] = 108;

#ifdef ALT_STDIO_DEBUG_MESSAGES
        alt_printf("Board IP address:%d.%d.%d.%d.\n", MY_IP_ADDR.ad_arr[3], MY_IP_ADDR.ad_arr[2],
                                                      MY_IP_ADDR.ad_arr[1], MY_IP_ADDR.ad_arr[0]);
#endif //ALT_STDIO_DEBUG_MESSAGES

    alt_16 fill_data_count = 0;
    char pkt_data = 0x00;
    for(fill_data_count=0; fill_data_count<200; fill_data_count++){
    	pkt[fill_data_count] = pkt_data;
    	rx_pkt[fill_data_count] = pkt_data;
    	pkt_data++;
    }

    pkt[200] = 0xEF;
    	pkt[800] = 0xDE;
    	rx_pkt[200] = 0xEF;
    	rx_pkt[800] = 0xDE;

    	alt_printf("Hello from NIOS\n");

//   MAC_init_vdr();
    PHY_init();
    MAC_init();

    //Detector_Init();
    while(1){
        //xMII_test();
    	//tse_mac_raw_send(unsigned char * data, unsigned data_bytes)
        Delay(0xfffff);
        tse_mac_raw_send(pkt, 200);
    }
/*
        //marsohod code test
        char leds = 0x1;
        int i = 0;
        while(1)
        {

        	//for (i=0; i<(ALT_CPU_FREQ/500); i++) // delay
        	//	leds = ((leds<<1) & 0xE) | (!(leds>>3) & 0x1);
        	for (i = 0; i < (ALT_CPU_FREQ/10); i++);
        		leds = 0xF;
        		IOWR_ALTERA_AVALON_PIO_DATA(LEDS_PIO_BASE, leds);

        	for (i = 0; i < (ALT_CPU_FREQ/10); i++);
        		leds = 0x0;
        		IOWR_ALTERA_AVALON_PIO_DATA(LEDS_PIO_BASE, leds);
        }
*/

    /* Event loop never exits. */
    //while (1);
    return 0;
}
