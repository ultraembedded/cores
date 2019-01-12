import serial

##################################################################
# UartBusInterface: UART -> Bus master interface
##################################################################
class UartBusInterface:
    ##################################################################
    # Construction
    ##################################################################
    def __init__(self, iface = '/dev/ttyUSB1', baud = 115200):
        self.interface  = iface
        self.baud       = baud
        self.uart       = None
        self.prog_cb    = None
        self.CMD_WRITE  = 0x10
        self.CMD_READ   = 0x11
        self.MAX_SIZE   = 255
        self.BLOCK_SIZE = 128
        self.GPIO_ADDR  = 0xF0000000
        self.STS_ADDR   = 0xF0000004

    ##################################################################
    # set_progress_cb: Set progress callback
    ##################################################################
    def set_progress_cb(self, prog_cb):
        self.prog_cb    = prog_cb

    ##################################################################
    # connect: Open serial connection
    ##################################################################
    def connect(self):
        self.uart = serial.Serial(
            port=self.interface,
            baudrate=self.baud,
            parity=serial.PARITY_NONE,
            stopbits=serial.STOPBITS_ONE,
            bytesize=serial.EIGHTBITS
        )
        self.uart.isOpen()

        # Check status register
        value = self.read32(self.STS_ADDR)
        if ((value & 0xFFFF0000) != 0xcafe0000):
            raise Exception("Target not responding correctly, check interface / baud rate...")

    ##################################################################
    # read32: Read a word from a specified address
    ##################################################################
    def read32(self, addr):
        # Connect if required
        if self.uart == None:
            self.connect()

        # Send read command
        cmd = bytearray([self.CMD_READ, 
                         4, 
                        (addr >> 24) & 0xFF, 
                        (addr >> 16) & 0xFF, 
                        (addr >> 8) & 0xFF, 
                        (addr >> 0) & 0xFF])
        self.uart.write(cmd)

        value = 0
        idx   = 0
        while (idx < 4):
            b = self.uart.read(1)
            value |= (ord(b) << (idx * 8))
            idx += 1

        return value

    ##################################################################
    # write32: Write a word to a specified address
    ##################################################################
    def write32(self, addr, value):
        # Connect if required
        if self.uart == None:
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
        self.uart.write(cmd)

    ##################################################################
    # write: Write a block of data to a specified address
    ##################################################################
    def write(self, addr, data, length, addr_incr=True, max_block_size=-1):
        # Connect if required
        if self.uart == None:
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
            self.uart.write(cmd)

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
        if self.uart == None:
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
            self.uart.write(cmd)

            # Read block response
            for i in range(l):
                data[idx] = ord(self.uart.read(1)) & 0xFF
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
        return self.read32(self.GPIO_ADDR)

    ##################################################################
    # write_gpio: Write a byte to GPIO
    ##################################################################
    def write_gpio(self, value):
        self.write32(self.GPIO_ADDR, value)
