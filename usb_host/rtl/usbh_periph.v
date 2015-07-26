//-----------------------------------------------------------------
//                        USB Full Speed Host
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

//-----------------------------------------------------------------
// Module: Peripheral interface for USB host
//-----------------------------------------------------------------
module usbh_periph
(
    // Clocking (48MHz) & Reset
    input               clk_i,
    input               rst_i,

    output              intr_o,

    // Peripheral Interface (from CPU)
    input [7:0]         addr_i,
    input [31:0]        data_i,
    output [31:0]       data_o,
    input               we_i,
    input               stb_i,

    // UTMI interface
    input [1:0]         utmi_linestate_i,
    input               utmi_rxerror_i,

    // Control
    output              sie_start_o,
    output              sie_sof_en_o,
    output              sie_rst_o,
    output     [7:0]    sie_token_pid_o,
    output     [10:0]   sie_token_data_o,
    output     [15:0]   sie_tx_count_o,
    output              sie_data_idx_o,
    output              sie_in_transfer_o,
    output              sie_resp_expected_o,

    // FIFO
    output     [7:0]    sie_tx_data_o,
    output              sie_tx_push_o,
    output              sie_tx_flush_o,
    output              sie_rx_pop_o,
    input [7:0]         sie_rx_data_i,

    // Status
    input               sie_rx_crc_err_i,
    input [7:0]         sie_rx_resp_pid_i,
    input               sie_rx_resp_timeout_i,
    input [15:0]        sie_rx_count_i,
    input               sie_rx_idle_i,
    input               sie_req_ack_i,
    input [15:0]        sie_sof_time_i,
    input               sie_rx_done_i,
    input               sie_tx_done_i,
    input               sie_sof_irq_i
);

//-----------------------------------------------------------------
// Peripheral Memory Map
//-----------------------------------------------------------------
`define USB_CTRL        8'h00
    `define USB_TX_FLUSH             2
    `define USB_ENABLE_SOF           1
    `define USB_RESET_ACTIVE         0
`define USB_STATUS      8'h00
    `define USB_STAT_SOF_TIME        31:16
    `define USB_STAT_RX_ERROR        2
    `define USB_STAT_LINESTATE_BITS  1:0
`define USB_IRQ         8'h04
`define USB_IRQ_MASK    8'h08
    `define USB_IRQ_SOF              0
    `define USB_IRQ_DONE             1
    `define USB_IRQ_ERR              2
`define USB_XFER_DATA   8'h0c
    `define USB_XFER_DATA_TX_LEN     15:0
`define USB_XFER_TOKEN  8'h10
    `define USB_XFER_START           31
    `define USB_XFER_IN              30
    `define USB_XFER_ACK             29
    `define USB_XFER_PID_DATAX       28
    `define USB_XFER_PID_BITS        23:16
`define USB_RX_STAT     8'h14
    `define USB_RX_STAT_START_PEND   31
    `define USB_RX_STAT_CRC_ERR      30
    `define USB_RX_STAT_RESP_TIMEOUT 29
    `define USB_RX_STAT_IDLE         28
    `define USB_RX_STAT_RESP_BITS    23:16
    `define USB_RX_STAT_COUNT_BITS   15:0
`define USB_WR_DATA     8'h18
`define USB_RD_DATA     8'h18

//-----------------------------------------------------------------
// Registers / Wires
//-----------------------------------------------------------------
reg          usb_err_q;

reg          intr_done_q;
reg          intr_sof_q;
reg          intr_err_q;

// Interrupt Mask
reg          intr_mask_done_q;
reg          intr_mask_sof_q;
reg          intr_mask_err_q;

// Control
reg          sie_start_q;
reg          sie_sof_en_q;
reg          sie_rst_q;
reg [7:0]    sie_token_pid_q;
reg [10:0]   sie_token_data_q;
reg [15:0]   sie_tx_count_q;
reg          sie_data_idx_q;
reg          sie_in_transfer_q;
reg          sie_resp_expected_q;

// FIFO
reg [7:0]    sie_tx_data_q;
reg          sie_tx_push_q;
reg          sie_tx_flush_q;
reg          sie_rx_pop_q;

