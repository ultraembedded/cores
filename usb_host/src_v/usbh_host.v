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

`include "usbh_host_defs.v"

//-----------------------------------------------------------------
// Module:  USB Host IP
//-----------------------------------------------------------------
module usbh_host
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
// Register usb_ctrl
//-----------------------------------------------------------------
reg usb_ctrl_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ctrl_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_CTRL))
    usb_ctrl_wr_q <= 1'b1;
else
    usb_ctrl_wr_q <= 1'b0;

// usb_ctrl_phy_dmpulldown [internal]
reg        usb_ctrl_phy_dmpulldown_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ctrl_phy_dmpulldown_q <= 1'd`USB_CTRL_PHY_DMPULLDOWN_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_CTRL))
    usb_ctrl_phy_dmpulldown_q <= cfg_wdata_i[`USB_CTRL_PHY_DMPULLDOWN_R];

wire        usb_ctrl_phy_dmpulldown_out_w = usb_ctrl_phy_dmpulldown_q;


// usb_ctrl_phy_dppulldown [internal]
reg        usb_ctrl_phy_dppulldown_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ctrl_phy_dppulldown_q <= 1'd`USB_CTRL_PHY_DPPULLDOWN_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_CTRL))
    usb_ctrl_phy_dppulldown_q <= cfg_wdata_i[`USB_CTRL_PHY_DPPULLDOWN_R];

wire        usb_ctrl_phy_dppulldown_out_w = usb_ctrl_phy_dppulldown_q;


// usb_ctrl_phy_termselect [internal]
reg        usb_ctrl_phy_termselect_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ctrl_phy_termselect_q <= 1'd`USB_CTRL_PHY_TERMSELECT_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_CTRL))
    usb_ctrl_phy_termselect_q <= cfg_wdata_i[`USB_CTRL_PHY_TERMSELECT_R];

wire        usb_ctrl_phy_termselect_out_w = usb_ctrl_phy_termselect_q;


// usb_ctrl_phy_xcvrselect [internal]
reg [1:0]  usb_ctrl_phy_xcvrselect_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ctrl_phy_xcvrselect_q <= 2'd`USB_CTRL_PHY_XCVRSELECT_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_CTRL))
    usb_ctrl_phy_xcvrselect_q <= cfg_wdata_i[`USB_CTRL_PHY_XCVRSELECT_R];

wire [1:0]  usb_ctrl_phy_xcvrselect_out_w = usb_ctrl_phy_xcvrselect_q;


// usb_ctrl_phy_opmode [internal]
reg [1:0]  usb_ctrl_phy_opmode_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ctrl_phy_opmode_q <= 2'd`USB_CTRL_PHY_OPMODE_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_CTRL))
    usb_ctrl_phy_opmode_q <= cfg_wdata_i[`USB_CTRL_PHY_OPMODE_R];

wire [1:0]  usb_ctrl_phy_opmode_out_w = usb_ctrl_phy_opmode_q;


// usb_ctrl_tx_flush [auto_clr]
reg        usb_ctrl_tx_flush_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ctrl_tx_flush_q <= 1'd`USB_CTRL_TX_FLUSH_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_CTRL))
    usb_ctrl_tx_flush_q <= cfg_wdata_i[`USB_CTRL_TX_FLUSH_R];
else
    usb_ctrl_tx_flush_q <= 1'd`USB_CTRL_TX_FLUSH_DEFAULT;

wire        usb_ctrl_tx_flush_out_w = usb_ctrl_tx_flush_q;


// usb_ctrl_enable_sof [internal]
reg        usb_ctrl_enable_sof_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_ctrl_enable_sof_q <= 1'd`USB_CTRL_ENABLE_SOF_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_CTRL))
    usb_ctrl_enable_sof_q <= cfg_wdata_i[`USB_CTRL_ENABLE_SOF_R];

wire        usb_ctrl_enable_sof_out_w = usb_ctrl_enable_sof_q;


//-----------------------------------------------------------------
// Register usb_status
//-----------------------------------------------------------------
reg usb_status_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_status_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_STATUS))
    usb_status_wr_q <= 1'b1;
else
    usb_status_wr_q <= 1'b0;




//-----------------------------------------------------------------
// Register usb_irq_ack
//-----------------------------------------------------------------
reg usb_irq_ack_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_irq_ack_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_IRQ_ACK))
    usb_irq_ack_wr_q <= 1'b1;
else
    usb_irq_ack_wr_q <= 1'b0;

// usb_irq_ack_device_detect [auto_clr]
reg        usb_irq_ack_device_detect_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_irq_ack_device_detect_q <= 1'd`USB_IRQ_ACK_DEVICE_DETECT_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_IRQ_ACK))
    usb_irq_ack_device_detect_q <= cfg_wdata_i[`USB_IRQ_ACK_DEVICE_DETECT_R];
else
    usb_irq_ack_device_detect_q <= 1'd`USB_IRQ_ACK_DEVICE_DETECT_DEFAULT;

wire        usb_irq_ack_device_detect_out_w = usb_irq_ack_device_detect_q;


// usb_irq_ack_err [auto_clr]
reg        usb_irq_ack_err_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_irq_ack_err_q <= 1'd`USB_IRQ_ACK_ERR_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_IRQ_ACK))
    usb_irq_ack_err_q <= cfg_wdata_i[`USB_IRQ_ACK_ERR_R];
else
    usb_irq_ack_err_q <= 1'd`USB_IRQ_ACK_ERR_DEFAULT;

wire        usb_irq_ack_err_out_w = usb_irq_ack_err_q;


// usb_irq_ack_done [auto_clr]
reg        usb_irq_ack_done_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_irq_ack_done_q <= 1'd`USB_IRQ_ACK_DONE_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_IRQ_ACK))
    usb_irq_ack_done_q <= cfg_wdata_i[`USB_IRQ_ACK_DONE_R];
else
    usb_irq_ack_done_q <= 1'd`USB_IRQ_ACK_DONE_DEFAULT;

wire        usb_irq_ack_done_out_w = usb_irq_ack_done_q;


// usb_irq_ack_sof [auto_clr]
reg        usb_irq_ack_sof_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_irq_ack_sof_q <= 1'd`USB_IRQ_ACK_SOF_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_IRQ_ACK))
    usb_irq_ack_sof_q <= cfg_wdata_i[`USB_IRQ_ACK_SOF_R];
else
    usb_irq_ack_sof_q <= 1'd`USB_IRQ_ACK_SOF_DEFAULT;

wire        usb_irq_ack_sof_out_w = usb_irq_ack_sof_q;


//-----------------------------------------------------------------
// Register usb_irq_sts
//-----------------------------------------------------------------
reg usb_irq_sts_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_irq_sts_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_IRQ_STS))
    usb_irq_sts_wr_q <= 1'b1;
else
    usb_irq_sts_wr_q <= 1'b0;





//-----------------------------------------------------------------
// Register usb_irq_mask
//-----------------------------------------------------------------
reg usb_irq_mask_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_irq_mask_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_IRQ_MASK))
    usb_irq_mask_wr_q <= 1'b1;
