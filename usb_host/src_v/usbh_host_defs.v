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

`define USB_CTRL    8'h0

    `define USB_CTRL_PHY_DMPULLDOWN      7
    `define USB_CTRL_PHY_DMPULLDOWN_DEFAULT    0
    `define USB_CTRL_PHY_DMPULLDOWN_B          7
    `define USB_CTRL_PHY_DMPULLDOWN_T          7
    `define USB_CTRL_PHY_DMPULLDOWN_W          1
    `define USB_CTRL_PHY_DMPULLDOWN_R          7:7

    `define USB_CTRL_PHY_DPPULLDOWN      6
    `define USB_CTRL_PHY_DPPULLDOWN_DEFAULT    0
    `define USB_CTRL_PHY_DPPULLDOWN_B          6
    `define USB_CTRL_PHY_DPPULLDOWN_T          6
    `define USB_CTRL_PHY_DPPULLDOWN_W          1
    `define USB_CTRL_PHY_DPPULLDOWN_R          6:6

    `define USB_CTRL_PHY_TERMSELECT      5
    `define USB_CTRL_PHY_TERMSELECT_DEFAULT    0
    `define USB_CTRL_PHY_TERMSELECT_B          5
    `define USB_CTRL_PHY_TERMSELECT_T          5
    `define USB_CTRL_PHY_TERMSELECT_W          1
    `define USB_CTRL_PHY_TERMSELECT_R          5:5

    `define USB_CTRL_PHY_XCVRSELECT_DEFAULT    0
    `define USB_CTRL_PHY_XCVRSELECT_B          3
    `define USB_CTRL_PHY_XCVRSELECT_T          4
    `define USB_CTRL_PHY_XCVRSELECT_W          2
    `define USB_CTRL_PHY_XCVRSELECT_R          4:3

    `define USB_CTRL_PHY_OPMODE_DEFAULT    0
    `define USB_CTRL_PHY_OPMODE_B          1
    `define USB_CTRL_PHY_OPMODE_T          2
    `define USB_CTRL_PHY_OPMODE_W          2
    `define USB_CTRL_PHY_OPMODE_R          2:1

    `define USB_CTRL_TX_FLUSH      1
    `define USB_CTRL_TX_FLUSH_DEFAULT    0
    `define USB_CTRL_TX_FLUSH_B          1
    `define USB_CTRL_TX_FLUSH_T          1
    `define USB_CTRL_TX_FLUSH_W          1
    `define USB_CTRL_TX_FLUSH_R          1:1

    `define USB_CTRL_ENABLE_SOF      0
    `define USB_CTRL_ENABLE_SOF_DEFAULT    0
    `define USB_CTRL_ENABLE_SOF_B          0
    `define USB_CTRL_ENABLE_SOF_T          0
    `define USB_CTRL_ENABLE_SOF_W          1
    `define USB_CTRL_ENABLE_SOF_R          0:0

`define USB_STATUS    8'h4

    `define USB_STATUS_SOF_TIME_DEFAULT    0
    `define USB_STATUS_SOF_TIME_B          16
    `define USB_STATUS_SOF_TIME_T          31
    `define USB_STATUS_SOF_TIME_W          16
    `define USB_STATUS_SOF_TIME_R          31:16

    `define USB_STATUS_RX_ERROR      2
    `define USB_STATUS_RX_ERROR_DEFAULT    0
    `define USB_STATUS_RX_ERROR_B          2
    `define USB_STATUS_RX_ERROR_T          2
    `define USB_STATUS_RX_ERROR_W          1
    `define USB_STATUS_RX_ERROR_R          2:2

    `define USB_STATUS_LINESTATE_BITS_DEFAULT    0
    `define USB_STATUS_LINESTATE_BITS_B          0
    `define USB_STATUS_LINESTATE_BITS_T          1
    `define USB_STATUS_LINESTATE_BITS_W          2
    `define USB_STATUS_LINESTATE_BITS_R          1:0

