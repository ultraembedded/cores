### UART

Github:   [http://github.com/ultraembedded/cores](https://github.com/ultraembedded/cores/tree/master/uart)

This IP core is a lightweight UART interface. 
This implementation does not support HW flow control (RTS, CTS) and only supports 8-bit data, no parity and either 1 or 2 stop bits (8N1, 8N2).

The IP is accessed via a Wishbone slave interface for control, status and data access.

Supported modes of operation:
* 8 bits of data (8)
* No parity bits (N)
* 1 or 2 stop bits (1/2)

##### Configuration
* UART_DIVISOR_W - Width of divisor, as required (between 1 and 16)
* UART_DIVISOR_DEFAULT - Default UART clock divisor value
* UART_STOP_BITS_DEFAULT - Number of stop bits (0 = 1 stop bit, 1 = 2 stop bits)

##### Register Map

| Offset | Name | Description   |
| ------ | ---- | ------------- |
| 0x00 | UART_CFG | [RW] UART Configuration Register |
| 0x04 | UART_USR | [R] UART Status Register |
| 0x08 | UART_UDR | [RW] UART Data Register |

##### Register: UART_CFG

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 19 | INT_RX_ERROR | Interrupt enable (Rx error / break condition) |
| 18 | INT_RX_READY | Interrupt enable (Rx ready) |
| 17 | INT_TX_READY | Interrupt enable (Tx completion) |
| 16 | STOP_BITS | Stop bits (0 = 1 stop bit, 1 = 2 stop bits) |
| 8:0 | DIV | UART clock divisor |

##### Register: UART_USR

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 2 | TX_BUSY | Transmit busy |
| 1 | RX_ERROR | Receive error - cleared by reading UDR |
| 0 | RX_READY | Receive data ready |

##### Register: UART_UDR

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 7:0 | DATA | Date byte |


##### Testing

Verified under simulation and on various FPGA evaluation boards.
The supplied testbench requires the SystemC libraries and Icarus Verilog, both of which are available for free.
