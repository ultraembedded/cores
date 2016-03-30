#ifndef I2S_TB_H
#define I2S_TB_H

#include "sc_vpi_clock.h"
#include "i2s_vpi.h"

#include "i2s_decoder.h"
#include "i2s_driver.h"

#define AUDIO_CLK_DIV           2

class i2s_tb: public sc_module
{
public:
    SC_HAS_PROCESS(i2s_tb);

    sc_signal <bool> rst_i;
    sc_signal <bool> audio_clk_i;
    sc_signal <bool> audio_rst_i;
    sc_signal <bool> i2s_mclk_o;
    sc_signal <bool> i2s_bclk_o;
    sc_signal <bool> i2s_ws_o;
    sc_signal <bool> i2s_data_o;
    sc_signal <sc_uint<32> > sample_i;
    sc_signal <bool> sample_req_o;

    i2s_tb(sc_module_name name):  sc_module(name), 
                                    m_dut("tb_top"),
                                    m_vpi_clk("tb_top.clk_i"),
                                    m_decoder("m_decoder"),
                                    m_driver("m_driver"),
                                    m_tx_fifo("m_tx_fifo")
    {
        m_dut.clk_i(m_vpi_clk.m_clk);
        m_dut.rst_i(rst_i);
        m_dut.audio_clk_i(audio_clk_i);
        m_dut.audio_rst_i(audio_rst_i);
        m_dut.i2s_mclk_o(i2s_mclk_o);
        m_dut.i2s_bclk_o(i2s_bclk_o);
        m_dut.i2s_ws_o(i2s_ws_o);
        m_dut.i2s_data_o(i2s_data_o);
        m_dut.sample_i(sample_i);
        m_dut.sample_req_o(sample_req_o);

        m_decoder.clk_i(m_vpi_clk.m_clk);
        m_decoder.rst_i(rst_i);
        m_decoder.i2s_mclk_i(i2s_mclk_o);
        m_decoder.i2s_bclk_i(i2s_bclk_o);
        m_decoder.i2s_ws_i(i2s_ws_o);
        m_decoder.i2s_data_i(i2s_data_o);

        m_driver.clk_i(m_vpi_clk.m_clk);
        m_driver.rst_i(rst_i);
        m_driver.sample_req_i(sample_req_o);
        m_driver.sample_data_o(sample_i);

        SC_CTHREAD(drive, m_vpi_clk.m_clk);
        SC_CTHREAD(monitor, m_vpi_clk.m_clk);

        SC_CTHREAD(audio_clk, m_vpi_clk.m_clk);
    }

    i2s_vpi       m_dut;
    sc_vpi_clock  m_vpi_clk;
    i2s_decoder   m_decoder;
    i2s_driver    m_driver;

    sc_fifo < sc_uint<32> > m_tx_fifo;

    void drive(void);
    void monitor(void);
    void audio_clk(void);
};

#endif
