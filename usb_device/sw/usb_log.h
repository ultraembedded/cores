#ifndef __USB_LOG_H__
#define __USB_LOG_H__

//-----------------------------------------------------------------
// Defines:
//-----------------------------------------------------------------
#define USBLOG_HW_RESET         1
#define USBLOG_HW_CTRL          7
#define USBLOG_HW_DATA          9
#define USBLOG_CONTROL          9
#define USBLOG_SETUP_DATA       9
#define USBLOG_SETUP            8
#define USBLOG_SETUP_OUT        8
#define USBLOG_SETUP_IN         8
#define USBLOG_SETUP_IN_DBG     11
#define USBLOG_DESC             7
#define USBLOG_DESC_WARN        1
#define USBLOG_INFO             8
#define USBLOG_ERR              0
#define USBLOG_CDC_INFO         7
#define USBLOG_DFU_INFO         7

//-----------------------------------------------------------------
// Prototypes
//-----------------------------------------------------------------
#ifdef HAS_USB_DEVICE_LOG
extern int  log_printf(int level, const char* ctrl1, ... );
#else
static int  log_printf(int level, const char* ctrl1, ... ) { return 0; }
#endif

#endif
