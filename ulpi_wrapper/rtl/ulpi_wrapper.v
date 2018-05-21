//-----------------------------------------------------------------
//                        ULPI (Link) Wrapper
//                              V1.1
//                        Ultra-Embedded.com
//                        Copyright 2015-2018
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

//-----------------------------------------------------------------
// Module: UTMI+ to ULPI Wrapper
//
// Description:
//   - Converts from UTMI interface to reduced pin count ULPI.
//   - No support for low power mode.
//   - I/O synchronous to 60MHz ULPI clock input (from PHY)
//   - Tested against SMSC/Microchip USB3300 in device mode.
//-----------------------------------------------------------------
module ulpi_wrapper
(
    // ULPI Interface (PHY)
    input             ulpi_clk60_i,
    input             ulpi_rst_i,
    input  [7:0]      ulpi_data_out_i,
    output [7:0]      ulpi_data_in_o,
    input             ulpi_dir_i,
    input             ulpi_nxt_i,
    output            ulpi_stp_o,

    // UTMI Interface (SIE)
    input             utmi_txvalid_i,
    output            utmi_txready_o,
    output            utmi_rxvalid_o,
    output            utmi_rxactive_o,
    output            utmi_rxerror_o,
    output [7:0]      utmi_data_in_o,
    input  [7:0]      utmi_data_out_i,  
    input  [1:0]      utmi_xcvrselect_i,
    input             utmi_termselect_i,
    input  [1:0]      utmi_op_mode_i,
    input             utmi_dppulldown_i,
    input             utmi_dmpulldown_i,
    output [1:0]      utmi_linestate_o
);

//-----------------------------------------------------------------
// States
//-----------------------------------------------------------------
localparam STATE_W          = 2;
localparam STATE_IDLE       = 2'd0;
localparam STATE_CMD        = 2'd1;
localparam STATE_DATA       = 2'd2;
localparam STATE_REG        = 2'd3;

reg [STATE_W-1:0]   state_q;

//-----------------------------------------------------------------
// Local Params
//-----------------------------------------------------------------
localparam REG_FUNC_CTRL = 8'h84;
localparam REG_OTG_CTRL  = 8'h8a;
localparam REG_TRANSMIT  = 8'h40;
localparam REG_WRITE     = 8'h80;
localparam REG_READ      = 8'hC0;

//-----------------------------------------------------------------
// UTMI Mode Select
//-----------------------------------------------------------------
reg         mode_update_q;
reg [1:0]   xcvrselect_q;
reg         termselect_q;
reg [1:0]   opmode_q;
reg         phy_reset_q;
reg         mode_write_q;

// Detect register write completion
wire mode_complete_w = (state_q == STATE_REG &&
                        mode_write_q         && 
                        ulpi_nxt_i           && 
                        !ulpi_dir_i);           // Not interrupted by a Rx

always @ (posedge ulpi_clk60_i or posedge ulpi_rst_i)
if (ulpi_rst_i)
begin
    mode_update_q   <= 1'b0;
    xcvrselect_q    <= 2'b0;
    termselect_q    <= 1'b0;
    opmode_q        <= 2'b11;
    phy_reset_q     <= 1'b1;
end
else
begin
    xcvrselect_q    <= utmi_xcvrselect_i;
    termselect_q    <= utmi_termselect_i;
    opmode_q        <= utmi_op_mode_i;

    if (mode_update_q && mode_complete_w)
    begin
        mode_update_q <= 1'b0;
        phy_reset_q   <= 1'b0;
    end
    else if (opmode_q     != utmi_op_mode_i     ||
             termselect_q != utmi_termselect_i ||
             xcvrselect_q != utmi_xcvrselect_i)
        mode_update_q <= 1'b1;
end

//-----------------------------------------------------------------
// UTMI OTG Control
//-----------------------------------------------------------------
reg otg_update_q;
reg dppulldown_q;
reg dmpulldown_q;
reg otg_write_q;

// Detect register write completion
wire otg_complete_w  = (state_q == STATE_REG &&
                        otg_write_q         && 
                        ulpi_nxt_i           && 
                        !ulpi_dir_i);           // Not interrupted by a Rx

always @ (posedge ulpi_clk60_i or posedge ulpi_rst_i)
if (ulpi_rst_i)
begin
    otg_update_q    <= 1'b0;
    dppulldown_q    <= 1'b1;
    dmpulldown_q    <= 1'b1;
end
else
begin
    dppulldown_q    <= utmi_dppulldown_i;
    dmpulldown_q    <= utmi_dmpulldown_i;

    if (otg_update_q && otg_complete_w)
        otg_update_q <= 1'b0;
    else if (dppulldown_q != utmi_dppulldown_i ||
             dmpulldown_q != utmi_dmpulldown_i)
        otg_update_q <= 1'b1;
