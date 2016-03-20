#include <stdio.h>
#include <stdlib.h>
#include <vpi_user.h>
#include <assert.h>

#include "ulpi_wrapper.h"

// User provided init function
extern void sc_main_tb(void);

//-----------------------------------------------------------------
// valueChangeCb
//-----------------------------------------------------------------
int ulpi_wrapper::valueChangeCb(void)
{
    s_vpi_value  value_s;
    static uint64_t last_time = 0;

    s_vpi_time vpi_time_s;

    vpi_time_s.type = vpiSimTime;
    vpi_time_s.high = 0;
    vpi_time_s.low  = 0;

    // For each I/O
    vpiHandle handle_ulpi_clk60_i       = vpi_handle_by_name("tb_top.ulpi_clk60_i", NULL);
    vpiHandle handle_ulpi_rst_i       = vpi_handle_by_name("tb_top.ulpi_rst_i", NULL);
    vpiHandle handle_ulpi_data_i       = vpi_handle_by_name("tb_top.ulpi_data_i", NULL);
    vpiHandle handle_ulpi_data_o       = vpi_handle_by_name("tb_top.ulpi_data_o", NULL);
    vpiHandle handle_ulpi_dir_i       = vpi_handle_by_name("tb_top.ulpi_dir_i", NULL);
    vpiHandle handle_ulpi_nxt_i       = vpi_handle_by_name("tb_top.ulpi_nxt_i", NULL);
    vpiHandle handle_ulpi_stp_o       = vpi_handle_by_name("tb_top.ulpi_stp_o", NULL);
    vpiHandle handle_reg_addr_i       = vpi_handle_by_name("tb_top.reg_addr_i", NULL);
    vpiHandle handle_reg_stb_i       = vpi_handle_by_name("tb_top.reg_stb_i", NULL);
    vpiHandle handle_reg_we_i       = vpi_handle_by_name("tb_top.reg_we_i", NULL);
    vpiHandle handle_reg_data_i       = vpi_handle_by_name("tb_top.reg_data_i", NULL);
    vpiHandle handle_reg_data_o       = vpi_handle_by_name("tb_top.reg_data_o", NULL);
    vpiHandle handle_reg_ack_o       = vpi_handle_by_name("tb_top.reg_ack_o", NULL);
    vpiHandle handle_utmi_txvalid_i       = vpi_handle_by_name("tb_top.utmi_txvalid_i", NULL);
    vpiHandle handle_utmi_txready_o       = vpi_handle_by_name("tb_top.utmi_txready_o", NULL);
    vpiHandle handle_utmi_rxvalid_o       = vpi_handle_by_name("tb_top.utmi_rxvalid_o", NULL);
    vpiHandle handle_utmi_rxactive_o       = vpi_handle_by_name("tb_top.utmi_rxactive_o", NULL);
    vpiHandle handle_utmi_rxerror_o       = vpi_handle_by_name("tb_top.utmi_rxerror_o", NULL);
    vpiHandle handle_utmi_data_o       = vpi_handle_by_name("tb_top.utmi_data_o", NULL);
    vpiHandle handle_utmi_data_i       = vpi_handle_by_name("tb_top.utmi_data_i", NULL);
    vpiHandle handle_utmi_xcvrselect_i       = vpi_handle_by_name("tb_top.utmi_xcvrselect_i", NULL);
    vpiHandle handle_utmi_termselect_i       = vpi_handle_by_name("tb_top.utmi_termselect_i", NULL);
    vpiHandle handle_utmi_opmode_i       = vpi_handle_by_name("tb_top.utmi_opmode_i", NULL);
    vpiHandle handle_utmi_dppulldown_i       = vpi_handle_by_name("tb_top.utmi_dppulldown_i", NULL);
    vpiHandle handle_utmi_dmpulldown_i       = vpi_handle_by_name("tb_top.utmi_dmpulldown_i", NULL);
    vpiHandle handle_utmi_linestate_o       = vpi_handle_by_name("tb_top.utmi_linestate_o", NULL);

    // Read current value from Verilog 
    value_s.format = vpiIntVal;

    // Clock & Reset
    vpi_get_value(handle_ulpi_clk60_i, &value_s);
    m_clk.write(value_s.value.integer);
    vpi_get_value(handle_ulpi_rst_i, &value_s);
    m_rst.write(value_s.value.integer);

    // Outputs
    vpi_get_value(handle_ulpi_data_o, &value_s);
    ulpi_data_o.write(value_s.value.integer);
    vpi_get_value(handle_ulpi_stp_o, &value_s);
    ulpi_stp_o.write(value_s.value.integer);
    vpi_get_value(handle_reg_data_o, &value_s);
    reg_data_o.write(value_s.value.integer);
    vpi_get_value(handle_reg_ack_o, &value_s);
    reg_ack_o.write(value_s.value.integer);
    vpi_get_value(handle_utmi_txready_o, &value_s);
    utmi_txready_o.write(value_s.value.integer);
    vpi_get_value(handle_utmi_rxvalid_o, &value_s);
    utmi_rxvalid_o.write(value_s.value.integer);
    vpi_get_value(handle_utmi_rxactive_o, &value_s);
    utmi_rxactive_o.write(value_s.value.integer);
    vpi_get_value(handle_utmi_rxerror_o, &value_s);
    utmi_rxerror_o.write(value_s.value.integer);
    vpi_get_value(handle_utmi_data_o, &value_s);
    utmi_data_o.write(value_s.value.integer);
    vpi_get_value(handle_utmi_linestate_o, &value_s);
    utmi_linestate_o.write(value_s.value.integer);

    // Get current time
    uint64_t time_value = 0;
    s_vpi_time time_now;
    time_now.type = vpiSimTime;
    vpi_get_time (0, &time_now);

    time_value = time_now.high;
    time_value <<= 32;
    time_value |= time_now.low;

    // Update systemC TB
    if(sc_pending_activity())
        sc_start((int)(time_value-last_time),SC_NS);

    last_time = time_value;

    // Inputs
    value_s.value.integer = ulpi_data_i.read();
    vpi_put_value(handle_ulpi_data_i, &value_s, &vpi_time_s, vpiInertialDelay);
    value_s.value.integer = ulpi_dir_i.read();
    vpi_put_value(handle_ulpi_dir_i, &value_s, &vpi_time_s, vpiInertialDelay);
    value_s.value.integer = ulpi_nxt_i.read();
    vpi_put_value(handle_ulpi_nxt_i, &value_s, &vpi_time_s, vpiInertialDelay);
    value_s.value.integer = reg_addr_i.read();
    vpi_put_value(handle_reg_addr_i, &value_s, &vpi_time_s, vpiInertialDelay);
    value_s.value.integer = reg_stb_i.read();
    vpi_put_value(handle_reg_stb_i, &value_s, &vpi_time_s, vpiInertialDelay);
    value_s.value.integer = reg_we_i.read();
    vpi_put_value(handle_reg_we_i, &value_s, &vpi_time_s, vpiInertialDelay);
    value_s.value.integer = reg_data_i.read();
    vpi_put_value(handle_reg_data_i, &value_s, &vpi_time_s, vpiInertialDelay);
    value_s.value.integer = utmi_txvalid_i.read();
    vpi_put_value(handle_utmi_txvalid_i, &value_s, &vpi_time_s, vpiInertialDelay);
    value_s.value.integer = utmi_data_i.read();
    vpi_put_value(handle_utmi_data_i, &value_s, &vpi_time_s, vpiInertialDelay);
    value_s.value.integer = utmi_xcvrselect_i.read();
    vpi_put_value(handle_utmi_xcvrselect_i, &value_s, &vpi_time_s, vpiInertialDelay);
    value_s.value.integer = utmi_termselect_i.read();
    vpi_put_value(handle_utmi_termselect_i, &value_s, &vpi_time_s, vpiInertialDelay);
    value_s.value.integer = utmi_opmode_i.read();
    vpi_put_value(handle_utmi_opmode_i, &value_s, &vpi_time_s, vpiInertialDelay);
    value_s.value.integer = utmi_dppulldown_i.read();
    vpi_put_value(handle_utmi_dppulldown_i, &value_s, &vpi_time_s, vpiInertialDelay);
    value_s.value.integer = utmi_dmpulldown_i.read();
    vpi_put_value(handle_utmi_dmpulldown_i, &value_s, &vpi_time_s, vpiInertialDelay);

    if (isStopped())
        vpi_sim_control(vpiFinish, 0);

    return 0;
}
//-----------------------------------------------------------------
// value_change
//-----------------------------------------------------------------
static int value_change(p_cb_data cb_data)
{
    ulpi_wrapper *p = (ulpi_wrapper*)cb_data->user_data;
    return p->valueChangeCb();
}
//-----------------------------------------------------------------
// attachCb
//-----------------------------------------------------------------
int ulpi_wrapper::attachCb(void)
{
    static s_vpi_value value_s;
    static s_vpi_time  vpi_time;
    s_cb_data          cb_data_s;

    vpi_time.high = 0;
    vpi_time.low  = 0;
    vpi_time.type = vpiSimTime;

    // For each I/O
    vpiHandle handle_ulpi_clk60_i       = vpi_handle_by_name("tb_top.ulpi_clk60_i", NULL);
    vpiHandle handle_ulpi_rst_i       = vpi_handle_by_name("tb_top.ulpi_rst_i", NULL);
    vpiHandle handle_ulpi_data_i       = vpi_handle_by_name("tb_top.ulpi_data_i", NULL);
    vpiHandle handle_ulpi_data_o       = vpi_handle_by_name("tb_top.ulpi_data_o", NULL);
    vpiHandle handle_ulpi_dir_i       = vpi_handle_by_name("tb_top.ulpi_dir_i", NULL);
    vpiHandle handle_ulpi_nxt_i       = vpi_handle_by_name("tb_top.ulpi_nxt_i", NULL);
    vpiHandle handle_ulpi_stp_o       = vpi_handle_by_name("tb_top.ulpi_stp_o", NULL);
    vpiHandle handle_reg_addr_i       = vpi_handle_by_name("tb_top.reg_addr_i", NULL);
    vpiHandle handle_reg_stb_i       = vpi_handle_by_name("tb_top.reg_stb_i", NULL);
    vpiHandle handle_reg_we_i       = vpi_handle_by_name("tb_top.reg_we_i", NULL);
    vpiHandle handle_reg_data_i       = vpi_handle_by_name("tb_top.reg_data_i", NULL);
    vpiHandle handle_reg_data_o       = vpi_handle_by_name("tb_top.reg_data_o", NULL);
    vpiHandle handle_reg_ack_o       = vpi_handle_by_name("tb_top.reg_ack_o", NULL);
    vpiHandle handle_utmi_txvalid_i       = vpi_handle_by_name("tb_top.utmi_txvalid_i", NULL);
    vpiHandle handle_utmi_txready_o       = vpi_handle_by_name("tb_top.utmi_txready_o", NULL);
    vpiHandle handle_utmi_rxvalid_o       = vpi_handle_by_name("tb_top.utmi_rxvalid_o", NULL);
    vpiHandle handle_utmi_rxactive_o       = vpi_handle_by_name("tb_top.utmi_rxactive_o", NULL);
    vpiHandle handle_utmi_rxerror_o       = vpi_handle_by_name("tb_top.utmi_rxerror_o", NULL);
    vpiHandle handle_utmi_data_o       = vpi_handle_by_name("tb_top.utmi_data_o", NULL);
    vpiHandle handle_utmi_data_i       = vpi_handle_by_name("tb_top.utmi_data_i", NULL);
    vpiHandle handle_utmi_xcvrselect_i       = vpi_handle_by_name("tb_top.utmi_xcvrselect_i", NULL);
    vpiHandle handle_utmi_termselect_i       = vpi_handle_by_name("tb_top.utmi_termselect_i", NULL);
    vpiHandle handle_utmi_opmode_i       = vpi_handle_by_name("tb_top.utmi_opmode_i", NULL);
    vpiHandle handle_utmi_dppulldown_i       = vpi_handle_by_name("tb_top.utmi_dppulldown_i", NULL);
    vpiHandle handle_utmi_dmpulldown_i       = vpi_handle_by_name("tb_top.utmi_dmpulldown_i", NULL);
    vpiHandle handle_utmi_linestate_o       = vpi_handle_by_name("tb_top.utmi_linestate_o", NULL);

    // Attach value change callbacks for outputs
    cb_data_s.user_data = (PLI_BYTE8*)this;
    cb_data_s.reason    = cbValueChange;
    cb_data_s.cb_rtn    = value_change;
    cb_data_s.time      = &vpi_time;
    cb_data_s.value     = &value_s;

    value_s.format      = vpiIntVal;

    cb_data_s.obj  = handle_ulpi_clk60_i;
    vpi_register_cb(&cb_data_s);

    cb_data_s.obj  = handle_ulpi_rst_i;
    vpi_register_cb(&cb_data_s);

    cb_data_s.obj  = handle_ulpi_data_o;
    vpi_register_cb(&cb_data_s);    
    cb_data_s.obj  = handle_ulpi_stp_o;
    vpi_register_cb(&cb_data_s);    
    cb_data_s.obj  = handle_reg_data_o;
    vpi_register_cb(&cb_data_s);    
    cb_data_s.obj  = handle_reg_ack_o;
    vpi_register_cb(&cb_data_s);    
    cb_data_s.obj  = handle_utmi_txready_o;
    vpi_register_cb(&cb_data_s);    
    cb_data_s.obj  = handle_utmi_rxvalid_o;
    vpi_register_cb(&cb_data_s);    
    cb_data_s.obj  = handle_utmi_rxactive_o;
    vpi_register_cb(&cb_data_s);    
    cb_data_s.obj  = handle_utmi_rxerror_o;
    vpi_register_cb(&cb_data_s);    
    cb_data_s.obj  = handle_utmi_data_o;
    vpi_register_cb(&cb_data_s);    
    cb_data_s.obj  = handle_utmi_linestate_o;
    vpi_register_cb(&cb_data_s);    

    // Initialize SystemC Model
    sc_main_tb();

    return 0;
}
//-----------------------------------------------------------------
// attach_system_c
//-----------------------------------------------------------------
static int attach_system_c(char *user_data)
{
    ulpi_wrapper *p = (ulpi_wrapper*)user_data;
    return p->attachCb();
}
//-----------------------------------------------------------------
// _register
//-----------------------------------------------------------------
static void _register(void)
{
    s_vpi_systf_data tf_data;

    tf_data.type      = vpiSysTask;
    tf_data.tfname    = "$attach_system_c";
    tf_data.calltf    = attach_system_c;
    tf_data.compiletf = 0;
    tf_data.sizetf    = 0;
    tf_data.user_data = (PLI_BYTE8*)&ulpi_wrapper::getInstance();
    vpi_register_systf(&tf_data);
}

void (*vlog_startup_routines[])() = 
{
    _register,
    0
};