else
    usb_irq_mask_wr_q <= 1'b0;

// usb_irq_mask_device_detect [internal]
reg        usb_irq_mask_device_detect_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_irq_mask_device_detect_q <= 1'd`USB_IRQ_MASK_DEVICE_DETECT_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_IRQ_MASK))
    usb_irq_mask_device_detect_q <= cfg_wdata_i[`USB_IRQ_MASK_DEVICE_DETECT_R];

wire        usb_irq_mask_device_detect_out_w = usb_irq_mask_device_detect_q;


// usb_irq_mask_err [internal]
reg        usb_irq_mask_err_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_irq_mask_err_q <= 1'd`USB_IRQ_MASK_ERR_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_IRQ_MASK))
    usb_irq_mask_err_q <= cfg_wdata_i[`USB_IRQ_MASK_ERR_R];

wire        usb_irq_mask_err_out_w = usb_irq_mask_err_q;


// usb_irq_mask_done [internal]
reg        usb_irq_mask_done_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_irq_mask_done_q <= 1'd`USB_IRQ_MASK_DONE_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_IRQ_MASK))
    usb_irq_mask_done_q <= cfg_wdata_i[`USB_IRQ_MASK_DONE_R];

wire        usb_irq_mask_done_out_w = usb_irq_mask_done_q;


// usb_irq_mask_sof [internal]
reg        usb_irq_mask_sof_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_irq_mask_sof_q <= 1'd`USB_IRQ_MASK_SOF_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_IRQ_MASK))
    usb_irq_mask_sof_q <= cfg_wdata_i[`USB_IRQ_MASK_SOF_R];

wire        usb_irq_mask_sof_out_w = usb_irq_mask_sof_q;


//-----------------------------------------------------------------
// Register usb_xfer_data
//-----------------------------------------------------------------
reg usb_xfer_data_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_xfer_data_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_XFER_DATA))
    usb_xfer_data_wr_q <= 1'b1;
else
    usb_xfer_data_wr_q <= 1'b0;

// usb_xfer_data_tx_len [internal]
reg [15:0]  usb_xfer_data_tx_len_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_xfer_data_tx_len_q <= 16'd`USB_XFER_DATA_TX_LEN_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_XFER_DATA))
    usb_xfer_data_tx_len_q <= cfg_wdata_i[`USB_XFER_DATA_TX_LEN_R];

wire [15:0]  usb_xfer_data_tx_len_out_w = usb_xfer_data_tx_len_q;


//-----------------------------------------------------------------
// Register usb_xfer_token
//-----------------------------------------------------------------
reg usb_xfer_token_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_xfer_token_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_XFER_TOKEN))
    usb_xfer_token_wr_q <= 1'b1;
else
    usb_xfer_token_wr_q <= 1'b0;

// usb_xfer_token_start [clearable]
reg        usb_xfer_token_start_q;

wire usb_xfer_token_start_ack_in_w;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_xfer_token_start_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_XFER_TOKEN))
    usb_xfer_token_start_q <= cfg_wdata_i[`USB_XFER_TOKEN_START_R];
