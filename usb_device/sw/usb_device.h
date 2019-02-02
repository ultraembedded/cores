#ifndef __USB_DEVICE_H__
#define __USB_DEVICE_H__

//-----------------------------------------------------------------
// Types
//-----------------------------------------------------------------
typedef void (*FP_CLASS_REQUEST)(unsigned char req, unsigned short wValue, unsigned short WIndex, unsigned char *data, unsigned short wLength);
typedef void (*FP_BUS_RESET)(void);

//-----------------------------------------------------------------
// Prototypes
//-----------------------------------------------------------------
#ifdef __cplusplus
extern "C" {
#endif

void usbf_init(unsigned int base, FP_BUS_RESET bus_reset, FP_CLASS_REQUEST class_request);
int  usb_control_send(unsigned char *buf, int size, int requested_size);

#ifdef __cplusplus
}
#endif

#endif
