#ifndef I2S_DRIVER_H
#define I2S_DRIVER_H

#include <systemc.h>

//-------------------------------------------------------------
// i2s_driver:
//-------------------------------------------------------------
SC_MODULE (i2s_driver)
{
public:
    // Clock and Reset
    sc_in  <bool>         clk_i;
    sc_in  <bool>         rst_i;

    // I/O
    sc_in  <bool>         sample_req_i;
    sc_out <sc_uint<32> > sample_data_o;

    // Constructor
    SC_HAS_PROCESS(i2s_driver);
    i2s_driver(sc_module_name name): sc_module(name),
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