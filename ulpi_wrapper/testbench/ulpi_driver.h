#ifndef ULPI_DRIVER_H
#define ULPI_DRIVER_H

#include <systemc.h>

//-----------------------------------------------------------------
// Defines
//-----------------------------------------------------------------
#define ULPI_REG_VIDL            0x0
#define ULPI_REG_VIDH            0x1
#define ULPI_REG_PIDL            0x2
#define ULPI_REG_PIDH            0x3
#define ULPI_REG_FUNC            0x4
#define ULPI_REG_OTG             0xa
#define ULPI_REG_SCRATCH         0x16
#define ULPI_REG_NUM             0x20

#define ULPI_RXCMD_LS_L          0
#define ULPI_RXCMD_LS_H          1
#define ULPI_RXCMD_RXEVENT_L     4
#define ULPI_RXCMD_RXEVENT_H     5
#define ULPI_RXEVENT_INACTIVE    0
#define ULPI_RXEVENT_ACTIVE      1
#define ULPI_RXEVENT_HOSTDC      2
#define ULPI_RXEVENT_ERROR       3

//-----------------------------------------------------------------
// ulpi_driver: ULPI Master Driver (PHY TB component)
//-----------------------------------------------------------------
SC_MODULE (ulpi_driver)
{
public:
    //-------------------------------------------------------------
    // Interface I/O
    //-------------------------------------------------------------    
    // Clock and Reset
    sc_in<bool>             clk_i;
    sc_in<bool>             rst_i;

    // I/O
    sc_out <sc_uint<8> >    ulpi_data_o;
    sc_in  <sc_uint<8> >    ulpi_data_i;
    sc_out <bool>           ulpi_dir_o;
    sc_out <bool>           ulpi_nxt_o;
    sc_in  <bool>           ulpi_stp_i;

    //-------------------------------------------------------------
    // Constructor
    //-------------------------------------------------------------
    SC_HAS_PROCESS(ulpi_driver);
    ulpi_driver(sc_module_name name): sc_module(name),
                                      m_tx_fifo(1024), 
                                      m_rx_fifo(1024)
    {
        SC_CTHREAD(drive, clk_i.pos());

        m_reg[ULPI_REG_VIDL]    = 0x24;
        m_reg[ULPI_REG_VIDH]    = 0x04;
        m_reg[ULPI_REG_PIDL]    = 0x04;
        m_reg[ULPI_REG_PIDH]    = 0x00;
        m_reg[ULPI_REG_FUNC]    = 0x41;
        m_reg[ULPI_REG_OTG]     = 0x06;
        m_reg[ULPI_REG_SCRATCH] = 0x00;
    }

    //-------------------------------------------------------------
    // Trace
    //-------------------------------------------------------------
    void add_trace(sc_trace_file *vcd, std::string prefix)
    {
        #undef  TRACE_SIGNAL
        #define TRACE_SIGNAL(s) sc_trace(vcd,s,prefix + #s)

        TRACE_SIGNAL(ulpi_data_o);
        TRACE_SIGNAL(ulpi_data_i);
        TRACE_SIGNAL(ulpi_dir_o);
        TRACE_SIGNAL(ulpi_nxt_o);
        TRACE_SIGNAL(ulpi_stp_i);

        #undef  TRACE_SIGNAL
    }

    //-------------------------------------------------------------
    // API
    //-------------------------------------------------------------
public:
    void write(sc_uint <8> data, bool last = false);
    bool read(sc_uint <8> &data);

    bool write_empty(void) { return m_tx_fifo.num_available() == 0; }
    bool read_ready(void)  { return m_rx_fifo.num_available() > 0; }

    //-------------------------------------------------------------
    // Internal
    //-------------------------------------------------------------
protected:
    void drive(void);
    void rx_write(sc_uint <8> data, bool last);
    bool tx_read(sc_uint <8> &data);

    void drive_rxcmd(sc_uint <2> linestate, bool rx_active, bool rx_error);
    void drive_rxdata(sc_uint <8> data);
    void drive_output(bool rx_data);
    void drive_input(void);

    void        reg_write(sc_uint <8> addr, sc_uint <8> data);
    sc_uint <8> reg_read(sc_uint <8> addr);

    //-------------------------------------------------------------
    // Members
    //-------------------------------------------------------------
    sc_fifo < sc_uint<9> >  m_tx_fifo;
    sc_fifo < sc_uint<9> >  m_rx_fifo;
    sc_uint <8>             m_reg[ULPI_REG_NUM];
};

#endif