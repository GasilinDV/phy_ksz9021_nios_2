#ifndef UDP_TX_OFFLOAD_REGS_H
#define UDP_TX_OFFLOAD_REGS_H

#include "io.h"

// UDP TX OFFLOAD ACCESS MACROS

#define UDP_TX_OFFLOAD_RD_CSR(base)                   IORD(base, 0)
#define UDP_TX_OFFLOAD_WR_CSR(base, data)             IOWR(base, 0, data)

#define UDP_TX_OFFLOAD_CSR_GO_BIT_MASK                (0x01)
#define UDP_TX_OFFLOAD_CSR_GO_BIT_OFST                (0)
#define UDP_TX_OFFLOAD_CSR_RUNNING_BIT_MASK           (0x02)
#define UDP_TX_OFFLOAD_CSR_RUNNING_BIT_OFST           (1)
#define UDP_TX_OFFLOAD_CSR_ERROR_BIT_MASK             (0x04)
#define UDP_TX_OFFLOAD_CSR_ERROR_BIT_OFST             (2)
#define UDP_TX_OFFLOAD_BYP_BIT_MASK                   (0x10000)
#define UDP_TX_OFFLOAD_BYP_BIT_OFST                   (16)

#define UDP_TX_OFFLOAD_RD_MAC_DST_HI(base)            IORD(base, 1)
#define UDP_TX_OFFLOAD_WR_MAC_DST_HI(base, data)      IOWR(base, 1, data)

#define UDP_TX_OFFLOAD_MAC_DST_HI_MASK                (0xFFFFFFFF)
#define UDP_TX_OFFLOAD_MAC_DST_HI_OFST                (0)

#define UDP_TX_OFFLOAD_RD_MAC_DST_LO(base)            IORD(base, 2)
#define UDP_TX_OFFLOAD_WR_MAC_DST_LO(base, data)      IOWR(base, 2, data)

#define UDP_TX_OFFLOAD_MAC_DST_LO_MASK                (0xFFFF)
#define UDP_TX_OFFLOAD_MAC_DST_LO_OFST                (0)

#define UDP_TX_OFFLOAD_RD_MAC_SRC_HI(base)            IORD(base, 3)
#define UDP_TX_OFFLOAD_WR_MAC_SRC_HI(base, data)      IOWR(base, 3, data)

#define UDP_TX_OFFLOAD_MAC_SRC_HI_MASK                (0xFFFFFFFF)
#define UDP_TX_OFFLOAD_MAC_SRC_HI_OFST                (0)

#define UDP_TX_OFFLOAD_RD_MAC_SRC_LO(base)            IORD(base, 4)
#define UDP_TX_OFFLOAD_WR_MAC_SRC_LO(base, data)      IOWR(base, 4, data)

#define UDP_TX_OFFLOAD_MAC_SRC_LO_MASK                (0xFFFF)
#define UDP_TX_OFFLOAD_MAC_SRC_LO_OFST                (0)

#define UDP_TX_OFFLOAD_RD_IP_SRC(base)                IORD(base, 5)
#define UDP_TX_OFFLOAD_WR_IP_SRC(base, data)          IOWR(base, 5, data)

#define UDP_TX_OFFLOAD_IP_SRC_MASK                    (0xFFFFFFFF)
#define UDP_TX_OFFLOAD_IP_SRC_OFST                    (0)

#define UDP_TX_OFFLOAD_RD_IP_DST(base)                IORD(base, 6)
#define UDP_TX_OFFLOAD_WR_IP_DST(base, data)          IOWR(base, 6, data)

#define UDP_TX_OFFLOAD_IP_DST_MASK                    (0xFFFFFFFF)
#define UDP_TX_OFFLOAD_IP_DST_OFST                    (0)

#define UDP_TX_OFFLOAD_RD_UDP_PORTS(base)             IORD(base, 7)
#define UDP_TX_OFFLOAD_WR_UDP_PORTS(base, data)       IOWR(base, 7, data)

#define UDP_TX_OFFLOAD_UDP_DST_MASK                   (0x0000FFFF)
#define UDP_TX_OFFLOAD_UDP_DST_OFST                   (0)
#define UDP_TX_OFFLOAD_UDP_SRC_MASK                   (0xFFFF0000)
#define UDP_TX_OFFLOAD_UDP_SRC_OFST                   (16)

#define UDP_TX_OFFLOAD_RD_PACKET_COUNTER(base)        IORD(base, 8)
#define UDP_TX_OFFLOAD_CLEAR_PACKET_COUNTER(base)     IOWR(base, 8, 0)

#define UDP_TX_OFFLOAD_PACKET_COUNTER_MASK            (0xFFFFFFFF)
#define UDP_TX_OFFLOAD_PACKET_COUNTER_OFST            (0)

#define UDP_TX_OFFLOAD_RD_IP_HDR_HI(base)             IORD(base, 9)
#define UDP_TX_OFFLOAD_WR_IP_HDR_HI(base, data)       IOWR(base, 9, data)

#define UDP_TX_OFFLOAD_DSCP_MASK                      (0x00FF0000)
#define UDP_TX_OFFLOAD_DSCP_OFST                      (16)
#define UDP_TX_OFFLOAD_IDENT_MASK                     (0x0000FFFF)
#define UDP_TX_OFFLOAD_IDENT_OFST                     (0)

#define UDP_TX_OFFLOAD_RD_IP_HDR_LO(base)             IORD(base, 10)
#define UDP_TX_OFFLOAD_WR_IP_HDR_LO(base, data)       IOWR(base, 10, data)

#define UDP_TX_OFFLOAD_FLAGS_MASK                     (0xE0000000)
#define UDP_TX_OFFLOAD_FLAGS_OFST                     (29)
#define UDP_TX_OFFLOAD_OFFSET_MASK                    (0x01FFFFFF)
#define UDP_TX_OFFLOAD_OFFSET_OFST                    (16)
#define UDP_TX_OFFLOAD_TTL_MASK                       (0x0000FF00)
#define UDP_TX_OFFLOAD_TTL_OFST                       (8)
#define UDP_TX_OFFLOAD_PROTO_MASK                     (0x000000FF)
#define UDP_TX_OFFLOAD_PROTO_OFST                     (0)

#define UDP_TX_OFFLOAD_RD_PACKET_LEN(base)            IORD(base, 11)
#define UDP_TX_OFFLOAD_WR_PACKET_LEN(base, data)      IOWR(base, 11, data)

#define UDP_TX_OFFLOAD_PACKET_LEN_MASK                (0xFFFFFFFF)
#define UDP_TX_OFFLOAD_PACKET_LEN_OFST                (0)

#define UDP_TX_OFFLOAD_RD_AUX_CONFIG(base)            IORD(base, 12)
#define UDP_TX_OFFLOAD_WR_AUX_CONFIG(base, data)      IOWR(base, 12, data)

#define UDP_TX_OFFLOAD_AUX_CONFIG_MASK                (0xFFFFFFFF)
#define UDP_TX_OFFLOAD_AUX_CONFIG_OFST                (0)

#endif /*UDP_TX_OFFLOAD_REGS_H*/
