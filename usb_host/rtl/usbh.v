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
// Module: Basic USB host interface
//-----------------------------------------------------------------
module usbh

//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
    parameter    TX_FIFO_DEPTH        = 64,
    parameter    TX_FIFO_ADDR_W       = 6,
    parameter    RX_FIFO_DEPTH        = 64,
    parameter    RX_FIFO_ADDR_W       = 6
)

//-----------------------------------------------------------------
// Ports
//-----------------------------------------------------------------
(
    // Clocking (48MHz) & Reset
    input               clk_i,
    input               rst_i,

    // Interrupt output
    output              intr_o,
    
    // Peripheral Interface (from CPU)
    input [7:0]         addr_i,
    input [31:0]        data_i,
    output [31:0]       data_o,
    input               we_i,
    input               stb_i,  

    // UTMI Interface    
    output [7:0]        utmi_data_o,
    output              utmi_txvalid_o,
    input               utmi_txready_i,
    input [7:0]         utmi_data_i,
    input               utmi_rxvalid_i,
    input               utmi_rxactive_i,
    input               utmi_rxerror_i,
    input [1:0]         utmi_linestate_i,

    output              usb_rst_o
);

//-----------------------------------------------------------------
// Registers / Wires
//-----------------------------------------------------------------
// SOF
reg [10:0]  sof_value_q;
reg [15:0]  sof_time_q;
reg         sof_irq_q;

reg         transfer_req_ack_q;

// Requests for transfers
wire        ctrl_sof_en_w;
wire        ctrl_in_transfer_w;
wire        ctrl_resp_expected_w;
wire        ctrl_data_idx_w;
wire [15:0] ctrl_tx_count_w;
wire [7:0]  ctrl_token_pid_w;
wire [10:0] ctrl_token_data_w;

wire [7:0]  fifo_tx_data_w;
wire        fifo_tx_pop_w;

wire [7:0]  fifo_rx_data_w;
wire        fifo_rx_push_w;

wire [7:0]  ctrl_fifo_tx_data_w;
wire        ctrl_fifo_tx_push_w;
wire        ctrl_fifo_tx_flush_w;

wire [7:0]  ctrl_fifo_rx_data_w;
wire        ctrl_fifo_rx_pop_w;

wire        ctrl_start_w;

reg         fifo_flush_q;

wire [7:0]  token_pid_w;
wire [6:0]  token_dev_w;
wire [3:0]  token_ep_w;

reg         transfer_start_q;
reg         in_transfer_q;
reg         sof_transfer_q;
reg         resp_expected_q;
wire        transfer_ack_w;

wire        status_crc_err_w;
wire        status_timeout_w;
wire [7:0]  status_response_w;
wire [15:0] status_rx_count_w;
wire        status_sie_idle_w;
wire        status_tx_done_w;
wire        status_rx_done_w;

wire        send_sof_w;
wire        sof_gaurd_band_w;
wire        clear_to_send_w;

//-----------------------------------------------------------------
// Definitions
//-----------------------------------------------------------------
localparam [15:0] SOF_ZERO        = 0;
localparam [15:0] SOF_INC         = 1;
localparam [15:0] SOF_THRESHOLD   = 48000;

localparam [15:0] EOF1_THRESHOLD  = (50 * 4); // EOF1 + some margin
localparam [15:0] MAX_XFER_SIZE   = (TX_FIFO_DEPTH > RX_FIFO_DEPTH) ? TX_FIFO_DEPTH : RX_FIFO_DEPTH;
localparam [15:0] MAX_XFER_PERIOD = ((MAX_XFER_SIZE + 6) * 10  * 4); // Max packet transfer time (+ margin)
localparam [15:0] SOF_GAURD_LOW   = (20 * 4);
localparam [15:0] SOF_GAURD_HIGH  = SOF_THRESHOLD - EOF1_THRESHOLD - MAX_XFER_PERIOD;

localparam PID_OUT      = 8'hE1;
localparam PID_IN       = 8'h69;
localparam PID_SOF      = 8'hA5;
localparam PID_SETUP    = 8'h2D;

localparam PID_DATA0    = 8'hC3;
localparam PID_DATA1    = 8'h4B;

localparam PID_ACK      = 8'hD2;
localparam PID_NAK      = 8'h5A;
localparam PID_STALL    = 8'h1E;

