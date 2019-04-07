### USB 1.1 Host Controller

This IP core is a cutdown USB host controller which allows communications with full-speed (12mbps) USB devices.

The IP is accessed via an AXI4-Lite slave register interface for control, status and data.

Data to be sent or received is stored in some internal FIFOs. The data is accessed through the AXI4-Lite slave port. There is no DMA engine (e.g. a bus mastering interface) associated with this IP.

The core functions well, is very small, but is fairly inefficient in terms of CPU cycles required to perform USB transfers.
This core is not compliant with any standard USB host interface specification, e.g OHCI or EHCI.

##### Instantiation
Instance usbh_host and hookup to UTMI PHY interface and a AXI4-Lite master (e.g. from your CPU).
The core requires a 48MHz/60MHz clock input, which the AXI4-Lite and UTMI interfaces are expected to be synchronous to.

##### Limitations
* Only tested for USB-FS (Full Speed / 12Mbit/s) only.
* AXI4-L address and data must arrive in the same cycle.

##### Testing

Verified under simulation and on FPGA with various USB devices attached (hubs, mass storage, network devices).

##### References
* [USB 2.0 Specification](https://usb.org/developers/docs/usb20_docs)
* [UTMI Specification](https://www.intel.com/content/dam/www/public/us/en/documents/technical-specifications/usb2-transceiver-macrocell-interface-specification.pdf)
* [USB Made Simple](http://www.usbmadesimple.co.uk/)
* [UTMI to ULPI Conversion](https://github.com/ultraembedded/cores/tree/master/ulpi_wrapper)

##### Configuration
* SOF_THRESHOLD  - Number of clock cycles per millisecond (default: 48000 for 48MHz)
* CLKS_PER_BIT   - Number of clock cycles per FS bit (default: 4 for 48MHz)

##### Size / Performance

With the default configuration...

* the design contains 317 registers, 392 LUTs (Xilinx ISE - Spartan 6)
* synthesizes to more than the required 48MHz on a Xilinx Spartan 6 LX9 (speed -3)

##### Register Map

| Offset | Name | Description   |
| ------ | ---- | ------------- |
| 0x00 | USB_CTRL | [RW] Control of USB reset, SOF and Tx FIFO flush |
| 0x04 | USB_STATUS | [R] Line state, Rx error status and frame time |
| 0x08 | USB_IRQ_ACK | [W] Acknowledge IRQ by setting relevant bit |
| 0x0c | USB_IRQ_STS | [R] Interrupt status |
| 0x10 | USB_IRQ_MASK | [RW] Interrupt mask |
| 0x14 | USB_XFER_DATA | [RW] Tx payload transfer length |
| 0x18 | USB_XFER_TOKEN | [RW] Transfer control info (direction, type) |
| 0x1c | USB_RX_STAT | [R] Transfer status (Rx length, error, idle) |
| 0x20 | USB_WR_DATA | [W] Tx FIFO address for write data |
| 0x20 | USB_RD_DATA | [R] Tx FIFO address for read data |

##### Register: USB_CTRL

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 7 | PHY_DMPULLDOWN | UTMI PHY D+ Pulldown Enable |
| 6 | PHY_DPPULLDOWN | UTMI PHY D+ Pulldown Enable |
| 5 | PHY_TERMSELECT | UTMI PHY Termination Select |
| 4:3 | PHY_XCVRSELECT | UTMI PHY Transceiver Select |
| 2:1 | PHY_OPMODE | UTMI PHY Output Mode |
| 1 | TX_FLUSH | Flush Tx FIFO |
| 0 | ENABLE_SOF | Enable SOF (start of frame) packet generation |

##### Register: USB_STATUS

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 31:16 | SOF_TIME | Current frame time (0 - 48000) |
| 2 | RX_ERROR | Rx error detected (UTMI). Clear on new xfer. |
| 1:0 | LINESTATE_BITS | Line state (1 = D-, 0 = D+) |

##### Register: USB_IRQ_ACK

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 3 | DEVICE_DETECT | Interrupt on device detect (linestate != SE0). |
| 2 | ERR | Interrupt on error conditions. |
| 1 | DONE | Interrupt on transfer completion. |
| 0 | SOF | Interrupt on start of frame. |

##### Register: USB_IRQ_STS

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 3 | DEVICE_DETECT | Interrupt on device detect (linestate != SE0). |
| 2 | ERR | Interrupt on error conditions. |
| 1 | DONE | Interrupt on transfer completion. |
| 0 | SOF | Interrupt on start of frame. |

##### Register: USB_IRQ_MASK

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 3 | DEVICE_DETECT | Interrupt on device detect (linestate != SE0). |
| 2 | ERR | Interrupt on error conditions. |
| 1 | DONE | Interrupt on transfer completion. |
| 0 | SOF | Interrupt on start of frame. |

##### Register: USB_XFER_DATA

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 15:0 | TX_LEN | Tx transfer data length |

##### Register: USB_XFER_TOKEN

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 31 | START | Transfer start request |
| 30 | IN | IN transfer (1) or OUT transfer (0) |
| 29 | ACK | Send ACK in response to IN data |
| 28 | PID_DATAX | DATA1 (1) or DATA0 (0) |
| 23:16 | PID_BITS | Token PID (SETUP=0x2d, OUT=0xE1 or IN=0x69) |
| 15:9 | DEV_ADDR | Device address |
| 8:5 | EP_ADDR | Endpoint address |

##### Register: USB_RX_STAT

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 31 | START_PEND | Transfer start pending |
| 30 | CRC_ERR | CRC error detected |
| 29 | RESP_TIMEOUT | Response timeout detected (no response) |
| 28 | IDLE | SIE idle |
| 23:16 | RESP_BITS | Received response PID |
| 15:0 | COUNT_BITS | Received data count |

##### Register: USB_WR_DATA

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 7:0 | DATA | Date byte |

##### Register: USB_RD_DATA

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 7:0 | DATA | Date byte |

