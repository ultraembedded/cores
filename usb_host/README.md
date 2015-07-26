### USB 1.1 Host Controller

This IP core is a cutdown USB host controller which allows communications with full-speed (12mbps) USB devices.

The IP is accessed via a Wishbone slave interface (asynchronous read result) for control, status and data.

Data to be sent or received is stored in some internal FIFOs (which are configurable in size). The data is accessed through the Wishbone slave port. There is no DMA engine (e.g. a bus mastering interface) associated with this IP.

The core functions well, is very small, but is fairly inefficient in terms of CPU cycles required to perform USB transfers.
This core is not compliant with any standard USB host interface specification, e.g OHCI or EHCI.

##### Instantiation
Instance usbh and hookup to UTMI PHY interface and a Wishbone master (e.g. from your CPU).
The core requires a 48MHz clock input.

##### Testing

Verified under simulation and on FPGA with various USB devices attached (hubs, mass storage, network devices).

##### Configuration
* TX_FIFO_DEPTH  - Transmit FIFO size
* TX_FIFO_ADDR_W - Transmit FIFO size (width of size field)
* RX_FIFO_DEPTH  - Receive FIFO size
* RX_FIFO_ADDR_W - Receive FIFO size (width of size field)

##### Size / Performance

With the default configuration...

* the design contains 214 flops, 2 RAM cells (RX and TX FIFOs)
* synthesizes to more than the required 48MHz on a Xilinx Spartan 6 LX9 (speed -3)

##### Register Map

| Offset | Name | Description                                                    |
| ------ | ---- | -------------------------------------------------------------- |
| 0x00   | USB_CTRL        | [Write] Control of USB reset, SOF and Tx FIFO flush |
| 0x00   | USB_STATUS      | [Read] line state, Rx error status and frame time   |
| 0x04   | USB_IRQ_ACK     | [Write] Acknowledge IRQ by setting relevant bit     |
| 0x04   | USB_IRQ_STS     | [Read] Interrupt status                             |
| 0x08   | USB_IRQ_MASK    | [Read/Write] Interrupt mask                         |
| 0x0c   | USB_XFER_DATA   | [Write] Tx payload transfer length                  |
| 0x10   | USB_XFER_TOKEN  | [Write] Transfer control info (direction, type)     |
| 0x14   | USB_RX_STAT     | [Read] Transfer status (Rx length, error, idle)     |
| 0x18   | USB_WR_DATA     | [Write] Tx FIFO address for write data              |
| 0x18   | USB_RD_DATA     | [Read] Tx FIFO address for read data                |


##### Register: USB_CTRL

| Bits | Name | Description                                                    |
| ---- | ---- | -------------------------------------------------------------- |
| 2    | USB_TX_FLUSH        | Flush Tx FIFO                                   |
| 1    | USB_ENABLE_SOF      | Enable SOF (start of frame) packet generation   |
| 0    | USB_RESET_ACTIVE    | 1 = assert USB reset state, 0 = normal          |

##### Register: USB_STATUS

| Bits  | Name | Description                                                    |
| ----- | ---- | -------------------------------------------------------------- |
| 31:16 | USB_STAT_SOF_TIME       | Current frame time (0 - 47999)              |
| 2     | USB_STAT_RX_ERROR       | Rx error detected (UTMI). Clear on new xfer.|
| 1:0   | USB_STAT_LINESTATE_BITS | Line state (1 = D-, 1 = D+)                 |

##### Register: USB_IRQ_ACK / USB_IRQ_STS / USB_IRQ_MASK

| Bits | Name | Description                                               |
| ---- | ---- | --------------------------------------------------------- |
| 2    | USB_IRQ_ERR    | Interrupt on error conditions.                  |
| 1    | USB_IRQ_DONE   | Interrupt on transfer completion                |
| 0    | USB_IRQ_SOF    | Interrupt on start of frame                     |

##### Register: USB_XFER_DATA

| Bits  | Name | Description                                                    |
| ----- | ---- | -------------------------------------------------------------- |
| 15:0  | USB_XFER_DATA_TX_LEN    | Tx transfer data length                     |

##### Register: USB_XFER_TOKEN

| Bits  | Name | Description                                                    |
| ----- | ---- | -------------------------------------------------------------- |
| 31    | USB_XFER_START     | Transfer start request                           |
| 30    | USB_XFER_IN        | IN transfer (1) or OUT transfer (0)              |
| 29    | USB_XFER_ACK       | Send ACK in response to IN data                  |
| 28    | USB_XFER_PID_DATAX | DATA1 (1) or DATA0 (0)                           |
| 23:16 | USB_XFER_PID_BITS  | Token PID (SETUP=0x2d, OUT=0xE1 or IN=0x69)      |
| 15:9  | USB_XFER_DEV_ADDR  | Device address                                   |
| 8:5   | USB_XFER_EP_ADDR   | Endpoint address                                 |

##### Register: USB_RX_STAT

| Bits  | Name | Description                                                    |
| ----- | ---- | -------------------------------------------------------------- |
| 31    | USB_RX_STAT_START_PEND   | Transfer start pending                     |
| 30    | USB_RX_STAT_CRC_ERR      | CRC error detected                         |
| 29    | USB_RX_STAT_RESP_TIMEOUT | Response timeout detected (no response)    |
| 28    | USB_RX_STAT_IDLE         | SIE idle                                   |
| 23:16 | USB_RX_STAT_RESP_BITS    | Received response PID                      |
| 15:0  | USB_RX_STAT_COUNT_BITS   | Received data count                        |

##### Register: USB_WR_DATA / USB_RD_DATA

| Bits  | Name | Description                                                    |
| ----- | ---- | -------------------------------------------------------------- |
| 7:0   | DATA | Data byte                                                      |
