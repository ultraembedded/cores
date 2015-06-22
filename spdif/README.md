### SPDIF Transmitter

This is a simple SPDIF transmitter module written in Verilog.

This module can either generate its own audio clock by dividing down clk_i or can use an external audio clock to drive the output stream via audio_clk_i.

For external clocking mode, the audio_clk_i clock rate should be:
* 32KHz - 4.096MHz
* 44.1KHz - 5.6448MHz
* 48KHz - 6.144MHz

Note that in external clocking mode, the frequency of clk_i must be more than 4 x audio_clk_i frequency.

For internal clocking mode, the clk_i input is divided to roughly the right frequency required for chosen the sample rate. This isn't going to be exact!

##### Testing

Tested on a Pioneer VSX D510 over TOSLINK and also on a cheap no-brand Ebay D/A converter.

##### Configuration

* CLK_RATE_KHZ - Clock speed (clk_i) in KHz
* AUDIO_RATE - Audio sample rate, e.g. 44100 or 48000
* AUDIO_CLK_SRC - Can be INTERNAL or EXTERNAL

##### Size / Performance

With the default configuration...
* the design contains 69 flops, 3 adders, 2 comparators, 11 multiplexers (according to ISE).