else if (usb_xfer_token_start_ack_in_w)
    usb_xfer_token_start_q <= 1'b0;

wire        usb_xfer_token_start_out_w = usb_xfer_token_start_q;


// usb_xfer_token_in [internal]
reg        usb_xfer_token_in_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_xfer_token_in_q <= 1'd`USB_XFER_TOKEN_IN_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_XFER_TOKEN))
    usb_xfer_token_in_q <= cfg_wdata_i[`USB_XFER_TOKEN_IN_R];

wire        usb_xfer_token_in_out_w = usb_xfer_token_in_q;


// usb_xfer_token_ack [internal]
reg        usb_xfer_token_ack_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_xfer_token_ack_q <= 1'd`USB_XFER_TOKEN_ACK_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_XFER_TOKEN))
    usb_xfer_token_ack_q <= cfg_wdata_i[`USB_XFER_TOKEN_ACK_R];

wire        usb_xfer_token_ack_out_w = usb_xfer_token_ack_q;


// usb_xfer_token_pid_datax [internal]
reg        usb_xfer_token_pid_datax_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_xfer_token_pid_datax_q <= 1'd`USB_XFER_TOKEN_PID_DATAX_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_XFER_TOKEN))
    usb_xfer_token_pid_datax_q <= cfg_wdata_i[`USB_XFER_TOKEN_PID_DATAX_R];

wire        usb_xfer_token_pid_datax_out_w = usb_xfer_token_pid_datax_q;


// usb_xfer_token_pid_bits [internal]
reg [7:0]  usb_xfer_token_pid_bits_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_xfer_token_pid_bits_q <= 8'd`USB_XFER_TOKEN_PID_BITS_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_XFER_TOKEN))
    usb_xfer_token_pid_bits_q <= cfg_wdata_i[`USB_XFER_TOKEN_PID_BITS_R];

wire [7:0]  usb_xfer_token_pid_bits_out_w = usb_xfer_token_pid_bits_q;


// usb_xfer_token_dev_addr [internal]
reg [6:0]  usb_xfer_token_dev_addr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_xfer_token_dev_addr_q <= 7'd`USB_XFER_TOKEN_DEV_ADDR_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_XFER_TOKEN))
    usb_xfer_token_dev_addr_q <= cfg_wdata_i[`USB_XFER_TOKEN_DEV_ADDR_R];

wire [6:0]  usb_xfer_token_dev_addr_out_w = usb_xfer_token_dev_addr_q;


// usb_xfer_token_ep_addr [internal]
reg [3:0]  usb_xfer_token_ep_addr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_xfer_token_ep_addr_q <= 4'd`USB_XFER_TOKEN_EP_ADDR_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_XFER_TOKEN))
    usb_xfer_token_ep_addr_q <= cfg_wdata_i[`USB_XFER_TOKEN_EP_ADDR_R];

wire [3:0]  usb_xfer_token_ep_addr_out_w = usb_xfer_token_ep_addr_q;


//-----------------------------------------------------------------
// Register usb_rx_stat
//-----------------------------------------------------------------
reg usb_rx_stat_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_rx_stat_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_RX_STAT))
    usb_rx_stat_wr_q <= 1'b1;
else
    usb_rx_stat_wr_q <= 1'b0;







//-----------------------------------------------------------------
// Register usb_wr_data
//-----------------------------------------------------------------
reg usb_wr_data_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_wr_data_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_WR_DATA))
    usb_wr_data_wr_q <= 1'b1;
else
    usb_wr_data_wr_q <= 1'b0;

// usb_wr_data_data [external]
wire [7:0]  usb_wr_data_data_out_w = wr_data_q[`USB_WR_DATA_DATA_R];


