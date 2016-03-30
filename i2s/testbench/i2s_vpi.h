#ifndef I2S_VPI_H
#define I2S_VPI_H

#include "sc_vpi_module.h"

class i2s_vpi: public sc_vpi_module
{
public:
    sc_in <bool> clk_i;
    sc_in <bool> rst_i;
    sc_in <bool> audio_clk_i;
    sc_in <bool> audio_rst_i;
    sc_out <bool> i2s_mclk_o;
    sc_out <bool> i2s_bclk_o;
    sc_out <bool> i2s_ws_o;
    sc_out <bool> i2s_data_o;
    sc_in <sc_uint<32> > sample_i;
    sc_out <bool> sample_req_o;

    void read_outputs(void)
    {
        sc_vpi_module_read_output_int(i2s_mclk_o, "i2s_mclk_o");
        sc_vpi_module_read_output_int(i2s_bclk_o, "i2s_bclk_o");
        sc_vpi_module_read_output_int(i2s_ws_o, "i2s_ws_o");
        sc_vpi_module_read_output_int(i2s_data_o, "i2s_data_o");
        sc_vpi_module_read_output_int(sample_req_o, "sample_req_o");
    }
    
    void write_inputs(void)
    {
        sc_vpi_module_write_input_int(clk_i, "clk_i");
        sc_vpi_module_write_input_int(rst_i, "rst_i");
        sc_vpi_module_write_input_int(audio_clk_i, "audio_clk_i");
        sc_vpi_module_write_input_int(audio_rst_i, "audio_rst_i");
        sc_vpi_module_write_input_int(sample_i, "sample_i");
    }

    i2s_vpi(sc_module_name name):  
                                    sc_vpi_module(name)
                                  , clk_i ("clk_i")
                                  , rst_i ("rst_i")
                                  , audio_clk_i ("audio_clk_i")
                                  , audio_rst_i ("audio_rst_i")
                                  , i2s_mclk_o ("i2s_mclk_o")
                                  , i2s_bclk_o ("i2s_bclk_o")
                                  , i2s_ws_o ("i2s_ws_o")
                                  , i2s_data_o ("i2s_data_o")
                                  , sample_i ("sample_i")
                                  , sample_req_o ("sample_req_o")
    { 
        register_signal("clk_i");
        register_signal("rst_i");
        register_signal("audio_clk_i");
        register_signal("audio_rst_i");
        register_signal("i2s_mclk_o");
        register_signal("i2s_bclk_o");
        register_signal("i2s_ws_o");
        register_signal("i2s_data_o");
        register_signal("sample_i");
        register_signal("sample_req_o");
    }
};

#endif