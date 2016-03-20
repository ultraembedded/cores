#include "ulpi_driver.h"

#define CMD_IDLE        0x0
#define CMD_XMIT        0x1
#define CMD_REG_WR      0x2
#define CMD_REG_RD      0x3

#define ULPI_CMD_H      7
#define ULPI_CMD_L      6

#define ULPI_ADDR_H     5
#define ULPI_ADDR_L     0

#define ULPI_PID_H      3
#define ULPI_PID_L      0

//-----------------------------------------------------------------
// reg_write
//-----------------------------------------------------------------
void ulpi_driver::reg_write(sc_uint <8> addr, sc_uint <8> data)
{
    m_reg[addr & (ULPI_REG_NUM-1)] = data;
}
//-----------------------------------------------------------------
// reg_read
//-----------------------------------------------------------------
sc_uint <8> ulpi_driver::reg_read(sc_uint <8> addr)
{
    return m_reg[addr & (ULPI_REG_NUM-1)];
}
//-----------------------------------------------------------------
// drive_rxcmd: Drive ULPI RX_CMD
//-----------------------------------------------------------------
void ulpi_driver::drive_rxcmd(sc_uint <2> linestate, bool rx_active, bool rx_error)
{
    sc_uint<8> data = 0;

    data.range(ULPI_RXCMD_LS_H, ULPI_RXCMD_LS_L) = linestate;

    if (rx_error)
        data.range(ULPI_RXCMD_RXEVENT_H, ULPI_RXCMD_RXEVENT_L) = ULPI_RXEVENT_ERROR;
    else if (rx_active)
        data.range(ULPI_RXCMD_RXEVENT_H, ULPI_RXCMD_RXEVENT_L) = ULPI_RXEVENT_ACTIVE;
    else
        data.range(ULPI_RXCMD_RXEVENT_H, ULPI_RXCMD_RXEVENT_L) = ULPI_RXEVENT_INACTIVE;

    // RX_CMD
    ulpi_dir_o.write(true);
    ulpi_nxt_o.write(false);
    ulpi_data_o.write(data);

    wait();
}
//-----------------------------------------------------------------
// drive_rxdata: Drive ULPI RX_DATA
//-----------------------------------------------------------------
void ulpi_driver::drive_rxdata(sc_uint <8> data)
{
    // RX_DATA
    ulpi_dir_o.write(true);
    ulpi_nxt_o.write(true);
    ulpi_data_o.write(data);

    wait();
}
//-----------------------------------------------------------------
// drive_output: Drive turnaround cycle (-> output)
//-----------------------------------------------------------------
void ulpi_driver::drive_output(bool rx_data)
{
    // Turnaround
    ulpi_dir_o.write(true);
    ulpi_nxt_o.write(rx_data);
    ulpi_data_o.write(0x00);
    wait();
    ulpi_nxt_o.write(false);
}
//-----------------------------------------------------------------
// drive_input: Drive turnaround cycle (-> input)
//-----------------------------------------------------------------
void ulpi_driver::drive_input(void)
{
    // Turnaround
    ulpi_dir_o.write(false);
    ulpi_nxt_o.write(false);
    ulpi_data_o.write(0x00);

    wait();
}
//-----------------------------------------------------------------
// drive
//-----------------------------------------------------------------
void ulpi_driver::drive(void) 
{
    drive_input();

    // Wait until reset complete
    while (rst_i.read())
        wait();

    while (true)
    {
        // PHY -> LINK
        if (m_tx_fifo.num_available())
        {
            sc_uint <9> fifo_data;
            sc_uint <8> data;
            bool        last;

            // Turnaround
            drive_output(true);

            do
            {
                // RX_CMD
                if (!(rand() % 4))
                {
                    last = false;

                    // RX_CMD (RX_ACTIVE = 1)
                    drive_rxcmd(0x2, true, false);
                }
                // RX_DATA
                else
                {
                    last = tx_read(data);
                    drive_rxdata(data);
                }
            }
            while (!last);

            // RX_CMD (RX_ACTIVE = 0)
            drive_rxcmd(0x2, false, false);

            // Turnaround
            drive_input();
        }
        // LINK -> PHY
        else
        {
            sc_uint <8> data = ulpi_data_i.read();
            sc_uint <2> cmd  = data.range(ULPI_CMD_H,ULPI_CMD_L);
            sc_uint <6> addr = data.range(ULPI_ADDR_H,ULPI_ADDR_L);
            sc_uint <8> pid  = 0;

            pid.range(3,0)   = data.range(ULPI_PID_H,ULPI_PID_L);
            pid.range(7,4)   = ~data.range(ULPI_PID_H,ULPI_PID_L);

            // Register read
            if (cmd == CMD_REG_RD)
            {
                // Accept command
                ulpi_nxt_o.write(true);
                wait();

                // Turnaround
                drive_output(false);

                // Data
                data = reg_read(addr);
                ulpi_data_o.write(data);
                wait();

                // Turnaround
                drive_input();
            }  
            // Not idle?
            else if (cmd != CMD_IDLE)
            {
                // Accept command
                ulpi_nxt_o.write(true);
                wait();
                ulpi_nxt_o.write(false);              

                // Record PID for future use
                bool        last_valid = (cmd == CMD_XMIT);
                sc_uint <8> last_data  = pid;

                while (!ulpi_stp_i.read())
                {
                    // Random data accept delay
                    if (!(rand() % 4))
                    {
                        int wait_len = rand() % 8;

                        ulpi_nxt_o.write(false);
                        while (!ulpi_stp_i.read() && wait_len--)
                            wait(1);

                        if (ulpi_stp_i.read())
                            break;
                    }

                    ulpi_nxt_o.write(true);
                    wait();
                    ulpi_nxt_o.write(false);

                    if (ulpi_stp_i.read())
                        break;

                    sc_uint <8> data = ulpi_data_i.read();

                    // Transmit
                    if (cmd == CMD_XMIT)
                    {
                        if (last_valid)
                            rx_write(last_data, false);

                        last_valid = true;
                        last_data  = data;
                    }
                    // Register write
                    else if (cmd == CMD_REG_WR)
                    {
                        reg_write(addr, data);
                        addr += 1;
                    }
                }

                // Flush pending received byte
                if (last_valid)
                    rx_write(last_data, true);   
            }

            wait();
        }
    }
}
//-----------------------------------------------------------------
// write
//-----------------------------------------------------------------
void ulpi_driver::write(sc_uint <8> data, bool last)
{
    sc_uint <9> fifo_data;

    fifo_data.range(7,0) = data;
    fifo_data.range(8,8) = last;

    m_tx_fifo.write(fifo_data);
}
//-----------------------------------------------------------------
// read
//-----------------------------------------------------------------
bool ulpi_driver::read(sc_uint <8> &data)
{
    sc_uint <9> fifo_data = m_rx_fifo.read();
    data = fifo_data.range(7,0);
    return (bool)fifo_data.range(8,8);
}
//-----------------------------------------------------------------
// rx_write
//-----------------------------------------------------------------
void ulpi_driver::rx_write(sc_uint <8> data, bool last)
{
    sc_uint <9> fifo_data;

    fifo_data.range(7,0) = data;
    fifo_data.range(8,8) = last;

    m_rx_fifo.write(fifo_data);
}
//-----------------------------------------------------------------
// tx_read
//-----------------------------------------------------------------
bool ulpi_driver::tx_read(sc_uint <8> &data)
{
    sc_uint <9> fifo_data = m_tx_fifo.read();
    data = fifo_data.range(7,0);
    return (bool)fifo_data.range(8,8);
}
