#ifndef __SC_VPI_MODULE_H__
#define __SC_VPI_MODULE_H__

#include <systemc.h>
#include <assert.h>
#include <vpi_user.h>

static int sc_vpi_module_value_change(p_cb_data cb_data);

#define sc_vpi_module_read_output_int(obj, name)  \
{                                   \
    s_vpi_value  value_s;           \
    s_vpi_time   vpi_time_s;        \
                                    \
    value_s.format = vpiIntVal;     \
                                    \
    vpi_time_s.type = vpiSimTime;   \
    vpi_time_s.high = 0;            \
    vpi_time_s.low  = 0;            \
                                    \
    std::string path = m_hdl_name;  \
    path = path + "." + name;       \
    vpiHandle handle = vpi_handle_by_name(path.c_str(), NULL); \
    assert(handle != NULL);           \
                                      \
    vpi_get_value(handle, &value_s);  \
    obj.write(value_s.value.integer); \
}

#define sc_vpi_module_write_input_int(obj, name)  \
{                                   \
    s_vpi_value  value_s;           \
    s_vpi_time   vpi_time_s;        \
                                    \
    value_s.format = vpiIntVal;     \
                                    \
    vpi_time_s.type = vpiSimTime;   \
    vpi_time_s.high = 0;            \
    vpi_time_s.low  = 0;            \
                                    \
    std::string path = m_hdl_name;  \
    path = path + "." + name;       \
    vpiHandle handle = vpi_handle_by_name(path.c_str(), NULL); \
    assert(handle != NULL);           \
                                      \
    value_s.value.integer = obj.read();  \
    vpi_put_value(handle, &value_s, &vpi_time_s, vpiInertialDelay); \
}

class sc_vpi_module
{
public:   
    std::string      m_hdl_name;
    uint64_t         m_last_time;
    sc_signal<bool>  m_stop;

    sc_vpi_module(sc_module_name name) : m_hdl_name((std::string)name)
    {
        m_last_time = 0;
        m_stop.write(false);
    }

    // Simulation control    
    void stopSimulation()  { m_stop.write(true); }
    bool isStopped()       { return m_stop.read(); }

    virtual void read_outputs(void) { }
    virtual void write_inputs(void) { }

    bool register_signal(const char *name)
    {
        static s_vpi_value value_s;
        static s_vpi_time  vpi_time;
        s_cb_data          cb_data_s;

        vpi_time.high = 0;
        vpi_time.low  = 0;
        vpi_time.type = vpiSimTime;

        // For each I/O
        std::string path = m_hdl_name;
        path = path + "." + name;
        vpiHandle handle = vpi_handle_by_name(path.c_str(), NULL);
        if (!handle)
            return false;

        // Attach value change callbacks for outputs
        cb_data_s.user_data = (PLI_BYTE8*)this;
        cb_data_s.reason    = cbValueChange;
        cb_data_s.cb_rtn    = sc_vpi_module_value_change;
        cb_data_s.time      = &vpi_time;
        cb_data_s.value     = &value_s;

        value_s.format      = vpiIntVal;

        cb_data_s.obj  = handle;
        vpi_register_cb(&cb_data_s);

        return true;
    }

    int value_change(void)
    {
        s_vpi_time vpi_time_s;

        vpi_time_s.type = vpiSimTime;
        vpi_time_s.high = 0;
        vpi_time_s.low  = 0;

        // Outputs
        read_outputs();

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
            sc_start((int)(time_value-m_last_time),SC_NS);

        m_last_time = time_value;

        // Inputs
        write_inputs();

        if (isStopped())
            vpi_sim_control(vpiFinish, 0);

        return 0;
    }
};

static int sc_vpi_module_value_change(p_cb_data cb_data)
{
    sc_vpi_module *p = (sc_vpi_module*)cb_data->user_data;
    return p->value_change();
}

#endif
