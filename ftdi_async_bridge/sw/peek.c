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
    uint32_t addr = 0xFFFFFFFF;
    uint32_t value = 0;
    int quiet = 0;

    while ((c = getopt (argc, argv, "a:i:q")) != -1)
    {
        switch(c)
        {
            case 'a':
                 addr = (uint32_t)strtoul(optarg, NULL, 0);
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

    if (help || addr == 0xFFFFFFFF)
    {
        fprintf (stderr,"Usage:\n");
        fprintf (stderr,"-a 0xNNNNNNNN     = Address to read\n");
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

    if (ftdi_hw_mem_read_word(addr, &value) != sizeof(value))
    {
        fprintf(stderr, "ERROR: Could not read from device\n");
        err = 1;
    }

    if (!quiet) 
    {
        printf("Read 0x%x from 0x%x\n", value, addr);
        value = 0;
    }

    ftdi_hw_close();

    return err ? -1 : value;
}
