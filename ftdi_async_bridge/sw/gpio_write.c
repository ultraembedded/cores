#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include "ftdi_hw.h"

//-----------------------------------------------------------------
// Defines:
//-----------------------------------------------------------------
#define DEFAULT_FTDI_IFACE  1

//-----------------------------------------------------------------
// main:
//-----------------------------------------------------------------
int main(int argc, char *argv[])
{
    int err = 0;
    int c;
    int help = 0;
    int ftdi_iface = DEFAULT_FTDI_IFACE;
    uint8_t value = 0;
    int quiet = 0;

    while ((c = getopt (argc, argv, "v:i:q")) != -1)
    {
        switch(c)
        {
            case 'v':
                 value = (uint8_t)strtoul(optarg, NULL, 0);
                 break;
            case 'i':
                 ftdi_iface = (int)strtol(optarg, NULL, 0);
                 break;
            case 'q':
                quiet = 1;
                break;
            default:
                help = 1;
                break;
        }
    }

    if (help)
    {
        fprintf (stderr,"Usage:\n");
        fprintf (stderr,"-v 0xNN           = Data to write\n");
        fprintf (stderr,"-i id             = FTDI interface ID (0 = A, 1 = B)\n");
        fprintf (stderr,"-q                = Quiet mode\n");
 
        exit(-1);
    }

    // Try and communicate with FTDI interface
    if (ftdi_hw_init(ftdi_iface) != 0)
    {
        fprintf(stderr, "ERROR: Could not open FTDI interface, try SUDOing / check connection\n");
        exit(-2);
    }

    if (!quiet) 
        printf("Write 0x%x to GPIO\n", value);

    if (ftdi_hw_gpio_write(value) != 0)
    {
        fprintf(stderr, "ERROR: Could not write to device\n");
        err = 1;
    }

    ftdi_hw_close();

    return err;
}
