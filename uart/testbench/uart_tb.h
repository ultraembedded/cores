#ifndef UART_TB_H
#define UART_TB_H

#include "sc_vpi_clock.h"
#include "uart_wb_vpi.h"

#include "uart_monitor.h"
#include "wb_lite_driver.h"

class uart_tb: public sc_module
{
public:
    SC_HAS_PROCESS(uart_tb);

    sc_signal <bool> rst_i;
    sc_signal <bool> intr_o;
    sc_signal <bool> tx_o;
    sc_signal <bool> rx_i;
    sc_signal <sc_uint<8> > addr_i;
    sc_signal <sc_uint<32> > data_o;
    sc_signal <sc_uint<32> > data_i;
    sc_signal <bool> we_i;
    sc_signal <bool> stb_i;
    sc_signal <bool> ack_o;

    uart_tb(sc_module_name name):   sc_module(name), 
                                    m_dut("tb_top"),
                                    m_vpi_clk("tb_top.clk_i"),
                                    m_reg("m_reg"),
                                    m_mon("m_mon"),
                                    m_tx_queue(2048),
                                    m_rx_queue(1)
    {
        m_dut.clk_i(m_vpi_clk.m_clk);
        m_dut.rst_i(rst_i);
        m_dut.intr_o(intr_o);
        m_dut.tx_o(tx_o);
        m_dut.rx_i(rx_i);
        m_dut.addr_i(addr_i);
        m_dut.data_o(data_o);
        m_dut.data_i(data_i);
        m_dut.we_i(we_i);
        m_dut.stb_i(stb_i);
        m_dut.ack_o(ack_o);

        m_reg.addr_o(addr_i);
        m_reg.data_o(data_i);
        m_reg.data_i(data_o);
        m_reg.we_o(we_i);
        m_reg.stb_o(stb_i);
        m_reg.ack_i(ack_o);

        m_mon.clk_i(m_vpi_clk.m_clk);
        m_mon.rst_i(rst_i);
        m_mon.tx_o(rx_i);
        m_mon.rx_i(tx_o);

        m_clk_div = 16;
        m_mon.set_clock_div(m_clk_div);
        m_mon.set_stop_bits(1);

        SC_CTHREAD(drive, m_vpi_clk.m_clk);
        SC_CTHREAD(monitor, m_vpi_clk.m_clk);
    }

    uart_wb_vpi     m_dut;
    sc_vpi_clock    m_vpi_clk;
    wb_lite_driver  m_reg;
    uart_monitor    m_mon;
    int             m_clk_div;

    sc_fifo < sc_uint <8> > m_tx_queue;
    sc_fifo < sc_uint <8> > m_rx_queue;

    void drive(void);
    void monitor(void);
};

#endif
