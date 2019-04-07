//-----------------------------------------------------------------
//                     USB Full Speed Host
//                           V0.5
//                     Ultra-Embedded.com
//                     Copyright 2015-2019
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
//                          Generated File
//-----------------------------------------------------------------

module usbh_sie
(
    // Inputs
     input           clk_i
    ,input           rst_i
    ,input           start_i
    ,input           in_transfer_i
    ,input           sof_transfer_i
    ,input           resp_expected_i
    ,input  [  7:0]  token_pid_i
    ,input  [  6:0]  token_dev_i
    ,input  [  3:0]  token_ep_i
    ,input  [ 15:0]  data_len_i
    ,input           data_idx_i
    ,input  [  7:0]  tx_data_i
    ,input           utmi_txready_i
    ,input  [  7:0]  utmi_data_i
    ,input           utmi_rxvalid_i
    ,input           utmi_rxactive_i

    // Outputs
    ,output          ack_o
    ,output          tx_pop_o
    ,output [  7:0]  rx_data_o
    ,output          rx_push_o
    ,output          tx_done_o
    ,output          rx_done_o
    ,output          crc_err_o
    ,output          timeout_o
    ,output [  7:0]  response_o
    ,output [ 15:0]  rx_count_o
    ,output          idle_o
    ,output [  7:0]  utmi_data_o
    ,output          utmi_txvalid_o
);



//-----------------------------------------------------------------
// Registers / Wires
//-----------------------------------------------------------------
reg                 start_ack_q;

// Status
reg                 status_tx_done_q;
reg                 status_rx_done_q;
reg                 status_crc_err_q;
reg                 status_timeout_q;
reg [7:0]           status_response_q;

reg [15:0]          byte_count_q;
reg                 in_transfer_q;

reg [2:0]           rx_time_q;
reg                 rx_time_en_q;
reg [7:0]           last_tx_time_q;

reg                 send_data1_q;
reg                 send_sof_q;
reg                 send_ack_q;

// CRC16
reg [15:0]          crc_sum_q;
wire [15:0]         crc_out_w;
wire [7:0]          crc_data_in_w;

// CRC5
wire [4:0]          crc5_out_w;
wire [4:0]          crc5_next_w = crc5_out_w ^ 5'h1F;

reg [15:0]          token_q;

reg                 wait_resp_q;

reg [3:0]           state_q;

//-----------------------------------------------------------------
// Definitions
//-----------------------------------------------------------------
localparam RX_TIMEOUT       = 8'd255; // ~5uS @ 48MHz
localparam TX_IFS           = 8'd7; // 2 FS bit times (x5 CLKs @ 60MHz, x4 CLKs @ 48MHz)

localparam PID_OUT          = 8'hE1;
localparam PID_IN           = 8'h69;
localparam PID_SOF          = 8'hA5;
localparam PID_SETUP        = 8'h2D;

localparam PID_DATA0        = 8'hC3;
localparam PID_DATA1        = 8'h4B;

localparam PID_ACK          = 8'hD2;
localparam PID_NAK          = 8'h5A;
localparam PID_STALL        = 8'h1E;

// States
localparam STATE_IDLE       = 4'd0;
localparam STATE_RX_DATA    = 4'd1;
localparam STATE_TX_PID     = 4'd2;
localparam STATE_TX_DATA    = 4'd3;
localparam STATE_TX_CRC1    = 4'd4;
localparam STATE_TX_CRC2    = 4'd5;
localparam STATE_TX_TOKEN1  = 4'd6;
localparam STATE_TX_TOKEN2  = 4'd7;
localparam STATE_TX_TOKEN3  = 4'd8;
localparam STATE_TX_ACKNAK  = 4'd9;
localparam STATE_TX_WAIT    = 4'd10;
localparam STATE_RX_WAIT    = 4'd11;
localparam STATE_TX_IFS     = 4'd12;

localparam RX_TIME_ZERO     = 3'd0;
localparam RX_TIME_INC      = 3'd1;
localparam RX_TIME_READY    = 3'd7; // 2-bit times (x5 CLKs @ 60MHz, x4 CLKs @ 48MHz)

//-----------------------------------------------------------------
// Wires
//-----------------------------------------------------------------
// Rx data
wire [7:0] rx_data_w;
wire       data_ready_w;
wire       crc_byte_w;
wire       rx_active_w;

// 2-bit times after last RX (inter-packet delay)?
wire autoresp_thresh_w = send_ack_q & rx_time_en_q & (rx_time_q == RX_TIME_READY);

