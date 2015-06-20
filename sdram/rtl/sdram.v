//-----------------------------------------------------------------
//                      Simple SDRAM Controller
//                              V0.1
//                        Ultra-Embedded.com
//                          Copyright 2015
//
//                 Email: admin@ultra-embedded.com
//
//                         License: GPL
// If you would like a version with a more permissive license for
// use in closed source commercial applications please contact me
// for details.
//-----------------------------------------------------------------
//
// This file is open source HDL; you can redistribute it and/or 
// modify it under the terms of the GNU General Public License as 
// published by the Free Software Foundation; either version 2 of 
// the License, or (at your option) any later version.
//
// This file is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public 
// License along with this file; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
// USA
//-----------------------------------------------------------------
module sdram

//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
    parameter    SDRAM_MHZ             = 50,
    parameter    SDRAM_ADDR_W          = 24,
    parameter    SDRAM_COL_W           = 9,    
    parameter    SDRAM_BANK_W          = 2,
    parameter    SDRAM_DQM_W           = 2,
    parameter    SDRAM_BANKS           = 2 ** SDRAM_BANK_W,
    parameter    SDRAM_ROW_W           = SDRAM_ADDR_W - SDRAM_COL_W - SDRAM_BANK_W,
    parameter    SDRAM_REFRESH_CNT     = 2 ** SDRAM_ROW_W,
    parameter    SDRAM_START_DELAY     = 100000 / (1000 / SDRAM_MHZ), // 100uS
    parameter    SDRAM_REFRESH_CYCLES  = (64000*SDRAM_MHZ) / SDRAM_REFRESH_CNT-1,
    parameter    SDRAM_READ_LATENCY    = 2,
    parameter    SDRAM_TARGET          = "XILINX"
)

//-----------------------------------------------------------------
// Ports
//-----------------------------------------------------------------
(
    input           clk_i,
    input           rst_i,

    // Wishbone Interface
    input           stb_i,
    input           we_i,
    input [3:0]     sel_i,
    input           cyc_i,
    input [31:0]    addr_i,
    input [31:0]    data_i,
    output [31:0]   data_o,
    output          stall_o,
    output          ack_o,
    
    // SDRAM Interface
    output          sdram_clk_o,
    output          sdram_cke_o,
    output          sdram_cs_o,
    output          sdram_ras_o,
    output          sdram_cas_o,
    output          sdram_we_o,
    output [1:0]    sdram_dqm_o,
    output [12:0]   sdram_addr_o,
    output [1:0]    sdram_ba_o,
    inout [15:0]    sdram_data_io
);

//-----------------------------------------------------------------
// Defines / Local params
//-----------------------------------------------------------------
localparam CMD_W             = 4;
localparam CMD_NOP           = 4'b0111;
localparam CMD_ACTIVE        = 4'b0011;
localparam CMD_READ          = 4'b0101;
localparam CMD_WRITE         = 4'b0100;
localparam CMD_TERMINATE     = 4'b0110;
localparam CMD_PRECHARGE     = 4'b0010;
localparam CMD_REFRESH       = 4'b0001;
localparam CMD_LOAD_MODE     = 4'b0000;

// Mode: Burst Length = 4 bytes, CAS=2
localparam MODE_REG          = {3'b000,1'b0,2'b00,3'b010,1'b0,3'b001};

// SM states
localparam STATE_W           = 4;
localparam STATE_INIT        = 4'd0;
localparam STATE_DELAY       = 4'd1;
localparam STATE_IDLE        = 4'd2;
localparam STATE_ACTIVATE    = 4'd3;
localparam STATE_READ        = 4'd4;
localparam STATE_READ_WAIT   = 4'd5;
localparam STATE_WRITE0      = 4'd6;
localparam STATE_WRITE1      = 4'd7;
localparam STATE_PRECHARGE   = 4'd8;
localparam STATE_REFRESH     = 4'd9;

localparam AUTO_PRECHARGE    = 10;
localparam ALL_BANKS         = 10;

