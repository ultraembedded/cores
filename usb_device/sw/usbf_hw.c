//-----------------------------------------------------------------
//                         USB CDC Device SW
//                               V0.1
//                         Ultra-Embedded.com
//                          Copyright 2014
//
//                  Email: admin@ultra-embedded.com
//
//                          License: GPL
// If you would like a version with a more permissive license for use in
// closed source commercial applications please contact me for details.
//-----------------------------------------------------------------
//
// This file is part of USB CDC Device SW.
//
// USB CDC Device SW is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// USB CDC Device SW is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with USB CDC Device SW; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//-----------------------------------------------------------------
#include "usbf_hw.h"
#include "usb_log.h"
#include "timer.h"

//-----------------------------------------------------------------
// Peripheral registers:
//-----------------------------------------------------------------
#define USB_FUNC_CTRL     0x0
    #define USB_FUNC_CTRL_HS_CHIRP_EN            8
    #define USB_FUNC_CTRL_HS_CHIRP_EN_SHIFT      8
    #define USB_FUNC_CTRL_HS_CHIRP_EN_MASK       0x1

    #define USB_FUNC_CTRL_PHY_DMPULLDOWN         7
    #define USB_FUNC_CTRL_PHY_DMPULLDOWN_SHIFT   7
    #define USB_FUNC_CTRL_PHY_DMPULLDOWN_MASK    0x1

    #define USB_FUNC_CTRL_PHY_DPPULLDOWN         6
    #define USB_FUNC_CTRL_PHY_DPPULLDOWN_SHIFT   6
    #define USB_FUNC_CTRL_PHY_DPPULLDOWN_MASK    0x1

    #define USB_FUNC_CTRL_PHY_TERMSELECT         5
    #define USB_FUNC_CTRL_PHY_TERMSELECT_SHIFT   5
    #define USB_FUNC_CTRL_PHY_TERMSELECT_MASK    0x1

    #define USB_FUNC_CTRL_PHY_XCVRSELECT_SHIFT   3
    #define USB_FUNC_CTRL_PHY_XCVRSELECT_MASK    0x3

    #define USB_FUNC_CTRL_PHY_OPMODE_SHIFT       1
    #define USB_FUNC_CTRL_PHY_OPMODE_MASK        0x3

    #define USB_FUNC_CTRL_INT_EN_SOF             0
    #define USB_FUNC_CTRL_INT_EN_SOF_SHIFT       0
    #define USB_FUNC_CTRL_INT_EN_SOF_MASK        0x1

#define USB_FUNC_STAT     0x4
    #define USB_FUNC_STAT_RST                    13
    #define USB_FUNC_STAT_RST_SHIFT              13
    #define USB_FUNC_STAT_RST_MASK               0x1

    #define USB_FUNC_STAT_LINESTATE_SHIFT        11
    #define USB_FUNC_STAT_LINESTATE_MASK         0x3

    #define USB_FUNC_STAT_FRAME_SHIFT            0
    #define USB_FUNC_STAT_FRAME_MASK             0x7ff

#define USB_FUNC_ADDR     0x8
    #define USB_FUNC_ADDR_DEV_ADDR_SHIFT         0
    #define USB_FUNC_ADDR_DEV_ADDR_MASK          0x7f

#define USB_EP0_CFG       0xc
    #define USB_EP0_CFG_INT_RX                   3
    #define USB_EP0_CFG_INT_RX_SHIFT             3
    #define USB_EP0_CFG_INT_RX_MASK              0x1

    #define USB_EP0_CFG_INT_TX                   2
    #define USB_EP0_CFG_INT_TX_SHIFT             2
    #define USB_EP0_CFG_INT_TX_MASK              0x1

    #define USB_EP0_CFG_STALL_EP                 1
    #define USB_EP0_CFG_STALL_EP_SHIFT           1
    #define USB_EP0_CFG_STALL_EP_MASK            0x1

    #define USB_EP0_CFG_ISO                      0
    #define USB_EP0_CFG_ISO_SHIFT                0
    #define USB_EP0_CFG_ISO_MASK                 0x1

#define USB_EP0_TX_CTRL   0x10
    #define USB_EP0_TX_CTRL_TX_FLUSH             17
    #define USB_EP0_TX_CTRL_TX_FLUSH_SHIFT       17
    #define USB_EP0_TX_CTRL_TX_FLUSH_MASK        0x1

    #define USB_EP0_TX_CTRL_TX_START             16
    #define USB_EP0_TX_CTRL_TX_START_SHIFT       16
    #define USB_EP0_TX_CTRL_TX_START_MASK        0x1

    #define USB_EP0_TX_CTRL_TX_LEN_SHIFT         0
    #define USB_EP0_TX_CTRL_TX_LEN_MASK          0x7ff

#define USB_EP0_RX_CTRL   0x14
    #define USB_EP0_RX_CTRL_RX_FLUSH             1
    #define USB_EP0_RX_CTRL_RX_FLUSH_SHIFT       1
    #define USB_EP0_RX_CTRL_RX_FLUSH_MASK        0x1

    #define USB_EP0_RX_CTRL_RX_ACCEPT            0
    #define USB_EP0_RX_CTRL_RX_ACCEPT_SHIFT      0
    #define USB_EP0_RX_CTRL_RX_ACCEPT_MASK       0x1

