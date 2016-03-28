#ifndef SPDIF_TB_H
#define SPDIF_TB_H

#include "sc_vpi_clock.h"
#include "spdif_vpi.h"

#include "spdif_decoder.h"
#include "spdif_driver.h"

#define AUDIO_CLK_DIV           4

class spdif_tb: public sc_module
{
public:
    SC_HAS_PROCESS(spdif_tb);

    sc_signal <bool> rst_i;
    sc_signal <bool> audio_clk_i;
    sc_signal <bool> spdif_o;
    sc_signal <sc_uint<32> > sample_i;
    sc_signal <bool> sample_req_o;

    spdif_tb(sc_module_name name):  sc_module(name), 
                                    m_dut("tb_top"),
                                    m_vpi_clk("tb_top.clk_i"),
                                    m_decoder("m_decoder"),
                                    m_driver("m_driver"),
                                    m_tx_fifo("m_tx_fifo")
    {
        m_dut.clk_i(m_vpi_clk.m_clk);
        m_dut.rst_i(rst_i);
        m_dut.audio_clk_i(audio_clk_i);
        m_dut.spdif_o(spdif_o);
        m_dut.sample_i(sample_i);
        m_dut.sample_req_o(sample_req_o);

        m_decoder.clk_i(m_vpi_clk.m_clk);
        m_decoder.rst_i(rst_i);
        m_decoder.rx_i(spdif_o);
        m_decoder.set_clock_div(AUDIO_CLK_DIV);

        m_driver.clk_i(m_vpi_clk.m_clk);
        m_driver.rst_i(rst_i);
        m_driver.sample_req_i(sample_req_o);
        m_driver.sample_data_o(sample_i);

        SC_CTHREAD(drive, m_vpi_clk.m_clk);
        SC_CTHREAD(monitor, m_vpi_clk.m_clk);

        SC_CTHREAD(audio_clk, m_vpi_clk.m_clk);
    }

    spdif_vpi       m_dut;
    sc_vpi_clock    m_vpi_clk;
    spdif_decoder   m_decoder;
    spdif_driver    m_driver;

    sc_fifo < sc_uint<32> > m_tx_fifo;

    void drive(void);
    void monitor(void);
    void audio_clk(void);
};

#endif
