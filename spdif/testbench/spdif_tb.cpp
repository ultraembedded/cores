#include "spdif_tb.h"

//-----------------------------------------------------------------
// sc_main_tb
//-----------------------------------------------------------------
static int attach_system_c(p_cb_data user_data)
{
    spdif_tb * u_tb  = new spdif_tb("spdif_tb");

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
// audio_clk: Produce audio clock
//-----------------------------------------------------------------
void spdif_tb::audio_clk(void)
{
    // Reset
    rst_i.write(true);
    wait(5);
    rst_i.write(false);
    wait(1);

    while (1)
    {
        wait(AUDIO_CLK_DIV/2);
        audio_clk_i.write(!audio_clk_i.read());
    }
}
//-----------------------------------------------------------------
// drive: Drive input sequence
//-----------------------------------------------------------------
void spdif_tb::drive(void) 
{
    sc_uint <32> data;
    int interations = 2000;

    // Drive input data
    while (interations--)
    {
        data.range(15,0)  = rand();
        data.range(31,16) = rand();
        m_tx_fifo.write(data.range(15,0));
        m_tx_fifo.write(data.range(31,16));

        m_driver.write(data);
    }
}
//-----------------------------------------------------------------
// monitor: Check output data
//-----------------------------------------------------------------
void spdif_tb::monitor(void) 
{
    do
    {
        wait();
    }
    while (rst_i.read());

    while (1)
    {
        sc_uint <16> data    = m_tx_fifo.read();
        sc_uint <16> rx_data = m_decoder.read();

        printf("EXPECT: %04x\n", (unsigned)data);
        printf("GOT: %04x\n", (unsigned)rx_data);

        sc_assert(rx_data == data);

        if (m_tx_fifo.num_available() == 0)
            m_dut.stopSimulation();
    }
}