#define USB_EP0_STS       0x18
    #define USB_EP0_STS_TX_ERR                   20
    #define USB_EP0_STS_TX_ERR_SHIFT             20
    #define USB_EP0_STS_TX_ERR_MASK              0x1

    #define USB_EP0_STS_TX_BUSY                  19
    #define USB_EP0_STS_TX_BUSY_SHIFT            19
    #define USB_EP0_STS_TX_BUSY_MASK             0x1

    #define USB_EP0_STS_RX_ERR                   18
    #define USB_EP0_STS_RX_ERR_SHIFT             18
    #define USB_EP0_STS_RX_ERR_MASK              0x1

    #define USB_EP0_STS_RX_SETUP                 17
    #define USB_EP0_STS_RX_SETUP_SHIFT           17
    #define USB_EP0_STS_RX_SETUP_MASK            0x1

    #define USB_EP0_STS_RX_READY                 16
    #define USB_EP0_STS_RX_READY_SHIFT           16
    #define USB_EP0_STS_RX_READY_MASK            0x1

    #define USB_EP0_STS_RX_COUNT_SHIFT           0
    #define USB_EP0_STS_RX_COUNT_MASK            0x7ff

#define USB_EP0_DATA      0x1c
    #define USB_EP0_DATA_DATA_SHIFT              0
    #define USB_EP0_DATA_DATA_MASK               0xff

#define USB_EP1_CFG       0x20
    #define USB_EP1_CFG_INT_RX                   3
    #define USB_EP1_CFG_INT_RX_SHIFT             3
    #define USB_EP1_CFG_INT_RX_MASK              0x1

    #define USB_EP1_CFG_INT_TX                   2
    #define USB_EP1_CFG_INT_TX_SHIFT             2
    #define USB_EP1_CFG_INT_TX_MASK              0x1

    #define USB_EP1_CFG_STALL_EP                 1
    #define USB_EP1_CFG_STALL_EP_SHIFT           1
    #define USB_EP1_CFG_STALL_EP_MASK            0x1

    #define USB_EP1_CFG_ISO                      0
    #define USB_EP1_CFG_ISO_SHIFT                0
    #define USB_EP1_CFG_ISO_MASK                 0x1

#define USB_EP1_TX_CTRL   0x24
    #define USB_EP1_TX_CTRL_TX_FLUSH             17
    #define USB_EP1_TX_CTRL_TX_FLUSH_SHIFT       17
    #define USB_EP1_TX_CTRL_TX_FLUSH_MASK        0x1

    #define USB_EP1_TX_CTRL_TX_START             16
    #define USB_EP1_TX_CTRL_TX_START_SHIFT       16
    #define USB_EP1_TX_CTRL_TX_START_MASK        0x1

    #define USB_EP1_TX_CTRL_TX_LEN_SHIFT         0
    #define USB_EP1_TX_CTRL_TX_LEN_MASK          0x7ff

#define USB_EP1_RX_CTRL   0x28
    #define USB_EP1_RX_CTRL_RX_FLUSH             1
    #define USB_EP1_RX_CTRL_RX_FLUSH_SHIFT       1
    #define USB_EP1_RX_CTRL_RX_FLUSH_MASK        0x1

    #define USB_EP1_RX_CTRL_RX_ACCEPT            0
    #define USB_EP1_RX_CTRL_RX_ACCEPT_SHIFT      0
    #define USB_EP1_RX_CTRL_RX_ACCEPT_MASK       0x1

#define USB_EP1_STS       0x2c
    #define USB_EP1_STS_TX_ERR                   20
    #define USB_EP1_STS_TX_ERR_SHIFT             20
    #define USB_EP1_STS_TX_ERR_MASK              0x1

    #define USB_EP1_STS_TX_BUSY                  19
    #define USB_EP1_STS_TX_BUSY_SHIFT            19
    #define USB_EP1_STS_TX_BUSY_MASK             0x1

    #define USB_EP1_STS_RX_ERR                   18
    #define USB_EP1_STS_RX_ERR_SHIFT             18
    #define USB_EP1_STS_RX_ERR_MASK              0x1

    #define USB_EP1_STS_RX_SETUP                 17
    #define USB_EP1_STS_RX_SETUP_SHIFT           17
    #define USB_EP1_STS_RX_SETUP_MASK            0x1

    #define USB_EP1_STS_RX_READY                 16
    #define USB_EP1_STS_RX_READY_SHIFT           16
    #define USB_EP1_STS_RX_READY_MASK            0x1

    #define USB_EP1_STS_RX_COUNT_SHIFT           0
    #define USB_EP1_STS_RX_COUNT_MASK            0x7ff

#define USB_EP1_DATA      0x30
    #define USB_EP1_DATA_DATA_SHIFT              0
    #define USB_EP1_DATA_DATA_MASK               0xff