//-----------------------------------------------------------------
// SIE
//-----------------------------------------------------------------
usbh_sie
u_sie
(
    // Clock (48MHz) & reset
    .clk_i(clk_i),
    .rst_i(rst_i),

    // Control
    .start_i(transfer_start_q),
    .in_transfer_i(in_transfer_q),
    .sof_transfer_i(sof_transfer_q),
    .resp_expected_i(resp_expected_q),    
    .ack_o(transfer_ack_w),

    // Token packet    
    .token_pid_i(token_pid_w),
    .token_dev_i(token_dev_w),
    .token_ep_i(token_ep_w),

    // Data packet
    .data_len_i(ctrl_tx_count_w),
    .data_idx_i(ctrl_data_idx_w),

    // Tx Data FIFO
    .tx_data_i(fifo_tx_data_w),
    .tx_pop_o(fifo_tx_pop_w),

    // Rx Data FIFO
    .rx_data_o(fifo_rx_data_w),
    .rx_push_o(fifo_rx_push_w),

    // Status
    .rx_done_o(status_rx_done_w),
    .tx_done_o(status_tx_done_w),
    .crc_err_o(status_crc_err_w),
    .timeout_o(status_timeout_w),
    .response_o(status_response_w),
    .rx_count_o(status_rx_count_w),
    .idle_o(status_sie_idle_w),

    // UTMI Interface
    .utmi_data_o(utmi_data_o),
    .utmi_txvalid_o(utmi_txvalid_o),
    .utmi_txready_i(utmi_txready_i),
    .utmi_data_i(utmi_data_i),
    .utmi_rxvalid_i(utmi_rxvalid_i),
    .utmi_rxactive_i(utmi_rxactive_i)
);    

//-----------------------------------------------------------------
// Peripheral Interface
//-----------------------------------------------------------------
usbh_periph
u_pif
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .intr_o(intr_o),

    // Peripheral Interface (from CPU)
    .addr_i(addr_i),
    .data_i(data_i),
    .data_o(data_o),
    .we_i(we_i),
    .stb_i(stb_i),

    // UTMI interface
    .utmi_linestate_i(utmi_linestate_i),
    .utmi_rxerror_i(utmi_rxerror_i),

    // Control
    .sie_start_o(ctrl_start_w),
    .sie_sof_en_o(ctrl_sof_en_w),
    .sie_rst_o(usb_rst_o),
    .sie_token_pid_o(ctrl_token_pid_w),
    .sie_token_data_o(ctrl_token_data_w),
    .sie_tx_count_o(ctrl_tx_count_w), 
    .sie_data_idx_o(ctrl_data_idx_w),
    .sie_in_transfer_o(ctrl_in_transfer_w),
    .sie_resp_expected_o(ctrl_resp_expected_w),

    // FIFO
    .sie_tx_data_o(ctrl_fifo_tx_data_w),
    .sie_tx_push_o(ctrl_fifo_tx_push_w),
    .sie_tx_flush_o(ctrl_fifo_tx_flush_w),
    .sie_rx_pop_o(ctrl_fifo_rx_pop_w),
    .sie_rx_data_i(ctrl_fifo_rx_data_w),

    // Status
    .sie_rx_crc_err_i(status_crc_err_w),
    .sie_rx_resp_timeout_i(status_timeout_w),
    .sie_rx_resp_pid_i(status_response_w),
    .sie_rx_count_i(status_rx_count_w),
    .sie_rx_idle_i(status_sie_idle_w),
    .sie_req_ack_i(transfer_req_ack_q),
    .sie_sof_time_i(sof_time_q),
    .sie_rx_done_i(status_rx_done_w),
    .sie_tx_done_i(status_tx_done_w),
    .sie_sof_irq_i(sof_irq_q)
);

//-----------------------------------------------------------------
// Tx FIFO (Host -> Device)
//-----------------------------------------------------------------
usbh_fifo
#(
    .DEPTH(TX_FIFO_DEPTH),
    .ADDR_W(TX_FIFO_ADDR_W)
)
u_fifo_tx
(
  .clk_i(clk_i),
  .rst_i(rst_i),

  .data_i(ctrl_fifo_tx_data_w),
  .push_i(ctrl_fifo_tx_push_w),

  .flush_i(ctrl_fifo_tx_flush_w),

  .full_o(),
  .empty_o(),

  .data_o(fifo_tx_data_w),
  .pop_i(fifo_tx_pop_w)
);

