TRACE   		?= 1
MAX_ADDRESS 	?= 8192
PART 			?= IS42VM16400K

all: compile run view
 
# Testbench
SRC+= ./top_tb.sv wb_master.sv IS42VM16400K.v MT48LC8M16A2.v

# DUT
SRC+= ../rtl/sdram.v

SRC_FLAGS = +define+MAX_ADDRESS=$(MAX_ADDRESS)

ifeq ($(TRACE),1)
    SRC_FLAGS += +define+TRACE=$(TRACE)
endif

SRC_FLAGS += +define+PART=$(PART)

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
