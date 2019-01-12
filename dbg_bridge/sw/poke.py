#!/usr/bin/env python
import sys
import argparse

from bus_interface import *

##################################################################
# Main
##################################################################
def main(argv):
    
    parser = argparse.ArgumentParser()
    parser.add_argument('-t', dest='type',   default='uart',                  help='Device type (uart|socket)')
    parser.add_argument('-d', dest='device', default='/dev/ttyUSB1',          help='Serial Device')
    parser.add_argument('-b', dest='baud',   default=1000000,       type=int, help='Baud rate')
    parser.add_argument('-a', dest='address',required=True,                   help='Address to write')
    parser.add_argument('-v', dest='value',  required=True,                   help='Value to write')
    args = parser.parse_args()

    bus_if = BusInterface(args.type, args.device, args.baud)

    addr   = int(args.address, 0)
    value  = int(args.value, 0)

    bus_if.write32(addr, value)

if __name__ == "__main__":
   main(sys.argv[1:])