`define USB_IRQ_ACK    8'h8

    `define USB_IRQ_ACK_DEVICE_DETECT      3
    `define USB_IRQ_ACK_DEVICE_DETECT_DEFAULT    0
    `define USB_IRQ_ACK_DEVICE_DETECT_B          3
    `define USB_IRQ_ACK_DEVICE_DETECT_T          3
    `define USB_IRQ_ACK_DEVICE_DETECT_W          1
    `define USB_IRQ_ACK_DEVICE_DETECT_R          3:3

    `define USB_IRQ_ACK_ERR      2
    `define USB_IRQ_ACK_ERR_DEFAULT    0
    `define USB_IRQ_ACK_ERR_B          2
    `define USB_IRQ_ACK_ERR_T          2
    `define USB_IRQ_ACK_ERR_W          1
    `define USB_IRQ_ACK_ERR_R          2:2

    `define USB_IRQ_ACK_DONE      1
    `define USB_IRQ_ACK_DONE_DEFAULT    0
    `define USB_IRQ_ACK_DONE_B          1
    `define USB_IRQ_ACK_DONE_T          1
    `define USB_IRQ_ACK_DONE_W          1
    `define USB_IRQ_ACK_DONE_R          1:1

    `define USB_IRQ_ACK_SOF      0
    `define USB_IRQ_ACK_SOF_DEFAULT    0
    `define USB_IRQ_ACK_SOF_B          0
    `define USB_IRQ_ACK_SOF_T          0
    `define USB_IRQ_ACK_SOF_W          1
    `define USB_IRQ_ACK_SOF_R          0:0

`define USB_IRQ_STS    8'hc

    `define USB_IRQ_STS_DEVICE_DETECT      3
    `define USB_IRQ_STS_DEVICE_DETECT_DEFAULT    0
    `define USB_IRQ_STS_DEVICE_DETECT_B          3
    `define USB_IRQ_STS_DEVICE_DETECT_T          3
    `define USB_IRQ_STS_DEVICE_DETECT_W          1
    `define USB_IRQ_STS_DEVICE_DETECT_R          3:3

    `define USB_IRQ_STS_ERR      2
    `define USB_IRQ_STS_ERR_DEFAULT    0
    `define USB_IRQ_STS_ERR_B          2
    `define USB_IRQ_STS_ERR_T          2
    `define USB_IRQ_STS_ERR_W          1
    `define USB_IRQ_STS_ERR_R          2:2

    `define USB_IRQ_STS_DONE      1
    `define USB_IRQ_STS_DONE_DEFAULT    0
    `define USB_IRQ_STS_DONE_B          1
    `define USB_IRQ_STS_DONE_T          1
    `define USB_IRQ_STS_DONE_W          1
    `define USB_IRQ_STS_DONE_R          1:1

    `define USB_IRQ_STS_SOF      0
    `define USB_IRQ_STS_SOF_DEFAULT    0
    `define USB_IRQ_STS_SOF_B          0
    `define USB_IRQ_STS_SOF_T          0
    `define USB_IRQ_STS_SOF_W          1
    `define USB_IRQ_STS_SOF_R          0:0

