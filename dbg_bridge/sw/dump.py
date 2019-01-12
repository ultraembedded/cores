#!/usr/bin/env python
import sys
import argparse

from bus_interface import *

##################################################################
# Print iterations progress
##################################################################
def print_progress(iteration, total, prefix='', suffix='', decimals=1, bar_length=50):
    str_format = "{0:." + str(decimals) + "f}"
    percents = str_format.format(100 * (iteration / float(total)))
    filled_length = int(round(bar_length * iteration / float(total)))
    bar = 'X' * filled_length + ' ' * (bar_length - filled_length)

    sys.stdout.write('\r%s |%s| %s%s %s' % (prefix, bar, percents, '%', suffix)),

    if iteration == total:
        sys.stdout.write('\n')
    sys.stdout.flush()

##################################################################
# Main
##################################################################
def main(argv):
    
    parser = argparse.ArgumentParser()
    parser.add_argument('-t', dest='type',    default='uart',                     help='Device type (uart|socket)')
    parser.add_argument('-d', dest='device',  default='/dev/ttyUSB1',             help='Serial Device')
    parser.add_argument('-b', dest='baud',    default=1000000,       type=int,    help='Baud rate')
    parser.add_argument('-o', dest='filename',required=True,                      help='Output filename')
    parser.add_argument('-a', dest='address', default="0",                        help='Address to dump from (default to 0x0)')
    parser.add_argument('-s', dest='size',    required=True,         type=int,    help='Size to dump')
    args = parser.parse_args()

    bus_if = BusInterface(args.type, args.device, args.baud)
    bus_if.set_progress_cb(print_progress)

    addr   = int(args.address, 0)
    print "Dump: %d bytes from 0x%08x" % (args.size, addr)

    # Read from target
    data   = bus_if.read(addr, args.size)

    # Write to file
    file = open(args.filename, mode='wb')
    file.write(data)

if __name__ == "__main__":
   main(sys.argv[1:])