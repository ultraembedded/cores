#########################################################
# Vars
#########################################################
SYSTEMC_HOME  ?= /opt/systemc-2.3.1

TRACE         ?= 1

RTL_DUT        = ../rtl/ulpi_wrapper.v

#########################################################
# Source
#########################################################
SRC          = $(wildcard *.cpp)

SRC_V        = tb_top.v
SRC_V       += $(RTL_DUT)

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

%.o : %.cpp
	gcc -c $(INC_PATH) $(CFLAGS) $< -o $@

$(VPI_OBJ).vpi: $(OBJ) 
	g++ -shared -o $(VPI_OBJ).vpi -Wl,--whole-archive $(LIB_OPT) $(OBJ) -Wl,--no-whole-archive

$(EXE) : $(SRC_V)
	iverilog -o $(EXE) $(SRC_V) $(VINC_PATH) $(VFLAGS)

run: $(EXE) $(VPI_OBJ).vpi
	vvp -M. -m$(VPI_OBJ) $(EXE) -vcd

clean: 
	rm -rf $(OBJ) dut.vpi *.vcd *.out
