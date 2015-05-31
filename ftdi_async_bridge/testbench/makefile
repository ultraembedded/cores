TRACE   		?= 1

all: compile run view                                                                                      
 
# Testbench
SRC+= ./top_tb.sv wb_slave.sv

SRC+= ../rtl/ftdi_if.v ../rtl/ftdi_sync.v

ifeq ($(TRACE),1)
    SRC_FLAGS += +define+TRACE=$(TRACE)
endif

INC_DIRS = -I.

compile : 
	vlib work
	vlog $(SRC) $(SRC_FLAGS)
 
run : compile
	vsim -c -do "run -all" top_tb
 
view : compile
ifeq ($(TRACE),1)
	gtkwave waveform.vcd gtksettings.sav  
endif

clean :                                                                                                  
	-rm -rf work waveform.vcd transcript
