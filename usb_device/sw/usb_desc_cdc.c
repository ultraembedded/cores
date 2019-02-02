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
#include <string.h>
#include <stdlib.h>
#include "usbf_defs.h"
#include "usb_desc.h"
#include "usb_log.h"

//-----------------------------------------------------------------
// PID/VID:
//-----------------------------------------------------------------
#ifndef USB_DEV_VID
    #define USB_DEV_VID                     0x9234
#endif
#ifndef USB_DEV_PID
    #define USB_DEV_PID                     0x5678
#endif
#define USB_DEV_VER                         0x0101

//-----------------------------------------------------------------
// Defines:
//-----------------------------------------------------------------

// Descriptor defs
#define SIZE_OF_DEVICE_DESCR   18

#ifdef USB_SPEED_HS
    #define EP0_MAX_PACKET_SIZE    64
#else
    #define EP0_MAX_PACKET_SIZE    8
#endif

// Configuration descriptor
#define NB_INTERFACE           2
#define CONF_NB                1
#define CONF_INDEX             0
#define CONF_ATTRIBUTES        0x80      // Bit7 bus-powered Bit6 self-powered
#define MAX_POWER              50        // Bus current = 100 mA

// Interface 0 descriptor
#define INTERFACE0_ID          0
#define ALTERNATE0             0
#define NB_ENDPOINT0           1
#define INTERFACE0_CLASS       0x02
#define INTERFACE0_SUB_CLASS   0x02
#define INTERFACE0_PROTOCOL    0x01
#define INTERFACE0_INDEX       0

// Endpoint 3 descriptor (INTR-IN)
#define ENDPOINT_ID_3          0x83
#define EP_ATTRIBUTES_3        0x03
#ifdef USB_SPEED_HS
    #define EP_SIZE_3         64    // TODO: Should be 512 for HS???
#else
    #define EP_SIZE_3         64
#endif
#define EP_INTERVAL_3          2

// Interface 1 descriptor
#define INTERFACE1_ID          1
#define ALTERNATE1             0
#define NB_ENDPOINT1           2
#define INTERFACE1_CLASS       0x0A
#define INTERFACE1_SUB_CLASS   0
#define INTERFACE1_PROTOCOL    0
#define INTERFACE1_INDEX       0

// Endpoint 1 descriptor
#define ENDPOINT_ID_1         0x01
#define EP_ATTRIBUTES_1       0x02
#ifdef USB_SPEED_HS
    #define EP_SIZE_1         512
#else
    #define EP_SIZE_1         64
#endif
#define EP_INTERVAL_1         0x00

// Endpoint 2 descriptor
#define ENDPOINT_ID_2         0x82
#define EP_ATTRIBUTES_2       0x02
#ifdef USB_SPEED_HS
    #define EP_SIZE_2         512
#else
    #define EP_SIZE_2         64
#endif
#define EP_INTERVAL_2         0x00

// String Descriptors
#define UNICODE_LANGUAGE_STR_ID  0
#define MANUFACTURER_STR_ID      1
#define PRODUCT_NAME_STR_ID      2
#define SERIAL_NUM_STR_ID        3
#define UNICODE_ENGLISH          0x0409

//-----------------------------------------------------------------
// Descriptors:
//-----------------------------------------------------------------
static const unsigned char _device_desc[18] =
{
	SIZE_OF_DEVICE_DESCR,                   // Descriptor size (18)
	DESC_DEVICE,                            // Descriptor type
	LO_BYTE(0x0200),                        // bcdUSB = 02.00 (BCD word)
	HI_BYTE(0x0200),
	DEV_CLASS_COMMS,                        // Device class
	0x00,                                   // Device subclass
	0x00,                                   // Device protocol
	EP0_MAX_PACKET_SIZE,                    // Max packet size for EP0
	LO_BYTE(USB_DEV_VID),                   
	HI_BYTE(USB_DEV_VID),
	LO_BYTE(USB_DEV_PID),
	HI_BYTE(USB_DEV_PID),
	LO_BYTE(USB_DEV_VER),
	HI_BYTE(USB_DEV_VER),
	0, // MANUFACTURER_STR_ID,              // manufacturer string index
	0, // PRODUCT_NAME_STR_ID,              // product string index
	0, // SERIAL_NUM_STR_ID,                // serial number string index
	1                                       // number of configurations
};

