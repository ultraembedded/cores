#ifndef ULPI_WRAPPER_TB_H
#define ULPI_WRAPPER_TB_H

#include "ulpi_wrapper_io.h"
#include "ulpi_driver.h"
#include "utmi_driver.h"
#include "wbl_driver.h"

class ulpi_wrapper_tb: public ulpi_wrapper_io
{
public:
    SC_HAS_PROCESS(ulpi_wrapper_tb);
    ulpi_wrapper_tb(sc_module_name name, ulpi_wrapper *dut): ulpi_wrapper_io(name, dut), 
                m_ulpi("m_ulpi"), m_utmi("m_utmi"), m_reg("m_reg"),
                m_phy_link_queue(2048), m_link_phy_queue(2048)
    {
        m_ulpi.clk_i(ulpi_clk60_i);
        m_ulpi.rst_i(ulpi_rst_i);

        m_ulpi.ulpi_data_o(ulpi_data_i);
        m_ulpi.ulpi_data_i(ulpi_data_o);
        m_ulpi.ulpi_dir_o(ulpi_dir_i);
        m_ulpi.ulpi_nxt_o(ulpi_nxt_i);
        m_ulpi.ulpi_stp_i(ulpi_stp_o);

        m_utmi.clk_i(ulpi_clk60_i);
        m_utmi.rst_i(ulpi_rst_i);

        m_utmi.utmi_txvalid_o(utmi_txvalid_i);
        m_utmi.utmi_data_o(utmi_data_i);
        m_utmi.utmi_txready_i(utmi_txready_o);

        m_utmi.utmi_data_i(utmi_data_o);
        m_utmi.utmi_rxvalid_i(utmi_rxvalid_o);
        m_utmi.utmi_rxactive_i(utmi_rxactive_o);

        m_reg.addr_o(reg_addr_i);
        m_reg.data_o(reg_data_i);
        m_reg.data_i(reg_data_o);
        m_reg.we_o(reg_we_i);
        m_reg.stb_o(reg_stb_i);
        m_reg.ack_i(reg_ack_o);

        SC_CTHREAD(testbench, ulpi_clk60_i);
        SC_CTHREAD(phy_tx, ulpi_clk60_i);
        SC_CTHREAD(phy_rx, ulpi_clk60_i);
        SC_CTHREAD(link_rx, ulpi_clk60_i);
        SC_CTHREAD(link_tx, ulpi_clk60_i);
    }

    ulpi_driver m_ulpi;
    utmi_driver m_utmi;
    wbl_driver  m_reg;

    sc_fifo < sc_uint <9> > m_phy_link_queue;
    sc_fifo < sc_uint <9> > m_link_phy_queue;
    sc_mutex                m_mutex;

    void testbench(void);
    void phy_tx(void);
    void phy_rx(void);
    void link_rx(void);
    void link_tx(void);
};

#endif
