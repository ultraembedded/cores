#ifndef SPDIF_DRIVER_H
#define SPDIF_DRIVER_H

#include <systemc.h>

//-------------------------------------------------------------
// spdif_driver:
//-------------------------------------------------------------
SC_MODULE (spdif_driver)
{
public:
    // Clock and Reset
    sc_in  <bool>         clk_i;
    sc_in  <bool>         rst_i;

    // I/O
    sc_in  <bool>         sample_req_i;
    sc_out <sc_uint<32> > sample_data_o;

    // Constructor
    SC_HAS_PROCESS(spdif_driver);
    spdif_driver(sc_module_name name): sc_module(name),
                                       m_tx_fifo(2048)
    {
        SC_CTHREAD(output, clk_i.pos());
    }

public:
    void         write(sc_uint <32> data) { m_tx_fifo.write(data); }
    bool         write_empty(void)        { return m_tx_fifo.num_available() == 0; }

private:
    void output(void);

    sc_fifo < sc_uint<32> > m_tx_fifo;
};

#endif