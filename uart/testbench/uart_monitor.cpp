#include "uart_monitor.h"

//-----------------------------------------------------------------
// output: Drive tx data
//-----------------------------------------------------------------
void uart_monitor::output(void)
{
    tx_o.write(true);

    do
    {
        wait();
    }
    while (rst_i.read());

    while (true)
    {
        sc_uint <8> tx_data = m_tx_fifo.read();
        int clks = 0;

        // Start bit
        tx_o.write(false);
        clks = m_divisor ? (m_divisor-1) : 0;
        do
        {
            wait();
        }
        while (clks--);

        // Data bits
        for (int i=0;i<8;i++)
        {
            tx_o.write((tx_data[i]) ? true : false);
            clks = m_divisor ? (m_divisor-1) : 0;
            do
            {
                wait();
            }
            while (clks--);
        }

        // Stop bits
        for (int i=0;i<m_stop_bits;i++)
        {
            tx_o.write(true);
            clks = m_divisor ? (m_divisor-1) : 0;
            do
            {
                wait();
            }
            while (clks--);
        }

        wait();
    }
}
//-----------------------------------------------------------------
// input: Handle rx data
//-----------------------------------------------------------------
void uart_monitor::input(void) 
{
    do
    {
        wait();
    }
    while (rst_i.read());

    while (true)
    {
        sc_uint <8> rx_data = 0;
        int clks = 0;

        // Detect start bit
        if (!rx_i.read())
        {
            // Wait 1.5 bit times
            if (m_divisor)
                clks = (m_divisor-1) + ((m_divisor-1)/2);
            else
                clks = 0;

            do
            {
                wait();
            }
            while (clks--);

            // Data bits
            for (int i=0;i<8;i++)
            {
                rx_data[i] = rx_i.read();
                clks = m_divisor ? (m_divisor-1) : 0;
                do
                {
                    wait();
                }
                while (clks--);
            }

            sc_assert(m_rx_fifo.num_free() >= 1);
            m_rx_fifo.write(rx_data);

            // Wait for IDLE
            sc_assert(rx_i.read());
            while (!rx_i.read())
                wait();

            if (m_print_enable)
                printf("%c", (char)rx_data);
        }
        else
            wait();
    }
}
