#ifndef UART_WB_VPI_H
#define UART_WB_VPI_H

#include "sc_vpi_module.h"

class uart_wb_vpi: public sc_vpi_module
{
public:
    sc_in <bool> clk_i;
    sc_in <bool> rst_i;
    sc_out <bool> intr_o;
    sc_out <bool> tx_o;
    sc_in <bool> rx_i;
    sc_in <sc_uint<8> > addr_i;
    sc_out <sc_uint<32> > data_o;
    sc_in <sc_uint<32> > data_i;
    sc_in <bool> we_i;
    sc_in <bool> stb_i;
    sc_out <bool> ack_o;

    void read_outputs(void)
    {
        sc_vpi_module_read_output_int(intr_o, "intr_o");
        sc_vpi_module_read_output_int(tx_o, "tx_o");
        sc_vpi_module_read_output_int(data_o, "data_o");
        sc_vpi_module_read_output_int(ack_o, "ack_o");
    }
    
    void write_inputs(void)
    {
        sc_vpi_module_write_input_int(clk_i, "clk_i");
        sc_vpi_module_write_input_int(rst_i, "rst_i");
        sc_vpi_module_write_input_int(rx_i, "rx_i");
        sc_vpi_module_write_input_int(addr_i, "addr_i");
        sc_vpi_module_write_input_int(data_i, "data_i");
        sc_vpi_module_write_input_int(we_i, "we_i");
        sc_vpi_module_write_input_int(stb_i, "stb_i");
    }

    uart_wb_vpi(sc_module_name name):  
                                    sc_vpi_module(name)
                                  , clk_i ("clk_i")
                                  , rst_i ("rst_i")
                                  , intr_o ("intr_o")
                                  , tx_o ("tx_o")
                                  , rx_i ("rx_i")
                                  , addr_i ("addr_i")
                                  , data_o ("data_o")
                                  , data_i ("data_i")
                                  , we_i ("we_i")
                                  , stb_i ("stb_i")
                                  , ack_o ("ack_o")
    { 
        register_signal("clk_i");
        register_signal("rst_i");
        register_signal("intr_o");
        register_signal("tx_o");
        register_signal("rx_i");
        register_signal("addr_i");
        register_signal("data_o");
        register_signal("data_i");
        register_signal("we_i");
        register_signal("stb_i");
        register_signal("ack_o");
    }
};

#endif