#define USB_EP2_CFG       0x34
    #define USB_EP2_CFG_INT_RX                   3
    #define USB_EP2_CFG_INT_RX_SHIFT             3
    #define USB_EP2_CFG_INT_RX_MASK              0x1

    #define USB_EP2_CFG_INT_TX                   2
    #define USB_EP2_CFG_INT_TX_SHIFT             2
    #define USB_EP2_CFG_INT_TX_MASK              0x1

    #define USB_EP2_CFG_STALL_EP                 1
    #define USB_EP2_CFG_STALL_EP_SHIFT           1
    #define USB_EP2_CFG_STALL_EP_MASK            0x1

    #define USB_EP2_CFG_ISO                      0
    #define USB_EP2_CFG_ISO_SHIFT                0
    #define USB_EP2_CFG_ISO_MASK                 0x1

#define USB_EP2_TX_CTRL   0x38
    #define USB_EP2_TX_CTRL_TX_FLUSH             17
    #define USB_EP2_TX_CTRL_TX_FLUSH_SHIFT       17
    #define USB_EP2_TX_CTRL_TX_FLUSH_MASK        0x1

    #define USB_EP2_TX_CTRL_TX_START             16
    #define USB_EP2_TX_CTRL_TX_START_SHIFT       16
    #define USB_EP2_TX_CTRL_TX_START_MASK        0x1

    #define USB_EP2_TX_CTRL_TX_LEN_SHIFT         0
    #define USB_EP2_TX_CTRL_TX_LEN_MASK          0x7ff

#define USB_EP2_RX_CTRL   0x3c
    #define USB_EP2_RX_CTRL_RX_FLUSH             1
    #define USB_EP2_RX_CTRL_RX_FLUSH_SHIFT       1
    #define USB_EP2_RX_CTRL_RX_FLUSH_MASK        0x1

    #define USB_EP2_RX_CTRL_RX_ACCEPT            0
    #define USB_EP2_RX_CTRL_RX_ACCEPT_SHIFT      0
    #define USB_EP2_RX_CTRL_RX_ACCEPT_MASK       0x1

#define USB_EP2_STS       0x40
    #define USB_EP2_STS_TX_ERR                   20
    #define USB_EP2_STS_TX_ERR_SHIFT             20
    #define USB_EP2_STS_TX_ERR_MASK              0x1

    #define USB_EP2_STS_TX_BUSY                  19
    #define USB_EP2_STS_TX_BUSY_SHIFT            19
    #define USB_EP2_STS_TX_BUSY_MASK             0x1

    #define USB_EP2_STS_RX_ERR                   18
    #define USB_EP2_STS_RX_ERR_SHIFT             18
    #define USB_EP2_STS_RX_ERR_MASK              0x1

    #define USB_EP2_STS_RX_SETUP                 17
    #define USB_EP2_STS_RX_SETUP_SHIFT           17
    #define USB_EP2_STS_RX_SETUP_MASK            0x1

    #define USB_EP2_STS_RX_READY                 16
    #define USB_EP2_STS_RX_READY_SHIFT           16
    #define USB_EP2_STS_RX_READY_MASK            0x1

    #define USB_EP2_STS_RX_COUNT_SHIFT           0
    #define USB_EP2_STS_RX_COUNT_MASK            0x7ff

#define USB_EP2_DATA      0x44
    #define USB_EP2_DATA_DATA_SHIFT              0
    #define USB_EP2_DATA_DATA_MASK               0xff

#define USB_EP3_CFG       0x48
    #define USB_EP3_CFG_INT_RX                   3
    #define USB_EP3_CFG_INT_RX_SHIFT             3
    #define USB_EP3_CFG_INT_RX_MASK              0x1

    #define USB_EP3_CFG_INT_TX                   2
    #define USB_EP3_CFG_INT_TX_SHIFT             2
    #define USB_EP3_CFG_INT_TX_MASK              0x1

    #define USB_EP3_CFG_STALL_EP                 1
    #define USB_EP3_CFG_STALL_EP_SHIFT           1
    #define USB_EP3_CFG_STALL_EP_MASK            0x1

    #define USB_EP3_CFG_ISO                      0
    #define USB_EP3_CFG_ISO_SHIFT                0
    #define USB_EP3_CFG_ISO_MASK                 0x1

#define USB_EP3_TX_CTRL   0x4c
    #define USB_EP3_TX_CTRL_TX_FLUSH             17
    #define USB_EP3_TX_CTRL_TX_FLUSH_SHIFT       17
    #define USB_EP3_TX_CTRL_TX_FLUSH_MASK        0x1

    #define USB_EP3_TX_CTRL_TX_START             16
    #define USB_EP3_TX_CTRL_TX_START_SHIFT       16
    #define USB_EP3_TX_CTRL_TX_START_MASK        0x1

    #define USB_EP3_TX_CTRL_TX_LEN_SHIFT         0
    #define USB_EP3_TX_CTRL_TX_LEN_MASK          0x7ff

