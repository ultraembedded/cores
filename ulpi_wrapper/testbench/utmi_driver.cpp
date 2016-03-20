#include "utmi_driver.h"

//-----------------------------------------------------------------
// tx_drive
//-----------------------------------------------------------------
void utmi_driver::tx_drive(void) 
{
    // Wait until reset complete
    while (rst_i.read())
        wait();

    // I/O
    // utmi_txvalid_o
    // utmi_data_o
    // utmi_txready_i

    utmi_txvalid_o.write(false);
    utmi_data_o.write(false);

    while (true)
    {
        bool last;
        sc_uint <8> data;

        do
        {
            last = tx_read(data);

            utmi_txvalid_o.write(true);
            utmi_data_o.write(data);

            do
            {
                wait();
            }
            while (!utmi_txready_i.read());

            utmi_txvalid_o.write(false);
            utmi_data_o.write(0);
        }
        while (!last);

        wait();
    }
}
//-----------------------------------------------------------------
// rx_mon
//-----------------------------------------------------------------
void utmi_driver::rx_mon(void) 
{
    // Wait until reset complete
    while (rst_i.read())
        wait();

    // I/O
    // utmi_data_i
    // utmi_rxvalid_i
    // utmi_rxactive_i

    bool last_valid = false;
    sc_uint <8> last_data = 0;
    while (true)
    {
        if (utmi_rxvalid_i.read())
        {
            if (last_valid)
                rx_write(last_data, false);

            last_valid = true;
            last_data  = utmi_data_i.read();
        }

        if (!utmi_rxactive_i.read() && last_valid)
        {
            rx_write(last_data, true);
            last_valid = false;
        }
        wait();
    }
}
//-----------------------------------------------------------------
// write
//-----------------------------------------------------------------
void utmi_driver::write(sc_uint <8> data, bool last)
{
    sc_uint <9> fifo_data;

    fifo_data.range(7,0) = data;
    fifo_data.range(8,8) = last;

    m_tx_fifo.write(fifo_data);
}
//-----------------------------------------------------------------
// read
//-----------------------------------------------------------------
bool utmi_driver::read(sc_uint <8> &data)
{
    sc_uint <9> fifo_data = m_rx_fifo.read();
    data = fifo_data.range(7,0);
    return (bool)fifo_data.range(8,8);
}
//-----------------------------------------------------------------
// rx_write
//-----------------------------------------------------------------
void utmi_driver::rx_write(sc_uint <8> data, bool last)
{
    sc_uint <9> fifo_data;

    fifo_data.range(7,0) = data;
    fifo_data.range(8,8) = last;

    m_rx_fifo.write(fifo_data);
}
//-----------------------------------------------------------------
// tx_read
//-----------------------------------------------------------------
bool utmi_driver::tx_read(sc_uint <8> &data)
{
    sc_uint <9> fifo_data = m_tx_fifo.read();
    data = fifo_data.range(7,0);
    return (bool)fifo_data.range(8,8);
}
