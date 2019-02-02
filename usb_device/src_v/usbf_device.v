//-----------------------------------------------------------------
//                       USB Device Core
//                           V1.0
//                     Ultra-Embedded.com
//                     Copyright 2014-2019
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

`include "usbf_device_defs.v"

//-----------------------------------------------------------------
// Module:  USB Device Endpoint
//-----------------------------------------------------------------
module usbf_device
(
    // Inputs
     input          clk_i
    ,input          rst_i
    ,input          cfg_awvalid_i
    ,input  [31:0]  cfg_awaddr_i
    ,input          cfg_wvalid_i
    ,input  [31:0]  cfg_wdata_i
    ,input  [3:0]   cfg_wstrb_i
    ,input          cfg_bready_i
    ,input          cfg_arvalid_i
    ,input  [31:0]  cfg_araddr_i
    ,input          cfg_rready_i
    ,input  [7:0]   utmi_data_in_i
    ,input          utmi_txready_i
    ,input          utmi_rxvalid_i
    ,input          utmi_rxactive_i
    ,input          utmi_rxerror_i
    ,input  [1:0]   utmi_linestate_i

    // Outputs
    ,output         cfg_awready_o
    ,output         cfg_wready_o
    ,output         cfg_bvalid_o
    ,output [1:0]   cfg_bresp_o
    ,output         cfg_arready_o
    ,output         cfg_rvalid_o
    ,output [31:0]  cfg_rdata_o
    ,output [1:0]   cfg_rresp_o
    ,output         intr_o
    ,output [7:0]   utmi_data_out_o
    ,output         utmi_txvalid_o
    ,output [1:0]   utmi_op_mode_o
    ,output [1:0]   utmi_xcvrselect_o
    ,output         utmi_termselect_o
    ,output         utmi_dppulldown_o
    ,output         utmi_dmpulldown_o
);

//-----------------------------------------------------------------
// Retime write data
//-----------------------------------------------------------------
reg [31:0] wr_data_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    wr_data_q <= 32'b0;
else
    wr_data_q <= cfg_wdata_i;

//-----------------------------------------------------------------
// Request Logic
//-----------------------------------------------------------------
wire read_en_w  = cfg_arvalid_i & cfg_arready_o;
wire write_en_w = cfg_awvalid_i & cfg_awready_o;

//-----------------------------------------------------------------
// Accept Logic
//-----------------------------------------------------------------
assign cfg_arready_o = ~cfg_rvalid_o;
assign cfg_awready_o = ~cfg_bvalid_o && ~cfg_arvalid_i; 
assign cfg_wready_o  = cfg_awready_o;


//-----------------------------------------------------------------
// Register usb_func_ctrl
//-----------------------------------------------------------------
reg usb_func_ctrl_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_func_ctrl_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_FUNC_CTRL))
    usb_func_ctrl_wr_q <= 1'b1;
else
    usb_func_ctrl_wr_q <= 1'b0;

// usb_func_ctrl_hs_chirp_en [internal]
reg        usb_func_ctrl_hs_chirp_en_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_func_ctrl_hs_chirp_en_q <= 1'd`USB_FUNC_CTRL_HS_CHIRP_EN_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_FUNC_CTRL))
    usb_func_ctrl_hs_chirp_en_q <= cfg_wdata_i[`USB_FUNC_CTRL_HS_CHIRP_EN_R];

wire        usb_func_ctrl_hs_chirp_en_out_w = usb_func_ctrl_hs_chirp_en_q;


// usb_func_ctrl_phy_dmpulldown [internal]
reg        usb_func_ctrl_phy_dmpulldown_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_func_ctrl_phy_dmpulldown_q <= 1'd`USB_FUNC_CTRL_PHY_DMPULLDOWN_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_FUNC_CTRL))
    usb_func_ctrl_phy_dmpulldown_q <= cfg_wdata_i[`USB_FUNC_CTRL_PHY_DMPULLDOWN_R];

wire        usb_func_ctrl_phy_dmpulldown_out_w = usb_func_ctrl_phy_dmpulldown_q;


// usb_func_ctrl_phy_dppulldown [internal]
reg        usb_func_ctrl_phy_dppulldown_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_func_ctrl_phy_dppulldown_q <= 1'd`USB_FUNC_CTRL_PHY_DPPULLDOWN_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_FUNC_CTRL))
    usb_func_ctrl_phy_dppulldown_q <= cfg_wdata_i[`USB_FUNC_CTRL_PHY_DPPULLDOWN_R];

wire        usb_func_ctrl_phy_dppulldown_out_w = usb_func_ctrl_phy_dppulldown_q;


// usb_func_ctrl_phy_termselect [internal]
reg        usb_func_ctrl_phy_termselect_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_func_ctrl_phy_termselect_q <= 1'd`USB_FUNC_CTRL_PHY_TERMSELECT_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_FUNC_CTRL))
    usb_func_ctrl_phy_termselect_q <= cfg_wdata_i[`USB_FUNC_CTRL_PHY_TERMSELECT_R];

wire        usb_func_ctrl_phy_termselect_out_w = usb_func_ctrl_phy_termselect_q;


// usb_func_ctrl_phy_xcvrselect [internal]
reg [1:0]  usb_func_ctrl_phy_xcvrselect_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_func_ctrl_phy_xcvrselect_q <= 2'd`USB_FUNC_CTRL_PHY_XCVRSELECT_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_FUNC_CTRL))
    usb_func_ctrl_phy_xcvrselect_q <= cfg_wdata_i[`USB_FUNC_CTRL_PHY_XCVRSELECT_R];

wire [1:0]  usb_func_ctrl_phy_xcvrselect_out_w = usb_func_ctrl_phy_xcvrselect_q;


// usb_func_ctrl_phy_opmode [internal]
reg [1:0]  usb_func_ctrl_phy_opmode_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_func_ctrl_phy_opmode_q <= 2'd`USB_FUNC_CTRL_PHY_OPMODE_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_FUNC_CTRL))
    usb_func_ctrl_phy_opmode_q <= cfg_wdata_i[`USB_FUNC_CTRL_PHY_OPMODE_R];

wire [1:0]  usb_func_ctrl_phy_opmode_out_w = usb_func_ctrl_phy_opmode_q;


// usb_func_ctrl_int_en_sof [internal]
reg        usb_func_ctrl_int_en_sof_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_func_ctrl_int_en_sof_q <= 1'd`USB_FUNC_CTRL_INT_EN_SOF_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_FUNC_CTRL))
    usb_func_ctrl_int_en_sof_q <= cfg_wdata_i[`USB_FUNC_CTRL_INT_EN_SOF_R];

wire        usb_func_ctrl_int_en_sof_out_w = usb_func_ctrl_int_en_sof_q;


//-----------------------------------------------------------------
// Register usb_func_stat
//-----------------------------------------------------------------
reg usb_func_stat_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_func_stat_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_FUNC_STAT))
    usb_func_stat_wr_q <= 1'b1;
else
    usb_func_stat_wr_q <= 1'b0;

// usb_func_stat_rst [external]
wire        usb_func_stat_rst_out_w = wr_data_q[`USB_FUNC_STAT_RST_R];


// usb_func_stat_linestate [external]
wire [1:0]  usb_func_stat_linestate_out_w = wr_data_q[`USB_FUNC_STAT_LINESTATE_R];


// usb_func_stat_frame [external]
wire [10:0]  usb_func_stat_frame_out_w = wr_data_q[`USB_FUNC_STAT_FRAME_R];


//-----------------------------------------------------------------
// Register usb_func_addr
//-----------------------------------------------------------------
reg usb_func_addr_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_func_addr_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_FUNC_ADDR))
    usb_func_addr_wr_q <= 1'b1;
else
    usb_func_addr_wr_q <= 1'b0;

// usb_func_addr_dev_addr [internal]
reg [6:0]  usb_func_addr_dev_addr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_func_addr_dev_addr_q <= 7'd`USB_FUNC_ADDR_DEV_ADDR_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_FUNC_ADDR))
    usb_func_addr_dev_addr_q <= cfg_wdata_i[`USB_FUNC_ADDR_DEV_ADDR_R];

wire [6:0]  usb_func_addr_dev_addr_out_w = usb_func_addr_dev_addr_q;


//-----------------------------------------------------------------
// Register usb_ep0_cfg
//-----------------------------------------------------------------
reg usb_ep0_cfg_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep0_cfg_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP0_CFG))
    usb_ep0_cfg_wr_q <= 1'b1;
else
    usb_ep0_cfg_wr_q <= 1'b0;

// usb_ep0_cfg_int_rx [internal]
reg        usb_ep0_cfg_int_rx_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep0_cfg_int_rx_q <= 1'd`USB_EP0_CFG_INT_RX_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP0_CFG))
    usb_ep0_cfg_int_rx_q <= cfg_wdata_i[`USB_EP0_CFG_INT_RX_R];

wire        usb_ep0_cfg_int_rx_out_w = usb_ep0_cfg_int_rx_q;


// usb_ep0_cfg_int_tx [internal]
reg        usb_ep0_cfg_int_tx_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep0_cfg_int_tx_q <= 1'd`USB_EP0_CFG_INT_TX_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP0_CFG))
    usb_ep0_cfg_int_tx_q <= cfg_wdata_i[`USB_EP0_CFG_INT_TX_R];

wire        usb_ep0_cfg_int_tx_out_w = usb_ep0_cfg_int_tx_q;


// usb_ep0_cfg_stall_ep [clearable]
reg        usb_ep0_cfg_stall_ep_q;

wire usb_ep0_cfg_stall_ep_ack_in_w;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep0_cfg_stall_ep_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP0_CFG))
    usb_ep0_cfg_stall_ep_q <= cfg_wdata_i[`USB_EP0_CFG_STALL_EP_R];