//-----------------------------------------------------------------
// Register usb_rd_data
//-----------------------------------------------------------------
reg usb_rd_data_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_rd_data_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `USB_RD_DATA))
    usb_rd_data_wr_q <= 1'b1;
else
    usb_rd_data_wr_q <= 1'b0;


wire [15:0]  usb_status_sof_time_in_w;
wire        usb_status_rx_error_in_w;
wire [1:0]  usb_status_linestate_bits_in_w;
wire        usb_irq_sts_device_detect_in_w;
wire        usb_irq_sts_err_in_w;
wire        usb_irq_sts_done_in_w;
wire        usb_irq_sts_sof_in_w;
wire        usb_rx_stat_start_pend_in_w;
wire        usb_rx_stat_crc_err_in_w;
wire        usb_rx_stat_resp_timeout_in_w;
wire        usb_rx_stat_idle_in_w;
wire [7:0]  usb_rx_stat_resp_bits_in_w;
wire [15:0]  usb_rx_stat_count_bits_in_w;
wire [7:0]  usb_rd_data_data_in_w;


//-----------------------------------------------------------------
// Read mux
//-----------------------------------------------------------------
reg [31:0] data_r;

always @ *
begin
    data_r = 32'b0;

    case (cfg_araddr_i[7:0])

    `USB_CTRL:
    begin
        data_r[`USB_CTRL_PHY_DMPULLDOWN_R] = usb_ctrl_phy_dmpulldown_q;
        data_r[`USB_CTRL_PHY_DPPULLDOWN_R] = usb_ctrl_phy_dppulldown_q;
        data_r[`USB_CTRL_PHY_TERMSELECT_R] = usb_ctrl_phy_termselect_q;
        data_r[`USB_CTRL_PHY_XCVRSELECT_R] = usb_ctrl_phy_xcvrselect_q;
        data_r[`USB_CTRL_PHY_OPMODE_R] = usb_ctrl_phy_opmode_q;
        data_r[`USB_CTRL_ENABLE_SOF_R] = usb_ctrl_enable_sof_q;
    end
    `USB_STATUS:
    begin
        data_r[`USB_STATUS_SOF_TIME_R] = usb_status_sof_time_in_w;
        data_r[`USB_STATUS_RX_ERROR_R] = usb_status_rx_error_in_w;
        data_r[`USB_STATUS_LINESTATE_BITS_R] = usb_status_linestate_bits_in_w;
    end
    `USB_IRQ_STS:
    begin
        data_r[`USB_IRQ_STS_DEVICE_DETECT_R] = usb_irq_sts_device_detect_in_w;
        data_r[`USB_IRQ_STS_ERR_R] = usb_irq_sts_err_in_w;
        data_r[`USB_IRQ_STS_DONE_R] = usb_irq_sts_done_in_w;
        data_r[`USB_IRQ_STS_SOF_R] = usb_irq_sts_sof_in_w;
    end
    `USB_IRQ_MASK:
    begin
        data_r[`USB_IRQ_MASK_DEVICE_DETECT_R] = usb_irq_mask_device_detect_q;
        data_r[`USB_IRQ_MASK_ERR_R] = usb_irq_mask_err_q;
        data_r[`USB_IRQ_MASK_DONE_R] = usb_irq_mask_done_q;
        data_r[`USB_IRQ_MASK_SOF_R] = usb_irq_mask_sof_q;
    end
    `USB_XFER_DATA:
    begin
        data_r[`USB_XFER_DATA_TX_LEN_R] = usb_xfer_data_tx_len_q;
    end
    `USB_XFER_TOKEN:
    begin
        data_r[`USB_XFER_TOKEN_IN_R] = usb_xfer_token_in_q;
        data_r[`USB_XFER_TOKEN_ACK_R] = usb_xfer_token_ack_q;
        data_r[`USB_XFER_TOKEN_PID_DATAX_R] = usb_xfer_token_pid_datax_q;
        data_r[`USB_XFER_TOKEN_PID_BITS_R] = usb_xfer_token_pid_bits_q;
        data_r[`USB_XFER_TOKEN_DEV_ADDR_R] = usb_xfer_token_dev_addr_q;
        data_r[`USB_XFER_TOKEN_EP_ADDR_R] = usb_xfer_token_ep_addr_q;
    end
    `USB_RX_STAT:
    begin
        data_r[`USB_RX_STAT_START_PEND_R] = usb_rx_stat_start_pend_in_w;
        data_r[`USB_RX_STAT_CRC_ERR_R] = usb_rx_stat_crc_err_in_w;
        data_r[`USB_RX_STAT_RESP_TIMEOUT_R] = usb_rx_stat_resp_timeout_in_w;
        data_r[`USB_RX_STAT_IDLE_R] = usb_rx_stat_idle_in_w;
        data_r[`USB_RX_STAT_RESP_BITS_R] = usb_rx_stat_resp_bits_in_w;
        data_r[`USB_RX_STAT_COUNT_BITS_R] = usb_rx_stat_count_bits_in_w;
    end
    `USB_RD_DATA:
    begin
        data_r[`USB_RD_DATA_DATA_R] = usb_rd_data_data_in_w;
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

