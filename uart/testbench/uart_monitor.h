#ifndef UART_MONITOR_H
#define UART_MONITOR_H

#include <systemc.h>

//-------------------------------------------------------------
// uart_monitor: UART driver / monitor component
//-------------------------------------------------------------
SC_MODULE (uart_monitor)
{
public:
    // Clock and Reset
    sc_in  <bool>   clk_i;
    sc_in  <bool>   rst_i;

    // I/O
    sc_in  <bool>   rx_i;
    sc_out <bool>   tx_o;

    // Constructor
    SC_HAS_PROCESS(uart_monitor);
    uart_monitor(sc_module_name name): sc_module(name),
                                      m_tx_fifo(2048), 
                                      m_rx_fifo(2048)
    {
        m_divisor      = 0;
        m_stop_bits    = 1;
        m_print_enable = false;

        SC_CTHREAD(output, clk_i.pos());
        SC_CTHREAD(input, clk_i.pos());
    }

public:
    void         write(sc_uint <8> data) { m_tx_fifo.write(data); }
    sc_uint <8>  read(void)              { return m_rx_fifo.read(); }
    bool         write_empty(void)       { return m_tx_fifo.num_available() == 0; }
    bool         read_ready(void)        { return m_rx_fifo.num_available() > 0; }

    void set_clock_div(int divisor)      { m_divisor = divisor; }
    void set_stop_bits(int bits)         { m_stop_bits = bits; }
    void print_enable(bool enable)       { m_print_enable = enable; }

private:
    void output(void);
    void input(void);

    sc_fifo < sc_uint<8> > m_tx_fifo;
    sc_fifo < sc_uint<8> > m_rx_fifo;
    int                    m_divisor;
    int                    m_stop_bits;
    bool                   m_print_enable;
};

#endif