else if (usb_ep0_cfg_stall_ep_ack_in_w)
    usb_ep0_cfg_stall_ep_q <= 1'b0;

wire        usb_ep0_cfg_stall_ep_out_w = usb_ep0_cfg_stall_ep_q;


// usb_ep0_cfg_iso [internal]
reg        usb_ep0_cfg_iso_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep0_cfg_iso_q <= 1'd`USB_EP0_CFG_ISO_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP0_CFG))
    usb_ep0_cfg_iso_q <= cfg_wdata_i[`USB_EP0_CFG_ISO_R];

wire        usb_ep0_cfg_iso_out_w = usb_ep0_cfg_iso_q;


//-----------------------------------------------------------------
// Register usb_ep0_tx_ctrl
//-----------------------------------------------------------------
reg usb_ep0_tx_ctrl_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep0_tx_ctrl_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP0_TX_CTRL))
    usb_ep0_tx_ctrl_wr_q <= 1'b1;
else
    usb_ep0_tx_ctrl_wr_q <= 1'b0;

// usb_ep0_tx_ctrl_tx_flush [auto_clr]
reg        usb_ep0_tx_ctrl_tx_flush_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep0_tx_ctrl_tx_flush_q <= 1'd`USB_EP0_TX_CTRL_TX_FLUSH_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP0_TX_CTRL))
    usb_ep0_tx_ctrl_tx_flush_q <= cfg_wdata_i[`USB_EP0_TX_CTRL_TX_FLUSH_R];
else
    usb_ep0_tx_ctrl_tx_flush_q <= 1'd`USB_EP0_TX_CTRL_TX_FLUSH_DEFAULT;

wire        usb_ep0_tx_ctrl_tx_flush_out_w = usb_ep0_tx_ctrl_tx_flush_q;


// usb_ep0_tx_ctrl_tx_start [auto_clr]
reg        usb_ep0_tx_ctrl_tx_start_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep0_tx_ctrl_tx_start_q <= 1'd`USB_EP0_TX_CTRL_TX_START_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP0_TX_CTRL))
    usb_ep0_tx_ctrl_tx_start_q <= cfg_wdata_i[`USB_EP0_TX_CTRL_TX_START_R];
else
    usb_ep0_tx_ctrl_tx_start_q <= 1'd`USB_EP0_TX_CTRL_TX_START_DEFAULT;

wire        usb_ep0_tx_ctrl_tx_start_out_w = usb_ep0_tx_ctrl_tx_start_q;


// usb_ep0_tx_ctrl_tx_len [internal]
reg [10:0]  usb_ep0_tx_ctrl_tx_len_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep0_tx_ctrl_tx_len_q <= 11'd`USB_EP0_TX_CTRL_TX_LEN_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP0_TX_CTRL))
    usb_ep0_tx_ctrl_tx_len_q <= cfg_wdata_i[`USB_EP0_TX_CTRL_TX_LEN_R];

wire [10:0]  usb_ep0_tx_ctrl_tx_len_out_w = usb_ep0_tx_ctrl_tx_len_q;


//-----------------------------------------------------------------
// Register usb_ep0_rx_ctrl
//-----------------------------------------------------------------
reg usb_ep0_rx_ctrl_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep0_rx_ctrl_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP0_RX_CTRL))
    usb_ep0_rx_ctrl_wr_q <= 1'b1;
else
    usb_ep0_rx_ctrl_wr_q <= 1'b0;

// usb_ep0_rx_ctrl_rx_flush [auto_clr]
reg        usb_ep0_rx_ctrl_rx_flush_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep0_rx_ctrl_rx_flush_q <= 1'd`USB_EP0_RX_CTRL_RX_FLUSH_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP0_RX_CTRL))
    usb_ep0_rx_ctrl_rx_flush_q <= cfg_wdata_i[`USB_EP0_RX_CTRL_RX_FLUSH_R];
else
    usb_ep0_rx_ctrl_rx_flush_q <= 1'd`USB_EP0_RX_CTRL_RX_FLUSH_DEFAULT;

wire        usb_ep0_rx_ctrl_rx_flush_out_w = usb_ep0_rx_ctrl_rx_flush_q;


// usb_ep0_rx_ctrl_rx_accept [auto_clr]
reg        usb_ep0_rx_ctrl_rx_accept_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep0_rx_ctrl_rx_accept_q <= 1'd`USB_EP0_RX_CTRL_RX_ACCEPT_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP0_RX_CTRL))
    usb_ep0_rx_ctrl_rx_accept_q <= cfg_wdata_i[`USB_EP0_RX_CTRL_RX_ACCEPT_R];
else
    usb_ep0_rx_ctrl_rx_accept_q <= 1'd`USB_EP0_RX_CTRL_RX_ACCEPT_DEFAULT;

wire        usb_ep0_rx_ctrl_rx_accept_out_w = usb_ep0_rx_ctrl_rx_accept_q;


//-----------------------------------------------------------------
// Register usb_ep0_sts
//-----------------------------------------------------------------
reg usb_ep0_sts_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep0_sts_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP0_STS))
    usb_ep0_sts_wr_q <= 1'b1;
else
    usb_ep0_sts_wr_q <= 1'b0;







//-----------------------------------------------------------------
// Register usb_ep0_data
//-----------------------------------------------------------------
reg usb_ep0_data_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep0_data_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP0_DATA))
    usb_ep0_data_wr_q <= 1'b1;
else
    usb_ep0_data_wr_q <= 1'b0;

// usb_ep0_data_data [external]
wire [7:0]  usb_ep0_data_data_out_w = wr_data_q[`USB_EP0_DATA_DATA_R];


//-----------------------------------------------------------------
// Register usb_ep1_cfg
//-----------------------------------------------------------------
reg usb_ep1_cfg_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep1_cfg_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP1_CFG))
    usb_ep1_cfg_wr_q <= 1'b1;
else
    usb_ep1_cfg_wr_q <= 1'b0;

// usb_ep1_cfg_int_rx [internal]
reg        usb_ep1_cfg_int_rx_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep1_cfg_int_rx_q <= 1'd`USB_EP1_CFG_INT_RX_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP1_CFG))
    usb_ep1_cfg_int_rx_q <= cfg_wdata_i[`USB_EP1_CFG_INT_RX_R];

wire        usb_ep1_cfg_int_rx_out_w = usb_ep1_cfg_int_rx_q;


// usb_ep1_cfg_int_tx [internal]
reg        usb_ep1_cfg_int_tx_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep1_cfg_int_tx_q <= 1'd`USB_EP1_CFG_INT_TX_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP1_CFG))
    usb_ep1_cfg_int_tx_q <= cfg_wdata_i[`USB_EP1_CFG_INT_TX_R];

wire        usb_ep1_cfg_int_tx_out_w = usb_ep1_cfg_int_tx_q;


// usb_ep1_cfg_stall_ep [clearable]
reg        usb_ep1_cfg_stall_ep_q;

wire usb_ep1_cfg_stall_ep_ack_in_w;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep1_cfg_stall_ep_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP1_CFG))
    usb_ep1_cfg_stall_ep_q <= cfg_wdata_i[`USB_EP1_CFG_STALL_EP_R];
else if (usb_ep1_cfg_stall_ep_ack_in_w)
    usb_ep1_cfg_stall_ep_q <= 1'b0;

wire        usb_ep1_cfg_stall_ep_out_w = usb_ep1_cfg_stall_ep_q;


