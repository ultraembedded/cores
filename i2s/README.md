### I2S Master

Github:   [http://github.com/ultraembedded/cores](https://github.com/ultraembedded/cores/tree/master/i2s)

This is a simple I2S master module written in Verilog.

The module requires clock source which is used to derive MCLK and BCLK for the I2S interface.

The audio_clk_i clock rate should be:
* 32KHz - 16.384MHz
* 44.1KHz - 22.5792MHz
* 48KHz - 24.576MHz

The frequency of clk_i must be more than 2 x audio_clk_i frequency.

The input interface expects 32-bits (2 x 16-bit audio samples) to be provided to it on 'sample_i' and held until 'sample_req_o' is pulsed (data pop request).

This allows connection to a simple FIFO for audio samples.

##### Testing

The supplied testbench requires the SystemC libraries and Icarus Verilog, both of which are available for free.
