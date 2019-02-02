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
#include "usb_cdc.h"
#include "usb_log.h"
#include "usb_device.h"
#include "usbf_hw.h"

//-----------------------------------------------------------------
// Locals:
//-----------------------------------------------------------------
static unsigned char _line_coding[7];

//-----------------------------------------------------------------
// cdc_set_line_coding:
//-----------------------------------------------------------------
static void cdc_set_line_coding(unsigned char *data)
{
	int i;

	for (i=0; i<7; i++)
		_line_coding[i] = data[i];

    log_printf(USBLOG_CDC_INFO, "CDC: Set Line Coding\n");
}
//-----------------------------------------------------------------
// cdc_get_line_coding:
//-----------------------------------------------------------------
static void cdc_get_line_coding(unsigned short wLength)
{
    log_printf(USBLOG_CDC_INFO, "CDC: Get Line Coding\n");

	usb_control_send( _line_coding, sizeof(_line_coding), wLength );	
}
//-----------------------------------------------------------------
// cdc_set_control_line_state:
//-----------------------------------------------------------------
static void cdc_set_control_line_state(void)
{
    log_printf(USBLOG_CDC_INFO, "CDC: Set Control Line State\n");
	usbhw_control_endpoint_ack();
}
//-----------------------------------------------------------------
// cdc_send_break:
//-----------------------------------------------------------------
static void cdc_send_break(void)
{
    log_printf(USBLOG_CDC_INFO, "CDC: Send Break\n");
	usbhw_control_endpoint_ack();
}
//-----------------------------------------------------------------
// cdc_send_encapsulated_command:
//-----------------------------------------------------------------
static void cdc_send_encapsulated_command (void)
{
    log_printf(USBLOG_CDC_INFO, "CDC: Send encap\n");
}
//-----------------------------------------------------------------
// cdc_get_encapsulated_response:
//-----------------------------------------------------------------
static void cdc_get_encapsulated_response (unsigned short wLength)
{
    log_printf(USBLOG_CDC_INFO, "CDC: Get encap\n");

	usbhw_control_endpoint_stall();
}
//-----------------------------------------------------------------
// usb_cdc_process_request:
//-----------------------------------------------------------------
void usb_cdc_process_request(unsigned char req, unsigned short wValue, unsigned short WIndex, unsigned char *data, unsigned short wLength)
{
	switch ( req )
	{
	case CDC_SEND_ENCAPSULATED_COMMAND:
        log_printf(USBLOG_CDC_INFO, "CDC: Send encap\n");
	    cdc_send_encapsulated_command();
	    break;
	case CDC_GET_ENCAPSULATED_RESPONSE:
        log_printf(USBLOG_CDC_INFO, "CDC: Get encap\n");
	    cdc_get_encapsulated_response(wLength);
	    break;
	case CDC_SET_LINE_CODING:
        log_printf(USBLOG_CDC_INFO, "CDC: Set line coding\n");
	    cdc_set_line_coding(data);
	    break;
	case CDC_GET_LINE_CODING:
        log_printf(USBLOG_CDC_INFO, "CDC: Get line coding\n");
	    cdc_get_line_coding(wLength);
	    break;
	case CDC_SET_CONTROL_LINE_STATE:
        log_printf(USBLOG_CDC_INFO, "CDC: Set line state\n");
	    cdc_set_control_line_state();
	    break;
	case CDC_SEND_BREAK:
        log_printf(USBLOG_CDC_INFO, "CDC: Send break\n");
	    cdc_send_break();
	    break;
	default:
        log_printf(USBLOG_CDC_INFO, "CDC: Unknown command\n");
		usbhw_control_endpoint_stall();
		break;
	}
}
//-----------------------------------------------------------------
// usb_cdc_init:
//-----------------------------------------------------------------
void usb_cdc_init(void)
{
	_line_coding[0] = 0x00;          // UART baud rate (32-bit word, LSB first)
	_line_coding[1] = 0xC2;
	_line_coding[2] = 0x01;
	_line_coding[3] = 0x00;
	_line_coding[4] = 0;             // stop bit #2
	_line_coding[5] = 0;             // parity
	_line_coding[6] = 8;             // data bits
}
