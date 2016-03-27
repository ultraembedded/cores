#include "wb_lite_driver.h"

//-----------------------------------------------------------------
// write
//-----------------------------------------------------------------
void wb_lite_driver::write(sc_uint <8> addr, sc_uint <32> data)
{
    addr_o.write(addr);
    data_o.write(data);
    we_o.write(true);
    stb_o.write(true);

    do
    {
        wait();

        if (!m_classic_mode)
        {
            addr_o.write(0);
            data_o.write(0);
            we_o.write(false);
            stb_o.write(false);
        }
    }
    while (!ack_i.read());

    if (m_classic_mode)
    {
        addr_o.write(0);
        data_o.write(0);
        we_o.write(false);
        stb_o.write(false);
    }
}
//-----------------------------------------------------------------
// read
//-----------------------------------------------------------------
sc_uint <32> wb_lite_driver::read(sc_uint <8> addr)
{
    addr_o.write(addr);
    data_o.write(0);
    we_o.write(false);
    stb_o.write(true);

    do
    {
        wait();

        if (!m_classic_mode)
        {
            addr_o.write(0);
            data_o.write(0);
            we_o.write(false);
            stb_o.write(false);
        }
    }
    while (!ack_i.read());

    if (m_classic_mode)
    {
        addr_o.write(0);
        data_o.write(0);
        we_o.write(false);
        stb_o.write(false);
    }

    return data_i.read();
}
