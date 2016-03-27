`define UART_CFG    8'h0

    `define UART_CFG_INT_RX_ERROR      19
	`define UART_CFG_INT_RX_ERROR_DEFAULT    0
    `define UART_CFG_INT_RX_ERROR_B          19
    `define UART_CFG_INT_RX_ERROR_T          19
    `define UART_CFG_INT_RX_ERROR_W          1
    `define UART_CFG_INT_RX_ERROR_R          19:19

    `define UART_CFG_INT_RX_READY      18
	`define UART_CFG_INT_RX_READY_DEFAULT    0
    `define UART_CFG_INT_RX_READY_B          18
    `define UART_CFG_INT_RX_READY_T          18
    `define UART_CFG_INT_RX_READY_W          1
    `define UART_CFG_INT_RX_READY_R          18:18

    `define UART_CFG_INT_TX_READY      17
	`define UART_CFG_INT_TX_READY_DEFAULT    0
    `define UART_CFG_INT_TX_READY_B          17
    `define UART_CFG_INT_TX_READY_T          17
    `define UART_CFG_INT_TX_READY_W          1
    `define UART_CFG_INT_TX_READY_R          17:17

    `define UART_CFG_STOP_BITS      16
	`define UART_CFG_STOP_BITS_DEFAULT    0
    `define UART_CFG_STOP_BITS_B          16
    `define UART_CFG_STOP_BITS_T          16
    `define UART_CFG_STOP_BITS_W          1
    `define UART_CFG_STOP_BITS_R          16:16

	`define UART_CFG_DIV_DEFAULT    0
    `define UART_CFG_DIV_B          0
    `define UART_CFG_DIV_T          8
    `define UART_CFG_DIV_W          9
    `define UART_CFG_DIV_R          8:0

`define UART_USR    8'h4

    `define UART_USR_TX_BUSY      2
	`define UART_USR_TX_BUSY_DEFAULT    0
    `define UART_USR_TX_BUSY_B          2
    `define UART_USR_TX_BUSY_T          2
    `define UART_USR_TX_BUSY_W          1
    `define UART_USR_TX_BUSY_R          2:2

    `define UART_USR_RX_ERROR      1
	`define UART_USR_RX_ERROR_DEFAULT    0
    `define UART_USR_RX_ERROR_B          1
    `define UART_USR_RX_ERROR_T          1
    `define UART_USR_RX_ERROR_W          1
    `define UART_USR_RX_ERROR_R          1:1

    `define UART_USR_RX_READY      0
	`define UART_USR_RX_READY_DEFAULT    0
    `define UART_USR_RX_READY_B          0
    `define UART_USR_RX_READY_T          0
    `define UART_USR_RX_READY_W          1
    `define UART_USR_RX_READY_R          0:0

`define UART_UDR    8'h8

	`define UART_UDR_DATA_DEFAULT    0
    `define UART_UDR_DATA_B          0
    `define UART_UDR_DATA_T          7
    `define UART_UDR_DATA_W          8
    `define UART_UDR_DATA_R          7:0

