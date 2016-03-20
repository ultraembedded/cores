#ifndef WBL_DRIVER_H
#define WBL_DRIVER_H

#include <systemc.h>

//-------------------------------------------------------------
// wbl_driver: Wishbone driver interface (8-bit A, 8-bit D)
//-------------------------------------------------------------
SC_MODULE(wbl_driver)
{
public:
    //-------------------------------------------------------------
    // Interface I/O
    //-------------------------------------------------------------
    sc_out <sc_uint<8> >    addr_o;
    sc_out <sc_uint<8> >    data_o;
    sc_in <sc_uint<8> >     data_i;
    sc_out <bool>           we_o;
    sc_out <bool>           stb_o;
    sc_in <bool>            ack_i;

    //-------------------------------------------------------------
    // Constructor
    //-------------------------------------------------------------
    SC_HAS_PROCESS(wbl_driver);
    wbl_driver(sc_module_name name): sc_module(name) { }

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
    void write(sc_uint <8> addr, sc_uint <8> data);
    sc_uint <8> read(sc_uint <8> addr);
};

#endif