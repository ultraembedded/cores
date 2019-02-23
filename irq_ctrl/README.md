### AXI Interrupt Controller

Github:   [http://github.com/ultraembedded/cores](https://github.com/ultraembedded/cores/tree/master/irq_ctrl)

This component is a simple IRQ controller implementation with AXI4-Lite slave interface.
The register interface has limited compatibility with Xilinx's LogiCORE IP AXI Interrupt Controller(INTC) IP, enough so that the Linux Kernel driver works with it unmodified.

##### Features
* 8 interrupt inputs.
* AXI4-L register interface.
* Single interrupt output

##### Limitations
* Active high interrupts only
* AXI4-L address and data must arrive in the same cycle.

##### Testing
Verified under simulation and then tested on FPGA using the stock Linux Kernel 4.19 driver (irq-xilinx-intc.c).

##### References
* [LogiCORE IP AXI Interrupt Controller (INTC) (v4.1)](https://www.xilinx.com/support/documentation/ip_documentation/axi_intc/v4_1/pg099-axi-intc.pdf)
