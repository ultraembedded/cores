SEED            ?= 1
CYCLES      	?= 200000
TRACE   		?= 1

all: compile run view                                                                                      
 
# Testbench
SRC+= ./top_tb.sv
SRC+= ./*.v

SRC+= ../rtl/*.v

SRC_FLAGS = +define+CYCLES=$(CYCLES) 
SRC_FLAGS = +define+SEED=$(SEED) 

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
