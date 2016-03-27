#include "ulpi_wrapper_tb.h"

//-----------------------------------------------------------------
// sc_main_tb
//-----------------------------------------------------------------
static int attach_system_c(p_cb_data user_data)
{
    ulpi_wrapper_tb * u_tb  = new ulpi_wrapper_tb("ulpi_wrapper_tb");

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
// testbench
//-----------------------------------------------------------------
void ulpi_wrapper_tb::testbench(void) 
{
    sc_uint <8> last_wr = 0xFF;

    ulpi_rst_i.write(true);
    wait(5);
    ulpi_rst_i.write(false);
    wait(1);

    m_reg.write(ULPI_REG_SCRATCH, last_wr);

    int cycles = 0;
    while (true)
    {
        // Random delay
        int wait_len = rand() % 10;
        if (wait_len)
            wait(wait_len);

        // Random register write
        if (rand() & 1)
        {
            last_wr = rand();
            m_reg.write(ULPI_REG_SCRATCH, last_wr);
        }
        // Random register read
        else
        {
            sc_assert(m_reg.read(ULPI_REG_SCRATCH) == last_wr);
        }

        if (!(rand() % 32))
        {
            if (rand() & 1)
                utmi_opmode_i.write(rand());
            else
                utmi_dppulldown_i.write(rand() & 1);
        }

        if (cycles++ == 1000)
            m_dut.stopSimulation();
    }
}
//-----------------------------------------------------------------
// phy_rx: PHY Rx Thread
//-----------------------------------------------------------------
void ulpi_wrapper_tb::phy_rx(void) 
{
    sc_uint <8> data;
    sc_uint <1> last;

    sc_uint <8> ulpi_data;
    sc_uint <1> ulpi_last;

    while (ulpi_rst_i.read())
        wait();

    while (1)
    {
        // Wait for data from ULPI interface
        ulpi_last = m_ulpi.read(ulpi_data);

        // Read actual data FIFO
        (last, data) = m_link_phy_queue.read();

        cout << hex << "EXPECT: DATA " << data << " LAST " << last << endl;
        cout << hex << "GOT:    DATA " << ulpi_data << " LAST " << ulpi_last << endl;

        sc_assert(ulpi_data == data);
        sc_assert(ulpi_last == last);
    }
}
//-----------------------------------------------------------------
// link_rx: Link Rx Thread
//-----------------------------------------------------------------
void ulpi_wrapper_tb::link_rx(void) 
{
    sc_uint <8> data;
    sc_uint <1> last;

    sc_uint <8> ulpi_data;
    sc_uint <1> ulpi_last;

    while (ulpi_rst_i.read())
        wait();

    while (1)
    {
        // Wait for data from UTMI interface
        ulpi_last = m_utmi.read(ulpi_data);

        // Read actual data FIFO
        (last, data) = m_phy_link_queue.read();

        cout << hex << "EXPECT: DATA " << data << " LAST " << last << endl;
        cout << hex << "GOT:    DATA " << ulpi_data << " LAST " << ulpi_last << endl;

        sc_assert(ulpi_data == data);
        sc_assert(ulpi_last == last);
    }
}
//-----------------------------------------------------------------
// phy_tx: PHY Tx Thread
//-----------------------------------------------------------------
void ulpi_wrapper_tb::phy_tx(void) 
{
    while (ulpi_rst_i.read())
        wait();

    while (1)
    {
        wait(10 + (rand() % 16));

        m_mutex.lock();

        int len = 1 + (rand() % 8);
        while (len--)
        {
            sc_uint <8> data = rand();
            sc_uint <1> last = (len == 0);

            cout << hex << "QUEUE (RX): DATA " << data << " LAST " << last << endl;
            m_phy_link_queue.write((last, data));
            m_ulpi.write(data, last);
        }

        do
        {
            wait(1);
        }
        while (m_phy_link_queue.num_available());

        m_mutex.unlock();
    }
}
//-----------------------------------------------------------------
// link_tx: Link Tx Thread
//-----------------------------------------------------------------
void ulpi_wrapper_tb::link_tx(void) 
{
    while (ulpi_rst_i.read())
        wait();

    while (1)
    {
        wait(10 + (rand() % 16));

        m_mutex.lock();

        int len = 1 + (rand() % 8);
        bool first = true;
        while (len--)
        {
            sc_uint <8> data = rand();
            sc_uint <1> last = (len == 0);

            // First byte is PID
            if (first)
                data.range(7,4) = ~data.range(3,0);

            first = false;

            cout << hex << "QUEUE (TX): DATA " << data << " LAST " << last << endl;
            m_link_phy_queue.write((last, data));
            m_utmi.write(data, last);
        }

        // Wait until transfer completed
        do
        {
            wait();
        }
        while (m_link_phy_queue.num_available());

        m_mutex.unlock();
    }
}