#define USB_EP3_RX_CTRL   0x50
    #define USB_EP3_RX_CTRL_RX_FLUSH             1
    #define USB_EP3_RX_CTRL_RX_FLUSH_SHIFT       1
    #define USB_EP3_RX_CTRL_RX_FLUSH_MASK        0x1

    #define USB_EP3_RX_CTRL_RX_ACCEPT            0
    #define USB_EP3_RX_CTRL_RX_ACCEPT_SHIFT      0
    #define USB_EP3_RX_CTRL_RX_ACCEPT_MASK       0x1

#define USB_EP3_STS       0x54
    #define USB_EP3_STS_TX_ERR                   20
    #define USB_EP3_STS_TX_ERR_SHIFT             20
    #define USB_EP3_STS_TX_ERR_MASK              0x1

    #define USB_EP3_STS_TX_BUSY                  19
    #define USB_EP3_STS_TX_BUSY_SHIFT            19
    #define USB_EP3_STS_TX_BUSY_MASK             0x1

    #define USB_EP3_STS_RX_ERR                   18
    #define USB_EP3_STS_RX_ERR_SHIFT             18
    #define USB_EP3_STS_RX_ERR_MASK              0x1

    #define USB_EP3_STS_RX_SETUP                 17
    #define USB_EP3_STS_RX_SETUP_SHIFT           17
    #define USB_EP3_STS_RX_SETUP_MASK            0x1

    #define USB_EP3_STS_RX_READY                 16
    #define USB_EP3_STS_RX_READY_SHIFT           16
    #define USB_EP3_STS_RX_READY_MASK            0x1

    #define USB_EP3_STS_RX_COUNT_SHIFT           0
    #define USB_EP3_STS_RX_COUNT_MASK            0x7ff

#define USB_EP3_DATA      0x58
    #define USB_EP3_DATA_DATA_SHIFT              0
    #define USB_EP3_DATA_DATA_MASK               0xff

//-----------------------------------------------------------------
// Defines:
//-----------------------------------------------------------------
#define EP_STRIDE           0x14

#define USB_FUNC_CTRL_MODE_MASK   (0xFF << USB_FUNC_CTRL_PHY_OPMODE_SHIFT)

#define USB_FUNC_CTRL_MODE_HS    ((0 << USB_FUNC_CTRL_PHY_OPMODE_SHIFT) | \
                                 (0 << USB_FUNC_CTRL_PHY_XCVRSELECT_SHIFT) | \
                                 (0 << USB_FUNC_CTRL_PHY_TERMSELECT_SHIFT) | \
                                 (0 << USB_FUNC_CTRL_PHY_DPPULLDOWN_SHIFT) | \
                                 (0 << USB_FUNC_CTRL_PHY_DMPULLDOWN_SHIFT) | \
                                 (0 << USB_FUNC_CTRL_HS_CHIRP_EN_SHIFT))
#define USB_FUNC_CTRL_MODE_PERIP_CHIRP ((2 << USB_FUNC_CTRL_PHY_OPMODE_SHIFT) | \
                                 (0 << USB_FUNC_CTRL_PHY_XCVRSELECT_SHIFT) | \
                                 (1 << USB_FUNC_CTRL_PHY_TERMSELECT_SHIFT) | \
                                 (0 << USB_FUNC_CTRL_PHY_DPPULLDOWN_SHIFT) | \
                                 (0 << USB_FUNC_CTRL_PHY_DMPULLDOWN_SHIFT) | \
                                 (1 << USB_FUNC_CTRL_HS_CHIRP_EN_SHIFT))
#define USB_FUNC_CTRL_MODE_HOST_CHIRP ((2 << USB_FUNC_CTRL_PHY_OPMODE_SHIFT) | \
                                 (0 << USB_FUNC_CTRL_PHY_XCVRSELECT_SHIFT) | \
                                 (1 << USB_FUNC_CTRL_PHY_TERMSELECT_SHIFT) | \
                                 (0 << USB_FUNC_CTRL_PHY_DPPULLDOWN_SHIFT) | \
                                 (0 << USB_FUNC_CTRL_PHY_DMPULLDOWN_SHIFT) | \
                                 (0 << USB_FUNC_CTRL_HS_CHIRP_EN_SHIFT))
#define USB_FUNC_CTRL_PULLUP_EN ((0 << USB_FUNC_CTRL_PHY_OPMODE_SHIFT) | \
                                 (1 << USB_FUNC_CTRL_PHY_XCVRSELECT_SHIFT) | \
                                 (1 << USB_FUNC_CTRL_PHY_TERMSELECT_SHIFT) | \
                                 (0 << USB_FUNC_CTRL_PHY_DPPULLDOWN_SHIFT) | \
                                 (0 << USB_FUNC_CTRL_PHY_DMPULLDOWN_SHIFT))
