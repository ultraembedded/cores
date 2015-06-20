### Simple SDRAM Controller

This IP core is that of a small, simple SDRAM controller used to provide a 32-bit pipelined Wishbone interface to a 16-bit SDRAM chip.

When accessing open rows, reads and writes can be pipelined to achieve full SDRAM bus utilization, however switching between reads & writes takes a few cycles.

The row management strategy is to leave active rows open until a row needs to be closed for a periodic auto refresh or until that bank needs to open another row due to a read or write request.

This IP supports supports 4 open active rows (one per bank).

##### Testing

Verified under simulation against a couple of SDRAM models and on the miniSpartan6+ board which features the AS4C16M16S.

The supplied testbench works with the free version of Modelsim.

##### Configuration
* SDRAM_MHZ - Clock speed (verified with 50MHz & 100MHz)
* SDRAM_ADDR_W - Total SDRAM address width (cols+rows+banks)
* SDRAM_COL_W - Number of column bits
* SDRAM_READ_LATENCY - Read data latency (use 3 for 100MHz, 2 for 50MHz)
* SDRAM_TARGET - Target XILINX or SIMULATION

##### Size / Performance

With the default configuration...

* the design contains 184 flops.
* synthesizes to > 160MHz on Xilinx Spartan 6 LX9 (speed -3)
* can hit up-to 92% of maximum bus rate for sequential accesses taking into account row open/close and refreshes.