wire usb_rd_data_rd_req_w = read_en_w & (cfg_araddr_i[7:0] == `USB_RD_DATA);

wire usb_wr_data_wr_req_w = usb_wr_data_wr_q;
wire usb_rd_data_wr_req_w = usb_rd_data_wr_q;

//-----------------------------------------------------------------
// Registers / Wires
//-----------------------------------------------------------------
// SOF
reg [10:0]  sof_value_q;
reg [15:0]  sof_time_q;
reg         sof_irq_q;

reg         transfer_req_ack_q;

wire [7:0]  fifo_tx_data_w;
wire        fifo_tx_pop_w;

wire [7:0]  fifo_rx_data_w;
wire        fifo_rx_push_w;

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

reg         usb_err_q;

reg         intr_done_q;
reg         intr_sof_q;
reg         intr_err_q;

//-----------------------------------------------------------------
// Definitions
//-----------------------------------------------------------------
localparam [15:0] SOF_ZERO        = 0;
localparam [15:0] SOF_INC         = 1;
localparam [15:0] SOF_THRESHOLD   = 48000-1;

localparam [15:0] CLKS_PER_BIT    = 4;

localparam [15:0] EOF1_THRESHOLD  = (50 * CLKS_PER_BIT); // EOF1 + some margin
localparam [15:0] MAX_XFER_SIZE   = 64;
localparam [15:0] MAX_XFER_PERIOD = ((MAX_XFER_SIZE + 6) * 10  * CLKS_PER_BIT); // Max packet transfer time (+ margin)
localparam [15:0] SOF_GAURD_LOW   = (20 * CLKS_PER_BIT);
localparam [15:0] SOF_GAURD_HIGH  = SOF_THRESHOLD - EOF1_THRESHOLD - MAX_XFER_PERIOD;

localparam PID_SOF      = 8'hA5;

//-----------------------------------------------------------------
// SIE
//-----------------------------------------------------------------
usbh_sie
u_sie
(
    // Clock & reset
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
    .data_len_i(usb_xfer_data_tx_len_out_w),
    .data_idx_i(usb_xfer_token_pid_datax_out_w),

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
    .utmi_data_o(utmi_data_out_o),
    .utmi_txvalid_o(utmi_txvalid_o),
    .utmi_txready_i(utmi_txready_i),
    .utmi_data_i(utmi_data_in_i),
    .utmi_rxvalid_i(utmi_rxvalid_i),
    .utmi_rxactive_i(utmi_rxactive_i)
);    

//-----------------------------------------------------------------
// Peripheral Interface
//-----------------------------------------------------------------
assign usb_status_sof_time_in_w       = sof_time_q;
assign usb_status_rx_error_in_w       = usb_err_q;
assign usb_status_linestate_bits_in_w = utmi_linestate_i;

assign usb_irq_sts_err_in_w           = intr_err_q;
assign usb_irq_sts_done_in_w          = intr_done_q;
assign usb_irq_sts_sof_in_w           = intr_sof_q;

assign usb_rx_stat_start_pend_in_w    = usb_xfer_token_start_out_w;
assign usb_rx_stat_crc_err_in_w       = status_crc_err_w;
assign usb_rx_stat_resp_timeout_in_w  = status_timeout_w;
assign usb_rx_stat_idle_in_w          = status_sie_idle_w;
assign usb_rx_stat_resp_bits_in_w     = status_response_w;
assign usb_rx_stat_count_bits_in_w    = status_rx_count_w;

assign usb_xfer_token_start_ack_in_w  = transfer_req_ack_q;

assign utmi_op_mode_o                 = usb_ctrl_phy_opmode_out_w;
assign utmi_xcvrselect_o              = usb_ctrl_phy_xcvrselect_out_w;
assign utmi_termselect_o              = usb_ctrl_phy_termselect_out_w;
assign utmi_dppulldown_o              = usb_ctrl_phy_dppulldown_out_w;
assign utmi_dmpulldown_o              = usb_ctrl_phy_dmpulldown_out_w;

//-----------------------------------------------------------------
// Tx FIFO (Host -> Device)
//-----------------------------------------------------------------
usbh_fifo
u_fifo_tx
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .data_i(usb_wr_data_data_out_w),
    .push_i(usb_wr_data_wr_req_w),

    .flush_i(usb_ctrl_tx_flush_out_w),

    .full_o(),
    .empty_o(),

    .data_o(fifo_tx_data_w),
    .pop_i(fifo_tx_pop_w)
);

//-----------------------------------------------------------------
// Rx FIFO (Device -> Host)
//-----------------------------------------------------------------
usbh_fifo
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

    .data_o(usb_rd_data_data_in_w),
    .pop_i(usb_rd_data_rd_req_w)
);

//-----------------------------------------------------------------
// Assignments
//-----------------------------------------------------------------
assign send_sof_w       = (sof_time_q == SOF_THRESHOLD && usb_ctrl_enable_sof_out_w) & status_sie_idle_w;
assign sof_gaurd_band_w = (sof_time_q <= SOF_GAURD_LOW || sof_time_q >= SOF_GAURD_HIGH);
assign clear_to_send_w  = (~sof_gaurd_band_w | ~usb_ctrl_enable_sof_out_w) & status_sie_idle_w;

assign token_pid_w      = sof_transfer_q ? PID_SOF : usb_xfer_token_pid_bits_out_w;

assign token_dev_w      = sof_transfer_q ? 
                          {sof_value_q[0], sof_value_q[1], sof_value_q[2], 
                          sof_value_q[3], sof_value_q[4], sof_value_q[5], sof_value_q[6]} :
                          {usb_xfer_token_dev_addr_out_w[0], usb_xfer_token_dev_addr_out_w[1], usb_xfer_token_dev_addr_out_w[2], usb_xfer_token_dev_addr_out_w[3], usb_xfer_token_dev_addr_out_w[4], usb_xfer_token_dev_addr_out_w[5], usb_xfer_token_dev_addr_out_w[6]};

assign token_ep_w       = sof_transfer_q ? 
                          {sof_value_q[7], sof_value_q[8], sof_value_q[9], sof_value_q[10]} : 
                          {usb_xfer_token_ep_addr_out_w[0], usb_xfer_token_ep_addr_out_w[1], usb_xfer_token_ep_addr_out_w[2], usb_xfer_token_ep_addr_out_w[3]};

//-----------------------------------------------------------------
// Control logic
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
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
        if (usb_xfer_token_start_out_w)
        begin              
            // Flush un-used previous Rx data
            fifo_flush_q       <= 1'b1;

            // Start transfer
            in_transfer_q      <= usb_xfer_token_in_out_w;
            resp_expected_q    <= usb_xfer_token_ack_out_w;
            transfer_start_q   <= 1'b1;
            sof_transfer_q     <= 1'b0;
            transfer_req_ack_q <= 1'b1;
        end
    end
end

//-----------------------------------------------------------------
// SOF Frame Number
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
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

//-----------------------------------------------------------------
// Record Errors
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_err_q <= 1'b0;
// Clear error
else if (usb_ctrl_wr_q)
    usb_err_q <= 1'b0;
// Record bus errors
else if (utmi_rxerror_i)
    usb_err_q <= 1'b1;

//-----------------------------------------------------------------
// Interrupts
//-----------------------------------------------------------------
reg err_cond_q;
reg intr_q;
reg device_det_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
begin
    intr_done_q   <= 1'b0;
    intr_sof_q    <= 1'b0;
    intr_err_q    <= 1'b0;
    err_cond_q    <= 1'b0;
    device_det_q  <= 1'b0;
    intr_q        <= 1'b0;
end
else
begin
    if (status_rx_done_w || status_tx_done_w)
        intr_done_q <= 1'b1;
    else if (usb_irq_ack_done_out_w)
        intr_done_q <= 1'b0;

    if (sof_irq_q)
        intr_sof_q  <= 1'b1;
    else if (usb_irq_ack_sof_out_w)
        intr_sof_q <= 1'b0;

    if ((status_crc_err_w || status_timeout_w) && (!err_cond_q))
        intr_err_q <= 1'b1;
    else if (usb_irq_ack_err_out_w)
        intr_err_q <= 1'b0;

    // Line state != SE0
    if (utmi_linestate_i != 2'b0)
        device_det_q  <= 1'b1;
    else if (usb_irq_ack_device_detect_out_w)
        device_det_q <= 1'b0;

    err_cond_q  <= (status_crc_err_w | status_timeout_w);

    intr_q <= (intr_done_q  & usb_irq_mask_done_out_w) |
              (intr_err_q   & usb_irq_mask_err_out_w)  |
              (intr_sof_q   & usb_irq_mask_sof_out_w)  |
              (device_det_q & usb_irq_mask_device_detect_out_w);
end

assign intr_o = intr_q;



endmodule
