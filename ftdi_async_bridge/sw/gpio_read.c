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

    while ((c = getopt (argc, argv, "i:q")) != -1)
    {
        switch(c)
        {
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
        fprintf (stderr,"-q                = Quiet mode (data returned via return value)\n");
 
        exit(-1);
    }

    // Try and communicate with FTDI interface
    if (ftdi_hw_init(ftdi_iface) != 0)
    {
        fprintf(stderr, "ERROR: Could not open FTDI interface, try SUDOing / check connection\n");
        exit(-2);
    }

    if (ftdi_hw_gpio_read(&value) != 0)
    {
        fprintf(stderr, "ERROR: Could not read from device\n");
        err = 1;
    }

    if (!quiet) 
    {
        printf("Read 0x%x from GPIO\n", value);
        value = 0;
    }

    ftdi_hw_close();

    return err ? -1 : value;
}
