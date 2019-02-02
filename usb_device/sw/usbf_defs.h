#ifndef __USBF_DEFS_H__
#define __USBF_DEFS_H__

//-----------------------------------------------------------------
// Macros:
//-----------------------------------------------------------------
// For Little Endian CPUs
#define USB_BYTE_SWAP16(n)          (n)
// For Big Endian CPUs
//#define USB_BYTE_SWAP16(n)        ((((unsigned short)((n) & 0xff)) << 8) | (((n) & 0xff00) >> 8))

#define LO_BYTE(w)                  ((unsigned char)(w))
#define HI_BYTE(w)                  ((unsigned char)(((unsigned short)(w) >> 8) & 0xFF))

#define MIN(a,b)                    ((a)<=(b)?(a):(b))

//-----------------------------------------------------------------
// Defines:
//-----------------------------------------------------------------

// Device class
#define DEV_CLASS_RESERVED      0x00
#define DEV_CLASS_AUDIO         0x01
#define DEV_CLASS_COMMS         0x02
#define DEV_CLASS_HID           0x03
#define DEV_CLASS_MONITOR       0x04
#define DEV_CLASS_PHY_IF        0x05
#define DEV_CLASS_POWER         0x06
#define DEV_CLASS_PRINTER       0x07
#define DEV_CLASS_STORAGE       0x08
#define DEV_CLASS_HUB           0x09
#define DEV_CLASS_TMC           0xFE
#define DEV_CLASS_VENDOR_CUSTOM 0xFF

// Standard requests (via SETUP packets)
#define REQ_GET_STATUS        0x00
#define REQ_CLEAR_FEATURE     0x01
#define REQ_SET_FEATURE       0x03
#define REQ_SET_ADDRESS       0x05
#define REQ_GET_DESCRIPTOR    0x06
#define REQ_SET_DESCRIPTOR    0x07
#define REQ_GET_CONFIGURATION 0x08
#define REQ_SET_CONFIGURATION 0x09
#define REQ_GET_INTERFACE     0x0A
#define REQ_SET_INTERFACE     0x0B
#define REQ_SYNC_FRAME        0x0C

// Descriptor types
#define DESC_DEVICE             0x01
#define DESC_CONFIGURATION      0x02
#define DESC_STRING             0x03
#define DESC_INTERFACE          0x04
#define DESC_ENDPOINT           0x05
#define DESC_DEV_QUALIFIER      0x06
#define DESC_OTHER_SPEED_CONF   0x07
#define DESC_IF_POWER           0x08

// Endpoints
#define ENDPOINT_DIR_MASK       (1 << 7)
#define ENDPOINT_DIR_IN         (1 << 7)
#define ENDPOINT_DIR_OUT        (0 << 7)
#define ENDPOINT_ADDR_MASK      (0x7F)
#define ENDPOINT_TYPE_MASK      (0x3)
#define ENDPOINT_TYPE_CONTROL   (0)
#define ENDPOINT_TYPE_ISO       (1)
#define ENDPOINT_TYPE_BULK      (2)
#define ENDPOINT_TYPE_INTERRUPT (3)

// Device Requests (bmRequestType)
#define USB_RECIPIENT_MASK       0x1F
#define USB_RECIPIENT_DEVICE     0x00
#define USB_RECIPIENT_INTERFACE  0x01
#define USB_RECIPIENT_ENDPOINT   0x02
#define USB_REQUEST_TYPE_MASK    0x60
#define USB_STANDARD_REQUEST     0x00
#define USB_CLASS_REQUEST        0x20
#define USB_VENDOR_REQUEST       0x40

// USB device addresses are 7-bits
#define USB_ADDRESS_MASK        0x7F

// USB Feature Selectors
#define USB_FEATURE_ENDPOINT_STATE      0x0000
#define USB_FEATURE_REMOTE_WAKEUP       0x0001
#define USB_FEATURE_TEST_MODE           0x0002

#endif
