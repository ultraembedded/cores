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

`include "uart_regs_defs.v"

//-----------------------------------------------------------------
// Module:  Auto generated register interface
//-----------------------------------------------------------------
module uart_regs
(
    input          clk_i,
    input          rst_i,

    // Register Ports
    output         uart_cfg_int_rx_error_o,
    output         uart_cfg_int_rx_ready_o,
    output         uart_cfg_int_tx_ready_o,
    output         uart_cfg_stop_bits_o,
    output [8:0]   uart_cfg_div_o,
    input          uart_usr_tx_busy_i,
    input          uart_usr_rx_error_i,
    input          uart_usr_rx_ready_i,
    output [7:0]   uart_udr_data_o,
    input  [7:0]   uart_udr_data_i,
    output         uart_udr_wr_req_o,
    output         uart_udr_rd_req_o,

    // Wishbone interface (classic mode, synchronous slave)
    input [7:0]    addr_i,
    input [31:0]   data_i,
    output [31:0]  data_o,
    input          we_i,
    input          stb_i,
    output         ack_o
);

//-----------------------------------------------------------------
// Retime write data
//-----------------------------------------------------------------
reg [31:0] data_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    data_q <= 32'b0;
else
    data_q <= data_i;

//-----------------------------------------------------------------
// Request Logic
//-----------------------------------------------------------------
wire read_en_w;
wire write_en_w;

assign read_en_w  = stb_i & ~we_i & ~ack_o;
assign write_en_w = stb_i &  we_i & ~ack_o;


//-----------------------------------------------------------------
// Register uart_cfg
//-----------------------------------------------------------------
reg uart_cfg_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    uart_cfg_wr_q <= 1'b0;
else if (write_en_w && (addr_i == `UART_CFG))
    uart_cfg_wr_q <= 1'b1;
else
    uart_cfg_wr_q <= 1'b0;

// uart_cfg_int_rx_error [internal]
reg        uart_cfg_int_rx_error_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    uart_cfg_int_rx_error_q <= 1'd`UART_CFG_INT_RX_ERROR_DEFAULT;
else if (write_en_w && (addr_i == `UART_CFG))
    uart_cfg_int_rx_error_q <= data_i[`UART_CFG_INT_RX_ERROR_R];

assign uart_cfg_int_rx_error_o = uart_cfg_int_rx_error_q;


// uart_cfg_int_rx_ready [internal]
reg        uart_cfg_int_rx_ready_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    uart_cfg_int_rx_ready_q <= 1'd`UART_CFG_INT_RX_READY_DEFAULT;
else if (write_en_w && (addr_i == `UART_CFG))
    uart_cfg_int_rx_ready_q <= data_i[`UART_CFG_INT_RX_READY_R];

assign uart_cfg_int_rx_ready_o = uart_cfg_int_rx_ready_q;


// uart_cfg_int_tx_ready [internal]
reg        uart_cfg_int_tx_ready_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    uart_cfg_int_tx_ready_q <= 1'd`UART_CFG_INT_TX_READY_DEFAULT;
else if (write_en_w && (addr_i == `UART_CFG))
    uart_cfg_int_tx_ready_q <= data_i[`UART_CFG_INT_TX_READY_R];

assign uart_cfg_int_tx_ready_o = uart_cfg_int_tx_ready_q;


// uart_cfg_stop_bits [internal]
reg        uart_cfg_stop_bits_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    uart_cfg_stop_bits_q <= 1'd`UART_CFG_STOP_BITS_DEFAULT;
else if (write_en_w && (addr_i == `UART_CFG))
    uart_cfg_stop_bits_q <= data_i[`UART_CFG_STOP_BITS_R];

assign uart_cfg_stop_bits_o = uart_cfg_stop_bits_q;


// uart_cfg_div [internal]
reg [8:0]  uart_cfg_div_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    uart_cfg_div_q <= 9'd`UART_CFG_DIV_DEFAULT;
else if (write_en_w && (addr_i == `UART_CFG))
    uart_cfg_div_q <= data_i[`UART_CFG_DIV_R];

assign uart_cfg_div_o = uart_cfg_div_q;


//-----------------------------------------------------------------
// Register uart_usr
//-----------------------------------------------------------------
reg uart_usr_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    uart_usr_wr_q <= 1'b0;
else if (write_en_w && (addr_i == `UART_USR))
    uart_usr_wr_q <= 1'b1;
else
    uart_usr_wr_q <= 1'b0;




//-----------------------------------------------------------------
// Register uart_udr
//-----------------------------------------------------------------
reg uart_udr_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    uart_udr_wr_q <= 1'b0;
else if (write_en_w && (addr_i == `UART_UDR))
    uart_udr_wr_q <= 1'b1;
else
    uart_udr_wr_q <= 1'b0;

// uart_udr_data [external]
assign uart_udr_data_o    = data_q[`UART_UDR_DATA_R];



//-----------------------------------------------------------------
// Read mux
//-----------------------------------------------------------------
reg [31:0] data_r;

always @ *
begin
    data_r = 32'b0;

    case (addr_i)

    `UART_CFG :
    begin
        data_r[`UART_CFG_INT_RX_ERROR_R] = uart_cfg_int_rx_error_q;
        data_r[`UART_CFG_INT_RX_READY_R] = uart_cfg_int_rx_ready_q;
        data_r[`UART_CFG_INT_TX_READY_R] = uart_cfg_int_tx_ready_q;
        data_r[`UART_CFG_STOP_BITS_R] = uart_cfg_stop_bits_q;
        data_r[`UART_CFG_DIV_R] = uart_cfg_div_q;
    end
    `UART_USR :
    begin
        data_r[`UART_USR_TX_BUSY_R] = uart_usr_tx_busy_i;
        data_r[`UART_USR_RX_ERROR_R] = uart_usr_rx_error_i;
        data_r[`UART_USR_RX_READY_R] = uart_usr_rx_ready_i;
    end
    `UART_UDR :
    begin
        data_r[`UART_UDR_DATA_R] = uart_udr_data_i;
    end
    default :
        data_r = 32'b0;
    endcase
end

//-----------------------------------------------------------------
// Retime read response
//-----------------------------------------------------------------
reg [31:0] rd_data_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    rd_data_q <= 32'b0;
else
    rd_data_q <= data_r;

assign data_o = rd_data_q;

//-----------------------------------------------------------------
// Wishbone Ack
//-----------------------------------------------------------------
reg ack_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    ack_q <= 1'b0;
else if (write_en_w || read_en_w)
    ack_q <= 1'b1;
else
    ack_q <= 1'b0;

assign ack_o = ack_q;

assign uart_udr_rd_req_o = read_en_w & (addr_i == `UART_UDR);

assign uart_udr_wr_req_o = uart_udr_wr_q;

endmodule
