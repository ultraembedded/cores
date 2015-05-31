#include <stdio.h>
#include <ftdi.h>

#include "ftdi_hw.h"

//-----------------------------------------------------------------
// Defines:
//-----------------------------------------------------------------
#define CMD_NOP        0x0
#define CMD_WR         0x1
#define CMD_RD         0x2
#define CMD_GP_WR      0x3
#define CMD_GP_RD      0x4

#define MAX_TX_SIZE    2048
#define HDR_SIZE       6

#define FTDI_PID       0x0403
#define FTDI_VID       0x6010

//-----------------------------------------------------------------
// Locals:
//-----------------------------------------------------------------
static struct ftdi_context *_handle;

//-----------------------------------------------------------------
// ftdi_hw_init:
//-----------------------------------------------------------------
int ftdi_hw_init(int interface)
{
    int status;

    _handle = ftdi_new();
    if (!_handle)
        return -1;

    // Open channel
    ftdi_set_interface(_handle, interface ? INTERFACE_B : INTERFACE_A);
    status = ftdi_usb_open(_handle, FTDI_PID, FTDI_VID);
    if (status != 0)
    {
        ftdi_free(_handle);
        _handle = NULL;
        return -1;
    }

    // Reset FTDI
    status = ftdi_usb_reset(_handle);
    if (status != 0)
    {
        ftdi_usb_close(_handle);
        ftdi_free(_handle);
        _handle = NULL;
        return -1;
    }

    // Flush buffers
    status = ftdi_usb_purge_buffers(_handle);
    if (status != 0)
    {
        ftdi_usb_close(_handle);
        ftdi_free(_handle);
        _handle = NULL;
        return -1;
    }

    // Set transfer mode
    status = ftdi_set_bitmode(_handle, 0xFF, BITMODE_RESET);
    if (status != 0)
    {
        ftdi_usb_close(_handle);
        ftdi_free(_handle);
        _handle = NULL;
        return -1;
    }

    return 0;
}
//-----------------------------------------------------------------
// ftdi_hw_close:
//-----------------------------------------------------------------
int ftdi_hw_close(void)
{
    if (_handle)
    {
        ftdi_usb_close(_handle);
        ftdi_free(_handle);
        _handle = NULL;
    }

    return 0;
}
//-----------------------------------------------------------------
// ftdi_hw_mem_write:
//-----------------------------------------------------------------
int ftdi_hw_mem_write(uint32_t addr, uint8_t *data, int length)
{
    int i;
    int sent = 0;
    int size = length;
    int res;
    uint8_t buffer[MAX_TX_SIZE + HDR_SIZE];
    uint8_t *p;

    while (sent < length)
    {
        size = (length - sent);
        if (size > MAX_TX_SIZE)
            size = MAX_TX_SIZE;

        // Build packet header
        p = buffer;
        *p++ = (((size >> 8) & 0xF) << 4) | CMD_WR;
        *p++ = (size & 0xFF);

        *p++ = (addr >> 24);
        *p++ = (addr >> 16);
        *p++ = (addr >> 8);
        *p++ = (addr >> 0);        

        // Fill packet payload
        for (i=0;i<size;i++)
            *p++ = *data++;

        // Write request + data to FTDI device
        res = ftdi_write_data(_handle, buffer, (size + HDR_SIZE));
        if (res != (size + HDR_SIZE))
        {
            fprintf(stderr, "ftdi_hw_mem_write: Failed to send\n");
            return -1;
        }        

        sent += size;
        addr += size;
    }

    return sent;
}
//-----------------------------------------------------------------
// ftdi_hw_mem_read:
//-----------------------------------------------------------------
int ftdi_hw_mem_read(uint32_t addr, uint8_t *data, int length)
{
    int i;
    int received = 0;
    int size = length;
    int remain;
    int res;
    uint8_t buffer[HDR_SIZE];
    uint8_t *p;

    while (received < length)
    {
        size = (length - received);
        if (size > MAX_TX_SIZE)
            size = MAX_TX_SIZE;

        // Round up to nearest 4 byte multiple
        size = (size + 3) & ~3;

        // Build packet header
        p = buffer;
        *p++ = (((size >> 8) & 0xF) << 4) | CMD_RD;
        *p++ = (size & 0xFF);

        *p++ = (addr >> 24);
        *p++ = (addr >> 16);
        *p++ = (addr >> 8);
        *p++ = (addr >> 0);

        // Write request to FTDI device
        res = ftdi_write_data(_handle, buffer, HDR_SIZE);
        if (res != HDR_SIZE)
        {
            fprintf(stderr, "ftdi_hw_mem_read: Failed to send request\n");
            return -1;
        }

        remain = size;
        do
        {
            res = ftdi_read_data(_handle, data, remain);
            if (res < 0)
            {
                fprintf(stderr, "ftdi_hw_mem_read: Failed to read data\n");
                return -1;
            }

            remain -= res;
            data += res;
        }
        while (remain > 0);

        received += size;
        addr     += size;
    }

    return received;
}
//-----------------------------------------------------------------
// ftdi_hw_mem_write_word:
//-----------------------------------------------------------------
int ftdi_hw_mem_write_word(uint32_t addr, uint32_t data)
{
    uint8_t buffer[4];

    buffer[3] = (data >> 24);
    buffer[2] = (data >> 16);
    buffer[1] = (data >> 8);
    buffer[0] = (data >> 0);

    return ftdi_hw_mem_write(addr, buffer, 4);
}
//-----------------------------------------------------------------
// ftdi_hw_mem_read_word:
//-----------------------------------------------------------------
int ftdi_hw_mem_read_word(uint32_t addr, uint32_t *data)
{
    uint8_t buffer[4];

    int res = ftdi_hw_mem_read(addr, buffer, 4);
    if (res > 0)
    {
        (*data) = ((uint32_t)buffer[3]) << 24;
        (*data)|= ((uint32_t)buffer[2]) << 16;
        (*data)|= ((uint32_t)buffer[1]) << 8;
        (*data)|= ((uint32_t)buffer[0]) << 0;
    }
    return res;
}
//-----------------------------------------------------------------
// ftdi_hw_gpio_write:
//-----------------------------------------------------------------
int ftdi_hw_gpio_write(uint8_t value)
{
    uint8_t buffer[2] = { CMD_GP_WR, value };

    // Write request to FTDI device
    int res = ftdi_write_data(_handle, buffer, sizeof(buffer));
    if (res != sizeof(buffer))
    {
        fprintf(stderr, "ftdi_hw_mem_write: Failed to send\n");
        return -1;
    }

    return 0;
}
//-----------------------------------------------------------------
// ftdi_hw_gpio_read:
//-----------------------------------------------------------------
int ftdi_hw_gpio_read(uint8_t *value)
{
    // Write request to FTDI device
    uint8_t request = CMD_GP_RD;
    int res = ftdi_write_data(_handle, &request, 1);
    if (res != 1)
    {
        fprintf(stderr, "ftdi_hw_mem_write: Failed to send\n");
        return -1;
    }

    // Poll for response
    do
    {
        res = ftdi_read_data(_handle, value, 1);
        if (res < 0)
        {
            fprintf(stderr, "ftdi_hw_mem_read: Failed to read data\n");
            return -1;
        }
    }
    while (res != 1);

    return 0;
}
