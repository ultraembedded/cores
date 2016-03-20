#ifndef ULPI_WRAPPER_IO_H
#define ULPI_WRAPPER_IO_H

#include <systemc.h>
#include "ulpi_wrapper.h"

SC_MODULE (ulpi_wrapper_io)
{
public:
  sc_in <bool> ulpi_clk60_i;
  sc_in <bool> ulpi_rst_i;
  sc_signal <sc_uint<8> > ulpi_data_i;
  sc_signal <sc_uint<8> > ulpi_data_o;
  sc_signal <bool> ulpi_dir_i;
  sc_signal <bool> ulpi_nxt_i;
  sc_signal <bool> ulpi_stp_o;
  sc_signal <sc_uint<8> > reg_addr_i;
  sc_signal <bool> reg_stb_i;
  sc_signal <bool> reg_we_i;
  sc_signal <sc_uint<8> > reg_data_i;
  sc_signal <sc_uint<8> > reg_data_o;
  sc_signal <bool> reg_ack_o;
  sc_signal <bool> utmi_txvalid_i;
  sc_signal <bool> utmi_txready_o;
  sc_signal <bool> utmi_rxvalid_o;
  sc_signal <bool> utmi_rxactive_o;
  sc_signal <bool> utmi_rxerror_o;
  sc_signal <sc_uint<8> > utmi_data_o;
  sc_signal <sc_uint<8> > utmi_data_i;
  sc_signal <sc_uint<2> > utmi_xcvrselect_i;
  sc_signal <bool> utmi_termselect_i;
  sc_signal <sc_uint<2> > utmi_opmode_i;
  sc_signal <bool> utmi_dppulldown_i;
  sc_signal <bool> utmi_dmpulldown_i;
  sc_signal <sc_uint<2> > utmi_linestate_o;

  // Constructor
  ulpi_wrapper_io(sc_module_name name, ulpi_wrapper *dut): 
       sc_module(name)
     , ulpi_clk60_i ("ulpi_clk60_i")
     , ulpi_rst_i ("ulpi_rst_i")
     , ulpi_data_i ("ulpi_data_i")
     , ulpi_data_o ("ulpi_data_o")
     , ulpi_dir_i ("ulpi_dir_i")
     , ulpi_nxt_i ("ulpi_nxt_i")
     , ulpi_stp_o ("ulpi_stp_o")
     , reg_addr_i ("reg_addr_i")
     , reg_stb_i ("reg_stb_i")
     , reg_we_i ("reg_we_i")
     , reg_data_i ("reg_data_i")
     , reg_data_o ("reg_data_o")
     , reg_ack_o ("reg_ack_o")
     , utmi_txvalid_i ("utmi_txvalid_i")
     , utmi_txready_o ("utmi_txready_o")
     , utmi_rxvalid_o ("utmi_rxvalid_o")
     , utmi_rxactive_o ("utmi_rxactive_o")
     , utmi_rxerror_o ("utmi_rxerror_o")
     , utmi_data_o ("utmi_data_o")
     , utmi_data_i ("utmi_data_i")
     , utmi_xcvrselect_i ("utmi_xcvrselect_i")
     , utmi_termselect_i ("utmi_termselect_i")
     , utmi_opmode_i ("utmi_opmode_i")
     , utmi_dppulldown_i ("utmi_dppulldown_i")
     , utmi_dmpulldown_i ("utmi_dmpulldown_i")
     , utmi_linestate_o ("utmi_linestate_o")
  { 
    m_dut = dut;

    this->ulpi_clk60_i(m_dut->m_clk);
    this->ulpi_rst_i(m_dut->m_rst);

    m_dut->ulpi_clk60_i(m_dut->m_clk);
    m_dut->ulpi_rst_i(m_dut->m_rst);
    m_dut->ulpi_data_i(ulpi_data_i);
    m_dut->ulpi_data_o(ulpi_data_o);
    m_dut->ulpi_dir_i(ulpi_dir_i);
    m_dut->ulpi_nxt_i(ulpi_nxt_i);
    m_dut->ulpi_stp_o(ulpi_stp_o);
    m_dut->reg_addr_i(reg_addr_i);
    m_dut->reg_stb_i(reg_stb_i);
    m_dut->reg_we_i(reg_we_i);
    m_dut->reg_data_i(reg_data_i);
    m_dut->reg_data_o(reg_data_o);
    m_dut->reg_ack_o(reg_ack_o);
    m_dut->utmi_txvalid_i(utmi_txvalid_i);
    m_dut->utmi_txready_o(utmi_txready_o);
    m_dut->utmi_rxvalid_o(utmi_rxvalid_o);
    m_dut->utmi_rxactive_o(utmi_rxactive_o);
    m_dut->utmi_rxerror_o(utmi_rxerror_o);
    m_dut->utmi_data_o(utmi_data_o);
    m_dut->utmi_data_i(utmi_data_i);
    m_dut->utmi_xcvrselect_i(utmi_xcvrselect_i);
    m_dut->utmi_termselect_i(utmi_termselect_i);
    m_dut->utmi_opmode_i(utmi_opmode_i);
    m_dut->utmi_dppulldown_i(utmi_dppulldown_i);
    m_dut->utmi_dmpulldown_i(utmi_dmpulldown_i);
    m_dut->utmi_linestate_o(utmi_linestate_o);
  }

  ulpi_wrapper *m_dut;
};

#endif