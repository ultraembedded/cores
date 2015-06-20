#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include "ftdi_hw.h"

//-----------------------------------------------------------------
// Defines:
//-----------------------------------------------------------------
#define CHUNK_SIZE          256
#define DEFAULT_FTDI_IFACE  1

//-----------------------------------------------------------------
// download
//-----------------------------------------------------------------
static int download(FILE *f, uint32_t addr, int length)
{
    uint8_t buf[CHUNK_SIZE];
    int err = 0;
    int i;
    int size;
    
    for (i=0;i<length;i+=CHUNK_SIZE)
    {
        size = (length - i);
        if (size > CHUNK_SIZE)
            size = CHUNK_SIZE;

        if (ftdi_hw_mem_read(addr, buf, size) != size)
        {
            fprintf(stderr, "Download: Error downloading file\n");
            err = 1;
            break;
        }

        if (fwrite(buf, 1, size, f) != size)
        {
            fprintf(stderr, "Download: Error writing file\n");
            err = 1;
            break;
        }

        addr += CHUNK_SIZE;

        printf("\r%d%%", (i * 100) / length);
        fflush(stdout);
    }

    return err;
}
//-----------------------------------------------------------------
// main
//-----------------------------------------------------------------
int main(int argc, char *argv[])
{
    int c;
    int size = -1;
    char *filename = NULL;
    int help = 0;
    int err = 1;
    uint32_t address = 0x0;
    int ftdi_iface = DEFAULT_FTDI_IFACE;
    FILE *f = NULL;

    while ((c = getopt (argc, argv, "o:s:a:i:")) != -1)
    {
        switch(c)
        {
            case 'o':
                 filename = optarg;
                 break;
            case 's':
                 size = (int)strtol(optarg, NULL, 0);
                 break;
            case 'a':
                address = strtoul(optarg, NULL, 0);
                break;
            case 'i':
                 ftdi_iface = (int)strtol(optarg, NULL, 0);
                 break;                
            default:
                help = 1;   
                break;
        }
    }

    if (help || filename == NULL || size < 0)
    {
        fprintf (stderr,"Usage:\n");
        fprintf (stderr,"-o filename.bin   = Output filename\n");
        fprintf (stderr,"-s n              = Size to dump\n");
        fprintf (stderr,"-a 0xnnnn         = Address to dump from (default to 0x0)\n");
        fprintf (stderr,"-i id             = FTDI interface ID (0 = A, 1 = B)\n");
 
        exit(-1);
    }

    // Try and communicate with FTDI interface
    if (ftdi_hw_init(ftdi_iface) != 0)
    {
        fprintf(stderr, "ERROR: Could not open FTDI interface, try SUDOing / check connection\n");
        exit(-2);
    }

    // Try and create new file
    f = fopen(filename, "wb");
    if (f)
    {
        printf("Downloading %s (%dKB) from 0x%x:\n", filename, (size + 1023) / 1024, address);

        err = download(f, address, size);

        if (!err)
            printf("\rDone!\n");
        else
            printf("\rFailed!\n");

        fclose(f);
        f = NULL;
    }
    else
    {
        fprintf (stderr,"Error: Could not create file\n");
        err = 1;
    }

    ftdi_hw_close();

    return err;
}