//-----------------------------------------------------------------
// Control
//-----------------------------------------------------------------
always @ (posedge rst_i or posedge clk_i )
if (rst_i == 1'b1)
begin
    sie_sof_en_q   <= 1'b0;
    sie_rst_q      <= 1'b0;
    sie_tx_flush_q <= 1'b0;
end
// IO Write Cycle
else if (we_i && stb_i && (addr_i == `USB_CTRL))
begin
    sie_rst_q      <= data_i[`USB_RESET_ACTIVE];
    sie_sof_en_q   <= data_i[`USB_ENABLE_SOF];
    sie_tx_flush_q <= data_i[`USB_TX_FLUSH];
end
else
    sie_tx_flush_q <= 1'b0;

//-----------------------------------------------------------------
// Data FIFO Write
//-----------------------------------------------------------------
always @ (posedge rst_i or posedge clk_i )
if (rst_i == 1'b1)
begin
    sie_tx_data_q <= 8'h00;
    sie_tx_push_q <= 1'b0;
end
// IO Write Cycle
else if (we_i && stb_i && (addr_i == `USB_WR_DATA))
begin
    sie_tx_data_q <= data_i[7:0];
    sie_tx_push_q <= 1'b1;
end
else
    sie_tx_push_q  <= 1'b0;

//-----------------------------------------------------------------
// Tx Length
//-----------------------------------------------------------------
always @ (posedge rst_i or posedge clk_i )
if (rst_i == 1'b1)
    sie_tx_count_q  <= 16'h0000;
// IO Write Cycle
else if (we_i && stb_i && (addr_i == `USB_XFER_DATA))
    sie_tx_count_q  <= data_i[`USB_XFER_DATA_TX_LEN];

//-----------------------------------------------------------------
// Tx Token
//-----------------------------------------------------------------
always @ (posedge rst_i or posedge clk_i )
if (rst_i == 1'b1)
begin
    sie_start_q        <= 1'b0;
    sie_in_transfer_q  <= 1'b0;
    sie_resp_expected_q<= 1'b0;
    sie_token_pid_q    <= 8'h00;
    sie_token_data_q   <= 11'h000;
    sie_data_idx_q     <= 1'b0;
    
end
// IO Write Cycle
else if (we_i && stb_i && (addr_i == `USB_XFER_TOKEN))
begin
    sie_start_q        <= data_i[`USB_XFER_START];
    sie_in_transfer_q  <= data_i[`USB_XFER_IN];
    sie_resp_expected_q<= data_i[`USB_XFER_ACK];
    sie_data_idx_q     <= data_i[`USB_XFER_PID_DATAX];
    sie_token_pid_q    <= data_i[`USB_XFER_PID_BITS];
    sie_token_data_q   <= { data_i[9], data_i[10], data_i[11], data_i[12], data_i[13], data_i[14], data_i[15],
    data_i[5], data_i[6], data_i[7], data_i[8] };
end
else if (sie_req_ack_i)
    sie_start_q <= 1'b0;

//-----------------------------------------------------------------
// Interrupt Masks
//-----------------------------------------------------------------
always @ (posedge rst_i or posedge clk_i )
if (rst_i == 1'b1)
begin
    intr_mask_done_q   <= 1'b0;
    intr_mask_sof_q    <= 1'b0;
    intr_mask_err_q    <= 1'b0;
end
// IO Write Cycle
else if (we_i && stb_i && (addr_i == `USB_IRQ_MASK))
begin
    intr_mask_done_q   <= data_i[`USB_IRQ_DONE];
    intr_mask_sof_q    <= data_i[`USB_IRQ_SOF];
    intr_mask_err_q    <= data_i[`USB_IRQ_ERR];
end

//-----------------------------------------------------------------
// Record Errors
//-----------------------------------------------------------------
always @ (posedge rst_i or posedge clk_i )
if (rst_i == 1'b1)
    usb_err_q <= 1'b0;
// Clear error
else if (we_i && stb_i && (addr_i == `USB_XFER_TOKEN || addr_i == `USB_CTRL))
    usb_err_q <= 1'b0;
// Record bus errors
else if (utmi_rxerror_i)
    usb_err_q <= 1'b1;

//-----------------------------------------------------------------
// Data FIFO Read
//-----------------------------------------------------------------
always @ (posedge rst_i or posedge clk_i )
if (rst_i == 1'b1)
    sie_rx_pop_q  <= 1'b0;
// IO Read Cycle
else if (~we_i && stb_i && (addr_i == `USB_RD_DATA))
    sie_rx_pop_q  <= 1'b1;
