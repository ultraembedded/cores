### FTDI Asynchronous FIFO Interface (FT245R mode)

This component provides a bridge from a FTDI asynchronous FIFO interface (such as found on the FT245R or FT2232) to a Wishbone master interface & GPIO interface.

Devices such as the FT2232 must be switched into asynchronous FIFO mode using the FT_PROG EEPROM programming tool from FTDI.

The component supports writes down to byte level granularity, and reads down to a 32-bit word level. 

##### Testing

Verified on FPGA on the miniSpartan6+ board which uses the FTDI FT2232HL.
Many megabytes of self checking transfers to and from SDRAM using this component.

The supplied smoke test works with the free version Modelsim.

##### Configuration
* CLK_DIV - Clock divider (minimum is 2)
* LITTLE_ENDIAN - System is little endian (1) or big endian (0)
* ADDR_W - Width of Wishbone address bus
* GP_OUTPUTS - Number of GPIO outputs (1 - 8)
* GP_INPUTS - Number of GPIO inputs (1 - 8)
* GP_IN_EVENT_MASK - Bit mask of inputs which are events that are registered and cleared on read

##### Size / Performance

With the default configuration...

* the design contains 122 flops.
* synthesizes to > 160MHz on Xilinx Spartan 6 LX9 (speed -3)
* write performance: 5.4MB/s (block size of 2KB)
* read performance: 2MB/s (block size of 2KB)