// usb_ep1_cfg_iso [internal]
reg        usb_ep1_cfg_iso_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep1_cfg_iso_q <= 1'd`USB_EP1_CFG_ISO_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP1_CFG))
    usb_ep1_cfg_iso_q <= cfg_wdata_i[`USB_EP1_CFG_ISO_R];

wire        usb_ep1_cfg_iso_out_w = usb_ep1_cfg_iso_q;


//-----------------------------------------------------------------
// Register usb_ep1_tx_ctrl
//-----------------------------------------------------------------
reg usb_ep1_tx_ctrl_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep1_tx_ctrl_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP1_TX_CTRL))
    usb_ep1_tx_ctrl_wr_q <= 1'b1;
else
    usb_ep1_tx_ctrl_wr_q <= 1'b0;

// usb_ep1_tx_ctrl_tx_flush [auto_clr]
reg        usb_ep1_tx_ctrl_tx_flush_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep1_tx_ctrl_tx_flush_q <= 1'd`USB_EP1_TX_CTRL_TX_FLUSH_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP1_TX_CTRL))
    usb_ep1_tx_ctrl_tx_flush_q <= cfg_wdata_i[`USB_EP1_TX_CTRL_TX_FLUSH_R];
else
    usb_ep1_tx_ctrl_tx_flush_q <= 1'd`USB_EP1_TX_CTRL_TX_FLUSH_DEFAULT;

wire        usb_ep1_tx_ctrl_tx_flush_out_w = usb_ep1_tx_ctrl_tx_flush_q;


// usb_ep1_tx_ctrl_tx_start [auto_clr]
reg        usb_ep1_tx_ctrl_tx_start_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep1_tx_ctrl_tx_start_q <= 1'd`USB_EP1_TX_CTRL_TX_START_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP1_TX_CTRL))
    usb_ep1_tx_ctrl_tx_start_q <= cfg_wdata_i[`USB_EP1_TX_CTRL_TX_START_R];
else
    usb_ep1_tx_ctrl_tx_start_q <= 1'd`USB_EP1_TX_CTRL_TX_START_DEFAULT;

wire        usb_ep1_tx_ctrl_tx_start_out_w = usb_ep1_tx_ctrl_tx_start_q;


// usb_ep1_tx_ctrl_tx_len [internal]
reg [10:0]  usb_ep1_tx_ctrl_tx_len_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep1_tx_ctrl_tx_len_q <= 11'd`USB_EP1_TX_CTRL_TX_LEN_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP1_TX_CTRL))
    usb_ep1_tx_ctrl_tx_len_q <= cfg_wdata_i[`USB_EP1_TX_CTRL_TX_LEN_R];

wire [10:0]  usb_ep1_tx_ctrl_tx_len_out_w = usb_ep1_tx_ctrl_tx_len_q;


//-----------------------------------------------------------------
// Register usb_ep1_rx_ctrl
//-----------------------------------------------------------------
reg usb_ep1_rx_ctrl_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep1_rx_ctrl_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP1_RX_CTRL))
    usb_ep1_rx_ctrl_wr_q <= 1'b1;
else
    usb_ep1_rx_ctrl_wr_q <= 1'b0;

// usb_ep1_rx_ctrl_rx_flush [auto_clr]
reg        usb_ep1_rx_ctrl_rx_flush_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep1_rx_ctrl_rx_flush_q <= 1'd`USB_EP1_RX_CTRL_RX_FLUSH_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP1_RX_CTRL))
    usb_ep1_rx_ctrl_rx_flush_q <= cfg_wdata_i[`USB_EP1_RX_CTRL_RX_FLUSH_R];
else
    usb_ep1_rx_ctrl_rx_flush_q <= 1'd`USB_EP1_RX_CTRL_RX_FLUSH_DEFAULT;

wire        usb_ep1_rx_ctrl_rx_flush_out_w = usb_ep1_rx_ctrl_rx_flush_q;


// usb_ep1_rx_ctrl_rx_accept [auto_clr]
reg        usb_ep1_rx_ctrl_rx_accept_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep1_rx_ctrl_rx_accept_q <= 1'd`USB_EP1_RX_CTRL_RX_ACCEPT_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP1_RX_CTRL))
    usb_ep1_rx_ctrl_rx_accept_q <= cfg_wdata_i[`USB_EP1_RX_CTRL_RX_ACCEPT_R];
else
    usb_ep1_rx_ctrl_rx_accept_q <= 1'd`USB_EP1_RX_CTRL_RX_ACCEPT_DEFAULT;

wire        usb_ep1_rx_ctrl_rx_accept_out_w = usb_ep1_rx_ctrl_rx_accept_q;


//-----------------------------------------------------------------
// Register usb_ep1_sts
//-----------------------------------------------------------------
reg usb_ep1_sts_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep1_sts_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP1_STS))
    usb_ep1_sts_wr_q <= 1'b1;
else
    usb_ep1_sts_wr_q <= 1'b0;







//-----------------------------------------------------------------
// Register usb_ep1_data
//-----------------------------------------------------------------
reg usb_ep1_data_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep1_data_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP1_DATA))
    usb_ep1_data_wr_q <= 1'b1;
else
    usb_ep1_data_wr_q <= 1'b0;

// usb_ep1_data_data [external]
wire [7:0]  usb_ep1_data_data_out_w = wr_data_q[`USB_EP1_DATA_DATA_R];


//-----------------------------------------------------------------
// Register usb_ep2_cfg
//-----------------------------------------------------------------
reg usb_ep2_cfg_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep2_cfg_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP2_CFG))
    usb_ep2_cfg_wr_q <= 1'b1;
else
    usb_ep2_cfg_wr_q <= 1'b0;

// usb_ep2_cfg_int_rx [internal]
reg        usb_ep2_cfg_int_rx_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep2_cfg_int_rx_q <= 1'd`USB_EP2_CFG_INT_RX_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP2_CFG))
    usb_ep2_cfg_int_rx_q <= cfg_wdata_i[`USB_EP2_CFG_INT_RX_R];

wire        usb_ep2_cfg_int_rx_out_w = usb_ep2_cfg_int_rx_q;


// usb_ep2_cfg_int_tx [internal]
reg        usb_ep2_cfg_int_tx_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep2_cfg_int_tx_q <= 1'd`USB_EP2_CFG_INT_TX_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP2_CFG))
    usb_ep2_cfg_int_tx_q <= cfg_wdata_i[`USB_EP2_CFG_INT_TX_R];

wire        usb_ep2_cfg_int_tx_out_w = usb_ep2_cfg_int_tx_q;


// usb_ep2_cfg_stall_ep [clearable]
reg        usb_ep2_cfg_stall_ep_q;

wire usb_ep2_cfg_stall_ep_ack_in_w;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep2_cfg_stall_ep_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP2_CFG))
    usb_ep2_cfg_stall_ep_q <= cfg_wdata_i[`USB_EP2_CFG_STALL_EP_R];
else if (usb_ep2_cfg_stall_ep_ack_in_w)
    usb_ep2_cfg_stall_ep_q <= 1'b0;

wire        usb_ep2_cfg_stall_ep_out_w = usb_ep2_cfg_stall_ep_q;


// usb_ep2_cfg_iso [internal]
reg        usb_ep2_cfg_iso_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep2_cfg_iso_q <= 1'd`USB_EP2_CFG_ISO_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP2_CFG))
    usb_ep2_cfg_iso_q <= cfg_wdata_i[`USB_EP2_CFG_ISO_R];

wire        usb_ep2_cfg_iso_out_w = usb_ep2_cfg_iso_q;


//-----------------------------------------------------------------
// Register usb_ep2_tx_ctrl
//-----------------------------------------------------------------
reg usb_ep2_tx_ctrl_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep2_tx_ctrl_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP2_TX_CTRL))
    usb_ep2_tx_ctrl_wr_q <= 1'b1;
else
    usb_ep2_tx_ctrl_wr_q <= 1'b0;

// usb_ep2_tx_ctrl_tx_flush [auto_clr]
reg        usb_ep2_tx_ctrl_tx_flush_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep2_tx_ctrl_tx_flush_q <= 1'd`USB_EP2_TX_CTRL_TX_FLUSH_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP2_TX_CTRL))
    usb_ep2_tx_ctrl_tx_flush_q <= cfg_wdata_i[`USB_EP2_TX_CTRL_TX_FLUSH_R];
else
    usb_ep2_tx_ctrl_tx_flush_q <= 1'd`USB_EP2_TX_CTRL_TX_FLUSH_DEFAULT;

wire        usb_ep2_tx_ctrl_tx_flush_out_w = usb_ep2_tx_ctrl_tx_flush_q;


// usb_ep2_tx_ctrl_tx_start [auto_clr]
reg        usb_ep2_tx_ctrl_tx_start_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep2_tx_ctrl_tx_start_q <= 1'd`USB_EP2_TX_CTRL_TX_START_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP2_TX_CTRL))
    usb_ep2_tx_ctrl_tx_start_q <= cfg_wdata_i[`USB_EP2_TX_CTRL_TX_START_R];
else
    usb_ep2_tx_ctrl_tx_start_q <= 1'd`USB_EP2_TX_CTRL_TX_START_DEFAULT;

wire        usb_ep2_tx_ctrl_tx_start_out_w = usb_ep2_tx_ctrl_tx_start_q;


// usb_ep2_tx_ctrl_tx_len [internal]
reg [10:0]  usb_ep2_tx_ctrl_tx_len_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep2_tx_ctrl_tx_len_q <= 11'd`USB_EP2_TX_CTRL_TX_LEN_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP2_TX_CTRL))
    usb_ep2_tx_ctrl_tx_len_q <= cfg_wdata_i[`USB_EP2_TX_CTRL_TX_LEN_R];

wire [10:0]  usb_ep2_tx_ctrl_tx_len_out_w = usb_ep2_tx_ctrl_tx_len_q;


//-----------------------------------------------------------------
// Register usb_ep2_rx_ctrl
//-----------------------------------------------------------------
reg usb_ep2_rx_ctrl_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep2_rx_ctrl_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP2_RX_CTRL))
    usb_ep2_rx_ctrl_wr_q <= 1'b1;
else
    usb_ep2_rx_ctrl_wr_q <= 1'b0;

// usb_ep2_rx_ctrl_rx_flush [auto_clr]
reg        usb_ep2_rx_ctrl_rx_flush_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep2_rx_ctrl_rx_flush_q <= 1'd`USB_EP2_RX_CTRL_RX_FLUSH_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP2_RX_CTRL))
    usb_ep2_rx_ctrl_rx_flush_q <= cfg_wdata_i[`USB_EP2_RX_CTRL_RX_FLUSH_R];
else
    usb_ep2_rx_ctrl_rx_flush_q <= 1'd`USB_EP2_RX_CTRL_RX_FLUSH_DEFAULT;

wire        usb_ep2_rx_ctrl_rx_flush_out_w = usb_ep2_rx_ctrl_rx_flush_q;


// usb_ep2_rx_ctrl_rx_accept [auto_clr]
reg        usb_ep2_rx_ctrl_rx_accept_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep2_rx_ctrl_rx_accept_q <= 1'd`USB_EP2_RX_CTRL_RX_ACCEPT_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP2_RX_CTRL))
    usb_ep2_rx_ctrl_rx_accept_q <= cfg_wdata_i[`USB_EP2_RX_CTRL_RX_ACCEPT_R];
else
    usb_ep2_rx_ctrl_rx_accept_q <= 1'd`USB_EP2_RX_CTRL_RX_ACCEPT_DEFAULT;

wire        usb_ep2_rx_ctrl_rx_accept_out_w = usb_ep2_rx_ctrl_rx_accept_q;


//-----------------------------------------------------------------
// Register usb_ep2_sts
//-----------------------------------------------------------------
reg usb_ep2_sts_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep2_sts_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP2_STS))
    usb_ep2_sts_wr_q <= 1'b1;
else
    usb_ep2_sts_wr_q <= 1'b0;







//-----------------------------------------------------------------
// Register usb_ep2_data
//-----------------------------------------------------------------
reg usb_ep2_data_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep2_data_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP2_DATA))
    usb_ep2_data_wr_q <= 1'b1;