end

//-----------------------------------------------------------------
// Bus turnaround detect
//-----------------------------------------------------------------
reg ulpi_dir_q;

always @ (posedge ulpi_clk60_i or posedge ulpi_rst_i)
if (ulpi_rst_i)
    ulpi_dir_q <= 1'b0;
else
    ulpi_dir_q <= ulpi_dir_i;

wire turnaround_w = ulpi_dir_q ^ ulpi_dir_i;

//-----------------------------------------------------------------
// Rx - Tx delay
//-----------------------------------------------------------------
localparam TX_DELAY_W       = 3;
localparam TX_START_DELAY   = 3'd7;

reg [TX_DELAY_W-1:0] tx_delay_q;

always @ (posedge ulpi_clk60_i or posedge ulpi_rst_i)
if (ulpi_rst_i)
    tx_delay_q <= {TX_DELAY_W{1'b0}};
else if (utmi_rxactive_o)
    tx_delay_q <= TX_START_DELAY;
else if (tx_delay_q != {TX_DELAY_W{1'b0}})
    tx_delay_q <= tx_delay_q - 1;

wire tx_delay_complete_w = (tx_delay_q == {TX_DELAY_W{1'b0}});

//-----------------------------------------------------------------
// Tx Buffer - decouple UTMI Tx from PHY I/O
//-----------------------------------------------------------------
reg [7:0] tx_buffer_q[0:1];
reg       tx_valid_q[0:1];
reg       tx_wr_idx_q;
reg       tx_rd_idx_q;

wire      utmi_tx_ready_w;
wire      utmi_tx_accept_w;

always @ (posedge ulpi_clk60_i or posedge ulpi_rst_i)
if (ulpi_rst_i)
begin
    tx_buffer_q[0] <= 8'b0;
    tx_buffer_q[1] <= 8'b0;
    tx_valid_q[0]  <= 1'b0;
    tx_valid_q[1]  <= 1'b0;
    tx_wr_idx_q    <= 1'b0;
    tx_rd_idx_q    <= 1'b0;
end    
else
begin
    // Push
    if (utmi_txvalid_i && utmi_txready_o)
    begin
        tx_buffer_q[tx_wr_idx_q] <= utmi_data_out_i;
        tx_valid_q[tx_wr_idx_q]  <= 1'b1;

        tx_wr_idx_q <= tx_wr_idx_q + 1'b1;
    end

    // Pop
    if (utmi_tx_ready_w && utmi_tx_accept_w)
    begin
        tx_valid_q[tx_rd_idx_q]  <= 1'b0;
        tx_rd_idx_q <= tx_rd_idx_q + 1'b1;
    end
end

// Tx buffer space (only accept after Rx->Tx turnaround delay)
assign utmi_txready_o  = ~tx_valid_q[tx_wr_idx_q] & tx_delay_complete_w;

assign utmi_tx_ready_w = tx_valid_q[tx_rd_idx_q];

wire [7:0] utmi_tx_data_w = tx_buffer_q[tx_rd_idx_q];

//-----------------------------------------------------------------
// Implementation
//-----------------------------------------------------------------

// Xilinx placement pragmas:
//synthesis attribute IOB of ulpi_data_q is "TRUE"
//synthesis attribute IOB of ulpi_stp_q is "TRUE"

reg [7:0]           ulpi_data_q;
reg                 ulpi_stp_q;
reg [7:0]           data_q;

reg                 utmi_rxvalid_q;
reg                 utmi_rxerror_q;
reg                 utmi_rxactive_q;
reg [1:0]           utmi_linestate_q;
reg [7:0]           utmi_data_q;

always @ (posedge ulpi_clk60_i or posedge ulpi_rst_i)
if (ulpi_rst_i)
begin
    state_q             <= STATE_IDLE;
    ulpi_data_q         <= 8'b0;
    data_q              <= 8'b0;
    ulpi_stp_q          <= 1'b1;

    utmi_rxvalid_q      <= 1'b0;
    utmi_rxerror_q      <= 1'b0;
    utmi_rxactive_q     <= 1'b0;
    utmi_linestate_q    <= 2'b0;
    utmi_data_q         <= 8'b0;

    mode_write_q        <= 1'b0;
    otg_write_q         <= 1'b0;
end
else
begin
    ulpi_stp_q          <= 1'b0;
    utmi_rxvalid_q      <= 1'b0;

    // Turnaround: Input + NXT - set RX_ACTIVE
    if (turnaround_w && ulpi_dir_i && ulpi_nxt_i)
    begin
        utmi_rxactive_q <= 1'b1;

        // Register write - abort
        if (state_q == STATE_REG)
        begin
            state_q       <= STATE_IDLE;
            ulpi_data_q   <= 8'b0;  // IDLE
        end
    end
    // Turnaround: Input -> Output - reset RX_ACTIVE
    else if (turnaround_w && !ulpi_dir_i)
    begin
        utmi_rxactive_q <= 1'b0;

        // Register write - abort
        if (state_q == STATE_REG)
        begin
            state_q       <= STATE_IDLE;
            ulpi_data_q   <= 8'b0;  // IDLE
        end
    end
    // Non-turnaround cycle
    else if (!turnaround_w)
    begin
        //-----------------------------------------------------------------
        // Input: RX_CMD (status)
        //-----------------------------------------------------------------
        if (ulpi_dir_i && !ulpi_nxt_i)
        begin
            // Phy status
            utmi_linestate_q <= ulpi_data_out_i[1:0];

            case (ulpi_data_out_i[5:4])
            2'b00:
            begin
                utmi_rxactive_q <= 1'b0;
                utmi_rxerror_q  <= 1'b0;
            end
            2'b01: 
            begin
                utmi_rxactive_q <= 1'b1;
                utmi_rxerror_q  <= 1'b0;
            end
            2'b11:
            begin
                utmi_rxactive_q <= 1'b1;
                utmi_rxerror_q  <= 1'b1;
            end
            default:
                ; // HOST_DISCONNECTED
            endcase
        end
        //-----------------------------------------------------------------
        // Input: RX_DATA
        //-----------------------------------------------------------------
        else if (ulpi_dir_i && ulpi_nxt_i)
        begin
            utmi_rxvalid_q  <= 1'b1;
            utmi_data_q     <= ulpi_data_out_i;
        end
        //-----------------------------------------------------------------
        // Output
        //-----------------------------------------------------------------
        else if (!ulpi_dir_i)
        begin        
            // IDLE: Pending mode update
            if ((state_q == STATE_IDLE) && mode_update_q)
            begin
                data_q        <= {1'b0, 1'b1, phy_reset_q, opmode_q, termselect_q, xcvrselect_q};
                ulpi_data_q   <= REG_FUNC_CTRL;

                otg_write_q   <= 1'b0;
                mode_write_q  <= 1'b1;

                state_q       <= STATE_CMD;
            end
            // IDLE: Pending OTG control update
            else if ((state_q == STATE_IDLE) && otg_update_q)
            begin
                data_q        <= {5'b0, dmpulldown_q, dppulldown_q, 1'b0};
                ulpi_data_q   <= REG_OTG_CTRL;

                otg_write_q   <= 1'b1;
                mode_write_q  <= 1'b0;

                state_q       <= STATE_CMD;
            end
            // IDLE: Pending transmit
            else if ((state_q == STATE_IDLE) && utmi_tx_ready_w)
            begin
                ulpi_data_q <= REG_TRANSMIT | {4'b0, utmi_tx_data_w[3:0]};
                state_q     <= STATE_DATA;
            end
            // Command
            else if ((state_q == STATE_CMD) && ulpi_nxt_i)
            begin
                // Write Register
                state_q     <= STATE_REG;
                ulpi_data_q <= data_q;
            end
            // Data (register write)
            else if (state_q == STATE_REG && ulpi_nxt_i)
            begin
                state_q       <= STATE_IDLE;
                ulpi_data_q   <= 8'b0;  // IDLE
                ulpi_stp_q    <= 1'b1;

                otg_write_q   <= 1'b0;
                mode_write_q  <= 1'b0;
            end
            // Data
            else if (state_q == STATE_DATA && ulpi_nxt_i)
            begin
                // End of packet
                if (!utmi_tx_ready_w)
                begin
                    state_q       <= STATE_IDLE;
                    ulpi_data_q   <= 8'b0;  // IDLE
                    ulpi_stp_q    <= 1'b1;
                end
                else
                begin
                    state_q        <= STATE_DATA;
                    ulpi_data_q    <= utmi_tx_data_w;
                end
            end
        end
    end
end

// Accept from buffer
assign utmi_tx_accept_w = ((state_q == STATE_IDLE) && !(mode_update_q || otg_update_q || turnaround_w) && !ulpi_dir_i) ||
                          (state_q == STATE_DATA && ulpi_nxt_i && !ulpi_dir_i);

//-----------------------------------------------------------------
// Assignments
//-----------------------------------------------------------------
// ULPI Interface
assign ulpi_data_in_o       = ulpi_data_q;
assign ulpi_stp_o           = ulpi_stp_q;

// UTMI Interface
assign utmi_linestate_o     = utmi_linestate_q;
assign utmi_data_in_o       = utmi_data_q;
assign utmi_rxerror_o       = utmi_rxerror_q;
assign utmi_rxactive_o      = utmi_rxactive_q;
assign utmi_rxvalid_o       = utmi_rxvalid_q;



endmodule
