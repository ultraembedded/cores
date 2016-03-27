#ifndef ULPI_WRAPPER_TB_H
#define ULPI_WRAPPER_TB_H

#include "sc_vpi_clock.h"
#include "ulpi_wrapper_vpi.h"

#include "ulpi_driver.h"
#include "utmi_driver.h"
#include "wbl_driver.h"

class ulpi_wrapper_tb: public sc_module
{
public:
    SC_HAS_PROCESS(ulpi_wrapper_tb);

    sc_signal< bool > ulpi_rst_i;
    sc_signal< sc_uint<8> > ulpi_data_i;
    sc_signal< sc_uint<8> > ulpi_data_o;
    sc_signal< bool > ulpi_dir_i;
    sc_signal< bool > ulpi_nxt_i;
    sc_signal< bool > ulpi_stp_o;
    sc_signal< sc_uint<8> > reg_addr_i;
    sc_signal< bool > reg_stb_i;
    sc_signal< bool > reg_we_i;
    sc_signal< sc_uint<8> > reg_data_i;
    sc_signal< sc_uint<8> > reg_data_o;
    sc_signal< bool > reg_ack_o;
    sc_signal< bool > utmi_txvalid_i;
    sc_signal< bool > utmi_txready_o;
    sc_signal< bool > utmi_rxvalid_o;
    sc_signal< bool > utmi_rxactive_o;
    sc_signal< bool > utmi_rxerror_o;
    sc_signal< sc_uint<8> > utmi_data_o;
    sc_signal< sc_uint<8> > utmi_data_i;
    sc_signal< sc_uint<2> > utmi_xcvrselect_i;
    sc_signal< bool > utmi_termselect_i;
    sc_signal< sc_uint<2> > utmi_opmode_i;
    sc_signal< bool > utmi_dppulldown_i;
    sc_signal< bool > utmi_dmpulldown_i;
    sc_signal< sc_uint<2> > utmi_linestate_o;

    ulpi_wrapper_tb(sc_module_name name): sc_module(name), 
                m_dut("tb_top"),
                m_vpi_clk("tb_top.ulpi_clk60_i"),
                m_ulpi("m_ulpi"), m_utmi("m_utmi"), m_reg("m_reg"),
                m_phy_link_queue(2048), m_link_phy_queue(2048)
    {
        m_dut.ulpi_clk60_i(m_vpi_clk.m_clk);
        m_dut.ulpi_rst_i(ulpi_rst_i);
        m_dut.ulpi_data_i(ulpi_data_i);
        m_dut.ulpi_data_o(ulpi_data_o);
        m_dut.ulpi_dir_i(ulpi_dir_i);
        m_dut.ulpi_nxt_i(ulpi_nxt_i);
        m_dut.ulpi_stp_o(ulpi_stp_o);
        m_dut.reg_addr_i(reg_addr_i);
        m_dut.reg_stb_i(reg_stb_i);
        m_dut.reg_we_i(reg_we_i);
        m_dut.reg_data_i(reg_data_i);
        m_dut.reg_data_o(reg_data_o);
        m_dut.reg_ack_o(reg_ack_o);
        m_dut.utmi_txvalid_i(utmi_txvalid_i);
        m_dut.utmi_txready_o(utmi_txready_o);
        m_dut.utmi_rxvalid_o(utmi_rxvalid_o);
        m_dut.utmi_rxactive_o(utmi_rxactive_o);
        m_dut.utmi_rxerror_o(utmi_rxerror_o);
        m_dut.utmi_data_o(utmi_data_o);
        m_dut.utmi_data_i(utmi_data_i);
        m_dut.utmi_xcvrselect_i(utmi_xcvrselect_i);
        m_dut.utmi_termselect_i(utmi_termselect_i);
        m_dut.utmi_opmode_i(utmi_opmode_i);
        m_dut.utmi_dppulldown_i(utmi_dppulldown_i);
        m_dut.utmi_dmpulldown_i(utmi_dmpulldown_i);
        m_dut.utmi_linestate_o(utmi_linestate_o);

        m_ulpi.clk_i(m_vpi_clk.m_clk);
        m_ulpi.rst_i(ulpi_rst_i);

        m_ulpi.ulpi_data_o(ulpi_data_i);
        m_ulpi.ulpi_data_i(ulpi_data_o);
        m_ulpi.ulpi_dir_o(ulpi_dir_i);
        m_ulpi.ulpi_nxt_o(ulpi_nxt_i);
        m_ulpi.ulpi_stp_i(ulpi_stp_o);

        m_utmi.clk_i(m_vpi_clk.m_clk);
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

        SC_CTHREAD(testbench, m_vpi_clk.m_clk);
        SC_CTHREAD(phy_tx, m_vpi_clk.m_clk);
        SC_CTHREAD(phy_rx, m_vpi_clk.m_clk);
        SC_CTHREAD(link_rx, m_vpi_clk.m_clk);
        SC_CTHREAD(link_tx, m_vpi_clk.m_clk);
    }

    ulpi_wrapper_vpi m_dut;

    sc_vpi_clock m_vpi_clk;

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
