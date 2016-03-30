#include "i2s_driver.h"

//-----------------------------------------------------------------
// output: Drive tx data
//-----------------------------------------------------------------
void i2s_driver::output(void)
{
    wait();
    sc_assert(m_tx_fifo.num_available() > 0);

    while (true)
    {
        sample_data_o.write(m_tx_fifo.read());

        wait();

        while (!sample_req_i.read())
            wait();
    }
}
