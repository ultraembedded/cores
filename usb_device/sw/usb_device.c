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
#include "usb_device.h"
#include "usb_desc.h"
#include "usb_log.h"
#include "usbf_defs.h"
#include "usbf_hw.h"

//-----------------------------------------------------------------
// Defines:
//-----------------------------------------------------------------
#define USB_CTRL_TX_TIMEOUT     100

#ifndef MAX_CTRL_DATA_LENGTH
    #define MAX_CTRL_DATA_LENGTH    64
#endif

//-----------------------------------------------------------------
// Types
//-----------------------------------------------------------------

// SETUP packet data format
struct device_request
{
	unsigned char   bmRequestType;
	unsigned char   bRequest;
	unsigned short  wValue;
	unsigned short  wIndex;
	unsigned short  wLength;
};

struct control_transfer
{
    // SETUP packet
	struct device_request   request;

    // Data (OUT) stage expected?
    int                     data_expected;

    // Data buffer
    unsigned char           data_buffer[MAX_CTRL_DATA_LENGTH];

    // Data received index
    int                     data_idx;
};

//-----------------------------------------------------------------
// Locals:
//-----------------------------------------------------------------
static struct control_transfer  _ctrl_xfer;
static int                      _remote_wake_enabled;
static FP_CLASS_REQUEST         _class_request;

//-----------------------------------------------------------------
// get_status:
//-----------------------------------------------------------------
static void get_status(struct device_request *request)
{    
	unsigned char bRecipient = request->bmRequestType & USB_RECIPIENT_MASK;
    unsigned char data[2] = {0, 0};

    log_printf(USBLOG_INFO, "USB: Get Status %x\n", bRecipient);

	if ( bRecipient == USB_RECIPIENT_DEVICE )
	{
        // Self-powered
		if (!usb_is_bus_powered()) 
            data[0] |= (1 << 0);

        // Remote Wake-up enabled
		if (_remote_wake_enabled) 
            data[0] |= (1 << 1);

		usb_control_send( data, 2, request->wLength );
	}
	else if ( bRecipient == USB_RECIPIENT_INTERFACE )
	{
		usb_control_send( data, 2, request->wLength );
	}
	else if ( bRecipient == USB_RECIPIENT_ENDPOINT )
	{
		if (usbhw_is_endpoint_stalled( request->wIndex & ENDPOINT_ADDR_MASK)) 
            data[0] = 1;
		usb_control_send( data, 2, request->wLength );
	}
	else
        usbhw_control_endpoint_stall();
}
//-----------------------------------------------------------------
// clear_feature:
//-----------------------------------------------------------------
static void clear_feature(struct device_request *request)
{
	unsigned char bRecipient = request->bmRequestType & USB_RECIPIENT_MASK;

    log_printf(USBLOG_INFO, "USB: Clear Feature %x\n", bRecipient);

	if ( bRecipient == USB_RECIPIENT_DEVICE )
	{
		if ( request->wValue == USB_FEATURE_REMOTE_WAKEUP )
		{
            log_printf(USBLOG_INFO, "USB: Disable remote wake\n");
            _remote_wake_enabled = 0;
			usbhw_control_endpoint_ack();
		}
		else if ( request->wValue == USB_FEATURE_TEST_MODE )
		{
            log_printf(USBLOG_INFO, "USB: Disable test mode\n");
			usbhw_control_endpoint_ack();
		}
		else
            usbhw_control_endpoint_stall();
	}
	else if ( bRecipient == USB_RECIPIENT_ENDPOINT && 
			  request->wValue == USB_FEATURE_ENDPOINT_STATE )
	{
		usbhw_control_endpoint_ack();
		usbhw_clear_endpoint_stall( request->wIndex & ENDPOINT_ADDR_MASK );
	}
	else
        usbhw_control_endpoint_stall();
}
//-----------------------------------------------------------------
// set_feature:
//-----------------------------------------------------------------
static void set_feature(struct device_request *request)
{
	unsigned char bRecipient = request->bmRequestType & USB_RECIPIENT_MASK;

    log_printf(USBLOG_INFO, "USB: Set Feature %x\n", bRecipient);

	if ( bRecipient == USB_RECIPIENT_DEVICE )
	{
		if ( request->wValue == USB_FEATURE_REMOTE_WAKEUP )
		{
            log_printf(USBLOG_INFO, "USB: Enable remote wake\n");
            _remote_wake_enabled = 1;
			usbhw_control_endpoint_ack();
		}
		else if ( request->wValue == USB_FEATURE_TEST_MODE )
		{
            log_printf(USBLOG_INFO, "USB: Enable test mode\n");
			usbhw_control_endpoint_ack();
		}
		else
            usbhw_control_endpoint_stall();
	}
	else if ( bRecipient == USB_RECIPIENT_ENDPOINT && 
			  request->wValue == USB_FEATURE_ENDPOINT_STATE )
	{
		usbhw_control_endpoint_ack();
		usbhw_set_endpoint_stall(request->wIndex & ENDPOINT_ADDR_MASK);
	}
	else
        usbhw_control_endpoint_stall();
}
//-----------------------------------------------------------------
// set_address:
//-----------------------------------------------------------------
static void set_address(struct device_request *request)
{
	unsigned char addr = (LO_BYTE(request->wValue)) & USB_ADDRESS_MASK;
	
	usbhw_set_address(addr);
    usbhw_control_endpoint_ack();

    log_printf(USBLOG_INFO, "USB: Set address %x\n", addr);
}
//-----------------------------------------------------------------
// get_descriptor:
//-----------------------------------------------------------------
static void get_descriptor(struct device_request *request)
{
	unsigned char  bDescriptorType = HI_BYTE(request->wValue);
	unsigned char  bDescriptorIndex = LO_BYTE( request->wValue );
	unsigned short wLength = request->wLength;
	unsigned char  bCount = 0;
    unsigned char *desc_ptr;

    desc_ptr = usb_get_descriptor(bDescriptorType, bDescriptorIndex, wLength, &bCount);

    if (desc_ptr)
        usb_control_send(desc_ptr, bCount, request->wLength);
    else
        usbhw_control_endpoint_stall();
}
//-----------------------------------------------------------------
// get_configuration:
//-----------------------------------------------------------------
static void get_configuration(struct device_request *request)
{
	unsigned char conf = usbhw_is_configured() ? 1 : 0;

    log_printf(USBLOG_INFO, "USB: Get configuration %x\n", conf);

	usb_control_send( &conf, 1, request->wLength );
}
//-----------------------------------------------------------------
// set_configuration:
//-----------------------------------------------------------------
static void set_configuration(struct device_request *request)
{
    log_printf(USBLOG_INFO, "USB: set_configuration %x\n", request->wValue);

	if ( request->wValue == 0 )
	{
		usbhw_control_endpoint_ack();
        usbhw_set_configured(0);
	}
    // Only support one configuration for now
	else if ( request->wValue == 1 )
	{
		usbhw_control_endpoint_ack();
        usbhw_set_configured(1);
	}
	else
        usbhw_control_endpoint_stall();
}
//-----------------------------------------------------------------
// get_interface:
//-----------------------------------------------------------------
static void get_interface(struct device_request *request)
{
    log_printf(USBLOG_INFO, "USB: Get interface\n");
	usbhw_control_endpoint_stall();
}
//-----------------------------------------------------------------
// set_interface:
//-----------------------------------------------------------------
static void set_interface(struct device_request *request)
{
    log_printf(USBLOG_INFO, "USB: set_interface %x %x\n", request->wValue, request->wIndex);

	if ( request->wValue == 0 && request->wIndex == 0 )
		usbhw_control_endpoint_ack();
	else
        usbhw_control_endpoint_stall();
}