`define USB_IRQ_MASK    8'h10

    `define USB_IRQ_MASK_DEVICE_DETECT      3
    `define USB_IRQ_MASK_DEVICE_DETECT_DEFAULT    0
    `define USB_IRQ_MASK_DEVICE_DETECT_B          3
    `define USB_IRQ_MASK_DEVICE_DETECT_T          3
    `define USB_IRQ_MASK_DEVICE_DETECT_W          1
    `define USB_IRQ_MASK_DEVICE_DETECT_R          3:3

    `define USB_IRQ_MASK_ERR      2
    `define USB_IRQ_MASK_ERR_DEFAULT    0
    `define USB_IRQ_MASK_ERR_B          2
    `define USB_IRQ_MASK_ERR_T          2
    `define USB_IRQ_MASK_ERR_W          1
    `define USB_IRQ_MASK_ERR_R          2:2

    `define USB_IRQ_MASK_DONE      1
    `define USB_IRQ_MASK_DONE_DEFAULT    0
    `define USB_IRQ_MASK_DONE_B          1
    `define USB_IRQ_MASK_DONE_T          1
    `define USB_IRQ_MASK_DONE_W          1
    `define USB_IRQ_MASK_DONE_R          1:1

    `define USB_IRQ_MASK_SOF      0
    `define USB_IRQ_MASK_SOF_DEFAULT    0
    `define USB_IRQ_MASK_SOF_B          0
    `define USB_IRQ_MASK_SOF_T          0
    `define USB_IRQ_MASK_SOF_W          1
    `define USB_IRQ_MASK_SOF_R          0:0

`define USB_XFER_DATA    8'h14

    `define USB_XFER_DATA_TX_LEN_DEFAULT    0
    `define USB_XFER_DATA_TX_LEN_B          0
    `define USB_XFER_DATA_TX_LEN_T          15
    `define USB_XFER_DATA_TX_LEN_W          16
    `define USB_XFER_DATA_TX_LEN_R          15:0

`define USB_XFER_TOKEN    8'h18

    `define USB_XFER_TOKEN_START      31
    `define USB_XFER_TOKEN_START_DEFAULT    0
    `define USB_XFER_TOKEN_START_B          31
    `define USB_XFER_TOKEN_START_T          31
    `define USB_XFER_TOKEN_START_W          1
    `define USB_XFER_TOKEN_START_R          31:31

    `define USB_XFER_TOKEN_IN      30
    `define USB_XFER_TOKEN_IN_DEFAULT    0
    `define USB_XFER_TOKEN_IN_B          30
    `define USB_XFER_TOKEN_IN_T          30
    `define USB_XFER_TOKEN_IN_W          1
    `define USB_XFER_TOKEN_IN_R          30:30

    `define USB_XFER_TOKEN_ACK      29
    `define USB_XFER_TOKEN_ACK_DEFAULT    0
    `define USB_XFER_TOKEN_ACK_B          29
    `define USB_XFER_TOKEN_ACK_T          29
    `define USB_XFER_TOKEN_ACK_W          1
    `define USB_XFER_TOKEN_ACK_R          29:29

    `define USB_XFER_TOKEN_PID_DATAX      28
    `define USB_XFER_TOKEN_PID_DATAX_DEFAULT    0
    `define USB_XFER_TOKEN_PID_DATAX_B          28
    `define USB_XFER_TOKEN_PID_DATAX_T          28
    `define USB_XFER_TOKEN_PID_DATAX_W          1
    `define USB_XFER_TOKEN_PID_DATAX_R          28:28

    `define USB_XFER_TOKEN_PID_BITS_DEFAULT    0
    `define USB_XFER_TOKEN_PID_BITS_B          16
    `define USB_XFER_TOKEN_PID_BITS_T          23
    `define USB_XFER_TOKEN_PID_BITS_W          8
    `define USB_XFER_TOKEN_PID_BITS_R          23:16

    `define USB_XFER_TOKEN_DEV_ADDR_DEFAULT    0
    `define USB_XFER_TOKEN_DEV_ADDR_B          9
    `define USB_XFER_TOKEN_DEV_ADDR_T          15
    `define USB_XFER_TOKEN_DEV_ADDR_W          7
    `define USB_XFER_TOKEN_DEV_ADDR_R          15:9

    `define USB_XFER_TOKEN_EP_ADDR_DEFAULT    0
    `define USB_XFER_TOKEN_EP_ADDR_B          5
    `define USB_XFER_TOKEN_EP_ADDR_T          8
    `define USB_XFER_TOKEN_EP_ADDR_W          4
    `define USB_XFER_TOKEN_EP_ADDR_R          8:5

`define USB_RX_STAT    8'h1c

    `define USB_RX_STAT_START_PEND      31
    `define USB_RX_STAT_START_PEND_DEFAULT    0
    `define USB_RX_STAT_START_PEND_B          31
    `define USB_RX_STAT_START_PEND_T          31
    `define USB_RX_STAT_START_PEND_W          1
    `define USB_RX_STAT_START_PEND_R          31:31

    `define USB_RX_STAT_CRC_ERR      30
    `define USB_RX_STAT_CRC_ERR_DEFAULT    0
    `define USB_RX_STAT_CRC_ERR_B          30
    `define USB_RX_STAT_CRC_ERR_T          30
    `define USB_RX_STAT_CRC_ERR_W          1
    `define USB_RX_STAT_CRC_ERR_R          30:30

    `define USB_RX_STAT_RESP_TIMEOUT      29
    `define USB_RX_STAT_RESP_TIMEOUT_DEFAULT    0
    `define USB_RX_STAT_RESP_TIMEOUT_B          29
    `define USB_RX_STAT_RESP_TIMEOUT_T          29
    `define USB_RX_STAT_RESP_TIMEOUT_W          1
    `define USB_RX_STAT_RESP_TIMEOUT_R          29:29

    `define USB_RX_STAT_IDLE      28
    `define USB_RX_STAT_IDLE_DEFAULT    0
    `define USB_RX_STAT_IDLE_B          28
    `define USB_RX_STAT_IDLE_T          28
    `define USB_RX_STAT_IDLE_W          1
    `define USB_RX_STAT_IDLE_R          28:28

    `define USB_RX_STAT_RESP_BITS_DEFAULT    0
    `define USB_RX_STAT_RESP_BITS_B          16
    `define USB_RX_STAT_RESP_BITS_T          23
    `define USB_RX_STAT_RESP_BITS_W          8
    `define USB_RX_STAT_RESP_BITS_R          23:16

    `define USB_RX_STAT_COUNT_BITS_DEFAULT    0
    `define USB_RX_STAT_COUNT_BITS_B          0
    `define USB_RX_STAT_COUNT_BITS_T          15
    `define USB_RX_STAT_COUNT_BITS_W          16
    `define USB_RX_STAT_COUNT_BITS_R          15:0

`define USB_WR_DATA    8'h20

    `define USB_WR_DATA_DATA_DEFAULT    0
    `define USB_WR_DATA_DATA_B          0
    `define USB_WR_DATA_DATA_T          7
    `define USB_WR_DATA_DATA_W          8
    `define USB_WR_DATA_DATA_R          7:0

`define USB_RD_DATA    8'h20

    `define USB_RD_DATA_DATA_DEFAULT    0
    `define USB_RD_DATA_DATA_B          0
    `define USB_RD_DATA_DATA_T          7
    `define USB_RD_DATA_DATA_W          8
    `define USB_RD_DATA_DATA_R          7:0

