#ifndef ULPI_WRAPPER_VPI_H
#define ULPI_WRAPPER_VPI_H

#include "sc_vpi_module.h"

class ulpi_wrapper_vpi: public sc_vpi_module
{
public:
    sc_in <bool> ulpi_clk60_i;
    sc_in <bool> ulpi_rst_i;
    sc_in <sc_uint<8> > ulpi_data_i;
    sc_out <sc_uint<8> > ulpi_data_o;
    sc_in <bool> ulpi_dir_i;
    sc_in <bool> ulpi_nxt_i;
    sc_out <bool> ulpi_stp_o;
    sc_in <bool> utmi_txvalid_i;
    sc_out <bool> utmi_txready_o;
    sc_out <bool> utmi_rxvalid_o;
    sc_out <bool> utmi_rxactive_o;
    sc_out <bool> utmi_rxerror_o;
    sc_out <sc_uint<8> > utmi_data_o;
    sc_in <sc_uint<8> > utmi_data_i;
    sc_in <sc_uint<2> > utmi_xcvrselect_i;
    sc_in <bool> utmi_termselect_i;
    sc_in <sc_uint<2> > utmi_opmode_i;
    sc_in <bool> utmi_dppulldown_i;
    sc_in <bool> utmi_dmpulldown_i;
    sc_out <sc_uint<2> > utmi_linestate_o;

    void read_outputs(void)
    {
        sc_vpi_module_read_output_int(ulpi_data_o, "ulpi_data_o");
        sc_vpi_module_read_output_int(ulpi_stp_o, "ulpi_stp_o");
        sc_vpi_module_read_output_int(utmi_txready_o, "utmi_txready_o");
        sc_vpi_module_read_output_int(utmi_rxvalid_o, "utmi_rxvalid_o");
        sc_vpi_module_read_output_int(utmi_rxactive_o, "utmi_rxactive_o");
        sc_vpi_module_read_output_int(utmi_rxerror_o, "utmi_rxerror_o");
        sc_vpi_module_read_output_int(utmi_data_o, "utmi_data_o");
        sc_vpi_module_read_output_int(utmi_linestate_o, "utmi_linestate_o");
    }
    
    void write_inputs(void)
    {
        sc_vpi_module_write_input_int(ulpi_clk60_i, "ulpi_clk60_i");
        sc_vpi_module_write_input_int(ulpi_rst_i, "ulpi_rst_i");
        sc_vpi_module_write_input_int(ulpi_data_i, "ulpi_data_i");
        sc_vpi_module_write_input_int(ulpi_dir_i, "ulpi_dir_i");
        sc_vpi_module_write_input_int(ulpi_nxt_i, "ulpi_nxt_i");
        sc_vpi_module_write_input_int(utmi_txvalid_i, "utmi_txvalid_i");
        sc_vpi_module_write_input_int(utmi_data_i, "utmi_data_i");
        sc_vpi_module_write_input_int(utmi_xcvrselect_i, "utmi_xcvrselect_i");
        sc_vpi_module_write_input_int(utmi_termselect_i, "utmi_termselect_i");
        sc_vpi_module_write_input_int(utmi_opmode_i, "utmi_opmode_i");
        sc_vpi_module_write_input_int(utmi_dppulldown_i, "utmi_dppulldown_i");
        sc_vpi_module_write_input_int(utmi_dmpulldown_i, "utmi_dmpulldown_i");
    }

    ulpi_wrapper_vpi(sc_module_name name):  
                                    sc_vpi_module(name)
                                  , ulpi_clk60_i ("ulpi_clk60_i")
                                  , ulpi_rst_i ("ulpi_rst_i")
                                  , ulpi_data_i ("ulpi_data_i")
                                  , ulpi_data_o ("ulpi_data_o")
                                  , ulpi_dir_i ("ulpi_dir_i")
                                  , ulpi_nxt_i ("ulpi_nxt_i")
                                  , ulpi_stp_o ("ulpi_stp_o")
                                  , utmi_txvalid_i ("utmi_txvalid_i")
                                  , utmi_txready_o ("utmi_txready_o")
                                  , utmi_rxvalid_o ("utmi_rxvalid_o")
                                  , utmi_rxactive_o ("utmi_rxactive_o")
                                  , utmi_rxerror_o ("utmi_rxerror_o")
                                  , utmi_data_o ("utmi_data_o")
                                  , utmi_data_i ("utmi_data_i")
                                  , utmi_xcvrselect_i ("utmi_xcvrselect_i")
                                  , utmi_termselect_i ("utmi_termselect_i")
                                  , utmi_opmode_i ("utmi_opmode_i")
                                  , utmi_dppulldown_i ("utmi_dppulldown_i")
                                  , utmi_dmpulldown_i ("utmi_dmpulldown_i")
                                  , utmi_linestate_o ("utmi_linestate_o")
    { 
        register_signal("ulpi_clk60_i");
        register_signal("ulpi_rst_i");
        register_signal("ulpi_data_i");
        register_signal("ulpi_data_o");
        register_signal("ulpi_dir_i");
        register_signal("ulpi_nxt_i");
        register_signal("ulpi_stp_o");
        register_signal("utmi_txvalid_i");
        register_signal("utmi_txready_o");
        register_signal("utmi_rxvalid_o");
        register_signal("utmi_rxactive_o");
        register_signal("utmi_rxerror_o");
        register_signal("utmi_data_o");
        register_signal("utmi_data_i");
        register_signal("utmi_xcvrselect_i");
        register_signal("utmi_termselect_i");
        register_signal("utmi_opmode_i");
        register_signal("utmi_dppulldown_i");
        register_signal("utmi_dmpulldown_i");
        register_signal("utmi_linestate_o");
    }
};

#endif