else
    usb_ep2_data_wr_q <= 1'b0;

// usb_ep2_data_data [external]
wire [7:0]  usb_ep2_data_data_out_w = wr_data_q[`USB_EP2_DATA_DATA_R];


//-----------------------------------------------------------------
// Register usb_ep3_cfg
//-----------------------------------------------------------------
reg usb_ep3_cfg_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep3_cfg_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP3_CFG))
    usb_ep3_cfg_wr_q <= 1'b1;
else
    usb_ep3_cfg_wr_q <= 1'b0;

// usb_ep3_cfg_int_rx [internal]
reg        usb_ep3_cfg_int_rx_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep3_cfg_int_rx_q <= 1'd`USB_EP3_CFG_INT_RX_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP3_CFG))
    usb_ep3_cfg_int_rx_q <= cfg_wdata_i[`USB_EP3_CFG_INT_RX_R];

wire        usb_ep3_cfg_int_rx_out_w = usb_ep3_cfg_int_rx_q;


// usb_ep3_cfg_int_tx [internal]
reg        usb_ep3_cfg_int_tx_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep3_cfg_int_tx_q <= 1'd`USB_EP3_CFG_INT_TX_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP3_CFG))
    usb_ep3_cfg_int_tx_q <= cfg_wdata_i[`USB_EP3_CFG_INT_TX_R];

wire        usb_ep3_cfg_int_tx_out_w = usb_ep3_cfg_int_tx_q;


// usb_ep3_cfg_stall_ep [clearable]
reg        usb_ep3_cfg_stall_ep_q;

wire usb_ep3_cfg_stall_ep_ack_in_w;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep3_cfg_stall_ep_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP3_CFG))
    usb_ep3_cfg_stall_ep_q <= cfg_wdata_i[`USB_EP3_CFG_STALL_EP_R];
else if (usb_ep3_cfg_stall_ep_ack_in_w)
    usb_ep3_cfg_stall_ep_q <= 1'b0;

wire        usb_ep3_cfg_stall_ep_out_w = usb_ep3_cfg_stall_ep_q;


// usb_ep3_cfg_iso [internal]
reg        usb_ep3_cfg_iso_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep3_cfg_iso_q <= 1'd`USB_EP3_CFG_ISO_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP3_CFG))
    usb_ep3_cfg_iso_q <= cfg_wdata_i[`USB_EP3_CFG_ISO_R];

wire        usb_ep3_cfg_iso_out_w = usb_ep3_cfg_iso_q;


//-----------------------------------------------------------------
// Register usb_ep3_tx_ctrl
//-----------------------------------------------------------------
reg usb_ep3_tx_ctrl_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep3_tx_ctrl_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP3_TX_CTRL))
    usb_ep3_tx_ctrl_wr_q <= 1'b1;
else
    usb_ep3_tx_ctrl_wr_q <= 1'b0;

// usb_ep3_tx_ctrl_tx_flush [auto_clr]
reg        usb_ep3_tx_ctrl_tx_flush_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep3_tx_ctrl_tx_flush_q <= 1'd`USB_EP3_TX_CTRL_TX_FLUSH_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP3_TX_CTRL))
    usb_ep3_tx_ctrl_tx_flush_q <= cfg_wdata_i[`USB_EP3_TX_CTRL_TX_FLUSH_R];
else
    usb_ep3_tx_ctrl_tx_flush_q <= 1'd`USB_EP3_TX_CTRL_TX_FLUSH_DEFAULT;

wire        usb_ep3_tx_ctrl_tx_flush_out_w = usb_ep3_tx_ctrl_tx_flush_q;


// usb_ep3_tx_ctrl_tx_start [auto_clr]
reg        usb_ep3_tx_ctrl_tx_start_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep3_tx_ctrl_tx_start_q <= 1'd`USB_EP3_TX_CTRL_TX_START_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP3_TX_CTRL))
    usb_ep3_tx_ctrl_tx_start_q <= cfg_wdata_i[`USB_EP3_TX_CTRL_TX_START_R];
else
    usb_ep3_tx_ctrl_tx_start_q <= 1'd`USB_EP3_TX_CTRL_TX_START_DEFAULT;

wire        usb_ep3_tx_ctrl_tx_start_out_w = usb_ep3_tx_ctrl_tx_start_q;


// usb_ep3_tx_ctrl_tx_len [internal]
reg [10:0]  usb_ep3_tx_ctrl_tx_len_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep3_tx_ctrl_tx_len_q <= 11'd`USB_EP3_TX_CTRL_TX_LEN_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP3_TX_CTRL))
    usb_ep3_tx_ctrl_tx_len_q <= cfg_wdata_i[`USB_EP3_TX_CTRL_TX_LEN_R];

wire [10:0]  usb_ep3_tx_ctrl_tx_len_out_w = usb_ep3_tx_ctrl_tx_len_q;


//-----------------------------------------------------------------
// Register usb_ep3_rx_ctrl
//-----------------------------------------------------------------
reg usb_ep3_rx_ctrl_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep3_rx_ctrl_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP3_RX_CTRL))
    usb_ep3_rx_ctrl_wr_q <= 1'b1;
else
    usb_ep3_rx_ctrl_wr_q <= 1'b0;

// usb_ep3_rx_ctrl_rx_flush [auto_clr]
reg        usb_ep3_rx_ctrl_rx_flush_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep3_rx_ctrl_rx_flush_q <= 1'd`USB_EP3_RX_CTRL_RX_FLUSH_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP3_RX_CTRL))
    usb_ep3_rx_ctrl_rx_flush_q <= cfg_wdata_i[`USB_EP3_RX_CTRL_RX_FLUSH_R];
else
    usb_ep3_rx_ctrl_rx_flush_q <= 1'd`USB_EP3_RX_CTRL_RX_FLUSH_DEFAULT;

wire        usb_ep3_rx_ctrl_rx_flush_out_w = usb_ep3_rx_ctrl_rx_flush_q;


// usb_ep3_rx_ctrl_rx_accept [auto_clr]
reg        usb_ep3_rx_ctrl_rx_accept_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep3_rx_ctrl_rx_accept_q <= 1'd`USB_EP3_RX_CTRL_RX_ACCEPT_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP3_RX_CTRL))
    usb_ep3_rx_ctrl_rx_accept_q <= cfg_wdata_i[`USB_EP3_RX_CTRL_RX_ACCEPT_R];
else
    usb_ep3_rx_ctrl_rx_accept_q <= 1'd`USB_EP3_RX_CTRL_RX_ACCEPT_DEFAULT;

wire        usb_ep3_rx_ctrl_rx_accept_out_w = usb_ep3_rx_ctrl_rx_accept_q;


//-----------------------------------------------------------------
// Register usb_ep3_sts
//-----------------------------------------------------------------
reg usb_ep3_sts_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep3_sts_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP3_STS))
    usb_ep3_sts_wr_q <= 1'b1;
else
    usb_ep3_sts_wr_q <= 1'b0;







//-----------------------------------------------------------------
// Register usb_ep3_data
//-----------------------------------------------------------------
reg usb_ep3_data_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ep3_data_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_EP3_DATA))
    usb_ep3_data_wr_q <= 1'b1;
