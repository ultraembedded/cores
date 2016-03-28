#########################################################
# Vars
#########################################################
SYSTEMC_HOME  ?= /usr/local/systemc-2.3.1

GENERATE_PATH ?= ~/svn_vhdl/tools/sysc_wrap
GENERATE_CMD  ?= python $(GENERATE_PATH)/generate.py
GENERATE_ARGS ?=

TRACE         ?= 1

DUT_NAME       = spdif
RTL_DUT        = ../rtl/spdif.v

#########################################################
# Source
#########################################################
SRC          = $(wildcard *.cpp)

SRC_V        = tb_top.v
SRC_V       += $(RTL_DUT)
SRC_V       += ../rtl/spdif_core.v

OBJ          = $(patsubst %.cpp,%.o,$(SRC)) 

VPI_OBJ      = dut

#########################################################
# CFLAGS
#########################################################
INC_PATH  = -I.
INC_PATH += -I/usr/include/iverilog
INC_PATH += -I$(SYSTEMC_HOME)/include

VINC_PATH = -I. -I../rtl
VFLAGS    = -DTRACE=$(TRACE)

CFLAGS    = -c -fpic

LIB_OPT   = $(SYSTEMC_HOME)/lib-linux64/libsystemc.a

EXE       = output.out

#########################################################
# Rules
#########################################################
all: run

tb_top.v: $(RTL_DUT)
	$(GENERATE_CMD) $(RTL_DUT) $@ $(GENERATE_PATH)/tb_top.v.mk $(GENERATE_ARGS)

$(DUT_NAME)_vpi.h: $(RTL_DUT)
	$(GENERATE_CMD) $(RTL_DUT) $@ $(GENERATE_PATH)/dut_vpi.h.mk $(GENERATE_ARGS)

%.o : %.cpp $(DUT_NAME)_vpi.h
	gcc -c $(INC_PATH) $(CFLAGS) $< -o $@

$(VPI_OBJ).vpi: $(OBJ) 
	g++ -shared -o $(VPI_OBJ).vpi -Wl,--whole-archive $(LIB_OPT) $(OBJ) -Wl,--no-whole-archive

$(EXE) : $(SRC_V)
	iverilog -o $(EXE) $(SRC_V) $(VINC_PATH) $(VFLAGS)

run: $(EXE) $(VPI_OBJ).vpi
	vvp -M. -m$(VPI_OBJ) $(EXE) -vcd

view:
	gtkwave waveform.vcd gtksettings.sav  

clean:
	rm -rf $(OBJ) dut.vpi *.vcd *.out tb_top.v $(DUT_NAME)_vpi.h