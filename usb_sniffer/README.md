### USB Sniffer

This core is a USB analyzer (USB bus sniffer). It converts from a ULPI interface (standard on various USB 2.0 PHYs such as the USB3300) to a bus-mastering Wishbone memory interface.

Configuration of the IP is performed using a Wishbone slave interface.

#### Features

* Filtering based on match or not match of device ID and/or endpoint
* Filtering of SOF packets
* 0.5uS timing resolution (HS) or 4uS timing resolution (FS/LS)
* Support LS (1.5mbps), FS (12mbps) and HS (480mbps) captures.
* Dense logging format.
* Supports continuous streaming, one shot and detects buffer overruns.


##### Register Map

| Offset | Name | Description   |
| ------ | ---- | ------------- |
| 0x00 | USB_BUFFER_CFG | [RW] Configuration Register |
| 0x04 | USB_BUFFER_BASE | [RW] Buffer Base Address |
| 0x08 | USB_BUFFER_END | [RW] Buffer End Address |
| 0x0c | USB_BUFFER_STS | [R] Status Register |
| 0x10 | USB_BUFFER_CURRENT | [R] Buffer Current address |
| 0x14 | USB_BUFFER_READ | [RW] Buffer Read Address |

##### Register: USB_BUFFER_CFG

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 30:24 | DEV | Device ID to match (only if MATCH_DEV = 1) |
| 19:16 | EP | Endpoint to match (only if MATCH_EP = 1) |
| 8:7 | SPEED | USB bus speed (0 = HS, 1 = FS, 2 = LS) |
| 6 | EXCLUDE_EP | Exclude specific endpoint |
| 5 | MATCH_EP | Match specific endpoint |
| 4 | EXCLUDE_DEV | Exclude specific device ID |
| 3 | MATCH_DEV | Match specific device ID |
| 2 | IGNORE_SOF | Drop SOF packets (0 = Log SOF, 1 = Drop SOF) |
| 1 | CONT | Continuous capture - overwrite on wrap (0 = Stop on full, 1 = cont) |
| 0 | ENABLED | Capture enabled |

##### Register: USB_BUFFER_BASE

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 31:0 | ADDR | Address of buffer base |

##### Register: USB_BUFFER_END

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 31:0 | ADDR | Address of buffer end |

##### Register: USB_BUFFER_STS

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 3 | OVERFLOW | Occurs when write pointer (BUFFER_CURRENT) hits read pointer (BUFFER_READ) |
| 2 | MEM_STALL | Overrun due to memory stall (data lost) |
| 1 | WRAPPED | Capture wrapped |
| 0 | TRIG | Capture triggered |

##### Register: USB_BUFFER_CURRENT

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 31:0 | ADDR | Current buffer address - always a log entry word |

##### Register: USB_BUFFER_READ

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 31:0 | ADDR | Used by block to detect overflow |


##### References

* [UTMI+ Low Pin Interface (ULPI) Specification](https://www.sparkfun.com/datasheets/Components/SMD/ULPI_v1_1.pdf)
* [SMSC USB3300 USB PHY Datasheet](http://ww1.microchip.com/downloads/en/DeviceDoc/3300db.pdf)
* [ULPI Wrapper](https://github.com/ultraembedded/cores/tree/master/ulpi_wrapper)

##### Testing

Tested on Spartan 6 LX9 (miniSpartan6+) with internal blockRAM and external USB PHY (USB3300).
Various types of USB device traces captured.