localparam SDRAM_DATA_W      = 16;

localparam CYCLE_TIME_NS     = 1000 / SDRAM_MHZ;

// SDRAM timing
localparam SDRAM_TRCD_CYCLES = (20 + (CYCLE_TIME_NS-1)) / CYCLE_TIME_NS;
localparam SDRAM_TRP_CYCLES  = (20 + (CYCLE_TIME_NS-1)) / CYCLE_TIME_NS;
localparam SDRAM_TRFC_CYCLES = (60 + (CYCLE_TIME_NS-1)) / CYCLE_TIME_NS;

//-----------------------------------------------------------------
// Registers / Wires
//-----------------------------------------------------------------

// Xilinx placement pragmas:
//synthesis attribute IOB of command_q is "TRUE"
//synthesis attribute IOB of addr_q is "TRUE"
//synthesis attribute IOB of dqm_q is "TRUE"
//synthesis attribute IOB of cke_q is "TRUE"
//synthesis attribute IOB of bank_q is "TRUE"
//synthesis attribute IOB of data_q is "TRUE"

reg [CMD_W-1:0]        command_q;
reg [SDRAM_ROW_W-1:0]  addr_q;
reg [SDRAM_DATA_W-1:0] data_q;
reg                    data_rd_en_q;
reg [SDRAM_DQM_W-1:0]  dqm_q;
reg                    cke_q;
reg [SDRAM_BANK_W-1:0] bank_q;

// Buffer half word during read and write commands
reg [SDRAM_DATA_W-1:0] data_buffer_q;
reg [SDRAM_DQM_W-1:0]  dqm_buffer_q;

wire [SDRAM_DATA_W-1:0] sdram_data_in_w;

reg                    refresh_q;

reg [SDRAM_BANKS-1:0]  row_open_q;
reg [SDRAM_ROW_W-1:0]  active_row_q[0:SDRAM_BANKS-1];

reg  [STATE_W-1:0]     state_q;
reg  [STATE_W-1:0]     next_state_r;
reg  [STATE_W-1:0]     target_state_r;
reg  [STATE_W-1:0]     target_state_q;
reg  [STATE_W-1:0]     delay_state_q;

