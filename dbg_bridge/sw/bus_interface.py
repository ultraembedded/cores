import sys

from uart_bus_interface import *
from socket_interface import *

##################################################################
# BusInterface: Bus Interface Wrapper
##################################################################
class BusInterface:
    ##################################################################
    # Construction
    ##################################################################
    def __init__(self, iface_type = 'uart', iface = '/dev/ttyUSB1', baud = 115200):
        if iface_type == "uart":
            self.bus = UartBusInterface(iface, baud)
        elif iface_type == "socket":
            self.bus = SocketInterface(iface)
        else:
            self.bus = None

    ##################################################################
    # set_progress_cb: Set progress callback
    ##################################################################
    def set_progress_cb(self, prog_cb):
        self.bus.set_progress_cb(prog_cb)

    ##################################################################
    # open: Open connection
    ##################################################################
    def open(self):
        pass

    ##################################################################
    # close: Close connection
    ##################################################################
    def close(self):
        pass

    ##################################################################
    # write: Write a block of data to a specified address
    ##################################################################
    def write(self, addr, data, length, addr_incr=True, max_block_size=-1):
        self.bus.write(addr, data, length, addr_incr, max_block_size)

    ##################################################################
    # read: Read a block of data from a specified address
    ##################################################################
    def read(self, addr, length, addr_incr=True, max_block_size=-1):
        return self.bus.read(addr, length, addr_incr, max_block_size)

    ##################################################################
    # read32: Read a word from a specified address
    ##################################################################
    def read32(self, addr):
        return self.bus.read32(addr)

    ##################################################################
    # write32: Write a word to a specified address
    ##################################################################
    def write32(self, addr, value):
        return self.bus.write32(addr, value)
  
    ##################################################################
    # read_gpio: Read GPIO bus
    ##################################################################
    def read_gpio(self):
        return self.bus.read_gpio()

    ##################################################################
    # write_gpio: Write a byte to GPIO
    ##################################################################
    def write_gpio(self, value):
        return self.bus.write_gpio(value)
