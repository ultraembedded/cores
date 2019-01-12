import socket
import sys

##################################################################
# SocketInterface: Socket -> Bus master
##################################################################
class SocketInterface:
    ##################################################################
    # Construction
    ##################################################################
    def __init__(self, port_num = '2000'):
        self.server_addr  = ('localhost', int(port_num))
        self.sock         = None
        self.prog_cb      = None
        self.CMD_WRITE    = 0x10
        self.CMD_READ     = 0x11
        self.MAX_SIZE     = 255
        self.BLOCK_SIZE   = 128

    ##################################################################
    # set_progress_cb: Set progress callback
    ##################################################################
    def set_progress_cb(self, prog_cb):
        self.prog_cb    = prog_cb

    ##################################################################
    # connect: Create socket
    ##################################################################
    def connect(self):
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    ##################################################################
    # read32: Read a word from a specified address
    ##################################################################
    def read32(self, addr):
        # Connect if required
        if self.sock == None:
            self.connect()

        # Send read command
        cmd = bytearray([self.CMD_READ, 
                         4, 
                        (addr >> 24) & 0xFF, 
                        (addr >> 16) & 0xFF, 
                        (addr >> 8) & 0xFF, 
                        (addr >> 0) & 0xFF])
        self.sock.sendto(cmd, self.server_addr)

        value = 0
        idx   = 0
        resp  = self.sock.recv(4)
        for b in resp:
            value |= (ord(b) << (idx * 8))
            idx += 1

        return value

    ##################################################################
    # write32: Write a word to a specified address
    ##################################################################
    def write32(self, addr, value):
        # Connect if required
        if self.sock == None:
            self.connect()

        # Send write command
        cmd = bytearray([self.CMD_WRITE,
                         4, 
                        (addr >> 24)  & 0xFF, 
                        (addr >> 16)  & 0xFF, 
                        (addr >> 8)   & 0xFF, 
                        (addr >> 0)   & 0xFF, 
                        (value >> 0)  & 0xFF, 
                        (value >> 8)  & 0xFF, 
                        (value >> 16) & 0xFF, 
                        (value >> 24) & 0xFF])
        self.sock.sendto(cmd, self.server_addr)
        self.sock.recv(1)

    ##################################################################
    # write: Write a block of data to a specified address
    ##################################################################
    def write(self, addr, data, length, addr_incr=True, max_block_size=-1):
        # Connect if required
        if self.sock == None:
            self.connect()

        # Write blocks
        idx       = 0
        remainder = length

        if self.prog_cb != None:
            self.prog_cb(0, length)

        if max_block_size == -1:
            max_block_size = self.BLOCK_SIZE

        while remainder > 0:
            l = max_block_size
            if l > remainder:
                l = remainder

            cmd = bytearray(2 + 4 + l)
            cmd[0] = self.CMD_WRITE
            cmd[1] = l & 0xFF
            cmd[2] = (addr >> 24) & 0xFF
            cmd[3] = (addr >> 16) & 0xFF
            cmd[4] = (addr >> 8)  & 0xFF
            cmd[5] = (addr >> 0)  & 0xFF

            for i in range(l):
                cmd[6+i] = data[idx]
                idx += 1

            # Write to serial port
            self.sock.sendto(cmd, self.server_addr)
            self.sock.recv(1)

            # Update display
            if self.prog_cb != None:
                self.prog_cb(idx, length)

            if addr_incr:
                addr  += l
            remainder -= l

    ##################################################################
    # read: Read a block of data from a specified address
    ##################################################################
    def read(self, addr, length, addr_incr=True, max_block_size=-1):
        # Connect if required
        if self.sock == None:
            self.connect()

        idx       = 0
        remainder = length
        data      = bytearray(length)

        if self.prog_cb != None:
            self.prog_cb(0, length)

        if max_block_size == -1:
            max_block_size = self.BLOCK_SIZE

        while remainder > 0:
            l = max_block_size
            if l > remainder:
                l = remainder

            cmd = bytearray(2 + 4)
            cmd[0] = self.CMD_READ
            cmd[1] = l & 0xFF
            cmd[2] = (addr >> 24) & 0xFF
            cmd[3] = (addr >> 16) & 0xFF
            cmd[4] = (addr >> 8)  & 0xFF
            cmd[5] = (addr >> 0)  & 0xFF

            # Write to serial port
            self.sock.sendto(cmd, self.server_addr)

            # Read block response
            resp  = self.sock.recv(l)
            for i in range(l):
                data[idx] = ord(resp[i]) & 0xFF
                idx += 1

            # Update display
            if self.prog_cb != None:
                self.prog_cb(idx, length)

            if addr_incr:
                addr  += l
            remainder -= l

        return data

    ##################################################################
    # read_gpio: Read GPIO bus
    ##################################################################
    def read_gpio(self):
        return self.read32(0xF0000000)

    ##################################################################
    # write_gpio: Write a byte to GPIO
    ##################################################################
    def write_gpio(self, value):
        self.write32(0xF0000000, value)
