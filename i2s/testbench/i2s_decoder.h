#ifndef I2S_DECODER_H
#define I2S_DECODER_H

#include <systemc.h>

#define I2S_MAX_BITS     24

//-------------------------------------------------------------
// i2s_decoder: Decoder for I2S interface
//-------------------------------------------------------------
SC_MODULE (i2s_decoder)
{
public:
    // Clock and Reset
    sc_in  <bool>   clk_i;
    sc_in  <bool>   rst_i;

    // I/O
    sc_in <bool>    i2s_mclk_i;
    sc_in <bool>    i2s_bclk_i;
    sc_in <bool>    i2s_ws_i;
    sc_in <bool>    i2s_data_i;

    // Constructor
    SC_HAS_PROCESS(i2s_decoder);
    i2s_decoder(sc_module_name name): sc_module(name),
                                      m_rx_fifo(1024)
    {
        m_bits    = 16;
        SC_CTHREAD(input, i2s_bclk_i.pos());
    }

public:
    sc_uint <I2S_MAX_BITS> read(void)    { return m_rx_fifo.read(); }
    bool read_ready(void)                { return m_rx_fifo.num_available() > 0; }
    void set_bit_width(int bits)         { m_bits = bits; }

private:
    void input(void);

    sc_fifo < sc_uint<I2S_MAX_BITS> > m_rx_fifo;
    int m_bits;
};

#endif