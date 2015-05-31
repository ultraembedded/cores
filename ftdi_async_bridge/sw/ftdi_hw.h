#ifndef _FTDI_HW_H_
#define _FTDI_HW_H_

#include <stdint.h>

//-----------------------------------------------------------------
// Defines:
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// Prototypes:
//-----------------------------------------------------------------
int ftdi_hw_init(int interface);
int ftdi_hw_close(void);

// Memory Access
int ftdi_hw_mem_write(uint32_t addr, uint8_t *data, int length);
int ftdi_hw_mem_read(uint32_t addr, uint8_t *data, int length);
int ftdi_hw_mem_write_word(uint32_t addr, uint32_t data);
int ftdi_hw_mem_read_word(uint32_t addr, uint32_t *data);

// GPIO
int ftdi_hw_gpio_write(uint8_t value);
int ftdi_hw_gpio_read(uint8_t *value);

#endif
