### ULPI Link Wrapper

This IP core converts from the UTMI interface to the reduced pin-count ULPI interface.
This enables interfacing from a standard USB SIE with UTMI interface to a USB 2.0 PHY.

This enables support of USB LS (1.5mbps), FS (12mbps) and HS (480mbps) transfers.

The design does not support low power mode.

All IOs are synchronous to the 60MHz ULPI clock input (sourced from the PHY), so care needs to be taken to configure the FPGA constraints to ensure the ULPI interface correctly meets timing.

##### References

* [UTMI+ Low Pin Interface (ULPI) Specification](https://www.sparkfun.com/datasheets/Components/SMD/ULPI_v1_1.pdf)
* [SMSC USB3300 USB PHY Datasheet](http://ww1.microchip.com/downloads/en/DeviceDoc/3300db.pdf)

##### Testing

Verified under simulation and also on a Xilinx FPGA connected to a SMSC/Microchip USB3300 in device mode using the [USB3300 USB HS](http://www.waveshare.com/usb3300-usb-hs-board.htm) evaluation board.

The supplied trivial testbench works with the free version of Modelsim.

##### Size / Performance

With the current configuration...

* the design contains 67 flops, uses 46 slices (59 LUTs on a Xilinx Spartan 6 with IOB packing for the outputs).