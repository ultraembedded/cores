#ifndef  __USB_CDC_H__
#define  __USB_CDC_H__

//-----------------------------------------------------------------
// Defines:
//-----------------------------------------------------------------
#define CDC_ENDPOINT_BULK_OUT           1
#define CDC_ENDPOINT_BULK_IN            2
#define CDC_ENDPOINT_INTR_IN            3

#define CDC_SEND_ENCAPSULATED_COMMAND   0x00
#define CDC_GET_ENCAPSULATED_RESPONSE   0x01
#define CDC_GET_LINE_CODING             0x21
#define CDC_SET_LINE_CODING             0x20
#define CDC_SET_CONTROL_LINE_STATE      0x22
#define CDC_SEND_BREAK                  0x23

//-----------------------------------------------------------------
// Prototypes:
//-----------------------------------------------------------------
#ifdef __cplusplus
extern "C" {
#endif

void usb_cdc_init( void );
void usb_cdc_process_request(unsigned char req, unsigned short wValue, unsigned short WIndex, unsigned char *data, unsigned short wLength);

#ifdef __cplusplus
}
#endif

#endif
