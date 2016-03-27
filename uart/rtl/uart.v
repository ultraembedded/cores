//-----------------------------------------------------------------
//                          Wishbone UART
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
// Module:
//-----------------------------------------------------------------
module uart

//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
    parameter UART_DIVISOR_W   = 9
)

//-----------------------------------------------------------------
// Ports
//-----------------------------------------------------------------
(
    // Clock & Reset
    input         clk_i,
    input         rst_i,

    // Control
    input [UART_DIVISOR_W-1:0] bit_div_i,
    input         stop_bits_i, // 0 = 1, 1 = 2

    // Transmit
    input         wr_i,
    input  [7:0]  data_i,
    output        tx_busy_o,

    // Receive
    input         rd_i,
    output [7:0]  data_o,
    output        rx_ready_o,

    output        rx_err_o,

    // UART pins
    input         rxd_i,
    output        txd_o
);

//-----------------------------------------------------------------
// Registers
//-----------------------------------------------------------------
localparam   START_BIT = 4'd0;
localparam   STOP_BIT0 = 4'd9;
localparam   STOP_BIT1 = 4'd10;

// TX Signals
reg                       tx_busy_q;
reg [3:0]                 tx_bits_q;
reg [UART_DIVISOR_W-1:0]  tx_count_q;
reg [7:0]                 tx_shift_reg_q;
reg                       txd_q;

// RX Signals
reg                       rxd_q;
reg [7:0]                 rx_data_q;
reg [3:0]                 rx_bits_q;
reg [UART_DIVISOR_W-1:0]  rx_count_q;
reg [7:0]                 rx_shift_reg_q;
reg                       rx_ready_q;
reg                       rx_busy_q;

reg                       rx_err_q;

//-----------------------------------------------------------------
// Re-sync RXD
//-----------------------------------------------------------------
reg rxd_ms_q;

always @ (posedge rst_i or posedge clk_i )
if (rst_i)
begin
   rxd_ms_q <= 1'b1;
   rxd_q    <= 1'b1;
end
else
begin
   rxd_ms_q <= rxd_i;
   rxd_q    <= rxd_ms_q;
end

