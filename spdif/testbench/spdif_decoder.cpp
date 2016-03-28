#include "spdif_decoder.h"

#define PREAMBLE_Z         0x17
#define PREAMBLE_Y         0x27
#define PREAMBLE_X         0x47

#define SPDIF_PREAMBLE_L   0
#define SPDIF_PREAMBLE_H   3
#define SPDIF_PREAMBLE_W   4

#define SPDIF_SAMPLE_L     4
#define SPDIF_SAMPLE_H     27
#define SPDIF_SAMPLE_W     24

#define SPDIF_NVALID_L     28
#define SPDIF_NVALID_H     28
#define SPDIF_NVALID_W     1

#define SPDIF_PARITY_L     31
#define SPDIF_PARITY_H     31
#define SPDIF_PARITY_W     1

#define SPDIF_FIELD(v,n)   v.range(SPDIF_##n##_H, SPDIF_##n##_L)

//-----------------------------------------------------------------
// input: Handle rx data
//-----------------------------------------------------------------
void spdif_decoder::input(void) 
{
    sc_uint <64> bmc_data = 0;
    sc_uint <32> data     = 0;

    do
    {
        wait();
    }
    while (rst_i.read());

    bool last_rx  = false;
    int  subframe = 0;
    bool rx       = false;
    while (true)
    {
        rx = rx_i.read();

        // Detect transition in preamble
        if (rx == false && last_rx == true)
        {
            // Wait for half a bit time to sample mid bit
            wait(m_divisor/2);

            // Preamble leading bits were 0111
            bmc_data = 0x7;

            // Capture remaining timeslots
            for (int i=4;i<64;i++)
            {
                wait(m_divisor);
                rx = rx_i.read();
                bmc_data[i] = rx;
            }

            // Check preamble type is expected
            if (subframe == 0)
                sc_assert(bmc_data.range(7,0) == PREAMBLE_Z);
            else if (subframe & 1)
                sc_assert(bmc_data.range(7,0) == PREAMBLE_Y);
            else
                sc_assert(bmc_data.range(7,0) == PREAMBLE_X);

            if (++subframe == 384)
                subframe = 0;

            // Decode BMC data
            for (int i=0;i<64;i+=2)
            {
                if (bmc_data[i+0] != bmc_data[i+1])
                    data[i/2] = 1;
                else
                    data[i/2] = 0;
            }

            // Check parity
            int ones_count = 0;
            for (int i=SPDIF_PREAMBLE_H+1;i<SPDIF_PARITY_L;i++)
                if (data[i])
                    ones_count += 1;

            if (ones_count & 1)
                sc_assert(SPDIF_FIELD(data, PARITY));
            else
                sc_assert(!SPDIF_FIELD(data, PARITY));

            sc_uint <SPDIF_SAMPLE_W> sample = SPDIF_FIELD(data, SAMPLE);

            // Valid sample
            if (!SPDIF_FIELD(data, NVALID))
            {
                sc_assert(m_rx_fifo.num_free() > 0);

                if (m_bits == 16)
                    m_rx_fifo.write(sample >> (SPDIF_SAMPLE_W - 16));
                else if (m_bits == 20)
                    m_rx_fifo.write(sample >> (SPDIF_SAMPLE_W - 20));
                else if (m_bits == 24)
                    m_rx_fifo.write(sample >> (SPDIF_SAMPLE_W - 24));
                else
                    sc_assert(!"Unsupported bit width");
            }
        }
        else
            wait();

        last_rx = rx;
    }
}