//-----------------------------------------------------------------
// usb_process_request:
//-----------------------------------------------------------------
static void usb_process_request(struct device_request *request, unsigned char type, unsigned char req, unsigned char *data)
{
	if ( type == USB_STANDARD_REQUEST )
	{
        // Standard requests
        switch (req)
        {
        case REQ_GET_STATUS:
            get_status(request);
            break;
        case REQ_CLEAR_FEATURE:
            clear_feature(request);
            break;
        case REQ_SET_FEATURE:
            set_feature(request);
            break;
        case REQ_SET_ADDRESS:
            set_address(request);
            break;
        case REQ_GET_DESCRIPTOR:
            get_descriptor(request);
            break;
        case REQ_GET_CONFIGURATION:
            get_configuration(request);
            break;
        case REQ_SET_CONFIGURATION:
            set_configuration(request);
            break;
        case REQ_GET_INTERFACE:
            get_interface(request);
            break;
        case REQ_SET_INTERFACE:
            set_interface(request);
            break;
        default:
            log_printf(USBLOG_ERR, "USB: Unknown standard request %x\n", req);
		    usbhw_control_endpoint_stall();
            break;
        }
	}
	else if ( type == USB_VENDOR_REQUEST )
	{
        log_printf(USBLOG_ERR, "Vendor: Unknown command\n");

        // None supported
		usbhw_control_endpoint_stall();
	}
	else if ( type == USB_CLASS_REQUEST && _class_request)
	{
        _class_request(req, request->wValue, request->wIndex, data, request->wLength);
	}
	else
        usbhw_control_endpoint_stall();
}
//-----------------------------------------------------------------
// usb_process_setup: Process SETUP packet
//-----------------------------------------------------------------
static void usb_process_setup(void)
{
    unsigned char type, req;
    unsigned char setup_pkt[EP0_MAX_PACKET_SIZE];

	usbhw_get_rx_data(ENDPOINT_CONTROL, setup_pkt, EP0_MAX_PACKET_SIZE);
    usbhw_clear_rx_ready(ENDPOINT_CONTROL);

    #if (LOG_LEVEL >= USBLOG_SETUP_DATA)
    {
        int i;

        log_printf(USBLOG_SETUP_DATA, "USB: SETUP data %d\n", EP0_MAX_PACKET_SIZE);
        
        for (i=0;i<EP0_MAX_PACKET_SIZE;i++)
            log_printf(USBLOG_SETUP_DATA, "%02x ", setup_pkt[i]);

        log_printf(USBLOG_SETUP_DATA, "\n");
    }
    #endif

    // Extract packet to local endian format
    _ctrl_xfer.request.bmRequestType = setup_pkt[0];
    _ctrl_xfer.request.bRequest      = setup_pkt[1];
    _ctrl_xfer.request.wValue        = setup_pkt[3];
    _ctrl_xfer.request.wValue      <<= 8;
    _ctrl_xfer.request.wValue       |= setup_pkt[2];
    _ctrl_xfer.request.wIndex        = setup_pkt[5];
    _ctrl_xfer.request.wIndex      <<= 8;
    _ctrl_xfer.request.wIndex       |= setup_pkt[4];
    _ctrl_xfer.request.wLength       = setup_pkt[7];
    _ctrl_xfer.request.wLength     <<= 8;
    _ctrl_xfer.request.wLength      |= setup_pkt[6];

	_ctrl_xfer.data_idx      = 0;
    _ctrl_xfer.data_expected = 0;

	type = _ctrl_xfer.request.bmRequestType & USB_REQUEST_TYPE_MASK;
	req  = _ctrl_xfer.request.bRequest;

    // SETUP - GET
	if (_ctrl_xfer.request.bmRequestType & ENDPOINT_DIR_IN)
	{
        log_printf(USBLOG_SETUP, "USB: SETUP Get wValue=0x%x wIndex=0x%x wLength=%d\n", 
                                    _ctrl_xfer.request.wValue,
                                    _ctrl_xfer.request.wIndex,
                                    _ctrl_xfer.request.wLength);

		usb_process_request(&_ctrl_xfer.request, type, req, _ctrl_xfer.data_buffer);           
	}
    // SETUP - SET
	else
	{
        // No data
		if ( _ctrl_xfer.request.wLength == 0 )
        {
            log_printf(USBLOG_SETUP, "USB: SETUP Set wValue=0x%x wIndex=0x%x wLength=%d\n", 
                                        _ctrl_xfer.request.wValue,
                                        _ctrl_xfer.request.wIndex,
                                        _ctrl_xfer.request.wLength);
            usb_process_request(&_ctrl_xfer.request, type, req, _ctrl_xfer.data_buffer);
        }
        // Data expected
		else
		{
            log_printf(USBLOG_SETUP, "USB: SETUP Set wValue=0x%x wIndex=0x%x wLength=%d [OUT expected]\n", 
                                        _ctrl_xfer.request.wValue,
                                        _ctrl_xfer.request.wIndex,
                                        _ctrl_xfer.request.wLength);
            
			if ( _ctrl_xfer.request.wLength <= MAX_CTRL_DATA_LENGTH )
            {
                // OUT packets expected to follow containing data
				_ctrl_xfer.data_expected = 1;
            }
            // Error: Too much data!
			else
			{
                log_printf(USBLOG_ERR, "USB: More data than max transfer size\n");
                usbhw_control_endpoint_stall();
			}
		}
	}
}
//-----------------------------------------------------------------
// usb_process_out: Process OUT (on control EP0)
//-----------------------------------------------------------------
static void usb_process_out(void)
{
	unsigned short received;
    unsigned char type;
    unsigned char req;

    // Error: Not expecting DATA-OUT!
	if (!_ctrl_xfer.data_expected)
	{
        log_printf(USBLOG_ERR, "USB: (EP0) OUT received but not expected, STALL\n");
		usbhw_control_endpoint_stall();
	}
	else
	{
		received = usbhw_get_rx_count( ENDPOINT_CONTROL );

        log_printf(USBLOG_SETUP_OUT, "USB: OUT received (%d bytes)\n", received);

		if ( (_ctrl_xfer.data_idx + received) > MAX_CTRL_DATA_LENGTH )
		{
            log_printf(USBLOG_ERR, "USB: Too much OUT EP0 data %d > %d, STALL\n", (_ctrl_xfer.data_idx + received), MAX_CTRL_DATA_LENGTH);
			usbhw_control_endpoint_stall();
		}
		else
		{
			usbhw_get_rx_data(ENDPOINT_CONTROL, &_ctrl_xfer.data_buffer[_ctrl_xfer.data_idx], received);
            usbhw_clear_rx_ready(ENDPOINT_CONTROL);
			_ctrl_xfer.data_idx += received;

            log_printf(USBLOG_SETUP_OUT, "USB: OUT packet re-assembled %d\n", _ctrl_xfer.data_idx);

            // End of transfer (short transfer received?)
		    if (received < EP0_MAX_PACKET_SIZE || _ctrl_xfer.data_idx >= _ctrl_xfer.request.wLength)
		    {
                // Send ZLP (ACK for Status stage)
                log_printf(USBLOG_SETUP_OUT, "USB: Send ZLP status stage %d %d\n", _ctrl_xfer.data_idx, _ctrl_xfer.request.wLength);

                usbhw_load_tx_buffer( ENDPOINT_CONTROL, 0, 0);
			    while (!usbhw_has_tx_space( ENDPOINT_CONTROL ))
                    ;
			    _ctrl_xfer.data_expected = 0;

	            type = _ctrl_xfer.request.bmRequestType & USB_REQUEST_TYPE_MASK;
	            req  = _ctrl_xfer.request.bRequest;

			    usb_process_request(&_ctrl_xfer.request, type, req, _ctrl_xfer.data_buffer);
		    }
            else
                log_printf(USBLOG_SETUP_OUT, "DEV: More data expected!\n");
        }
	}
}
//-----------------------------------------------------------------
// usb_control_send: Perform a transfer via IN
//-----------------------------------------------------------------
int usb_control_send(unsigned char *buf, int size, int requested_size)
{
	t_time tS;
	int send;
	int remain;
	int count = 0;
    int err = 0;

    log_printf(USBLOG_SETUP_IN, "USB: usb_control_send %d\n", size);

    // Loop until partial packet sent
    do
	{
		remain = size - count;
		send = MIN(remain, EP0_MAX_PACKET_SIZE);

        log_printf(USBLOG_SETUP_IN_DBG, " Remain %d, Send %d\n", remain, send);

        // Do not send ZLP if requested size was size transferred
        if (remain == 0 && size == requested_size)
            break;

		usbhw_load_tx_buffer(ENDPOINT_CONTROL, buf, (unsigned char) send);

		buf += send;
		count += send;

        log_printf(USBLOG_SETUP_IN_DBG, " Sent %d, Remain %d\n", send, (size - count));

		tS = usbhw_timer_now();
		while ( !usbhw_has_tx_space( ENDPOINT_CONTROL ) )
		{
            if (usbhw_timer_diff(usbhw_timer_now(), tS) > USB_CTRL_TX_TIMEOUT)
			{
                log_printf(USBLOG_ERR, "USB: Timeout sending IN data\n");
                err = 1;
				break;
			}

            // Give up on early OUT (STATUS stage)
            if (usbhw_is_rx_ready(ENDPOINT_CONTROL))
            {
                log_printf(USBLOG_ERR, "USB: Early ACK received...\n");
                break;
            }
		}
	}
    while (send >= EP0_MAX_PACKET_SIZE);

    if (!err)
    {
        log_printf(USBLOG_SETUP_IN, "USB: Sent total %d\n", count);

	    // Wait for ACK from host
	    tS = usbhw_timer_now();
	    do
        {
            if (usbhw_timer_diff(usbhw_timer_now(), tS) > USB_CTRL_TX_TIMEOUT)
		    {
			    log_printf(USBLOG_ERR, "USB: ACK not received\n");
                err = 1;
			    break;
		    }
	    } 
        while (!usbhw_is_rx_ready(ENDPOINT_CONTROL));

        usbhw_clear_rx_ready(ENDPOINT_CONTROL);

        if (!err)
        {
            log_printf(USBLOG_SETUP_IN, "USB: ACK received\n");
        }
    }

    return !err;
}
//-----------------------------------------------------------------
// usbf_init:
//-----------------------------------------------------------------
void usbf_init(unsigned int base, FP_BUS_RESET bus_reset, FP_CLASS_REQUEST class_request)
{
    _class_request = class_request;
    usbhw_init(base, bus_reset, usb_process_setup, usb_process_out);
}
