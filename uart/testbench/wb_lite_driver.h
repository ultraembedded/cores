#ifndef WB_LITE_DRIVER_H
#define WB_LITE_DRIVER_H

#include <systemc.h>

//-------------------------------------------------------------
// wb_lite_driver: Wishbone lite driver interface
//-------------------------------------------------------------
SC_MODULE(wb_lite_driver)
{
public:
    //-------------------------------------------------------------
    // Interface I/O
    //-------------------------------------------------------------
    sc_out <sc_uint<8> >    addr_o;
    sc_out <sc_uint<32> >   data_o;
    sc_in <sc_uint<32> >    data_i;
    sc_out <bool>           we_o;
    sc_out <bool>           stb_o;
    sc_in <bool>            ack_i;

    //-------------------------------------------------------------
    // Constants
    //-------------------------------------------------------------
    static const int IF_WIDTH = 8 + 32 + 32 + 1 + 1 + 1;   

    //-------------------------------------------------------------
    // Constructor
    //-------------------------------------------------------------
    SC_HAS_PROCESS(wb_lite_driver);
    wb_lite_driver(sc_module_name name): sc_module(name) { m_classic_mode = false; }

    //-------------------------------------------------------------
    // Trace
    //-------------------------------------------------------------
    void add_trace(sc_trace_file *vcd, std::string prefix)
    {
        #undef  TRACE_SIGNAL
        #define TRACE_SIGNAL(s) sc_trace(vcd,s,prefix + #s)

        TRACE_SIGNAL(addr_o);
        TRACE_SIGNAL(data_o);
        TRACE_SIGNAL(data_i);
        TRACE_SIGNAL(we_o);
        TRACE_SIGNAL(stb_o);
        TRACE_SIGNAL(ack_i);

        #undef  TRACE_SIGNAL
    }

    //-------------------------------------------------------------
    // API
    //-------------------------------------------------------------
    void         set_classic_mode(bool enable) { m_classic_mode = enable; }
    void         write(sc_uint <8> addr, sc_uint <32> data);
    sc_uint <32> read(sc_uint <8> addr);

protected:
    //-------------------------------------------------------------
    // Members
    //-------------------------------------------------------------
    bool m_classic_mode;
};

#endif