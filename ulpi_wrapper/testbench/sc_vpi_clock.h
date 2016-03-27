#ifndef __SC_VPI_CLOCK_H__
#define __SC_VPI_CLOCK_H__

#include <systemc.h>
#include <vpi_user.h>


static int sc_vpi_clock_after_delay(p_cb_data cb_data);

class sc_vpi_clock
{
public:

    sc_signal <bool> m_clk;
    int              m_low_ns;
    int              m_high_ns;
    uint64_t         m_last_time;
    
    sc_module_name   m_name;

    vpiHandle        m_vpi_handle;

    sc_vpi_clock(sc_module_name name) : m_clk(name), m_name(name)
    {
        m_low_ns  = 5;
        m_high_ns = 5;
        m_last_time = 0;

        m_vpi_handle = vpi_handle_by_name((const char*)name, NULL);
        sc_assert(m_vpi_handle != NULL);
    }

    void start(void) { after_delay(); }

    int after_delay(void)
    {
        bool clk_next = !m_clk.read(); 
        s_vpi_time  vpi_time_s;
        s_cb_data   cb_data_s;

        vpi_time_s.type = vpiSimTime;
        vpi_time_s.high = 0;
        vpi_time_s.low  = 0;

        s_vpi_value  value_s;
        value_s.format = vpiIntVal;
        value_s.value.integer = clk_next;
        vpi_put_value(m_vpi_handle, &value_s, &vpi_time_s, vpiInertialDelay);     

        // Setup wait time
        vpi_time_s.high = 0;
        vpi_time_s.low  = clk_next ? m_high_ns : m_low_ns;
        vpi_time_s.type = vpiSimTime;

        m_clk.write(clk_next);   

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

        // Attach value change callbacks for outputs
        cb_data_s.user_data = (PLI_BYTE8*)this;
        cb_data_s.reason    = cbAfterDelay;
        cb_data_s.cb_rtn    = sc_vpi_clock_after_delay;
        cb_data_s.time      = &vpi_time_s;
        cb_data_s.value     = NULL;
        vpi_register_cb(&cb_data_s);        
    }
};

static int sc_vpi_clock_after_delay(p_cb_data cb_data)
{
    sc_vpi_clock *p = (sc_vpi_clock*)cb_data->user_data;
    return p->after_delay();
}


#endif
