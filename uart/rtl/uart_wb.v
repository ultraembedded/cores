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
module uart_wb

//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
    parameter UART_DIVISOR_W         = 9,
    parameter UART_DIVISOR_DEFAULT   = 1,
    parameter UART_STOP_BITS_DEFAULT = 0
)

//-----------------------------------------------------------------
// Ports
//-----------------------------------------------------------------
(
    // Clocking & Reset
    input               clk_i,
    input               rst_i,

    // Interrupt
    output              intr_o,

    // UART Pins
    output              tx_o,
    input               rx_i,

    // Wishbone interface (classic mode, synchronous slave)
    input [7:0]         addr_i,
    output [31:0]       data_o,
    input [31:0]        data_i,
    input               we_i,
    input               stb_i,
    output              ack_o
);

//-----------------------------------------------------------------
// Registers / Wires
//-----------------------------------------------------------------
wire [7:0]                uart_tx_data_w;
wire [7:0]                uart_rx_data_w;
wire                      uart_wr_w;
wire                      uart_rd_w;
wire                      uart_tx_busy_w;
wire                      uart_rx_ready_w;
wire                      uart_rx_err_w;

wire [UART_DIVISOR_W-1:0] uart_div_w;
wire                      uart_stop_bits_w;

wire                      uart_int_en_rx_err_w;
wire                      uart_int_en_rx_ready_w;
wire                      uart_int_en_tx_ready_w;

//-----------------------------------------------------------------
// Core
//-----------------------------------------------------------------
uart
#(
    .UART_DIVISOR_W(UART_DIVISOR_W)
)
u_uart
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    // Control
    .bit_div_i(uart_div_w),
    .stop_bits_i(uart_stop_bits_w),

    // Transmit
    .wr_i(uart_wr_w),
    .data_i(uart_tx_data_w),
    .tx_busy_o(uart_tx_busy_w),

    // Receive
    .rd_i(uart_rd_w),
    .data_o(uart_rx_data_w),
    .rx_ready_o(uart_rx_ready_w),
    .rx_err_o(uart_rx_err_w),

    // UART pins
    .rxd_i(rx_i),
    .txd_o(tx_o)
);

//-----------------------------------------------------------------
// Register Block
//-----------------------------------------------------------------
uart_regs
u_regs
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    // Configuration
    .uart_cfg_stop_bits_o(uart_stop_bits_w),
    .uart_cfg_div_o(uart_div_w),
    .uart_cfg_int_rx_error_o(uart_int_en_rx_err_w),
    .uart_cfg_int_rx_ready_o(uart_int_en_rx_ready_w),
    .uart_cfg_int_tx_ready_o(uart_int_en_tx_ready_w),

    // Transmit
    .uart_udr_wr_req_o(uart_wr_w),
    .uart_udr_data_o(uart_tx_data_w),
    .uart_usr_tx_busy_i(uart_tx_busy_w),

    // Receive
    .uart_udr_rd_req_o(uart_rd_w),
    .uart_udr_data_i(uart_rx_data_w),
    .uart_usr_rx_ready_i(uart_rx_ready_w),
    .uart_usr_rx_error_i(uart_rx_err_w),

    // Wishbone interface (classic mode, synchronous slave)
    .addr_i(addr_i),
    .data_o(data_o),
    .data_i(data_i),
    .we_i(we_i),
    .stb_i(stb_i),
    .ack_o(ack_o)
);

//-----------------------------------------------------------------
// Interrupt
//-----------------------------------------------------------------
reg intr_q;

always @ (posedge rst_i or posedge clk_i)
if (rst_i)
   intr_q <= 1'b0;
else
   intr_q <= (uart_rx_ready_w    & uart_int_en_rx_ready_w) | 
             (uart_rx_err_w      & uart_int_en_rx_err_w) | 
             (!uart_tx_busy_w    & uart_int_en_tx_ready_w);

//-----------------------------------------------------------------
// Assignments
//-----------------------------------------------------------------
assign intr_o = intr_q;

endmodule