// Response timeout (no response after 500uS from transmit)
wire rx_resp_timeout_w = (last_tx_time_q >= RX_TIMEOUT) & wait_resp_q;

// Tx - Tx IFS timeout
wire tx_ifs_ready_w    = (last_tx_time_q >= TX_IFS);

// CRC16 error on received data
wire crc_error_w = (state_q == STATE_RX_DATA) && !rx_active_w && in_transfer_q        &&
                   (status_response_q == PID_DATA0 || status_response_q == PID_DATA1) &&
                   (crc_sum_q != 16'hB001);

//-----------------------------------------------------------------
// State Machine
//-----------------------------------------------------------------
reg [3:0] next_state_r;

always @ *
begin
    next_state_r = state_q;
        
    //-----------------------------------------
    // Tx State Machine
    //-----------------------------------------
    case (state_q)

        //-----------------------------------------
        // TX_TOKEN1 (byte 1 of token)
        //-----------------------------------------
        STATE_TX_TOKEN1 :
        begin
            // Data sent?
            if (utmi_txready_i)
                next_state_r = STATE_TX_TOKEN2;
        end
        //-----------------------------------------
        // TX_TOKEN2 (byte 2 of token)
        //-----------------------------------------
        STATE_TX_TOKEN2 :
        begin
            // Data sent?
            if (utmi_txready_i)
                next_state_r = STATE_TX_TOKEN3;        
        end
        //-----------------------------------------
        // TX_TOKEN3 (byte 3 of token)
        //-----------------------------------------
        STATE_TX_TOKEN3 :
        begin
            // Data sent?
            if (utmi_txready_i)
            begin
                // SOF - no data packet
                if (send_sof_q)
                    next_state_r = STATE_TX_IFS;
                // IN - wait for data
                else if (in_transfer_q)
                    next_state_r = STATE_RX_WAIT;
                // OUT/SETUP - Send data or ZLP
                else
                    next_state_r = STATE_TX_IFS;
            end
        end
        //-----------------------------------------
        // TX_IFS
        //-----------------------------------------
        STATE_TX_IFS :
        begin
            // IFS expired
            if (tx_ifs_ready_w)
            begin
                // SOF - no data packet
                if (send_sof_q)
                    next_state_r = STATE_IDLE;
                // OUT/SETUP - Send data or ZLP
                else
                    next_state_r = STATE_TX_PID;
            end
        end
        //-----------------------------------------
        // TX_PID
        //-----------------------------------------
        STATE_TX_PID :
        begin
            // Last data byte sent?
            if (utmi_txready_i && (byte_count_q == 16'b0))
                next_state_r = STATE_TX_CRC1;
            else if (utmi_txready_i)
                next_state_r = STATE_TX_DATA;
        end
        //-----------------------------------------
        // TX_DATA
        //-----------------------------------------
        STATE_TX_DATA :
        begin
            // Last data byte sent?
            if (utmi_txready_i && (byte_count_q == 16'b0))
                next_state_r = STATE_TX_CRC1;
        end
        //-----------------------------------------
        // TX_CRC1 (first byte)
        //-----------------------------------------
        STATE_TX_CRC1 :
        begin
            // Data sent?
            if (utmi_txready_i)
                next_state_r = STATE_TX_CRC2;
        end
        //-----------------------------------------
        // TX_CRC (second byte)
        //-----------------------------------------
        STATE_TX_CRC2 :
        begin
            // Data sent?
            if (utmi_txready_i)
            begin
               // If a response is expected
               if (wait_resp_q)
                  next_state_r = STATE_RX_WAIT;
                // No response expected (e.g ISO transfer)
               else
                  next_state_r = STATE_IDLE;                
            end
        end
        //-----------------------------------------
        // STATE_TX_WAIT
        //-----------------------------------------
        STATE_TX_WAIT :
        begin
            // Waited long enough?
            if (autoresp_thresh_w)
                next_state_r = STATE_TX_ACKNAK;
        end        
        //-----------------------------------------
        // STATE_TX_ACKNAK
        //-----------------------------------------
        STATE_TX_ACKNAK :
        begin
            // Data sent?
            if (utmi_txready_i)
                next_state_r = STATE_IDLE;
        end
        //-----------------------------------------
        // STATE_RX_WAIT
        //-----------------------------------------
        STATE_RX_WAIT :
        begin
           // Data received?
           if (data_ready_w)
              next_state_r = STATE_RX_DATA;
            // Waited long enough?
           else if (rx_resp_timeout_w)
              next_state_r = STATE_IDLE;
        end
        //-----------------------------------------
        // RX_DATA
        //-----------------------------------------
        STATE_RX_DATA :
        begin
            // Receive complete
            if (~rx_active_w)
            begin
                // Send ACK but incoming data had CRC error, do not ACK
                if (send_ack_q && crc_error_w)
                    next_state_r = STATE_IDLE;
                // Send an ACK response without CPU interaction?
                else if (send_ack_q && (status_response_q == PID_DATA0 || status_response_q == PID_DATA1))
                    next_state_r = STATE_TX_WAIT;
                else
                    next_state_r = STATE_IDLE;
            end
        end
        //-----------------------------------------
        // IDLE / RECEIVE BEGIN
        //-----------------------------------------
        STATE_IDLE :
        begin
           // Token transfer request
           if (start_i)
              next_state_r  = STATE_TX_TOKEN1;
        end
        default :
           ;
    endcase
end

// Update state
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    state_q   <= STATE_IDLE;
else
    state_q   <= next_state_r;

//-----------------------------------------------------------------
// Tx Token
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    token_q         <= 16'h0000;
else if (state_q == STATE_IDLE)
    token_q         <= {token_dev_i, token_ep_i, 5'b0};
// PID of token sent, capture calculated CRC for token packet
else if (state_q == STATE_TX_TOKEN1 && utmi_txready_i)
    token_q[4:0]    <= crc5_next_w;

//-----------------------------------------------------------------
// Tx Timer
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    last_tx_time_q <= 8'd0;
// Start counting from last Tx
else if (state_q == STATE_IDLE || (utmi_txvalid_o && utmi_txready_i))
    last_tx_time_q <= 8'd0;
// Increment the Tx timeout
else if (last_tx_time_q != RX_TIMEOUT)
    last_tx_time_q <= last_tx_time_q + 8'd1;

//-----------------------------------------------------------------
// Transmit / Receive counter
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    byte_count_q <= 16'h0000;
// New transfer request (not automatic SOF request)
else if (state_q == STATE_IDLE && start_i && !sof_transfer_i)
    byte_count_q <= data_len_i;
else if (state_q == STATE_RX_WAIT)
    byte_count_q <= 16'h0000;
// Transmit byte
else if ((state_q == STATE_TX_PID || state_q == STATE_TX_DATA) && utmi_txready_i)
begin
    // Count down data left to send
    if (byte_count_q != 16'd0)
        byte_count_q <= byte_count_q - 16'd1;
end
// Received byte
else if (state_q == STATE_RX_DATA && data_ready_w && !crc_byte_w)
    byte_count_q <= byte_count_q + 16'd1;

//-----------------------------------------------------------------
// Transfer start ack
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    start_ack_q  <= 1'b0;
// First byte of PID sent, ack transfer request
else if (state_q == STATE_TX_TOKEN1 && utmi_txready_i)
    start_ack_q  <= 1'b1;
else
    start_ack_q  <= 1'b0;

//-----------------------------------------------------------------
// Record request details
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
begin
    in_transfer_q   <= 1'b0;
    send_ack_q      <= 1'b0;
    send_data1_q    <= 1'b0;
    send_sof_q      <= 1'b0;
end
// Start of new request
else if (state_q == STATE_IDLE && start_i)
begin
    // Transfer request
    // e.g. (H)SOF                                   [sof_transfer_i]
    //      (H)OUT + (H)DATA + (F)ACK/NACK/STALL     [data_len_i >= 0 && !in_transfer_i]
    //      (H)IN  + (F)DATA + (H)ACK                [in_transfer_i]
    //      (H)IN  + (F)NAK/STALL                    [in_transfer_i]
    in_transfer_q   <= in_transfer_i;

    // Send ACK in response to IN DATA
    send_ack_q      <= in_transfer_i && resp_expected_i;

    // DATA0/1
    send_data1_q    <= data_idx_i;

    send_sof_q      <= sof_transfer_i;
end

//-----------------------------------------------------------------
// Response delay timer
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
begin
    rx_time_q       <= RX_TIME_ZERO;
    rx_time_en_q    <= 1'b0;
end
else if (state_q == STATE_IDLE)
begin
    rx_time_q       <= RX_TIME_ZERO;
    rx_time_en_q    <= 1'b0;
end
// Receive complete
else if (state_q == STATE_RX_DATA && !utmi_rxactive_i)
begin
    // Reset time since end of last data byte
    rx_time_q       <= RX_TIME_ZERO;
    rx_time_en_q    <= 1'b1;
end
// Increment timer if enabled (and less than the threshold)
else if (rx_time_en_q && rx_time_q != RX_TIME_READY)
    rx_time_q       <= rx_time_q + RX_TIME_INC;

// Response expected
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    wait_resp_q <= 1'b0;
// Incoming data
else if (state_q == STATE_RX_WAIT && data_ready_w)
    wait_resp_q <= 1'b0;
else if (state_q == STATE_IDLE && start_i)
    wait_resp_q <= resp_expected_i;

//-----------------------------------------------------------------
// Status
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
begin
   if (rst_i)
   begin
       status_response_q    <= 8'h00;
       status_timeout_q     <= 1'b0;
       status_rx_done_q     <= 1'b0;
       status_tx_done_q     <= 1'b0;
   end
   else
   begin
        case (state_q)

        //-----------------------------------------
        // RX_WAIT
        //-----------------------------------------
        STATE_RX_WAIT :
        begin
           // Store response PID
           if (data_ready_w)
               status_response_q   <= rx_data_w;

           // Waited long enough?
           if (rx_resp_timeout_w)
               status_timeout_q    <= 1'b1;

            status_tx_done_q     <= 1'b0;
        end
        //-----------------------------------------
        // RX_DATA
        //-----------------------------------------
        STATE_RX_DATA :
        begin
           // Receive complete
           if (!utmi_rxactive_i)
                status_rx_done_q   <= 1'b1;
           else
                status_rx_done_q   <= 1'b0;
        end
        //-----------------------------------------
        // TX_CRC (second byte)
        //-----------------------------------------
        STATE_TX_CRC2 :
        begin
            // Data sent?
            if (utmi_txready_i && !wait_resp_q)
            begin
                // Transfer now complete
                status_tx_done_q    <= 1'b1;
            end
        end
        //-----------------------------------------
        // IDLE / RECEIVE BEGIN
        //-----------------------------------------
        STATE_IDLE :
        begin
            // Transfer request
            // e.g. (H)SOF                                   [sof_transfer_i]
            //      (H)OUT + (H)DATA + (F)ACK/NACK/STALL     [data_len_i >= 0 && !in_transfer_i]
            //      (H)IN  + (F)DATA + (H)ACK                [in_transfer_i]
            //      (H)IN  + (F)NAK/STALL                    [in_transfer_i]
            if (start_i && !sof_transfer_i) // (not automatic SOF request)
            begin
                // Clear status
                status_response_q       <= 8'h00;
                status_timeout_q        <= 1'b0;
            end

            status_rx_done_q     <= 1'b0;
            status_tx_done_q     <= 1'b0;
        end
        //-----------------------------------------
        // DEFAULT
        //-----------------------------------------        
        default :
        begin
            status_rx_done_q     <= 1'b0;
            status_tx_done_q     <= 1'b0;
        end
       endcase
   end
end


//-----------------------------------------------------------------
// Data delay (to strip the CRC16 trailing bytes)
//-----------------------------------------------------------------
reg [31:0] data_buffer_q;
reg [3:0]  data_valid_q;
reg [3:0]  rx_active_q;

wire shift_en_w = (utmi_rxvalid_i & utmi_rxactive_i) || !utmi_rxactive_i;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    data_buffer_q <= 32'b0;
else if (shift_en_w)
    data_buffer_q <= {utmi_data_i, data_buffer_q[31:8]};

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    data_valid_q <= 4'b0;
else if (shift_en_w)
    data_valid_q <= {(utmi_rxvalid_i & utmi_rxactive_i), data_valid_q[3:1]};
else
    data_valid_q <= {data_valid_q[3:1], 1'b0};

reg [1:0] data_crc_q;
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    data_crc_q <= 2'b0;
else if (shift_en_w)
    data_crc_q <= {!utmi_rxactive_i, data_crc_q[1]};

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    rx_active_q <= 4'b0;
else
    rx_active_q <= {utmi_rxactive_i, rx_active_q[3:1]};

assign rx_data_w    = data_buffer_q[7:0];
assign data_ready_w = data_valid_q[0];
assign crc_byte_w   = data_crc_q[0];
assign rx_active_w  = rx_active_q[0];

//-----------------------------------------------------------------
// CRC
//-----------------------------------------------------------------

// CRC16 (Data)
usbh_crc16
u_crc16
(
    .crc_i(crc_sum_q),
    .data_i(crc_data_in_w),
    .crc_o(crc_out_w)
);

// CRC5 (Token)
usbh_crc5
u_crc5
(
    .crc_i(5'h1F),
    .data_i(token_q[15:5]),
    .crc_o(crc5_out_w)
);

// CRC control / check
always @ (posedge clk_i or posedge rst_i)
begin
   if (rst_i)
   begin
       crc_sum_q          <= 16'hFFFF;
       status_crc_err_q   <= 1'b0;
   end
   else
   begin
        case (state_q)
            //-----------------------------------------
            // TX_PID
            //-----------------------------------------
            STATE_TX_PID :
            begin
                // First byte is PID (not CRC'd), reset CRC16
                crc_sum_q      <= 16'hFFFF;
            end        
            //-----------------------------------------
            // TX_DATA
            //-----------------------------------------
            STATE_TX_DATA :
            begin
                // Data sent?
                if (utmi_txready_i)
                begin
                    // Next CRC start value
                    crc_sum_q      <= crc_out_w;
                end
            end
            //-----------------------------------------
            // RX_WAIT
            //-----------------------------------------
            STATE_RX_WAIT :
            begin
                // Reset CRC16
                crc_sum_q   <= 16'hFFFF;
            end            
            //-----------------------------------------
            // RX_DATA
            //-----------------------------------------
            STATE_RX_DATA :
            begin
               // Data received?
               if (data_ready_w)
               begin
                   // Next CRC start value
                   crc_sum_q          <= crc_out_w;
               end
               // Receive complete
               else if (!rx_active_w)
               begin
                    // If some data received, check CRC
                    if (crc_error_w)
                        status_crc_err_q   <= 1'b1;
                    else
                        status_crc_err_q   <= 1'b0;
               end
            end

            //-----------------------------------------
            // IDLE / RECEIVE BEGIN
            //-----------------------------------------
            STATE_IDLE :
            begin
               // Start transfer request
               if (start_i && !sof_transfer_i)
               begin
                  // Clear error flag!
                  status_crc_err_q  <= 1'b0;
               end
            end
           default :
               ;
        endcase
   end
end

//-----------------------------------------------------------------
// Assignments
//-----------------------------------------------------------------
wire [15:0] token_rev_w;

genvar i;
generate
for (i=0; i < 16; i=i+1) 
begin : LOOP
    assign token_rev_w[i] = token_q[15-i];
end
endgenerate

reg       utmi_txvalid_r;
reg [7:0] utmi_data_r;

always @ *
begin
    if (state_q == STATE_TX_CRC1)
    begin
        utmi_txvalid_r = 1'b1;
        utmi_data_r    = crc_sum_q[7:0] ^ 8'hFF;
    end
    else if (state_q == STATE_TX_CRC2)
    begin
        utmi_txvalid_r = 1'b1;
        utmi_data_r    = crc_sum_q[15:8] ^ 8'hFF;
    end
    else if (state_q == STATE_TX_TOKEN1)
    begin
        utmi_txvalid_r = 1'b1;
        utmi_data_r    = token_pid_i;
    end
    else if (state_q == STATE_TX_TOKEN2)
    begin
        utmi_txvalid_r = 1'b1;
        utmi_data_r    = token_rev_w[7:0];
    end
    else if (state_q == STATE_TX_TOKEN3)
    begin
        utmi_txvalid_r = 1'b1;
        utmi_data_r    = token_rev_w[15:8];
    end
    else if (state_q == STATE_TX_PID)
    begin
        utmi_txvalid_r = 1'b1;
        utmi_data_r    = send_data1_q ? PID_DATA1 : PID_DATA0;
    end
    else if (state_q == STATE_TX_ACKNAK)
    begin
        utmi_txvalid_r = 1'b1;
        utmi_data_r    = PID_ACK;
    end
    else if (state_q == STATE_TX_DATA)
    begin
        utmi_txvalid_r = 1'b1;
        utmi_data_r    = tx_data_i;
    end
    else
    begin
        utmi_txvalid_r = 1'b0;
        utmi_data_r    = 8'b0;
    end
end

assign utmi_txvalid_o = utmi_txvalid_r;
assign utmi_data_o    = utmi_data_r;

// Push incoming data into FIFO (not PID or CRC)
assign rx_data_o    = rx_data_w;
assign rx_push_o    = (state_q != STATE_IDLE && state_q != STATE_RX_WAIT) & data_ready_w & !crc_byte_w;

assign crc_data_in_w = (state_q == STATE_RX_DATA) ? rx_data_w : tx_data_i;

assign rx_count_o   = byte_count_q;
assign idle_o       = (state_q == STATE_IDLE);

assign ack_o        = start_ack_q;

assign tx_pop_o     = state_q == STATE_TX_DATA && utmi_txready_i;

assign tx_done_o    = status_tx_done_q;
assign rx_done_o    = status_rx_done_q;
assign crc_err_o    = status_crc_err_q;
assign timeout_o    = status_timeout_q;
assign response_o   = status_response_q;



endmodule
