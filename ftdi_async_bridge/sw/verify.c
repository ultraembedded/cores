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
// load_file_to_mem
//-----------------------------------------------------------------
static uint8_t* load_file_to_mem(const char *filename, long size_override, int *pSize)
{
    uint8_t *buf = NULL;
    FILE *f = fopen(filename, "rb");

    *pSize = 0;

    if (f)
    {
        long size;

        // Get size of file
        fseek(f, 0, SEEK_END);
        size = ftell(f);
        rewind(f);

        // User overriden file size
        if (size_override >= 0)
        {
            if (size > size_override)
                size = size_override;
        }

        buf = (uint8_t*)malloc(size);
        if (buf)
        {
            // Read file data into allocated memory
            int len = fread(buf, 1, size, f);
            if (len != size)
            {
                free(buf);
                buf = NULL;
            }
            else
                *pSize = size;
        }
        fclose(f);
    }

    return buf;
}
//-----------------------------------------------------------------
// compare
//-----------------------------------------------------------------
static int compare(uint32_t addr, uint8_t *data, int length)
{
    uint8_t buf[CHUNK_SIZE];
    int res = 1;
    int i;
    int size;
    
    for (i=0;i<length;i+=CHUNK_SIZE)
    {
        size = (length - i);
        if (size > CHUNK_SIZE)
            size = CHUNK_SIZE;

        if (ftdi_hw_mem_read(addr, buf, size) != size)
        {
            fprintf(stderr, "Compare: Error downloading file\n");
            res = -1;
            break;
        }

        // Check for differences
        if (memcmp(data, buf, size) != 0)
        {
            res = 0;
            break;
        }

        addr += CHUNK_SIZE;
        data += CHUNK_SIZE;

        printf("\r%d%%", (i * 100) / length);
        fflush(stdout);
    }

    return res;
}
//-----------------------------------------------------------------
// main
//-----------------------------------------------------------------
int main(int argc, char *argv[])
{
    int c;
    long size_override = -1;
    char *filename = NULL;
    int help = 0;
    int err = 1;
    int res;
    int size;
    uint32_t address = 0x0;
    uint8_t *buf;
    int ftdi_iface = DEFAULT_FTDI_IFACE;

    while ((c = getopt (argc, argv, "f:s:a:i:")) != -1)
    {
        switch(c)
        {
            case 'f':
                 filename = optarg;
                 break;
            case 's':
                 size_override = strtol(optarg, NULL, 0);
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

    if (help || filename == NULL)
    {
        fprintf (stderr,"Usage:\n");
        fprintf (stderr,"-f filename.bin   = Executable to compare (binary)\n");
        fprintf (stderr,"-a 0xnnnn         = Address to compare to (default to 0x0)\n");
        fprintf (stderr,"-i id             = FTDI interface ID (0 = A, 1 = B)\n");
        fprintf (stderr,"-s 0xnnnn         = Size override\n");
 
        exit(-1);
    }

    // Try and communicate with FTDI interface
    if (ftdi_hw_init(ftdi_iface) != 0)
    {
        fprintf(stderr, "ERROR: Could not open FTDI interface, try SUDOing / check connection\n");
        exit(-2);
    }

    // Read file into memory
    buf = load_file_to_mem(filename, size_override, &size);
    if (buf)
    {
        printf("Comparing %s (%dKB) to 0x%x:\n", filename, (size + 1023) / 1024, address);

        // Upload file to target
        res = compare(address, buf, size);

        // Free file memory
        free(buf);
        buf = NULL;

        if (res == 1)
            printf("\nMatches!\n");
        else if (res == 0)
            printf("\nDiffers!\n");
        else
        {
            printf("\n");
            err = 1;
        }
    }
    else
    {
        fprintf (stderr,"Error: Could not open image\n");
        err = 1;
    }

    ftdi_hw_close();

    return err;
}
