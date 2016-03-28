#ifndef SPDIF_DECODER_H
#define SPDIF_DECODER_H

#include <systemc.h>

#define SPDIF_MAX_BITS     24

//-------------------------------------------------------------
// spdif_decoder: Decoder for SPDIF signal
//-------------------------------------------------------------
SC_MODULE (spdif_decoder)
{
public:
    // Clock and Reset
    sc_in  <bool>   clk_i;
    sc_in  <bool>   rst_i;

    // I/O
    sc_in  <bool>   rx_i;

    // Constructor
    SC_HAS_PROCESS(spdif_decoder);
    spdif_decoder(sc_module_name name): sc_module(name),
                                        m_rx_fifo(1024)
    {
        m_divisor = 0;
        m_bits    = 16;
        SC_CTHREAD(input, clk_i.pos());
    }

public:
    sc_uint <SPDIF_MAX_BITS> read(void)  { return m_rx_fifo.read(); }
    bool read_ready(void)                { return m_rx_fifo.num_available() > 0; }
    void set_clock_div(int divisor)      { m_divisor = divisor; }
    void set_bit_width(int bits)         { m_bits = bits; }

private:
    void input(void);

    sc_fifo < sc_uint<SPDIF_MAX_BITS> > m_rx_fifo;

    int m_divisor;
    int m_bits;
};

#endif