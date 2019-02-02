### USB Peripheral Interface

Github:   [http://github.com/ultraembedded/cores](https://github.com/ultraembedded/cores/tree/master/usb_device)

This component is a simple USB Peripheral Interface (Device) implementation with an AXI4-Lite slave register interface, and
with a UTMI interface for connection to a USB PHY.

It has been designed to support USB2.0, but currently has been only tested in Full Speed peripheral mode (12Mbit/s).

##### Features
* USB 2.0 Device mode support.
* Simple register data read/write interface (low performance / not DMA based).
* UTMI PHY interface (see my UTMI to ULPI Conversion wrapper project to allow connection to a ULPI PHY e.g. USB3300)
* Current build configuration has 4 endpoints

##### Limitations
* Only tested for USB-FS (Full Speed / 12Mbit/s) only.
* AXI4-L address and data must arrive in the same cycle.

##### Software
Provided with a USB-CDC test stack (USB Serial port) with loopback/echo example.

To make this functional on your platform;
* Set USB_DEV_BASE to the correct address for the peripheral.
* Implement the millisecond timer functions in timer.h.
* Change USB_BYTE_SWAP16 in usbf_defs.h if your CPU is big endian.

##### Testing
Verified under simulation then tested on FPGA as a USB-CDC mode peripheral (USB serial port) against Linux & Windows PCs.

##### References
* [USB 2.0 Specification](https://usb.org/developers/docs/usb20_docs)
* [UTMI Specification](https://www.intel.com/content/dam/www/public/us/en/documents/technical-specifications/usb2-transceiver-macrocell-interface-specification.pdf)
* [USB Made Simple](http://www.usbmadesimple.co.uk/)
* [UTMI to ULPI Conversion](https://github.com/ultraembedded/cores/tree/master/ulpi_wrapper)

##### Register Map

| Offset | Name | Description   |
| ------ | ---- | ------------- |
| 0x00 | USB_FUNC_CTRL | [RW] Control Register |
| 0x04 | USB_FUNC_STAT | [RW] Status Register |
| 0x08 | USB_FUNC_ADDR | [RW] Address Register |
| 0x0c | USB_EP0_CFG | [RW] Endpoint 0 Configuration |
| 0x10 | USB_EP0_TX_CTRL | [RW] Endpoint 0 Tx Control |
| 0x14 | USB_EP0_RX_CTRL | [W] Endpoint 0 Rx Control |
| 0x18 | USB_EP0_STS | [R] Endpoint 0 status |
| 0x1c | USB_EP0_DATA | [RW] Endpoint Data FIFO |
| 0x20 | USB_EP1_CFG | [RW] Endpoint 1 Configuration |
| 0x24 | USB_EP1_TX_CTRL | [RW] Endpoint 1 Tx Control |
| 0x28 | USB_EP1_RX_CTRL | [W] Endpoint 1 Rx Control |
| 0x2c | USB_EP1_STS | [R] Endpoint 1 status |
| 0x30 | USB_EP1_DATA | [RW] Endpoint Data FIFO |
| 0x34 | USB_EP2_CFG | [RW] Endpoint 2 Configuration |
| 0x38 | USB_EP2_TX_CTRL | [RW] Endpoint 2 Tx Control |
| 0x3c | USB_EP2_RX_CTRL | [W] Endpoint 2 Rx Control |
| 0x40 | USB_EP2_STS | [R] Endpoint 2 status |
| 0x44 | USB_EP2_DATA | [RW] Endpoint Data FIFO |
| 0x48 | USB_EP3_CFG | [RW] Endpoint 3 Configuration |
| 0x4c | USB_EP3_TX_CTRL | [RW] Endpoint 3 Tx Control |
| 0x50 | USB_EP3_RX_CTRL | [W] Endpoint 3 Rx Control |
| 0x54 | USB_EP3_STS | [R] Endpoint 3 status |
| 0x58 | USB_EP3_DATA | [RW] Endpoint Data FIFO |

##### Register: USB_FUNC_CTRL

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 8 | HS_CHIRP_EN | High-speed Chirp Enable |
| 7 | PHY_DMPULLDOWN | UTMI PHY D+ Pulldown Enable |
| 6 | PHY_DPPULLDOWN | UTMI PHY D+ Pulldown Enable |
| 5 | PHY_TERMSELECT | UTMI PHY Termination Select |
| 4:3 | PHY_XCVRSELECT | UTMI PHY Transceiver Select |
| 2:1 | PHY_OPMODE | UTMI PHY Output Mode |
| 0 | INT_EN_SOF | Interrupt enable - SOF reception |

##### Register: USB_FUNC_STAT

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 13 | RST | USB Reset Detected (cleared on write) |
| 12:11 | LINESTATE | USB line state (bit 1 = D+, bit 0 = D-) |
| 10:0 | FRAME | Frame number |

##### Register: USB_FUNC_ADDR

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 6:0 | DEV_ADDR | Device address |

##### Register: USB_EPx_CFG

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 3 | INT_RX | Interrupt on Rx ready |
| 2 | INT_TX | Interrupt on Tx complete |
| 1 | STALL_EP | Stall endpoint |
| 0 | ISO | Isochronous endpoint |

##### Register: USB_EPx_TX_CTRL

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 17 | TX_FLUSH | Invalidate Tx buffer |
| 16 | TX_START | Transmit start - enable transmit of endpoint data |
| 10:0 | TX_LEN | Transmit length |

##### Register: USB_EPx_RX_CTRL

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 1 | RX_FLUSH | Invalidate Rx buffer |
| 0 | RX_ACCEPT | Receive data accepted (read) |

##### Register: USB_EPx_STS

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 20 | TX_ERR | Transmit error (buffer underrun) |
| 19 | TX_BUSY | Transmit busy (active) |
| 18 | RX_ERR | Receive error - CRC mismatch or buffer overflow |
| 17 | RX_SETUP | SETUP request received |
| 16 | RX_READY | Receive ready (data available) |
| 10:0 | RX_COUNT | Endpoint received length (RD) |

##### Register: USB_EPx_DATA

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 7:0 | DATA | Read or write from Rx or Tx endpoint FIFO |

