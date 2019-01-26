### AXI4 -> Async SRAM (16-bit) Interface

Github:   [http://github.com/ultraembedded/cores](https://github.com/ultraembedded/cores/tree/master/asram16_axi4)

This component is a simple memory controller interface for asynchronous SRAM featuring an AXI4 interface.

##### Limitations
Does not support narrow bursts (i.e where AxSize != 32-bit), hence these signals are not present.

##### Testing
Verified under simulation, tested on a Xilinx Spartan6 FPGA against an Alliance Memory AS7C34098A 16-bit SRAM (but will work with other 16-bit asynchronous SRAM parts).

##### Configuration
* parameter WRITE_WAIT_CYCLES - Number of clock cycles to achieve tAW.
* parameter READ_WAIT_CYCLES - Number of clock cycles to achieve tAA.
* parameter WRITE_HOLD_CYCLES - Number of clock cycles to achieve tDH.
* define SUPPORT_FIXED_BURST - Support for fixed AXI4 burst transfers.
* define SUPPORT_WRAP_BURST - Support for wrapping AXI4 burst transfers.

##### References
* [Alliance Memory AS7C34098A](https://www.alliancememory.com/datasheets/as7c34098a)