//-----------------------------------------------------------------
// RX Clock Divider
//-----------------------------------------------------------------
wire rx_sample_w = (rx_count_q == {(UART_DIVISOR_W){1'b0}});

always @ (posedge clk_i or posedge rst_i )
if (rst_i)
begin
    rx_count_q     <= {(UART_DIVISOR_W){1'b0}};
end
else
begin
    // Inactive
    if (!rx_busy_q)
        rx_count_q    <= {1'b0, bit_div_i[UART_DIVISOR_W-1:1]};
    // Rx bit timer
    else if (rx_count_q != 0)
        rx_count_q    <= (rx_count_q - 1);
    // Active
    else if (rx_sample_w)
    begin
        // Last bit?
        if ((rx_bits_q == STOP_BIT0 && !stop_bits_i) || (rx_bits_q == STOP_BIT1 && stop_bits_i))
            rx_count_q    <= {(UART_DIVISOR_W){1'b0}};
        else
            rx_count_q    <= bit_div_i;
    end
end

//-----------------------------------------------------------------
// RX Shift Register
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i )
begin
    if (rst_i)
    begin        
        rx_shift_reg_q <= 8'h00;
        rx_busy_q      <= 1'b0;
    end
    // Rx busy
    else if (rx_busy_q && rx_sample_w)
    begin
        // Last bit?
        if (rx_bits_q == STOP_BIT0 && !stop_bits_i)
            rx_busy_q <= 1'b0;
        else if (rx_bits_q == STOP_BIT1 && stop_bits_i)
            rx_busy_q <= 1'b0;
        else if (rx_bits_q == START_BIT)
        begin
            // Start bit should still be low as sampling mid
            // way through start bit, so if high, error!
            if (rxd_q)
                rx_busy_q <= 1'b0;
        end
        // Rx shift register
        else 
            rx_shift_reg_q <= {rxd_q, rx_shift_reg_q[7:1]};
    end
    // Start bit?
    else if (!rx_busy_q && rxd_q == 1'b0)
    begin
        rx_shift_reg_q <= 8'h00;
        rx_busy_q      <= 1'b1;
    end
end

always @ (posedge clk_i or posedge rst_i )
if (rst_i)
    rx_bits_q  <= START_BIT;
else if (rx_sample_w && rx_busy_q)
begin
    if ((rx_bits_q == STOP_BIT1 && stop_bits_i) || (rx_bits_q == STOP_BIT0 && !stop_bits_i))
        rx_bits_q <= START_BIT;
    else
        rx_bits_q <= rx_bits_q + 4'd1;
end
else if (!rx_busy_q && (bit_div_i == {(UART_DIVISOR_W){1'b0}}))
    rx_bits_q  <= START_BIT + 4'd1;
else if (!rx_busy_q)
    rx_bits_q  <= START_BIT;

//-----------------------------------------------------------------
// RX Data
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i )
begin
   if (rst_i)
   begin
       rx_ready_q      <= 1'b0;
       rx_data_q       <= 8'h00;
       rx_err_q        <= 1'b0;
   end
   else
   begin
       // If reading data, reset data state
       if (rd_i == 1'b1)
       begin
           rx_ready_q <= 1'b0;
           rx_err_q   <= 1'b0;
       end

       if (rx_busy_q && rx_sample_w)
       begin
           // Stop bit
           if ((rx_bits_q == STOP_BIT1 && stop_bits_i) || (rx_bits_q == STOP_BIT0 && !stop_bits_i))
           begin
               // RXD should be still high
               if (rxd_q)
               begin
                   rx_data_q      <= rx_shift_reg_q;
                   rx_ready_q     <= 1'b1;
               end
               // Bad Stop bit - wait for a full bit period
               // before allowing start bit detection again
               else
               begin
                   rx_ready_q      <= 1'b0;
                   rx_data_q       <= 8'h00;
                   rx_err_q        <= 1'b1;
               end
           end
           // Mid start bit sample - if high then error
           else if (rx_bits_q == START_BIT && rxd_q)
               rx_err_q        <= 1'b1;
       end
   end
end

//-----------------------------------------------------------------
// TX Clock Divider
//-----------------------------------------------------------------
wire tx_sample_w = (tx_count_q == {(UART_DIVISOR_W){1'b0}});

always @ (posedge clk_i or posedge rst_i )
if (rst_i)
begin
    tx_count_q     <= {(UART_DIVISOR_W){1'b0}};
end
else
begin
    // Idle
    if (!tx_busy_q)
        tx_count_q  <= bit_div_i;
    // Tx bit timer
    else if (tx_count_q != 0)
        tx_count_q  <= (tx_count_q - 1);
    else if (tx_sample_w)
        tx_count_q  <= bit_div_i;
end

//-----------------------------------------------------------------
// TX Shift Register
//-----------------------------------------------------------------

always @ (posedge clk_i or posedge rst_i )
begin
    if (rst_i)
    begin        
        tx_shift_reg_q <= 8'h00;
        tx_busy_q      <= 1'b0;
    end
    // Tx busy
    else if (tx_busy_q)
    begin
        // Shift tx data
        if (tx_bits_q != START_BIT && tx_sample_w)
            tx_shift_reg_q <= {1'b0, tx_shift_reg_q[7:1]};

        // Last bit?
        if (tx_bits_q == STOP_BIT0 && tx_sample_w && !stop_bits_i)
            tx_busy_q <= 1'b0;
        else if (tx_bits_q == STOP_BIT1 && tx_sample_w && stop_bits_i)
            tx_busy_q <= 1'b0;
    end
    // Buffer data to transmit
    else if (wr_i)
    begin
        tx_shift_reg_q <= data_i;
        tx_busy_q      <= 1'b1;
    end
end

always @ (posedge clk_i or posedge rst_i )
if (rst_i)
    tx_bits_q  <= 4'd0;
else if (tx_sample_w && tx_busy_q)
begin
    if ((tx_bits_q == STOP_BIT1 && stop_bits_i) || (tx_bits_q == STOP_BIT0 && !stop_bits_i))
        tx_bits_q <= START_BIT;
    else
        tx_bits_q <= tx_bits_q + 4'd1;
end

//-----------------------------------------------------------------
// UART Tx Pin
//-----------------------------------------------------------------
reg txd_r;

always @ *
begin
    txd_r = 1'b1;

    if (tx_busy_q)
    begin
        // Start bit (TXD = L)
        if (tx_bits_q == START_BIT)
            txd_r = 1'b0;
        // Stop bits (TXD = H)
        else if (tx_bits_q == STOP_BIT0 || tx_bits_q == STOP_BIT1)
            txd_r = 1'b1;
        // Data bits
        else
            txd_r = tx_shift_reg_q[0];
    end
end

always @ (posedge clk_i or posedge rst_i )
if (rst_i)
    txd_q <= 1'b1;
else
    txd_q <= txd_r;

//-----------------------------------------------------------------
// Outputs
//-----------------------------------------------------------------
assign tx_busy_o  = tx_busy_q;
assign rx_ready_o = rx_ready_q;
assign txd_o      = txd_q;
assign data_o     = rx_data_q;
assign rx_err_o   = rx_err_q;

endmodule