//-----------------------------------------------------------------
// Rx FIFO (Device -> Host)
//-----------------------------------------------------------------
usbh_fifo
#(
    .DEPTH(RX_FIFO_DEPTH),
    .ADDR_W(RX_FIFO_ADDR_W)
)
u_fifo_rx
(
  .clk_i(clk_i),
  .rst_i(rst_i),

  // Receive from UTMI interface
  .data_i(fifo_rx_data_w),
  .push_i(fifo_rx_push_w),

  .flush_i(fifo_flush_q),

  .full_o(),
  .empty_o(),

  .data_o(ctrl_fifo_rx_data_w),
  .pop_i(ctrl_fifo_rx_pop_w)
);

//-----------------------------------------------------------------
// Assignments
//-----------------------------------------------------------------
assign send_sof_w       = (sof_time_q == SOF_THRESHOLD && ctrl_sof_en_w) & status_sie_idle_w;
assign sof_gaurd_band_w = (sof_time_q <= SOF_GAURD_LOW || sof_time_q >= SOF_GAURD_HIGH);
assign clear_to_send_w  = (~sof_gaurd_band_w | ~ctrl_sof_en_w) & status_sie_idle_w;

assign token_pid_w      = sof_transfer_q ? PID_SOF : ctrl_token_pid_w;

assign token_dev_w      = sof_transfer_q ? 
                          {sof_value_q[0], sof_value_q[1], sof_value_q[2], 
                          sof_value_q[3], sof_value_q[4], sof_value_q[5], sof_value_q[6]} :
                          ctrl_token_data_w[10:4];

assign token_ep_w       = sof_transfer_q ? 
                          {sof_value_q[7], sof_value_q[8], sof_value_q[9], sof_value_q[10]} : 
                          ctrl_token_data_w[3:0];

//-----------------------------------------------------------------
// Control logic
//-----------------------------------------------------------------
always @ (posedge rst_i or posedge clk_i )
begin
   if (rst_i == 1'b1)
   begin
       fifo_flush_q       <= 1'b0;
       transfer_start_q   <= 1'b0;
       sof_transfer_q     <= 1'b0;
       transfer_req_ack_q <= 1'b0;
       in_transfer_q      <= 1'b0;
       resp_expected_q    <= 1'b0;
   end
   else
   begin
       // Transfer in progress?
       if (transfer_start_q)
       begin
            // Transfer accepted
            if (transfer_ack_w)
                transfer_start_q   <= 1'b0;

            fifo_flush_q       <= 1'b0;
            transfer_req_ack_q <= 1'b0;
       end
       // Time to send another SOF token?
       else if (send_sof_w)
       begin
            // Start transfer
            in_transfer_q     <= 1'b0;
            resp_expected_q   <= 1'b0;
            transfer_start_q  <= 1'b1;
            sof_transfer_q    <= 1'b1;
       end               
       // Not in SOF gaurd band region or SOF disabled?
       else if (clear_to_send_w)
       begin
            // Transfer request
            if (ctrl_start_w)
            begin              
                // Flush un-used previous Rx data
                fifo_flush_q       <= 1'b1;

                // Start transfer
                in_transfer_q      <= ctrl_in_transfer_w;
                resp_expected_q    <= ctrl_resp_expected_w;
                transfer_start_q   <= 1'b1;
                sof_transfer_q     <= 1'b0;
                transfer_req_ack_q <= 1'b1;
            end
      end
   end
end

//-----------------------------------------------------------------
// SOF Frame Number
//-----------------------------------------------------------------
always @ (posedge rst_i or posedge clk_i )
begin
    if (rst_i == 1'b1)
    begin
        sof_value_q    <= 11'd0;
        sof_time_q     <= SOF_ZERO;
        sof_irq_q      <= 1'b0;
    end
    // Time to send another SOF token?
    else if (send_sof_w)
    begin
        sof_time_q    <= SOF_ZERO;
        sof_value_q   <= sof_value_q + 11'd1;

        // Start of frame interrupt
        sof_irq_q     <= 1'b1;
    end
    else
    begin
        // Increment the SOF timer
        if (sof_time_q != SOF_THRESHOLD)
            sof_time_q <= sof_time_q + SOF_INC;

        sof_irq_q     <= 1'b0;
    end
end

endmodule