else
    usb_ep3_data_wr_q <= 1'b0;

// usb_ep3_data_data [external]
wire [7:0]  usb_ep3_data_data_out_w = wr_data_q[`USB_EP3_DATA_DATA_R];


wire        usb_func_stat_rst_in_w;
wire [1:0]  usb_func_stat_linestate_in_w;
wire [10:0]  usb_func_stat_frame_in_w;
wire        usb_ep0_sts_tx_err_in_w;
wire        usb_ep0_sts_tx_busy_in_w;
wire        usb_ep0_sts_rx_err_in_w;
wire        usb_ep0_sts_rx_setup_in_w;
wire        usb_ep0_sts_rx_ready_in_w;
wire [10:0]  usb_ep0_sts_rx_count_in_w;
wire [7:0]  usb_ep0_data_data_in_w;
wire        usb_ep1_sts_tx_err_in_w;
wire        usb_ep1_sts_tx_busy_in_w;
wire        usb_ep1_sts_rx_err_in_w;
wire        usb_ep1_sts_rx_setup_in_w;
wire        usb_ep1_sts_rx_ready_in_w;
wire [10:0]  usb_ep1_sts_rx_count_in_w;
wire [7:0]  usb_ep1_data_data_in_w;
wire        usb_ep2_sts_tx_err_in_w;
wire        usb_ep2_sts_tx_busy_in_w;
wire        usb_ep2_sts_rx_err_in_w;
wire        usb_ep2_sts_rx_setup_in_w;
wire        usb_ep2_sts_rx_ready_in_w;
wire [10:0]  usb_ep2_sts_rx_count_in_w;
wire [7:0]  usb_ep2_data_data_in_w;
wire        usb_ep3_sts_tx_err_in_w;
wire        usb_ep3_sts_tx_busy_in_w;
wire        usb_ep3_sts_rx_err_in_w;
wire        usb_ep3_sts_rx_setup_in_w;
wire        usb_ep3_sts_rx_ready_in_w;
wire [10:0]  usb_ep3_sts_rx_count_in_w;
wire [7:0]  usb_ep3_data_data_in_w;


//-----------------------------------------------------------------
// Read mux
//-----------------------------------------------------------------
reg [31:0] data_r;

always @ *
begin
    data_r = 32'b0;

    case (cfg_araddr_i[7:0])

    `USB_FUNC_CTRL:
    begin
        data_r[`USB_FUNC_CTRL_HS_CHIRP_EN_R] = usb_func_ctrl_hs_chirp_en_q;
        data_r[`USB_FUNC_CTRL_PHY_DMPULLDOWN_R] = usb_func_ctrl_phy_dmpulldown_q;
        data_r[`USB_FUNC_CTRL_PHY_DPPULLDOWN_R] = usb_func_ctrl_phy_dppulldown_q;
        data_r[`USB_FUNC_CTRL_PHY_TERMSELECT_R] = usb_func_ctrl_phy_termselect_q;
        data_r[`USB_FUNC_CTRL_PHY_XCVRSELECT_R] = usb_func_ctrl_phy_xcvrselect_q;
        data_r[`USB_FUNC_CTRL_PHY_OPMODE_R] = usb_func_ctrl_phy_opmode_q;
        data_r[`USB_FUNC_CTRL_INT_EN_SOF_R] = usb_func_ctrl_int_en_sof_q;
    end
    `USB_FUNC_STAT:
    begin
        data_r[`USB_FUNC_STAT_RST_R] = usb_func_stat_rst_in_w;
        data_r[`USB_FUNC_STAT_LINESTATE_R] = usb_func_stat_linestate_in_w;
        data_r[`USB_FUNC_STAT_FRAME_R] = usb_func_stat_frame_in_w;
    end
    `USB_FUNC_ADDR:
    begin
        data_r[`USB_FUNC_ADDR_DEV_ADDR_R] = usb_func_addr_dev_addr_q;
    end
    `USB_EP0_CFG:
    begin
        data_r[`USB_EP0_CFG_INT_RX_R] = usb_ep0_cfg_int_rx_q;
        data_r[`USB_EP0_CFG_INT_TX_R] = usb_ep0_cfg_int_tx_q;
        data_r[`USB_EP0_CFG_ISO_R] = usb_ep0_cfg_iso_q;
    end
    `USB_EP0_TX_CTRL:
    begin
        data_r[`USB_EP0_TX_CTRL_TX_LEN_R] = usb_ep0_tx_ctrl_tx_len_q;
    end
    `USB_EP0_STS:
    begin
        data_r[`USB_EP0_STS_TX_ERR_R] = usb_ep0_sts_tx_err_in_w;
        data_r[`USB_EP0_STS_TX_BUSY_R] = usb_ep0_sts_tx_busy_in_w;
        data_r[`USB_EP0_STS_RX_ERR_R] = usb_ep0_sts_rx_err_in_w;
        data_r[`USB_EP0_STS_RX_SETUP_R] = usb_ep0_sts_rx_setup_in_w;
        data_r[`USB_EP0_STS_RX_READY_R] = usb_ep0_sts_rx_ready_in_w;
        data_r[`USB_EP0_STS_RX_COUNT_R] = usb_ep0_sts_rx_count_in_w;
    end
    `USB_EP0_DATA:
    begin
        data_r[`USB_EP0_DATA_DATA_R] = usb_ep0_data_data_in_w;
    end
    `USB_EP1_CFG:
    begin
        data_r[`USB_EP1_CFG_INT_RX_R] = usb_ep1_cfg_int_rx_q;
        data_r[`USB_EP1_CFG_INT_TX_R] = usb_ep1_cfg_int_tx_q;
        data_r[`USB_EP1_CFG_ISO_R] = usb_ep1_cfg_iso_q;
    end
    `USB_EP1_TX_CTRL:
    begin
        data_r[`USB_EP1_TX_CTRL_TX_LEN_R] = usb_ep1_tx_ctrl_tx_len_q;
    end
    `USB_EP1_STS:
    begin
        data_r[`USB_EP1_STS_TX_ERR_R] = usb_ep1_sts_tx_err_in_w;
        data_r[`USB_EP1_STS_TX_BUSY_R] = usb_ep1_sts_tx_busy_in_w;
        data_r[`USB_EP1_STS_RX_ERR_R] = usb_ep1_sts_rx_err_in_w;
        data_r[`USB_EP1_STS_RX_SETUP_R] = usb_ep1_sts_rx_setup_in_w;
        data_r[`USB_EP1_STS_RX_READY_R] = usb_ep1_sts_rx_ready_in_w;
        data_r[`USB_EP1_STS_RX_COUNT_R] = usb_ep1_sts_rx_count_in_w;
    end
    `USB_EP1_DATA:
    begin
        data_r[`USB_EP1_DATA_DATA_R] = usb_ep1_data_data_in_w;
    end
    `USB_EP2_CFG:
    begin
        data_r[`USB_EP2_CFG_INT_RX_R] = usb_ep2_cfg_int_rx_q;
        data_r[`USB_EP2_CFG_INT_TX_R] = usb_ep2_cfg_int_tx_q;
        data_r[`USB_EP2_CFG_ISO_R] = usb_ep2_cfg_iso_q;
    end
    `USB_EP2_TX_CTRL:
    begin
        data_r[`USB_EP2_TX_CTRL_TX_LEN_R] = usb_ep2_tx_ctrl_tx_len_q;
    end
    `USB_EP2_STS:
    begin
        data_r[`USB_EP2_STS_TX_ERR_R] = usb_ep2_sts_tx_err_in_w;
        data_r[`USB_EP2_STS_TX_BUSY_R] = usb_ep2_sts_tx_busy_in_w;
        data_r[`USB_EP2_STS_RX_ERR_R] = usb_ep2_sts_rx_err_in_w;
        data_r[`USB_EP2_STS_RX_SETUP_R] = usb_ep2_sts_rx_setup_in_w;
        data_r[`USB_EP2_STS_RX_READY_R] = usb_ep2_sts_rx_ready_in_w;
        data_r[`USB_EP2_STS_RX_COUNT_R] = usb_ep2_sts_rx_count_in_w;
    end
    `USB_EP2_DATA:
    begin
        data_r[`USB_EP2_DATA_DATA_R] = usb_ep2_data_data_in_w;
    end
    `USB_EP3_CFG:
    begin
        data_r[`USB_EP3_CFG_INT_RX_R] = usb_ep3_cfg_int_rx_q;
        data_r[`USB_EP3_CFG_INT_TX_R] = usb_ep3_cfg_int_tx_q;
        data_r[`USB_EP3_CFG_ISO_R] = usb_ep3_cfg_iso_q;
    end
    `USB_EP3_TX_CTRL:
    begin
        data_r[`USB_EP3_TX_CTRL_TX_LEN_R] = usb_ep3_tx_ctrl_tx_len_q;
    end
    `USB_EP3_STS:
    begin
        data_r[`USB_EP3_STS_TX_ERR_R] = usb_ep3_sts_tx_err_in_w;
        data_r[`USB_EP3_STS_TX_BUSY_R] = usb_ep3_sts_tx_busy_in_w;
        data_r[`USB_EP3_STS_RX_ERR_R] = usb_ep3_sts_rx_err_in_w;
        data_r[`USB_EP3_STS_RX_SETUP_R] = usb_ep3_sts_rx_setup_in_w;
        data_r[`USB_EP3_STS_RX_READY_R] = usb_ep3_sts_rx_ready_in_w;
        data_r[`USB_EP3_STS_RX_COUNT_R] = usb_ep3_sts_rx_count_in_w;
    end
    `USB_EP3_DATA:
    begin
        data_r[`USB_EP3_DATA_DATA_R] = usb_ep3_data_data_in_w;
    end
    default :
        data_r = 32'b0;
    endcase
end

//-----------------------------------------------------------------
// RVALID
//-----------------------------------------------------------------
reg rvalid_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    rvalid_q <= 1'b0;
else if (read_en_w)
    rvalid_q <= 1'b1;
else if (cfg_rready_i)
    rvalid_q <= 1'b0;

assign cfg_rvalid_o = rvalid_q;

//-----------------------------------------------------------------
// Retime read response
//-----------------------------------------------------------------
reg [31:0] rd_data_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    rd_data_q <= 32'b0;
else if (!cfg_rvalid_o || cfg_rready_i)
    rd_data_q <= data_r;

assign cfg_rdata_o = rd_data_q;
assign cfg_rresp_o = 2'b0;

//-----------------------------------------------------------------
// BVALID
//-----------------------------------------------------------------
reg bvalid_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    bvalid_q <= 1'b0;
else if (write_en_w)
    bvalid_q <= 1'b1;
else if (cfg_bready_i)
    bvalid_q <= 1'b0;

assign cfg_bvalid_o = bvalid_q;
assign cfg_bresp_o  = 2'b0;

wire usb_ep0_data_rd_req_w = read_en_w & (cfg_araddr_i[7:0] == `USB_EP0_DATA);
wire usb_ep1_data_rd_req_w = read_en_w & (cfg_araddr_i[7:0] == `USB_EP1_DATA);
wire usb_ep2_data_rd_req_w = read_en_w & (cfg_araddr_i[7:0] == `USB_EP2_DATA);
wire usb_ep3_data_rd_req_w = read_en_w & (cfg_araddr_i[7:0] == `USB_EP3_DATA);

wire usb_func_stat_wr_req_w = usb_func_stat_wr_q;
wire usb_ep0_data_wr_req_w = usb_ep0_data_wr_q;
wire usb_ep1_data_wr_req_w = usb_ep1_data_wr_q;
wire usb_ep2_data_wr_req_w = usb_ep2_data_wr_q;
wire usb_ep3_data_wr_req_w = usb_ep3_data_wr_q;


//-----------------------------------------------------------------
// Wires
//-----------------------------------------------------------------
wire          stat_rst_w;
wire  [10:0]  stat_frame_w;
wire          stat_rst_clr_w = usb_func_stat_rst_out_w;
wire          stat_wr_req_w  = usb_func_stat_wr_req_w;

wire         usb_ep0_tx_rd_w;
wire [7:0]   usb_ep0_tx_data_w;
wire         usb_ep0_tx_empty_w;

wire         usb_ep0_rx_wr_w;
wire [7:0]   usb_ep0_rx_data_w;
wire         usb_ep0_rx_full_w;
wire         usb_ep1_tx_rd_w;
wire [7:0]   usb_ep1_tx_data_w;
wire         usb_ep1_tx_empty_w;

wire         usb_ep1_rx_wr_w;
wire [7:0]   usb_ep1_rx_data_w;
wire         usb_ep1_rx_full_w;
wire         usb_ep2_tx_rd_w;
wire [7:0]   usb_ep2_tx_data_w;
wire         usb_ep2_tx_empty_w;

wire         usb_ep2_rx_wr_w;
wire [7:0]   usb_ep2_rx_data_w;
wire         usb_ep2_rx_full_w;
wire         usb_ep3_tx_rd_w;
wire [7:0]   usb_ep3_tx_data_w;
wire         usb_ep3_tx_empty_w;

wire         usb_ep3_rx_wr_w;
wire [7:0]   usb_ep3_rx_data_w;
wire         usb_ep3_rx_full_w;

// Rx SIE Interface (shared)
wire        rx_strb_w;
wire [7:0]  rx_data_w;
wire        rx_last_w;
wire        rx_crc_err_w;

// EP0 Rx SIE Interface
wire        ep0_rx_space_w;
wire        ep0_rx_valid_w;
wire        ep0_rx_setup_w;

// EP0 Tx SIE Interface
wire        ep0_tx_ready_w;
wire        ep0_tx_data_valid_w;
wire        ep0_tx_data_strb_w;
wire [7:0]  ep0_tx_data_w;
wire        ep0_tx_data_last_w;
wire        ep0_tx_data_accept_w;
// EP1 Rx SIE Interface
wire        ep1_rx_space_w;
wire        ep1_rx_valid_w;
wire        ep1_rx_setup_w;

// EP1 Tx SIE Interface
wire        ep1_tx_ready_w;
wire        ep1_tx_data_valid_w;
wire        ep1_tx_data_strb_w;
wire [7:0]  ep1_tx_data_w;
wire        ep1_tx_data_last_w;
wire        ep1_tx_data_accept_w;
// EP2 Rx SIE Interface
wire        ep2_rx_space_w;
wire        ep2_rx_valid_w;
wire        ep2_rx_setup_w;

// EP2 Tx SIE Interface
wire        ep2_tx_ready_w;
wire        ep2_tx_data_valid_w;
wire        ep2_tx_data_strb_w;
wire [7:0]  ep2_tx_data_w;
wire        ep2_tx_data_last_w;
wire        ep2_tx_data_accept_w;
// EP3 Rx SIE Interface
wire        ep3_rx_space_w;
wire        ep3_rx_valid_w;
wire        ep3_rx_setup_w;

// EP3 Tx SIE Interface
wire        ep3_tx_ready_w;
wire        ep3_tx_data_valid_w;
wire        ep3_tx_data_strb_w;
wire [7:0]  ep3_tx_data_w;
wire        ep3_tx_data_last_w;
wire        ep3_tx_data_accept_w;

// Transceiver Control
assign utmi_dmpulldown_o            = usb_func_ctrl_phy_dmpulldown_out_w;
assign utmi_dppulldown_o            = usb_func_ctrl_phy_dppulldown_out_w;
assign utmi_termselect_o            = usb_func_ctrl_phy_termselect_out_w;
assign utmi_xcvrselect_o            = usb_func_ctrl_phy_xcvrselect_out_w;
assign utmi_op_mode_o               = usb_func_ctrl_phy_opmode_out_w;

// Status
assign usb_func_stat_rst_in_w       = stat_rst_w;
assign usb_func_stat_linestate_in_w = utmi_linestate_i;
assign usb_func_stat_frame_in_w     = stat_frame_w;

//-----------------------------------------------------------------
// Core
//-----------------------------------------------------------------
usbf_device_core
u_core
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .intr_o(intr_o),

    // UTMI interface
    .utmi_data_o(utmi_data_out_o),
    .utmi_data_i(utmi_data_in_i),
    .utmi_txvalid_o(utmi_txvalid_o),
    .utmi_txready_i(utmi_txready_i),
    .utmi_rxvalid_i(utmi_rxvalid_i),
    .utmi_rxactive_i(utmi_rxactive_i),
    .utmi_rxerror_i(utmi_rxerror_i),
    .utmi_linestate_i(utmi_linestate_i),

    .reg_chirp_en_i(usb_func_ctrl_hs_chirp_en_out_w),
    .reg_int_en_sof_i(usb_func_ctrl_int_en_sof_out_w),

    .reg_dev_addr_i(usb_func_addr_dev_addr_out_w),

    // Rx SIE Interface (shared)
    .rx_strb_o(rx_strb_w),
    .rx_data_o(rx_data_w),
    .rx_last_o(rx_last_w),
    .rx_crc_err_o(rx_crc_err_w),

    // EP0 Config
    .ep0_iso_i(usb_ep0_cfg_iso_out_w),
    .ep0_stall_i(usb_ep0_cfg_stall_ep_out_w),
    .ep0_cfg_int_rx_i(usb_ep0_cfg_int_rx_out_w),
    .ep0_cfg_int_tx_i(usb_ep0_cfg_int_tx_out_w),    

    // EP0 Rx SIE Interface
    .ep0_rx_setup_o(ep0_rx_setup_w),
    .ep0_rx_valid_o(ep0_rx_valid_w),
    .ep0_rx_space_i(ep0_rx_space_w),

    // EP0 Tx SIE Interface
    .ep0_tx_ready_i(ep0_tx_ready_w),
    .ep0_tx_data_valid_i(ep0_tx_data_valid_w),
    .ep0_tx_data_strb_i(ep0_tx_data_strb_w),
    .ep0_tx_data_i(ep0_tx_data_w),
    .ep0_tx_data_last_i(ep0_tx_data_last_w),
    .ep0_tx_data_accept_o(ep0_tx_data_accept_w),

    // EP1 Config
    .ep1_iso_i(usb_ep1_cfg_iso_out_w),
    .ep1_stall_i(usb_ep1_cfg_stall_ep_out_w),
    .ep1_cfg_int_rx_i(usb_ep1_cfg_int_rx_out_w),
    .ep1_cfg_int_tx_i(usb_ep1_cfg_int_tx_out_w),    

    // EP1 Rx SIE Interface
    .ep1_rx_setup_o(ep1_rx_setup_w),
    .ep1_rx_valid_o(ep1_rx_valid_w),
    .ep1_rx_space_i(ep1_rx_space_w),

    // EP1 Tx SIE Interface
    .ep1_tx_ready_i(ep1_tx_ready_w),
    .ep1_tx_data_valid_i(ep1_tx_data_valid_w),
    .ep1_tx_data_strb_i(ep1_tx_data_strb_w),
    .ep1_tx_data_i(ep1_tx_data_w),
    .ep1_tx_data_last_i(ep1_tx_data_last_w),
    .ep1_tx_data_accept_o(ep1_tx_data_accept_w),

    // EP2 Config
    .ep2_iso_i(usb_ep2_cfg_iso_out_w),
    .ep2_stall_i(usb_ep2_cfg_stall_ep_out_w),
    .ep2_cfg_int_rx_i(usb_ep2_cfg_int_rx_out_w),
    .ep2_cfg_int_tx_i(usb_ep2_cfg_int_tx_out_w),    

    // EP2 Rx SIE Interface
    .ep2_rx_setup_o(ep2_rx_setup_w),
    .ep2_rx_valid_o(ep2_rx_valid_w),
    .ep2_rx_space_i(ep2_rx_space_w),

    // EP2 Tx SIE Interface
    .ep2_tx_ready_i(ep2_tx_ready_w),
    .ep2_tx_data_valid_i(ep2_tx_data_valid_w),
    .ep2_tx_data_strb_i(ep2_tx_data_strb_w),
    .ep2_tx_data_i(ep2_tx_data_w),
    .ep2_tx_data_last_i(ep2_tx_data_last_w),
    .ep2_tx_data_accept_o(ep2_tx_data_accept_w),

    // EP3 Config
    .ep3_iso_i(usb_ep3_cfg_iso_out_w),
    .ep3_stall_i(usb_ep3_cfg_stall_ep_out_w),
    .ep3_cfg_int_rx_i(usb_ep3_cfg_int_rx_out_w),
    .ep3_cfg_int_tx_i(usb_ep3_cfg_int_tx_out_w),    

    // EP3 Rx SIE Interface
    .ep3_rx_setup_o(ep3_rx_setup_w),
    .ep3_rx_valid_o(ep3_rx_valid_w),
    .ep3_rx_space_i(ep3_rx_space_w),

    // EP3 Tx SIE Interface
    .ep3_tx_ready_i(ep3_tx_ready_w),
    .ep3_tx_data_valid_i(ep3_tx_data_valid_w),
    .ep3_tx_data_strb_i(ep3_tx_data_strb_w),
    .ep3_tx_data_i(ep3_tx_data_w),
    .ep3_tx_data_last_i(ep3_tx_data_last_w),
    .ep3_tx_data_accept_o(ep3_tx_data_accept_w),

    // Status
    .reg_sts_rst_clr_i(stat_rst_clr_w & stat_wr_req_w),
    .reg_sts_rst_o(stat_rst_w),
    .reg_sts_frame_num_o(stat_frame_w)
);

assign usb_ep0_cfg_stall_ep_ack_in_w = ep0_rx_setup_w;
assign usb_ep1_cfg_stall_ep_ack_in_w = ep1_rx_setup_w;
assign usb_ep2_cfg_stall_ep_ack_in_w = ep2_rx_setup_w;
assign usb_ep3_cfg_stall_ep_ack_in_w = ep3_rx_setup_w;

//-----------------------------------------------------------------
// FIFOs
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// Endpoint 0: Host -> Device
//-----------------------------------------------------------------
usbf_fifo
#(
    .WIDTH(8),
    .DEPTH(8),
    .ADDR_W(3)
)
u_fifo_rx_ep0
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .data_i(usb_ep0_rx_data_w),
    .push_i(usb_ep0_rx_wr_w),

    .flush_i(usb_ep0_rx_ctrl_rx_flush_out_w),

    .full_o(usb_ep0_rx_full_w),
    .empty_o(),

    // Output to register block
    .data_o(usb_ep0_data_data_in_w),
    .pop_i(usb_ep0_data_rd_req_w)
);

//-----------------------------------------------------------------
// Endpoint 0: Device -> Host
//-----------------------------------------------------------------
usbf_fifo
#(
    .WIDTH(8),
    .DEPTH(8),
    .ADDR_W(3)
)
u_fifo_tx_ep0
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    // Input from register block
    .data_i(usb_ep0_data_data_out_w),
    .push_i(usb_ep0_data_wr_req_w),

    .flush_i(usb_ep0_tx_ctrl_tx_flush_out_w),

    .full_o(),
    .empty_o(usb_ep0_tx_empty_w),

    .data_o(usb_ep0_tx_data_w),
    .pop_i(usb_ep0_tx_rd_w)
);

//-----------------------------------------------------------------
// Endpoint 1: Host -> Device
//-----------------------------------------------------------------
usbf_fifo
#(
    .WIDTH(8),
    .DEPTH(64),
    .ADDR_W(6)
)
u_fifo_rx_ep1
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .data_i(usb_ep1_rx_data_w),
    .push_i(usb_ep1_rx_wr_w),

    .flush_i(usb_ep1_rx_ctrl_rx_flush_out_w),

    .full_o(usb_ep1_rx_full_w),
    .empty_o(),

    // Output to register block
    .data_o(usb_ep1_data_data_in_w),
    .pop_i(usb_ep1_data_rd_req_w)
);

//-----------------------------------------------------------------
// Endpoint 1: Device -> Host
//-----------------------------------------------------------------
usbf_fifo
#(
    .WIDTH(8),
    .DEPTH(64),
    .ADDR_W(6)
)
u_fifo_tx_ep1
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    // Input from register block
    .data_i(usb_ep1_data_data_out_w),
    .push_i(usb_ep1_data_wr_req_w),

    .flush_i(usb_ep1_tx_ctrl_tx_flush_out_w),

    .full_o(),
    .empty_o(usb_ep1_tx_empty_w),

    .data_o(usb_ep1_tx_data_w),
    .pop_i(usb_ep1_tx_rd_w)
);

//-----------------------------------------------------------------
// Endpoint 2: Host -> Device
//-----------------------------------------------------------------
usbf_fifo
#(
    .WIDTH(8),
    .DEPTH(64),
    .ADDR_W(6)
)
u_fifo_rx_ep2
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .data_i(usb_ep2_rx_data_w),
    .push_i(usb_ep2_rx_wr_w),

    .flush_i(usb_ep2_rx_ctrl_rx_flush_out_w),

    .full_o(usb_ep2_rx_full_w),
    .empty_o(),

    // Output to register block
    .data_o(usb_ep2_data_data_in_w),
    .pop_i(usb_ep2_data_rd_req_w)
);

//-----------------------------------------------------------------
// Endpoint 2: Device -> Host
//-----------------------------------------------------------------
usbf_fifo
#(
    .WIDTH(8),
    .DEPTH(64),
    .ADDR_W(6)
)
u_fifo_tx_ep2
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    // Input from register block
    .data_i(usb_ep2_data_data_out_w),
    .push_i(usb_ep2_data_wr_req_w),

    .flush_i(usb_ep2_tx_ctrl_tx_flush_out_w),

    .full_o(),
    .empty_o(usb_ep2_tx_empty_w),

    .data_o(usb_ep2_tx_data_w),
    .pop_i(usb_ep2_tx_rd_w)
);

//-----------------------------------------------------------------
// Endpoint 3: Host -> Device
//-----------------------------------------------------------------
usbf_fifo
#(
    .WIDTH(8),
    .DEPTH(64),
    .ADDR_W(6)
)
u_fifo_rx_ep3
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .data_i(usb_ep3_rx_data_w),
    .push_i(usb_ep3_rx_wr_w),

    .flush_i(usb_ep3_rx_ctrl_rx_flush_out_w),

    .full_o(usb_ep3_rx_full_w),
    .empty_o(),

    // Output to register block
    .data_o(usb_ep3_data_data_in_w),
    .pop_i(usb_ep3_data_rd_req_w)
);

//-----------------------------------------------------------------
// Endpoint 3: Device -> Host
//-----------------------------------------------------------------
usbf_fifo
#(
    .WIDTH(8),
    .DEPTH(64),
    .ADDR_W(6)
)
u_fifo_tx_ep3
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    // Input from register block
    .data_i(usb_ep3_data_data_out_w),
    .push_i(usb_ep3_data_wr_req_w),

    .flush_i(usb_ep3_tx_ctrl_tx_flush_out_w),

    .full_o(),
    .empty_o(usb_ep3_tx_empty_w),

    .data_o(usb_ep3_tx_data_w),
    .pop_i(usb_ep3_tx_rd_w)
);


//-----------------------------------------------------------------
// Endpoint 0: Control
//-----------------------------------------------------------------
usbf_sie_ep
u_ep0
(
    .clk_i(clk_i),
    .rst_i(rst_i),   

    // Rx SIE Interface
    .rx_space_o(ep0_rx_space_w),
    .rx_valid_i(ep0_rx_valid_w),
    .rx_setup_i(ep0_rx_setup_w),
    .rx_strb_i(rx_strb_w),
    .rx_data_i(rx_data_w),
    .rx_last_i(rx_last_w),
    .rx_crc_err_i(rx_crc_err_w),

    // Rx FIFO Interface
    .rx_push_o(usb_ep0_rx_wr_w),
    .rx_data_o(usb_ep0_rx_data_w),
    .rx_full_i(usb_ep0_rx_full_w),

    // Rx Register Interface
    .rx_length_o(usb_ep0_sts_rx_count_in_w),
    .rx_ready_o(usb_ep0_sts_rx_ready_in_w),
    .rx_err_o(usb_ep0_sts_rx_err_in_w),
    .rx_setup_o(usb_ep0_sts_rx_setup_in_w),
    .rx_ack_i(usb_ep0_rx_ctrl_rx_accept_out_w),

    // Tx FIFO Interface
    .tx_pop_o(usb_ep0_tx_rd_w),
    .tx_data_i(usb_ep0_tx_data_w),
    .tx_empty_i(usb_ep0_tx_empty_w),

    // Tx Register Interface
    .tx_flush_i(usb_ep0_tx_ctrl_tx_flush_out_w),
    .tx_length_i(usb_ep0_tx_ctrl_tx_len_out_w),
    .tx_start_i(usb_ep0_tx_ctrl_tx_start_out_w),
    .tx_busy_o(usb_ep0_sts_tx_busy_in_w),
    .tx_err_o(usb_ep0_sts_tx_err_in_w),

    // Tx SIE Interface
    .tx_ready_o(ep0_tx_ready_w),
    .tx_data_valid_o(ep0_tx_data_valid_w),
    .tx_data_strb_o(ep0_tx_data_strb_w),
    .tx_data_o(ep0_tx_data_w),
    .tx_data_last_o(ep0_tx_data_last_w),
    .tx_data_accept_i(ep0_tx_data_accept_w)
);
//-----------------------------------------------------------------
// Endpoint 1: Control
//-----------------------------------------------------------------
usbf_sie_ep
u_ep1
(
    .clk_i(clk_i),
    .rst_i(rst_i),   

    // Rx SIE Interface
    .rx_space_o(ep1_rx_space_w),
    .rx_valid_i(ep1_rx_valid_w),
    .rx_setup_i(ep1_rx_setup_w),
    .rx_strb_i(rx_strb_w),
    .rx_data_i(rx_data_w),
    .rx_last_i(rx_last_w),
    .rx_crc_err_i(rx_crc_err_w),

    // Rx FIFO Interface
    .rx_push_o(usb_ep1_rx_wr_w),
    .rx_data_o(usb_ep1_rx_data_w),
    .rx_full_i(usb_ep1_rx_full_w),

    // Rx Register Interface
    .rx_length_o(usb_ep1_sts_rx_count_in_w),
    .rx_ready_o(usb_ep1_sts_rx_ready_in_w),
    .rx_err_o(usb_ep1_sts_rx_err_in_w),
    .rx_setup_o(usb_ep1_sts_rx_setup_in_w),
    .rx_ack_i(usb_ep1_rx_ctrl_rx_accept_out_w),

    // Tx FIFO Interface
    .tx_pop_o(usb_ep1_tx_rd_w),
    .tx_data_i(usb_ep1_tx_data_w),
    .tx_empty_i(usb_ep1_tx_empty_w),

    // Tx Register Interface
    .tx_flush_i(usb_ep1_tx_ctrl_tx_flush_out_w),
    .tx_length_i(usb_ep1_tx_ctrl_tx_len_out_w),
    .tx_start_i(usb_ep1_tx_ctrl_tx_start_out_w),
    .tx_busy_o(usb_ep1_sts_tx_busy_in_w),
    .tx_err_o(usb_ep1_sts_tx_err_in_w),

    // Tx SIE Interface
    .tx_ready_o(ep1_tx_ready_w),
    .tx_data_valid_o(ep1_tx_data_valid_w),
    .tx_data_strb_o(ep1_tx_data_strb_w),
    .tx_data_o(ep1_tx_data_w),
    .tx_data_last_o(ep1_tx_data_last_w),
    .tx_data_accept_i(ep1_tx_data_accept_w)
);
//-----------------------------------------------------------------
// Endpoint 2: Control
//-----------------------------------------------------------------
usbf_sie_ep
u_ep2
(
    .clk_i(clk_i),
    .rst_i(rst_i),   

    // Rx SIE Interface
    .rx_space_o(ep2_rx_space_w),
    .rx_valid_i(ep2_rx_valid_w),
    .rx_setup_i(ep2_rx_setup_w),
    .rx_strb_i(rx_strb_w),
    .rx_data_i(rx_data_w),
    .rx_last_i(rx_last_w),
    .rx_crc_err_i(rx_crc_err_w),

    // Rx FIFO Interface
    .rx_push_o(usb_ep2_rx_wr_w),
    .rx_data_o(usb_ep2_rx_data_w),
    .rx_full_i(usb_ep2_rx_full_w),

    // Rx Register Interface
    .rx_length_o(usb_ep2_sts_rx_count_in_w),
    .rx_ready_o(usb_ep2_sts_rx_ready_in_w),
    .rx_err_o(usb_ep2_sts_rx_err_in_w),
    .rx_setup_o(usb_ep2_sts_rx_setup_in_w),
    .rx_ack_i(usb_ep2_rx_ctrl_rx_accept_out_w),

    // Tx FIFO Interface
    .tx_pop_o(usb_ep2_tx_rd_w),
    .tx_data_i(usb_ep2_tx_data_w),
    .tx_empty_i(usb_ep2_tx_empty_w),

    // Tx Register Interface
    .tx_flush_i(usb_ep2_tx_ctrl_tx_flush_out_w),
    .tx_length_i(usb_ep2_tx_ctrl_tx_len_out_w),
    .tx_start_i(usb_ep2_tx_ctrl_tx_start_out_w),
    .tx_busy_o(usb_ep2_sts_tx_busy_in_w),
    .tx_err_o(usb_ep2_sts_tx_err_in_w),

    // Tx SIE Interface
    .tx_ready_o(ep2_tx_ready_w),
    .tx_data_valid_o(ep2_tx_data_valid_w),
    .tx_data_strb_o(ep2_tx_data_strb_w),
    .tx_data_o(ep2_tx_data_w),
    .tx_data_last_o(ep2_tx_data_last_w),
    .tx_data_accept_i(ep2_tx_data_accept_w)
);
//-----------------------------------------------------------------
// Endpoint 3: Control
//-----------------------------------------------------------------
usbf_sie_ep
u_ep3
(
    .clk_i(clk_i),
    .rst_i(rst_i),   

    // Rx SIE Interface
    .rx_space_o(ep3_rx_space_w),
    .rx_valid_i(ep3_rx_valid_w),
    .rx_setup_i(ep3_rx_setup_w),
    .rx_strb_i(rx_strb_w),
    .rx_data_i(rx_data_w),
    .rx_last_i(rx_last_w),
    .rx_crc_err_i(rx_crc_err_w),

    // Rx FIFO Interface
    .rx_push_o(usb_ep3_rx_wr_w),
    .rx_data_o(usb_ep3_rx_data_w),
    .rx_full_i(usb_ep3_rx_full_w),

    // Rx Register Interface
    .rx_length_o(usb_ep3_sts_rx_count_in_w),
    .rx_ready_o(usb_ep3_sts_rx_ready_in_w),
    .rx_err_o(usb_ep3_sts_rx_err_in_w),
    .rx_setup_o(usb_ep3_sts_rx_setup_in_w),
    .rx_ack_i(usb_ep3_rx_ctrl_rx_accept_out_w),

    // Tx FIFO Interface
    .tx_pop_o(usb_ep3_tx_rd_w),
    .tx_data_i(usb_ep3_tx_data_w),
    .tx_empty_i(usb_ep3_tx_empty_w),

    // Tx Register Interface
    .tx_flush_i(usb_ep3_tx_ctrl_tx_flush_out_w),
    .tx_length_i(usb_ep3_tx_ctrl_tx_len_out_w),
    .tx_start_i(usb_ep3_tx_ctrl_tx_start_out_w),
    .tx_busy_o(usb_ep3_sts_tx_busy_in_w),
    .tx_err_o(usb_ep3_sts_tx_err_in_w),

    // Tx SIE Interface
    .tx_ready_o(ep3_tx_ready_w),
    .tx_data_valid_o(ep3_tx_data_valid_w),
    .tx_data_strb_o(ep3_tx_data_strb_w),
    .tx_data_o(ep3_tx_data_w),
    .tx_data_last_o(ep3_tx_data_last_w),
    .tx_data_accept_i(ep3_tx_data_accept_w)
);


endmodule
