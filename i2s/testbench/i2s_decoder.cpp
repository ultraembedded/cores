#include "i2s_decoder.h"

//-----------------------------------------------------------------
// input: Handle rx data
//-----------------------------------------------------------------
void i2s_decoder::input(void) 
{
    do
    {
        wait();
    }
    while (rst_i.read());

    bool first = true;
    int  bit_cnt = 0;
    sc_uint <I2S_MAX_BITS> data = 0;
    sc_uint <I2S_MAX_BITS> rev_data = 0;
    bool ws;

    while (true)
    {
        if (!first)
        {
            // Left
            if (!ws)
            {
                sc_assert(bit_cnt < m_bits);

                rev_data[bit_cnt] = i2s_data_i.read();

                if (++bit_cnt == m_bits)
                {
                    for (int i=0;i<m_bits;i++)
                        data[m_bits-i-1] = rev_data[i];

                    m_rx_fifo.write(data);
                    data = 0;
                }
            }
            // Right
            else
            {
                sc_assert(bit_cnt >= m_bits);
                sc_assert(bit_cnt < (m_bits*2));

                rev_data[bit_cnt-m_bits] = i2s_data_i.read();

                if (++bit_cnt == (m_bits*2))
                {
                    for (int i=0;i<m_bits;i++)
                        data[m_bits-i-1] = rev_data[i];

                    m_rx_fifo.write(data);
                    data    = 0;
                    bit_cnt = 0;
                }
            }
        }
        else
            first = false;

        ws = i2s_ws_i.read();

        wait();
    }
}