static const unsigned char _config_desc[67] =
{
	/* Config. descriptor (short) */
    9, DESC_CONFIGURATION,
    LO_BYTE( sizeof(_config_desc) ), HI_BYTE( sizeof(_config_desc) ),
    NB_INTERFACE, CONF_NB, CONF_INDEX, CONF_ATTRIBUTES, MAX_POWER,

	/* Interface #0 descriptor */
    9, DESC_INTERFACE, INTERFACE0_ID, ALTERNATE0, NB_ENDPOINT0,
    INTERFACE0_CLASS, INTERFACE0_SUB_CLASS, INTERFACE0_PROTOCOL, INTERFACE0_INDEX,

	/* CDC-specific Functional Descriptors (type = 0x24) - Ref. USBCDC Spec. $5.2.3 */
    0x05, 0x24, 0x00, 0x10, 0x01,   // CDC-specific header
    0x05, 0x24, 0x01, 0x03, 0x01,   // Call Management descriptor
    0x04, 0x24, 0x02, 0x06,         // Abstract Control Management descriptor
    0x05, 0x24, 0x06, 0x00, 0x01,   // Union functional descriptor

	/* Endpoint descriptor #3 */
    7, DESC_ENDPOINT, ENDPOINT_ID_3, EP_ATTRIBUTES_3,
    LO_BYTE(EP_SIZE_3), HI_BYTE(EP_SIZE_3), EP_INTERVAL_3,

	/* Interface #1 descriptor */
    9, DESC_INTERFACE, INTERFACE1_ID, ALTERNATE1, NB_ENDPOINT1,
    INTERFACE1_CLASS, INTERFACE1_SUB_CLASS, INTERFACE1_PROTOCOL, INTERFACE1_INDEX,

	/* Endpoint descriptor #1 */
    7, DESC_ENDPOINT, ENDPOINT_ID_1, EP_ATTRIBUTES_1,
    LO_BYTE(EP_SIZE_1), HI_BYTE(EP_SIZE_1), EP_INTERVAL_1,

	/* Endpoint descriptor #2 */
    7, DESC_ENDPOINT, ENDPOINT_ID_2, EP_ATTRIBUTES_2,
    LO_BYTE(EP_SIZE_2), HI_BYTE(EP_SIZE_2), EP_INTERVAL_2
};

static const unsigned char _string_desc_lang[] =
{
	(4),    // Descriptor size
	DESC_STRING,
	LO_BYTE( UNICODE_ENGLISH ),
	HI_BYTE( UNICODE_ENGLISH ),
};

static const unsigned char _string_desc_man[] =
{
	(2 + 28),
	DESC_STRING,
	'U',0,'L',0,'T',0,'R',0,'A',0,'-',0,'E',0,'M',0,'B',0,'E',0,'D',0,'D',0,'E',0,'D',0
};

static const unsigned char _string_desc_prod[] =
{
	(2 + 28),
	DESC_STRING,
	'U',0,'S',0,'B',0,' ',0,'D',0,'E',0,'M',0,'O',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0
};

static const unsigned char _string_desc_serial[] =
{
	(2 + 12),
	DESC_STRING,
	'0',0,'0',0,'0',0,'0',0,'0',0,'0',0
};

//-----------------------------------------------------------------
// usb_get_descriptor:
//-----------------------------------------------------------------
unsigned char *usb_get_descriptor( unsigned char bDescriptorType, unsigned char bDescriptorIndex, unsigned short wLength, unsigned char *pSize )
{
	if ( bDescriptorType == DESC_DEVICE )
	{
		*pSize = MIN( wLength, SIZE_OF_DEVICE_DESCR );
        log_printf(USBLOG_DESC, "USB: Get device descriptor %d\n", *pSize);
		
        return (unsigned char *)_device_desc;
	}
	else if ( bDescriptorType == DESC_CONFIGURATION )
	{
		*pSize = MIN( sizeof(_config_desc), wLength );
        log_printf(USBLOG_DESC, "USB: Get conf descriptor %d\n", *pSize);

		return (unsigned char *)_config_desc;
	}
	else if ( bDescriptorType == DESC_STRING )
	{
        log_printf(USBLOG_DESC, "USB: Get string descriptor %x\n", bDescriptorIndex);

		switch( bDescriptorIndex )
		{
		case UNICODE_LANGUAGE_STR_ID:
			*pSize = MIN( sizeof(_string_desc_lang), wLength );
			return (unsigned char *)_string_desc_lang;

		case MANUFACTURER_STR_ID:
			*pSize = MIN( sizeof(_string_desc_man), wLength );
			return (unsigned char *)_string_desc_man;

		case PRODUCT_NAME_STR_ID:
			*pSize = MIN( sizeof(_string_desc_prod), wLength );
			return (unsigned char *)_string_desc_prod;

		case SERIAL_NUM_STR_ID:
			*pSize = MIN( sizeof(_string_desc_serial), wLength );
			return (unsigned char *)_string_desc_serial;

		default:
            log_printf(USBLOG_DESC_WARN, "USB: Unknown descriptor index %x, STALL\n", bDescriptorIndex);
			return NULL;
		}
	}
	else
    {
        log_printf(USBLOG_DESC_WARN, "USB: Unknown descriptor type %x, STALL\n", bDescriptorType);
        return NULL;
    }
}
//-----------------------------------------------------------------
// usb_is_bus_powered:
//-----------------------------------------------------------------
int usb_is_bus_powered(void)
{
    return (CONF_ATTRIBUTES & 0x80) ? 1 : 0;
}