#define USB_FUNC_CTRL_PULLUP_DIS ((1 << USB_FUNC_CTRL_PHY_OPMODE_SHIFT) | \
                                 (0 << USB_FUNC_CTRL_PHY_XCVRSELECT_SHIFT) | \
                                 (0 << USB_FUNC_CTRL_PHY_TERMSELECT_SHIFT) | \
                                 (0 << USB_FUNC_CTRL_PHY_DPPULLDOWN_SHIFT) | \
                                 (0 << USB_FUNC_CTRL_PHY_DMPULLDOWN_SHIFT))

#define USB_FUNC_ENDPOINTS      4

#define MIN(a,b)                ((a)<=(b)?(a):(b))

//-----------------------------------------------------------------
// Locals:
//-----------------------------------------------------------------
static unsigned int _tx_count[USB_FUNC_ENDPOINTS];
static int _addressed;
static int _configured;
static int _attached;
static int _endpoint_stalled[USB_FUNC_ENDPOINTS];
static FUNC_PTR _func_bus_reset;
static FUNC_PTR _func_setup;
static FUNC_PTR _func_ctrl_out;
static unsigned int _ctrl_reg;
static unsigned int _usb_base;

//-----------------------------------------------------------------
// usbhw_reg_write:
//-----------------------------------------------------------------
static void usbhw_reg_write(unsigned int addr, unsigned data)
{
    *((volatile unsigned int*)(_usb_base + addr)) = data;
}
//-----------------------------------------------------------------
// usbhw_reg_read:
//-----------------------------------------------------------------
static unsigned int usbhw_reg_read(unsigned int addr)
{
    return *((volatile unsigned int*)(_usb_base + addr));
}
//-----------------------------------------------------------------
// usbhw_init:
//-----------------------------------------------------------------
void usbhw_init(unsigned int base, FUNC_PTR bus_reset, FUNC_PTR on_setup, FUNC_PTR on_out)
{
    int i;

    _usb_base = base;

    log_printf(USBLOG_HW_RESET, "Init\n");

    for (i=0;i<USB_FUNC_ENDPOINTS;i++)
    {
        _tx_count[i] = 0;
        _endpoint_stalled[i] = 0;
    }
    
    _addressed  = 0;
    _configured = 0;
    _attached   = 0;

    _ctrl_reg = USB_FUNC_CTRL_PULLUP_DIS;

    _func_bus_reset = bus_reset;
    _func_setup = on_setup;
    _func_ctrl_out = on_out;

    usbhw_reg_write(USB_EP0_TX_CTRL, (1 << USB_EP0_TX_CTRL_TX_FLUSH_SHIFT));
    usbhw_reg_write(USB_EP1_TX_CTRL, (1 << USB_EP1_TX_CTRL_TX_FLUSH_SHIFT));
    usbhw_reg_write(USB_EP2_TX_CTRL, (1 << USB_EP2_TX_CTRL_TX_FLUSH_SHIFT));
    usbhw_reg_write(USB_EP3_TX_CTRL, (1 << USB_EP3_TX_CTRL_TX_FLUSH_SHIFT));

    usbhw_reg_write(USB_EP0_RX_CTRL, (1 << USB_EP0_RX_CTRL_RX_FLUSH_SHIFT));
    usbhw_reg_write(USB_EP1_RX_CTRL, (1 << USB_EP1_RX_CTRL_RX_FLUSH_SHIFT));
    usbhw_reg_write(USB_EP2_RX_CTRL, (1 << USB_EP2_RX_CTRL_RX_FLUSH_SHIFT));
    usbhw_reg_write(USB_EP3_RX_CTRL, (1 << USB_EP3_RX_CTRL_RX_FLUSH_SHIFT));
}
//-----------------------------------------------------------------
// usbhw_service:
//-----------------------------------------------------------------
void usbhw_service(void)
{
    unsigned int status = usbhw_reg_read(USB_FUNC_STAT);
    static int _initial  = 1;
    static int _reset_count = 0;
    int i;

    // Acknowledge fake USB reset after attach..
    if (_initial)
    {
        usbhw_reg_write(USB_FUNC_CTRL, _ctrl_reg);
        
        _initial = 0;
        return ; 
    }

#ifdef USB_SPEED_HS
    // Bus reset event
    if (status & (1 << USB_FUNC_STAT_RST))
    {
        // Ack bus reset by writing to CTRL register
        usbhw_reg_write(USB_FUNC_STAT, (1 << USB_FUNC_STAT_RST));

        usbhw_reg_write(USB_EP0_TX_CTRL, (1 << USB_EP0_TX_CTRL_TX_FLUSH_SHIFT));
        usbhw_reg_write(USB_EP0_RX_CTRL, (1 << USB_EP0_RX_CTRL_RX_FLUSH_SHIFT));

        usbhw_reg_write(USB_EP1_TX_CTRL, (1 << USB_EP1_TX_CTRL_TX_FLUSH_SHIFT));
        usbhw_reg_write(USB_EP2_TX_CTRL, (1 << USB_EP2_TX_CTRL_TX_FLUSH_SHIFT));
        usbhw_reg_write(USB_EP3_TX_CTRL, (1 << USB_EP3_TX_CTRL_TX_FLUSH_SHIFT));
        usbhw_reg_write(USB_EP1_RX_CTRL, (1 << USB_EP1_RX_CTRL_RX_FLUSH_SHIFT));
        usbhw_reg_write(USB_EP2_RX_CTRL, (1 << USB_EP2_RX_CTRL_RX_FLUSH_SHIFT));
        usbhw_reg_write(USB_EP3_RX_CTRL, (1 << USB_EP3_RX_CTRL_RX_FLUSH_SHIFT));        

        // Fail ... 
        if (_reset_count > 4)
        {
            log_printf(USBLOG_HW_RESET, " DEVICE: Another Reset Detected %d\n", timer_now());

            // Force detach
            usbhw_attach(0);
            timer_sleep(100);
            usbhw_attach(1);

            _reset_count = 0;
            return ;
        }

        _configured = 0;
        _addressed  = 0;

        for (i=0;i<USB_FUNC_ENDPOINTS;i++)
        {
            _tx_count[i] = 0;
            _endpoint_stalled[i] = 0;
        }

        log_printf(USBLOG_HW_RESET, " DEVICE: Reset Detected %d\n", timer_now());

        // Detected SE0 for at least 2.5us, now drive HS CHIRP for at least 1ms
        usbhw_reg_write(USB_FUNC_CTRL, USB_FUNC_CTRL_MODE_PERIP_CHIRP);
        timer_sleep(3);

        // Stop driving the chirp pattern
        log_printf(USBLOG_HW_RESET, " DEVICE: Peripheral Chirp De-assert %d\n", timer_now());
        usbhw_reg_write(USB_FUNC_CTRL, USB_FUNC_CTRL_MODE_HOST_CHIRP);

        int chirps = 0;
        while (chirps < 5)
        {
            static unsigned old_ls = ~0;
            unsigned new_ls = (usbhw_reg_read(USB_FUNC_STAT) >> USB_FUNC_STAT_LINESTATE_SHIFT) & 0x3;
            if ((old_ls != new_ls) && (new_ls == 1 || new_ls == 2))
                chirps++;
            old_ls = new_ls;
        }        

        log_printf(USBLOG_HW_RESET, " DEVICE: Host Chirp Detected %d\n", timer_now());
        usbhw_reg_write(USB_FUNC_CTRL, USB_FUNC_CTRL_MODE_HS);


        log_printf(USBLOG_HW_RESET, " DEVICE: BUS RESET %d\n", timer_now());


        if (_func_bus_reset)
            _func_bus_reset();

        // Ack bus reset by writing to CTRL register
        usbhw_reg_write(USB_FUNC_STAT, (1 << USB_FUNC_STAT_RST));
        _reset_count += 1;
    }
#else
    // Bus reset event
    if (status & (1 << USB_FUNC_STAT_RST))
    {
        // Ack bus reset by writing to CTRL register
        usbhw_reg_write(USB_FUNC_STAT, (1 << USB_FUNC_STAT_RST));

        _configured = 0;
        _addressed  = 0;

        for (i=0;i<USB_FUNC_ENDPOINTS;i++)
        {
            _tx_count[i] = 0;
            _endpoint_stalled[i] = 0;
        }

        log_printf(USBLOG_HW_RESET, " DEVICE: BUS RESET %d\n", timer_now());

        usbhw_reg_write(USB_EP0_TX_CTRL, (1 << USB_EP0_TX_CTRL_TX_FLUSH_SHIFT));
        usbhw_reg_write(USB_EP1_TX_CTRL, (1 << USB_EP1_TX_CTRL_TX_FLUSH_SHIFT));
        usbhw_reg_write(USB_EP2_TX_CTRL, (1 << USB_EP2_TX_CTRL_TX_FLUSH_SHIFT));
        usbhw_reg_write(USB_EP3_TX_CTRL, (1 << USB_EP3_TX_CTRL_TX_FLUSH_SHIFT));

        usbhw_reg_write(USB_EP0_RX_CTRL, (1 << USB_EP0_RX_CTRL_RX_FLUSH_SHIFT));
        usbhw_reg_write(USB_EP1_RX_CTRL, (1 << USB_EP1_RX_CTRL_RX_FLUSH_SHIFT));
        usbhw_reg_write(USB_EP2_RX_CTRL, (1 << USB_EP2_RX_CTRL_RX_FLUSH_SHIFT));
        usbhw_reg_write(USB_EP3_RX_CTRL, (1 << USB_EP3_RX_CTRL_RX_FLUSH_SHIFT));

        if (_func_bus_reset)
            _func_bus_reset();
    }
#endif

    status = usbhw_reg_read(USB_EP0_STS);

    // Tx underflow error 
    if (status & (1 << USB_EP0_STS_TX_ERR))
    {
        log_printf(USBLOG_ERR, "Tx underflow error!\n");
        while (1) 
            ;
    }
    // CRC error 
    else if (status & (1 << USB_EP0_STS_RX_ERR))
    {
        log_printf(USBLOG_ERR, "Rx CRC error!\n");
        while (1)
            ;
    }    
    // SETUP packet received (EP0)
    else if ((status & (1 << USB_EP0_STS_RX_READY)) && (status & (1 << USB_EP0_STS_RX_SETUP)))
    {
        log_printf(USBLOG_HW_CTRL, "SETUP packet received\n");

        if (_func_setup)
            _func_setup();

        log_printf(USBLOG_HW_CTRL, "SETUP packet processed\n");
    }
    // OUT data received on EP0
    else if (status & (1 << USB_EP0_STS_RX_READY))
    {
        log_printf(USBLOG_HW_CTRL, "OUT packet received on EP0\n");

        if (_func_ctrl_out)
            _func_ctrl_out();
    }
}
//-----------------------------------------------------------------
// usbhw_attach:
//-----------------------------------------------------------------
void usbhw_attach(int state)
{
    // Pull up D+ to Vdd
    if ( state )
    {
        _attached = 1;
        _ctrl_reg &= ~USB_FUNC_CTRL_MODE_MASK;
        _ctrl_reg |= USB_FUNC_CTRL_PULLUP_EN;
        usbhw_reg_write(USB_FUNC_CTRL, _ctrl_reg);
        log_printf(USBLOG_HW_CTRL, "ATTACH\n");

        // Reset any previous reset detection
        usbhw_reg_write(USB_FUNC_STAT, (1 << USB_FUNC_STAT_RST));
    }
    // Disconnect pull-up to disconnect from bus
    else
    {
        _attached = 0;
        _ctrl_reg &= ~USB_FUNC_CTRL_MODE_MASK;
        _ctrl_reg |= USB_FUNC_CTRL_PULLUP_DIS;
        usbhw_reg_write(USB_FUNC_CTRL, _ctrl_reg);
        log_printf(USBLOG_HW_CTRL, "DETACH\n");          
    }
}
//-----------------------------------------------------------------
// usbhw_is_configured:
//-----------------------------------------------------------------
int usbhw_is_configured(void)
{
    return _configured;
}
//-----------------------------------------------------------------
// usbhw_is_addressed:
//-----------------------------------------------------------------
int usbhw_is_addressed(void)
{
    return _addressed;
}
//-----------------------------------------------------------------
// usbhw_is_attached:
//-----------------------------------------------------------------
int usbhw_is_attached(void)
{
    return _attached;
}
//-----------------------------------------------------------------
// usbhw_set_configured:
//-----------------------------------------------------------------
void usbhw_set_configured(int configured)
{
    _configured = configured;
}
//-----------------------------------------------------------------
// usbhw_set_address:
//-----------------------------------------------------------------
void usbhw_set_address(unsigned char addr)
{    
    usbhw_reg_write(USB_FUNC_ADDR, addr);
    _addressed = 1;
}
//-----------------------------------------------------------------
// usbhw_is_endpoint_stalled:
//-----------------------------------------------------------------
int usbhw_is_endpoint_stalled(unsigned char endpoint)
{
    return _endpoint_stalled[endpoint];
}
//-----------------------------------------------------------------
// usbhw_clear_endpoint_stall:
//-----------------------------------------------------------------
void usbhw_clear_endpoint_stall(unsigned char endpoint)
{
    unsigned int data = usbhw_reg_read(USB_EP0_CFG + (endpoint * EP_STRIDE));
    data &= ~(1 << USB_EP0_CFG_STALL_EP);
    usbhw_reg_write(USB_EP0_CFG + (endpoint * EP_STRIDE), data);

    _endpoint_stalled[endpoint] = 0;
}
//-----------------------------------------------------------------
// usbhw_set_endpoint_stall:
//-----------------------------------------------------------------
void usbhw_set_endpoint_stall(unsigned char endpoint)
{
    unsigned int data = usbhw_reg_read(USB_EP0_CFG + (endpoint * EP_STRIDE));
    data |= (1 << USB_EP0_CFG_STALL_EP);
    usbhw_reg_write(USB_EP0_CFG + (endpoint * EP_STRIDE), data);

    _endpoint_stalled[endpoint] = 1;
}
//-----------------------------------------------------------------
// usbhw_is_rx_ready: Is some receive data ready on an endpoint?
//-----------------------------------------------------------------
int usbhw_is_rx_ready(unsigned char endpoint)
{
    return (usbhw_reg_read(USB_EP0_STS + (endpoint * EP_STRIDE)) & (1 << USB_EP0_STS_RX_READY_SHIFT)) ? 1 : 0;
}
//-----------------------------------------------------------------
// usbhw_get_rx_count: Get amount of data waiting in endpoint
//-----------------------------------------------------------------
int usbhw_get_rx_count(unsigned char endpoint)
{
    return (usbhw_reg_read(USB_EP0_STS + (endpoint * EP_STRIDE)) >> USB_EP0_STS_RX_COUNT_SHIFT) & USB_EP0_STS_RX_COUNT_MASK;
}
//-----------------------------------------------------------------
// usbhw_get_rx_data: Read data from endpoint
//-----------------------------------------------------------------
int usbhw_get_rx_data(unsigned char endpoint, unsigned char *data, int max_len)
{
    int i;
    int bytes_ready;
    int bytes_read = 0;

    // Received data count includes CRC
    bytes_ready = usbhw_get_rx_count(endpoint);

    // Limit data read to buffer size
    bytes_read = MIN(bytes_ready, max_len);

    for (i=0;i<bytes_read;i++)
        *data++ = usbhw_reg_read(USB_EP0_DATA + (endpoint * EP_STRIDE));

    // Return number of bytes read
    return bytes_read;
}
//-----------------------------------------------------------------
// usbhw_get_rx_byte: Read byte from endpoint
//-----------------------------------------------------------------
unsigned char usbhw_get_rx_byte(unsigned char endpoint)
{
    return usbhw_reg_read(USB_EP0_DATA + (endpoint * EP_STRIDE));
}
//-----------------------------------------------------------------
// usbhw_clear_rx_ready: Clear Rx data ready flag
//-----------------------------------------------------------------
void usbhw_clear_rx_ready(unsigned char endpoint)
{
    log_printf(USBLOG_HW_DATA, "Clear endpoint buffer\n");
    usbhw_reg_write(USB_EP0_RX_CTRL + (endpoint * EP_STRIDE), 1 << USB_EP1_RX_CTRL_RX_ACCEPT_SHIFT);
}
//-----------------------------------------------------------------
// usbhw_has_tx_space: Is there space in the tx buffer
//-----------------------------------------------------------------
int usbhw_has_tx_space(unsigned char endpoint)
{
    return (usbhw_reg_read(USB_EP0_STS + (endpoint * EP_STRIDE)) & (1 << USB_EP1_STS_TX_BUSY_SHIFT)) ? 0 : 1;
}
//-----------------------------------------------------------------
// usbhw_load_tx_buffer: Load tx buffer & start transfer (non-blocking) 
//-----------------------------------------------------------------
int usbhw_load_tx_buffer(unsigned char endpoint, unsigned char *data, int count)
{
    int i;
    unsigned int word_data = 0;

    for (i=0;i<count;i++)
        usbhw_reg_write(USB_EP0_DATA + (endpoint * EP_STRIDE), *data++);

    // Start transmit
    word_data = (1 << USB_EP0_TX_CTRL_TX_START_SHIFT) | count;
    usbhw_reg_write(USB_EP0_TX_CTRL + (endpoint * EP_STRIDE), word_data);

    log_printf(USBLOG_HW_DATA, "Tx %d bytes\n", count);

    return count;
}
//-----------------------------------------------------------------
// usbhw_write_tx_byte: Write a byte to Tx buffer (don't send yet)
//-----------------------------------------------------------------
void usbhw_write_tx_byte(unsigned char endpoint, unsigned char data)
{
    usbhw_reg_write(USB_EP0_DATA + (endpoint * EP_STRIDE), data);
    _tx_count[endpoint]++;
}
//-----------------------------------------------------------------
// usbhw_start_tx: Start a tx packet with data loaded into endpoint
//-----------------------------------------------------------------
void usbhw_start_tx(unsigned char endpoint)
{
    // Start transmit
    unsigned int word_data = (1 << USB_EP0_TX_CTRL_TX_START_SHIFT) | _tx_count[endpoint];
    usbhw_reg_write(USB_EP0_TX_CTRL + (endpoint * EP_STRIDE), word_data);

    log_printf(USBLOG_HW_DATA, "Tx %d bytes\n", _tx_count[endpoint]);

    _tx_count[endpoint] = 0;  
}
//-----------------------------------------------------------------
// usbhw_control_endpoint_stall:
//-----------------------------------------------------------------
void usbhw_control_endpoint_stall(void)
{
    log_printf(USBLOG_ERR, "Error, send EP stall!\n");
    usbhw_set_endpoint_stall(0);

    // Control endpoint stalls are self clearing
    _endpoint_stalled[0] = 0;
}
//-----------------------------------------------------------------
// usbhw_control_endpoint_ack:
//-----------------------------------------------------------------
void usbhw_control_endpoint_ack(void)
{
    // Send ZLP on EP0
    log_printf(USBLOG_HW_DATA, "Send ZLP\n");
    usbhw_reg_write(USB_EP0_TX_CTRL, (1 << USB_EP0_TX_CTRL_TX_START_SHIFT));

    log_printf(USBLOG_HW_DATA, "Tx [ZLP/ACK]\n");

    while (!usbhw_has_tx_space(0))
        ;

    log_printf(USBLOG_HW_DATA, "Tx complete\n");
}
//-----------------------------------------------------------------
// usbhw_get_frame_number:
//-----------------------------------------------------------------
unsigned short usbhw_get_frame_number(void)
{
    return (usbhw_reg_read(USB_FUNC_STAT) >> USB_FUNC_STAT_FRAME_SHIFT) & USB_FUNC_STAT_FRAME_MASK;
}

//-----------------------------------------------------------------
// usbhw_timer_now:
//-----------------------------------------------------------------
t_time usbhw_timer_now(void)
{
    return timer_now();
}