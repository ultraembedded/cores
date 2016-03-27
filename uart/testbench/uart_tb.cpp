#include "uart_tb.h"
#include "uart_regs.h"

//-----------------------------------------------------------------
// sc_main_tb
//-----------------------------------------------------------------
static int attach_system_c(p_cb_data user_data)
{
    uart_tb * u_tb  = new uart_tb("uart_tb");

    // Initialize SystemC
    sc_start(0, SC_NS);

    // Start clock
    u_tb->m_vpi_clk.start();
}
//-----------------------------------------------------------------
// _register
//-----------------------------------------------------------------
static void _register(void)
{
    s_cb_data          cb_data_s;
    cb_data_s.user_data = NULL;
    cb_data_s.reason    = cbStartOfSimulation;
    cb_data_s.cb_rtn    = attach_system_c;
    cb_data_s.time      = NULL;
    cb_data_s.value     = NULL;
    vpi_register_cb(&cb_data_s);
}

void (*vlog_startup_routines[])() = 
{
    _register,
    0
};

//-----------------------------------------------------------------
// drive: Drive input sequence
//-----------------------------------------------------------------
void uart_tb::drive(void) 
{
    sc_uint <32> data; 

    // Reset
    rst_i.write(true);
    wait(1);
    rst_i.write(false);
    wait(1);

    // Set baud / mode
    data[UART_CFG_STOP_BITS_SHIFT] = 0; // 1-stop bit
    data |= (m_clk_div-1);
    m_reg.write(UART_CFG, data);    

    int cycles = 0;
    while (true)
    {
        // Random delay
        int wait_len = rand() % 10;
        if (wait_len)
            wait(wait_len);

        // Rx - MON -> DUT
        if (rand() & 1)
        {
            // Poll for rx ready
            if (m_reg.read(UART_USR) & (1 << UART_USR_RX_READY_SHIFT))
            {
                sc_assert(m_rx_queue.num_available() >= 1);
                sc_assert(m_rx_queue.read() == m_reg.read(UART_UDR));
            }
        }
        // Tx - DUT -> MON
        else
        {
            data = rand() & 0xFF;
            m_reg.write(UART_UDR, data);
            m_tx_queue.write(data);

            // Poll for tx complete
            while (m_reg.read(UART_USR) & (1 << UART_USR_TX_BUSY_SHIFT))
                ;
        }

        if (cycles++ == 1000)
            m_dut.stopSimulation();
    }
}
//-----------------------------------------------------------------
// monitor: Check output data
//-----------------------------------------------------------------
void uart_tb::monitor(void) 
{
    do
    {
        wait();
    }
    while (rst_i.read());

    while (1)
    {
        if (m_mon.read_ready())
        {
            sc_uint <8> data;
            sc_uint <8> rx_data;
            sc_assert(m_tx_queue.num_available() > 0);

            data = m_tx_queue.read();
            rx_data = m_mon.read();
            printf("EXPECT: %02x GOT: %02x\n", (unsigned)data, (unsigned)rx_data);
            sc_assert(data == rx_data);

            // Loopback
            m_rx_queue.write(data);
            m_mon.write(data);
        }
        else
            wait();
    }
}