// Address bits
wire [SDRAM_ROW_W-1:0]  addr_col_w  = {{(SDRAM_ROW_W-SDRAM_COL_W){1'b0}}, addr_i[SDRAM_COL_W:2], 1'b0};
wire [SDRAM_ROW_W-1:0]  addr_row_w  = addr_i[SDRAM_ADDR_W:SDRAM_COL_W+2+1];
wire [SDRAM_BANK_W-1:0] addr_bank_w = addr_i[SDRAM_COL_W+2:SDRAM_COL_W+2-1];

//-----------------------------------------------------------------
// SDRAM State Machine
//-----------------------------------------------------------------
always @ *
begin
    next_state_r   = state_q;
    target_state_r = target_state_q;

    case (state_q)
    //-----------------------------------------
    // STATE_INIT
    //-----------------------------------------
    STATE_INIT :
    begin
        if (refresh_q)
            next_state_r = STATE_IDLE;
    end
    //-----------------------------------------
    // STATE_IDLE
    //-----------------------------------------
    STATE_IDLE :
    begin
        // Pending refresh
        // Note: tRAS (open row time) cannot be exceeded due to periodic
        //        auto refreshes.
        if (refresh_q)
        begin
            // Close open rows, then refresh
            if (|row_open_q)
                next_state_r = STATE_PRECHARGE;
            else
                next_state_r = STATE_REFRESH;

            target_state_r = STATE_REFRESH;
        end
        // Access request
        else if (stb_i && cyc_i)
        begin
            // Open row hit
            if (row_open_q[addr_bank_w] && addr_row_w == active_row_q[addr_bank_w])
            begin
                if (we_i)
                    next_state_r = STATE_WRITE0;
                else
                    next_state_r = STATE_READ;
            end
            // Row miss, close row, open new row
            else if (row_open_q[addr_bank_w])
            begin
                next_state_r   = STATE_PRECHARGE;

                if (we_i)
                    target_state_r = STATE_WRITE0;
                else
                    target_state_r = STATE_READ;
            end
            // No open row, open row
            else
            begin
                next_state_r   = STATE_ACTIVATE;

                if (we_i)
                    target_state_r = STATE_WRITE0;
                else
                    target_state_r = STATE_READ;
            end
        end
    end
    //-----------------------------------------
    // STATE_ACTIVATE
    //-----------------------------------------
    STATE_ACTIVATE :
    begin
        // Proceed to read or write state
        next_state_r = target_state_r;
    end
    //-----------------------------------------
    // STATE_READ
    //-----------------------------------------
    STATE_READ :
    begin
        next_state_r = STATE_READ_WAIT;
    end
    //-----------------------------------------
    // STATE_READ_WAIT
    //-----------------------------------------
    STATE_READ_WAIT :
    begin
        next_state_r = STATE_IDLE;

        // Another pending read request (with no refresh pending)
        if (!refresh_q && stb_i && cyc_i && !we_i)
        begin
            // Open row hit
            if (row_open_q[addr_bank_w] && addr_row_w == active_row_q[addr_bank_w])
                next_state_r = STATE_READ;
        end
    end
    //-----------------------------------------
    // STATE_WRITE0
    //-----------------------------------------
    STATE_WRITE0 :
    begin
        next_state_r = STATE_WRITE1;
    end
    //-----------------------------------------
    // STATE_WRITE1
    //-----------------------------------------
    STATE_WRITE1 :
    begin
        next_state_r = STATE_IDLE;

        // Another pending write request (with no refresh pending)
        if (!refresh_q && stb_i && cyc_i && we_i)
        begin
            // Open row hit
            if (row_open_q[addr_bank_w] && addr_row_w == active_row_q[addr_bank_w])
                next_state_r = STATE_WRITE0;
        end
    end
    //-----------------------------------------
    // STATE_PRECHARGE
    //-----------------------------------------
    STATE_PRECHARGE :
    begin
        // Closing row to perform refresh
        if (target_state_r == STATE_REFRESH)
            next_state_r = STATE_REFRESH;
        // Must be closing row to open another
        else
            next_state_r = STATE_ACTIVATE;
    end
    //-----------------------------------------
    // STATE_REFRESH
    //-----------------------------------------
    STATE_REFRESH :
    begin
        next_state_r = STATE_IDLE;
    end
    //-----------------------------------------
    // STATE_DELAY
    //-----------------------------------------
    STATE_DELAY :
    begin
        next_state_r = delay_state_q;
    end
    default:
        ;
   endcase
end

//-----------------------------------------------------------------
// Delays
//-----------------------------------------------------------------
localparam DELAY_W = 4;

reg [DELAY_W-1:0] delay_q;
reg [DELAY_W-1:0] delay_r;

/* verilator lint_off WIDTH */

always @ *
begin
    case (state_q)
    //-----------------------------------------
    // STATE_ACTIVATE
    //-----------------------------------------
    STATE_ACTIVATE :
    begin
        // tRCD (ACTIVATE -> READ / WRITE)
        delay_r = SDRAM_TRCD_CYCLES;        
    end
    //-----------------------------------------
    // STATE_READ_WAIT
    //-----------------------------------------
    STATE_READ_WAIT :
    begin
        delay_r = SDRAM_READ_LATENCY;

        // Another pending read request (with no refresh pending)
        if (!refresh_q && stb_i && cyc_i && !we_i)
        begin
            // Open row hit
            if (row_open_q[addr_bank_w] && addr_row_w == active_row_q[addr_bank_w])
                delay_r = 4'd0;
        end        
    end    
    //-----------------------------------------
    // STATE_PRECHARGE
    //-----------------------------------------
    STATE_PRECHARGE :
    begin
        // tRP (PRECHARGE -> ACTIVATE)
        delay_r = SDRAM_TRP_CYCLES;
    end
    //-----------------------------------------
    // STATE_REFRESH
    //-----------------------------------------
    STATE_REFRESH :
    begin
        // tRFC
        delay_r = SDRAM_TRFC_CYCLES;
    end
    //-----------------------------------------
    // STATE_DELAY
    //-----------------------------------------
    STATE_DELAY:
    begin
        delay_r = delay_q - 4'd1;  
    end
    //-----------------------------------------
    // Others
    //-----------------------------------------
    default:
    begin
        delay_r = {DELAY_W{1'b0}};
    end
    endcase
end
/* verilator lint_on WIDTH */

// Record target state
always @ (posedge rst_i or posedge clk_i)
if (rst_i)
    target_state_q   <= STATE_IDLE;
else
    target_state_q   <= target_state_r;

// Record delayed state
always @ (posedge rst_i or posedge clk_i)
if (rst_i)
    delay_state_q   <= STATE_IDLE;
// On entering into delay state, record intended next state
else if (state_q != STATE_DELAY && delay_r != {DELAY_W{1'b0}})
    delay_state_q   <= next_state_r;

// Update actual state
always @ (posedge rst_i or posedge clk_i)
if (rst_i)
    state_q   <= STATE_INIT;
// Delaying...
else if (delay_r != {DELAY_W{1'b0}})
    state_q   <= STATE_DELAY;
else
    state_q   <= next_state_r;

// Update delay flops
always @ (posedge rst_i or posedge clk_i)
if (rst_i)
    delay_q   <= {DELAY_W{1'b0}};
else
    delay_q   <= delay_r;

//-----------------------------------------------------------------
// Refresh counter
//-----------------------------------------------------------------
localparam REFRESH_CNT_W = 17;

reg [REFRESH_CNT_W-1:0] refresh_timer_q;
always @ (posedge rst_i or posedge clk_i)
if (rst_i)
    refresh_timer_q <= SDRAM_START_DELAY + 100;
else if (refresh_timer_q == {REFRESH_CNT_W{1'b0}})
    refresh_timer_q <= SDRAM_REFRESH_CYCLES;
else
    refresh_timer_q <= refresh_timer_q - 1;

always @ (posedge rst_i or posedge clk_i)
if (rst_i)
    refresh_q <= 1'b0;
else if (refresh_timer_q == {REFRESH_CNT_W{1'b0}})
    refresh_q <= 1'b1;
else if (state_q == STATE_REFRESH)
    refresh_q <= 1'b0;

//-----------------------------------------------------------------
// Input sampling
//-----------------------------------------------------------------

reg [SDRAM_DATA_W-1:0] sample_data0_q;
always @ (posedge rst_i or posedge clk_i)
if (rst_i)
    sample_data0_q <= {SDRAM_DATA_W{1'b0}};
else
    sample_data0_q <= sdram_data_in_w;

reg [SDRAM_DATA_W-1:0] sample_data_q;
always @ (posedge rst_i or posedge clk_i)
if (rst_i)
    sample_data_q <= {SDRAM_DATA_W{1'b0}};
else
    sample_data_q <= sample_data0_q;

//-----------------------------------------------------------------
// Command Output
//-----------------------------------------------------------------
integer idx;

always @ (posedge rst_i or posedge clk_i)
if (rst_i)
begin
    command_q       <= CMD_NOP;
    data_q          <= 16'b0;
    addr_q          <= {SDRAM_ROW_W{1'b0}};
    bank_q          <= {SDRAM_BANK_W{1'b0}};
    cke_q           <= 1'b0; 
    dqm_q           <= {SDRAM_DQM_W{1'b0}};
    data_rd_en_q    <= 1'b1;
    dqm_buffer_q    <= {SDRAM_DQM_W{1'b0}};

    for (idx=0;idx<SDRAM_BANKS;idx=idx+1)
        active_row_q[idx] <= {SDRAM_ROW_W{1'b0}};

    row_open_q      <= {SDRAM_BANKS{1'b0}};
end
else
begin
    case (state_q)
    //-----------------------------------------
    // STATE_IDLE / Default (delays)
    //-----------------------------------------
    default:
    begin
        // Default
        command_q    <= CMD_NOP;
        addr_q       <= {SDRAM_ROW_W{1'b0}};
        bank_q       <= {SDRAM_BANK_W{1'b0}};
        data_rd_en_q <= 1'b1;
    end
    //-----------------------------------------
    // STATE_INIT
    //-----------------------------------------
    STATE_INIT:
    begin
        // Assert CKE
        if (refresh_timer_q == 50)
        begin
            // Assert CKE after 100uS
            cke_q <= 1'b1;
        end
        // PRECHARGE
        else if (refresh_timer_q == 40)
        begin
            // Precharge all banks
            command_q           <= CMD_PRECHARGE;
            addr_q[ALL_BANKS]   <= 1'b1;
        end
        // 2 x REFRESH (with at least tREF wait)
        else if (refresh_timer_q == 20 || refresh_timer_q == 30)
        begin
            command_q <= CMD_REFRESH;
        end
        // Load mode register
        else if (refresh_timer_q == 10)
        begin
            command_q <= CMD_LOAD_MODE;
            addr_q    <= MODE_REG;
        end
        // Other cycles during init - just NOP
        else
        begin
            command_q   <= CMD_NOP;
            addr_q      <= {SDRAM_ROW_W{1'b0}};
            bank_q      <= {SDRAM_BANK_W{1'b0}};
        end
    end
    //-----------------------------------------
    // STATE_ACTIVATE
    //-----------------------------------------
    STATE_ACTIVATE :
    begin
        // Select a row and activate it
        command_q     <= CMD_ACTIVE;
        addr_q        <= addr_row_w;
        bank_q        <= addr_bank_w;

        active_row_q[addr_bank_w]  <= addr_row_w;
        row_open_q[addr_bank_w]    <= 1'b1;
    end
    //-----------------------------------------
    // STATE_PRECHARGE
    //-----------------------------------------
    STATE_PRECHARGE :
    begin
        // Precharge due to refresh, close all banks
        if (target_state_r == STATE_REFRESH)
        begin
            // Precharge all banks
            command_q           <= CMD_PRECHARGE;
            addr_q[ALL_BANKS]   <= 1'b1;
            row_open_q          <= {SDRAM_BANKS{1'b0}};
        end
        else
        begin
            // Precharge specific banks
            command_q           <= CMD_PRECHARGE;
            addr_q[ALL_BANKS]   <= 1'b0;
            bank_q              <= addr_bank_w;

            row_open_q[addr_bank_w] <= 1'b0;
        end
    end
    //-----------------------------------------
    // STATE_REFRESH
    //-----------------------------------------
    STATE_REFRESH :
    begin
        // Auto refresh
        command_q   <= CMD_REFRESH;
        addr_q      <= {SDRAM_ROW_W{1'b0}};
        bank_q      <= {SDRAM_BANK_W{1'b0}};        
    end
    //-----------------------------------------
    // STATE_READ
    //-----------------------------------------
    STATE_READ :
    begin
        command_q   <= CMD_READ;
        addr_q      <= addr_col_w;
        bank_q      <= addr_bank_w;

        // Disable auto precharge (auto close of row)
        addr_q[AUTO_PRECHARGE]  <= 1'b0;

        // Read mask (all bytes in burst)
        dqm_q       <= {SDRAM_DQM_W{1'b0}};
    end
    //-----------------------------------------
    // STATE_WRITE0
    //-----------------------------------------
    STATE_WRITE0 :
    begin
        command_q       <= CMD_WRITE;
        addr_q          <= addr_col_w;
        bank_q          <= addr_bank_w;
        data_q          <= data_i[15:0];

        // Disable auto precharge (auto close of row)
        addr_q[AUTO_PRECHARGE]  <= 1'b0;

        // Write mask
        dqm_q           <= ~sel_i[1:0];
        dqm_buffer_q    <= ~sel_i[3:2];

        data_rd_en_q    <= 1'b0;
    end
    //-----------------------------------------
    // STATE_WRITE1
    //-----------------------------------------
    STATE_WRITE1 :
    begin
        // Burst continuation
        command_q   <= CMD_NOP;

        data_q      <= data_buffer_q;

        // Disable auto precharge (auto close of row)
        addr_q[AUTO_PRECHARGE]  <= 1'b0;

        // Write mask
        dqm_q       <= dqm_buffer_q;
    end
    endcase
end

//-----------------------------------------------------------------
// Record read events
//-----------------------------------------------------------------
reg [SDRAM_READ_LATENCY+1:0]  rd_q;

always @ (posedge rst_i or posedge clk_i)
if (rst_i)
    rd_q    <= {(SDRAM_READ_LATENCY+2){1'b0}};
else
    rd_q    <= {rd_q[SDRAM_READ_LATENCY:0], (state_q == STATE_READ)};

//-----------------------------------------------------------------
// Data Buffer
//-----------------------------------------------------------------

// Buffer upper 16-bits of write data so write command can be accepted
// in WRITE0. Also buffer lower 16-bits of read data.
always @ (posedge rst_i or posedge clk_i)
if (rst_i)
    data_buffer_q <= 16'b0;
else if (state_q == STATE_WRITE0)
    data_buffer_q <= data_i[31:16];
else if (rd_q[SDRAM_READ_LATENCY+1])
    data_buffer_q <= sample_data_q;

// Read data output
assign data_o = {sample_data_q, data_buffer_q};

//-----------------------------------------------------------------
// Wishbone ACK
//-----------------------------------------------------------------
reg ack_q;

always @ (posedge rst_i or posedge clk_i)
if (rst_i)
    ack_q   <= 1'b0;
else
begin
    if (state_q == STATE_WRITE1)
        ack_q <= 1'b1;
    else if (rd_q[SDRAM_READ_LATENCY+1])
        ack_q <= 1'b1;
    else
        ack_q <= 1'b0;
end

assign ack_o  = ack_q;

// Accept wishbone command in READ or WRITE0 states
assign stall_o = ~(state_q == STATE_READ || state_q == STATE_WRITE0);

//-----------------------------------------------------------------
// SDRAM I/O
//-----------------------------------------------------------------
genvar i;

generate 
if (SDRAM_TARGET == "XILINX")
begin
    // 180 degree phase delayed sdram clock output
    ODDR2 
    #(
        .DDR_ALIGNMENT("NONE"),
        .INIT(1'b0),
        .SRTYPE("SYNC")
    )
    u_clock_delay
    (
        .Q(sdram_clk_o),
        .C0(clk_i),
        .C1(~clk_i),
        .CE(1'b1),
        .R(1'b0),
        .S(1'b0),
        .D0(1'b0),
        .D1(1'b1)
    );

    for (i=0; i < 16; i = i + 1) 
    begin
      IOBUF 
      #(
        .DRIVE(12),
        .IOSTANDARD("LVTTL"),
        .SLEW("FAST")
      )
      u_data_buf
      (
        .O(sdram_data_in_w[i]),
        .IO(sdram_data_io[i]),
        .I(data_q[i]),
        .T(data_rd_en_q)
      );
    end
end
else
begin
    assign sdram_clk_o     = ~clk_i;
    assign sdram_data_io   = data_rd_en_q ? 16'bz : data_q;
    assign sdram_data_in_w = sdram_data_io;
end
endgenerate

assign sdram_cke_o  = cke_q;
assign sdram_cs_o   = command_q[3];
assign sdram_ras_o  = command_q[2];
assign sdram_cas_o  = command_q[1];
assign sdram_we_o   = command_q[0];
assign sdram_dqm_o  = dqm_q;
assign sdram_ba_o   = bank_q;
assign sdram_addr_o = addr_q;

endmodule
