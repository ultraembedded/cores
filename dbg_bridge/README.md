### UART -> AXI Debug Bridge

Github:   [http://github.com/ultraembedded/cores](https://github.com/ultraembedded/cores/tree/master/dbg_bridge)

This component provides a bridge from a standard UART interface (8N1) to a AXI4 bus master & GPIO interface.  
This can be very useful for FPGA dev boards featuring a FTDI UART interface where loading memories, peeking, poking SoC state is required.

##### Testing

Used extensively on various Xilinx FPGAs over the years.

##### Configuration
* CLK_FREQ - Clock (clk_i) frequency (in Hz).
* UART_SPEED - UART baud rate (bps)
* AXI_ID - AXI ID to be used for transactions

##### Software
Included python based utils provide peek and poke access, plus binary load / dump support.

Examples:
```
# Read a memory location (0x0)
./sw/peek.py -d /dev/ttyUSB1 -b 115200 -a 0x0

# Write a memory word (0x0 = 0x12345678)
./sw/poke.py -d /dev/ttyUSB1 -b 115200 -a 0x0 -v 0x12345678
``` 