#!/usr/bin/env python
import sys
import argparse

from bus_interface import *

##################################################################
# Main
##################################################################
def main(argv):
    
    parser = argparse.ArgumentParser()
    parser.add_argument('-t', dest='type',   default='uart',                     help='Device type (uart|socket)')
    parser.add_argument('-d', dest='device', default='/dev/ttyUSB1',             help='Serial Device')
    parser.add_argument('-b', dest='baud',   default=1000000,       type=int,    help='Baud rate')
    parser.add_argument('-a', dest='address',required=True,                      help='Address to read')
    parser.add_argument('-q', dest='quiet',  action='store_true', default=False, help='Quiet mode - set exit code to read value')
    args = parser.parse_args()

    bus_if = BusInterface(args.type, args.device, args.baud)

    addr   = int(args.address, 0)
    value  = bus_if.read32(addr)

    if not args.quiet:
        print "%08x: 0x%08x (%d)" % (addr, value, value)
    else:
        sys.exit(value)

if __name__ == "__main__":
   main(sys.argv[1:])