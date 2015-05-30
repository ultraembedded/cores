`timescale 100ps/100ps

//-----------------------------------------------------------------
// Module
//-----------------------------------------------------------------
module top_tb ;

//-----------------------------------------------------------------
// Simulation
//-----------------------------------------------------------------
`include "simulation.svh"

`CLOCK_GEN(clk, 200)
`RESET_GEN(rst, 200)

`ifdef TRACE
    `TB_VCD(top_tb, "waveform.vcd")
`endif

`TB_RUN_FOR(10ms)

//-----------------------------------------------------------------
// Registers / Wires
//-----------------------------------------------------------------
wire [31:0] addr;
wire [31:0] data_w;
wire [31:0] data_r;
wire [3:0]  sel;
wire [2:0]  cti;
wire        stb;
wire        cyc;
wire        we;
wire        stall;
wire        ack;

// SDRAM Interface
wire          sdram_clk;
wire          sdram_cke;
wire          sdram_cs;
wire          sdram_ras;
wire          sdram_cas;
wire          sdram_we;
wire [1:0]    sdram_dqm;
wire [12:0]   sdram_addr;
wire [1:0]    sdram_ba;
wire [15:0]   sdram_data;

//-----------------------------------------------------------------
// Instantiation
//-----------------------------------------------------------------

// Wishbone master
wb_master
#(
    .MIN_ADDRESS(0),
    .MAX_ADDRESS(`MAX_ADDRESS),
    .BURST_ENABLED(1),
    .READ_ONLY(0)
)
u_master
(
    .clk_i(clk),
    .rst_i(rst),

    // Wishbone I/F
    .addr_o(addr),
    .data_o(data_w),
    .data_i(data_r),
    .stb_o(stb),
    .sel_o(sel),
    .cyc_o(cyc),
    .cti_o(cti),
    .we_o(we),
    .stall_i(stall),
    .ack_i(ack)
);

// SDRAM Controller
sdram
#( 
    .SDRAM_START_DELAY(1000),
    .SDRAM_TARGET("SIMULATION") 
)
u_dut
(
    .clk_i(clk),
    .rst_i(rst),

    // Wishbone I/F
    .addr_i(addr),
    .data_i(data_w),
    .data_o(data_r),
    .stb_i(stb),
    .sel_i(sel),
    .cyc_i(cyc),
    .we_i(we),
    .stall_o(stall),
    .ack_o(ack),

    // SDRAM Interface
    .sdram_clk_o(sdram_clk),
    .sdram_cke_o(sdram_cke),
    .sdram_cs_o(sdram_cs),
    .sdram_ras_o(sdram_ras),
    .sdram_cas_o(sdram_cas),
    .sdram_we_o(sdram_we),
    .sdram_dqm_o(sdram_dqm),
    .sdram_addr_o(sdram_addr),
    .sdram_ba_o(sdram_ba),
    .sdram_data_io(sdram_data)
);

// SDRAM
`PART
u_ram
(
    .dq(sdram_data), 
    .addr(sdram_addr), 
    .ba(sdram_ba), 
    .clk(sdram_clk), 
    .cke(sdram_cke), 
    .csb(sdram_cs), 
    .rasb(sdram_ras), 
    .casb(sdram_cas), 
    .web(sdram_we), 
    .dqm(sdram_dqm)
);

//-------------------------------------------------------------------
// Debug
//-------------------------------------------------------------------
integer perf_cycles;
integer perf_resps;

initial
begin
    perf_cycles = 0;
    perf_resps  = 0;
end

always @ (posedge clk)
begin
    perf_cycles = perf_cycles + 1;
    if (ack)
        perf_resps  = perf_resps + 1;

    if (perf_cycles == 50000)
    begin
        $display("Transfer Rate = %dMB/s\n", ((perf_resps * 4) * 1000) / 1048576);
        perf_resps = 0;
        perf_cycles = 0;
    end
end

//-----------------------------------------------------------------
// Test bench timeout
//-----------------------------------------------------------------
`TB_TIMEOUT(clk, rst, stb && !stall, 100000)

endmodule
