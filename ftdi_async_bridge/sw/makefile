###############################################################################
# Rules
###############################################################################
all:
	make -f makefile.mk TARGET=load
	make -f makefile.mk TARGET=peek
	make -f makefile.mk TARGET=poke
	make -f makefile.mk TARGET=dump
	make -f makefile.mk TARGET=verify
	make -f makefile.mk TARGET=gpio_read
	make -f makefile.mk TARGET=gpio_write
	make -f makefile.mk TARGET=sdram_test

clean:
	make -f makefile.mk TARGET=load clean
	make -f makefile.mk TARGET=peek clean
	make -f makefile.mk TARGET=poke clean
	make -f makefile.mk TARGET=dump clean
	make -f makefile.mk TARGET=verify clean
	make -f makefile.mk TARGET=gpio_read clean
	make -f makefile.mk TARGET=gpio_write clean
	make -f makefile.mk TARGET=sdram_test clean

