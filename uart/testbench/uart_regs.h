#ifndef __UART_REGS_H__
#define __UART_REGS_H__

#define UART_CFG          0x0
    #define UART_CFG_INT_RX_ERROR_SHIFT          19
    #define UART_CFG_INT_RX_ERROR_MASK           0x1

    #define UART_CFG_INT_RX_READY_SHIFT          18
    #define UART_CFG_INT_RX_READY_MASK           0x1

    #define UART_CFG_INT_TX_READY_SHIFT          17
    #define UART_CFG_INT_TX_READY_MASK           0x1

    #define UART_CFG_STOP_BITS_SHIFT             16
    #define UART_CFG_STOP_BITS_MASK              0x1

    #define UART_CFG_DIV_SHIFT                   0
    #define UART_CFG_DIV_MASK                    0x1ff

#define UART_USR          0x4
    #define UART_USR_TX_BUSY_SHIFT               2
    #define UART_USR_TX_BUSY_MASK                0x1

    #define UART_USR_RX_ERROR_SHIFT              1
    #define UART_USR_RX_ERROR_MASK               0x1

    #define UART_USR_RX_READY_SHIFT              0
    #define UART_USR_RX_READY_MASK               0x1

#define UART_UDR          0x8
    #define UART_UDR_DATA_SHIFT                  0
    #define UART_UDR_DATA_MASK                   0xff

#endif