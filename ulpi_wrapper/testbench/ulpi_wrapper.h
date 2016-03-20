#ifndef ULPI_WRAPPER_H
#define ULPI_WRAPPER_H

#include <systemc.h>

//-----------------------------------------------------------------
// DUT
//-----------------------------------------------------------------
SC_MODULE (ulpi_wrapper)
{
public:

    // Singleton
    static ulpi_wrapper& getInstance(void)
    {
        static ulpi_wrapper instance("ulpi_wrapper");
        return instance;
    }

    // Ports
    sc_in <bool> ulpi_clk60_i;
    sc_in <bool> ulpi_rst_i;
    sc_in <sc_uint<8> > ulpi_data_i;
    sc_out <sc_uint<8> > ulpi_data_o;
    sc_in <bool> ulpi_dir_i;
    sc_in <bool> ulpi_nxt_i;
    sc_out <bool> ulpi_stp_o;
    sc_in <sc_uint<8> > reg_addr_i;
    sc_in <bool> reg_stb_i;
    sc_in <bool> reg_we_i;
    sc_in <sc_uint<8> > reg_data_i;
    sc_out <sc_uint<8> > reg_data_o;
    sc_out <bool> reg_ack_o;
    sc_in <bool> utmi_txvalid_i;
    sc_out <bool> utmi_txready_o;
    sc_out <bool> utmi_rxvalid_o;
    sc_out <bool> utmi_rxactive_o;
    sc_out <bool> utmi_rxerror_o;
    sc_out <sc_uint<8> > utmi_data_o;
    sc_in <sc_uint<8> > utmi_data_i;
    sc_in <sc_uint<2> > utmi_xcvrselect_i;
    sc_in <bool> utmi_termselect_i;
    sc_in <sc_uint<2> > utmi_opmode_i;
    sc_in <bool> utmi_dppulldown_i;
    sc_in <bool> utmi_dmpulldown_i;
    sc_out <sc_uint<2> > utmi_linestate_o;

    // Simulation control    
    void stopSimulation()  { m_stop.write(true); }
    bool isStopped()       { return m_stop.read(); }

    // Callbacks
    int valueChangeCb(void);
    int attachCb(void);

    // Members
    sc_signal<bool>  m_stop;
    sc_signal<bool>  m_clk;
    sc_signal<bool>  m_rst;

private:
    SC_CTOR(ulpi_wrapper) { m_stop.write(false); }
};

#endif