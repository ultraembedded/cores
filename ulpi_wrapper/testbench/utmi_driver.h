#ifndef UTMI_DRIVER_H
#define UTMI_DRIVER_H

#include <systemc.h>

//-------------------------------------------------------------
// utmi_driver: UTMI driver (LINK) component
//-------------------------------------------------------------
SC_MODULE (utmi_driver)
{
public:
    //-------------------------------------------------------------
    // Interface I/O
    //-------------------------------------------------------------
    // Clock and Reset
    sc_in<bool>             clk_i;
    sc_in<bool>             rst_i;

    // I/O
    sc_out <bool>           utmi_txvalid_o;
    sc_out <sc_uint<8> >    utmi_data_o;
    sc_in  <bool>           utmi_txready_i;

    sc_in  <sc_uint<8> >    utmi_data_i;
    sc_in  <bool>           utmi_rxvalid_i;
    sc_in  <bool>           utmi_rxactive_i;

    //-------------------------------------------------------------
    // Constructor
    //-------------------------------------------------------------
    SC_HAS_PROCESS(utmi_driver);
    utmi_driver(sc_module_name name): sc_module(name),
                                      m_tx_fifo(2048),
                                      m_rx_fifo(2048)
    {
        SC_CTHREAD(tx_drive, clk_i.pos());
        SC_CTHREAD(rx_mon, clk_i.pos());
    }

    //-------------------------------------------------------------
    // Trace
    //-------------------------------------------------------------
    void add_trace(sc_trace_file *vcd, std::string prefix)
    {
        #undef  TRACE_SIGNAL
        #define TRACE_SIGNAL(s) sc_trace(vcd,s,prefix + #s)

        TRACE_SIGNAL(utmi_txvalid_o);
        TRACE_SIGNAL(utmi_data_o);
        TRACE_SIGNAL(utmi_txready_i);
        TRACE_SIGNAL(utmi_data_i);
        TRACE_SIGNAL(utmi_rxvalid_i);
        TRACE_SIGNAL(utmi_rxactive_i);

        #undef  TRACE_SIGNAL
    }

    //-------------------------------------------------------------
    // API
    //-------------------------------------------------------------
    void write(sc_uint <8> data, bool last);
    bool read(sc_uint <8> &data);

    //-------------------------------------------------------------
    // Internal
    //-------------------------------------------------------------
protected:
    void tx_drive(void);
    void rx_mon(void);
    void rx_write(sc_uint <8> data, bool last);
    bool tx_read(sc_uint <8> &data);    

    sc_fifo < sc_uint<9> > m_tx_fifo;
    sc_fifo < sc_uint<9> > m_rx_fifo;
};

#endif