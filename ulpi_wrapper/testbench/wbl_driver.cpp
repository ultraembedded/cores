#include "wbl_driver.h"

//-----------------------------------------------------------------
// write
//-----------------------------------------------------------------
void wbl_driver::write(sc_uint <8> addr, sc_uint <8> data)
{
    addr_o.write(addr);
    data_o.write(data);
    we_o.write(true);
    stb_o.write(true);

    do
    {
        wait();

        addr_o.write(0);
        data_o.write(0);
        we_o.write(false);
        stb_o.write(false);
    }
    while (!ack_i.read());
}
//-----------------------------------------------------------------
// read
//-----------------------------------------------------------------
sc_uint <8> wbl_driver::read(sc_uint <8> addr)
{
    addr_o.write(addr);
    data_o.write(0);
    we_o.write(false);
    stb_o.write(true);

    do
    {
        wait();

        addr_o.write(0);
        data_o.write(0);
        we_o.write(false);
        stb_o.write(false);
    }
    while (!ack_i.read());

    return data_i.read();
}