else
    sie_rx_pop_q  <= 1'b0;

assign sie_start_o          = sie_start_q;
assign sie_sof_en_o         = sie_sof_en_q;
assign sie_rst_o            = sie_rst_q;
assign sie_token_pid_o      = sie_token_pid_q;
assign sie_token_data_o     = sie_token_data_q;
assign sie_tx_count_o       = sie_tx_count_q;
assign sie_data_idx_o       = sie_data_idx_q;
assign sie_in_transfer_o    = sie_in_transfer_q;
assign sie_resp_expected_o  = sie_resp_expected_q;
assign sie_tx_data_o        = sie_tx_data_q;
assign sie_tx_push_o        = sie_tx_push_q;
assign sie_tx_flush_o       = sie_tx_flush_q;
assign sie_rx_pop_o         = sie_rx_pop_q;

//-----------------------------------------------------------------
// Peripheral Registers (Read)
//-----------------------------------------------------------------
reg [31:0] data_r;

always @ *
begin
     data_r = 32'h00000000;

     case (addr_i)

     `USB_STATUS :
     begin
          data_r[`USB_STAT_SOF_TIME]        = sie_sof_time_i;
          data_r[`USB_STAT_RX_ERROR]        = usb_err_q;
          data_r[`USB_STAT_LINESTATE_BITS]  = utmi_linestate_i;    
     end

     `USB_RX_STAT :
     begin
          data_r[`USB_RX_STAT_START_PEND]    = sie_start_o;
          data_r[`USB_RX_STAT_CRC_ERR]       = sie_rx_crc_err_i;
          data_r[`USB_RX_STAT_RESP_TIMEOUT]  = sie_rx_resp_timeout_i;
          data_r[`USB_RX_STAT_IDLE]          = sie_rx_idle_i;
          data_r[`USB_RX_STAT_RESP_BITS]     = sie_rx_resp_pid_i;
          data_r[`USB_RX_STAT_COUNT_BITS]    = sie_rx_count_i;
     end     

     `USB_RD_DATA :
          data_r = {24'h000000, sie_rx_data_i};

     `USB_IRQ :
     begin
          data_r[`USB_IRQ_DONE] = intr_done_q;
          data_r[`USB_IRQ_SOF]  = intr_sof_q;
          data_r[`USB_IRQ_ERR]  = intr_err_q;
     end

     `USB_IRQ_MASK :
     begin
          data_r[`USB_IRQ_DONE] = intr_mask_done_q;
          data_r[`USB_IRQ_SOF]  = intr_mask_sof_q;
          data_r[`USB_IRQ_ERR]  = intr_mask_err_q;
     end  

     default :
          data_r = 32'h00000000;
     endcase
end

assign data_o = data_r;

//-----------------------------------------------------------------
// Interrupts
//-----------------------------------------------------------------
reg err_cond_q;
reg intr_q;

always @ (posedge rst_i or posedge clk_i )
if (rst_i == 1'b1)
begin
    intr_done_q   <= 1'b0;
    intr_sof_q    <= 1'b0;
    intr_err_q    <= 1'b0;
    err_cond_q    <= 1'b0;

    intr_q        <= 1'b0;
end
else
begin
    if (sie_rx_done_i || sie_tx_done_i)
        intr_done_q <= 1'b1;
    else if (we_i && stb_i && (addr_i == `USB_IRQ) && data_i[`USB_IRQ_DONE])
        intr_done_q <= 1'b0;

    if (sie_sof_irq_i)
        intr_sof_q  <= 1'b1;
    else if (we_i && stb_i && (addr_i == `USB_IRQ) && data_i[`USB_IRQ_SOF])
        intr_sof_q <= 1'b0;

    if ((sie_rx_crc_err_i || sie_rx_resp_timeout_i) && (!err_cond_q))
        intr_err_q <= 1'b1;
    else if (we_i && stb_i && (addr_i == `USB_IRQ) && data_i[`USB_IRQ_ERR])
        intr_err_q <= 1'b0;

    err_cond_q  <= (sie_rx_crc_err_i | sie_rx_resp_timeout_i);

    intr_q <= (intr_done_q & intr_mask_done_q) |
              (intr_err_q  & intr_mask_err_q)  |
              (intr_sof_q  & intr_mask_sof_q);
end

assign intr_o = intr_q;

endmodule
