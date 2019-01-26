### SPI-Lite SPI Master Interface

Github:   [http://github.com/ultraembedded/cores](https://github.com/ultraembedded/cores/tree/master/spilite_axi4l)

This component is a simple SPI Master mode implementation with AXI4-Lite slave interface.
The register interface has limited compatibility with Xilinx's SPI peripheral IP, enough so that the Linux Kernel SPI driver works with it unmodified.

##### Features
* All combinations of SPI Master modes (CPHA, CPOL) supported.
* 8 slaves support (8 chip select lines).
* 4 entry Tx/Rx FIFOs.
* 8-bit SPI data unit size.
* LSB or MSB data first option.
* Loopback test mode supported.
* AXI4-L register interface.
* Interrupt output (on Tx-empty / Rx valid).

##### Limitations
* SPI Master only
* Manual chip select mode only.
* AXI4-L address and data must arrive in the same cycle.

##### Testing
Verified under simulation then tested on FPGA against various SPI flash parts under Linux using the stock Linux Kernel 4.19 driver (spi-xilinx.c).

##### Configuration
* parameter C_SCK_RATIO - Clock divider ratio for clk_i -> spi_clk_o

##### References
* [LogiCORE IP AXI Serial Peripheral Interface (AXI SPI) (v1.01a)](https://www.xilinx.com/support/documentation/ip_documentation/axi_spi_ds742.pdf)
