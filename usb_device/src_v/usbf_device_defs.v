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

`define USB_FUNC_CTRL    8'h0

    `define USB_FUNC_CTRL_HS_CHIRP_EN      8
    `define USB_FUNC_CTRL_HS_CHIRP_EN_DEFAULT    0
    `define USB_FUNC_CTRL_HS_CHIRP_EN_B          8
    `define USB_FUNC_CTRL_HS_CHIRP_EN_T          8
    `define USB_FUNC_CTRL_HS_CHIRP_EN_W          1
    `define USB_FUNC_CTRL_HS_CHIRP_EN_R          8:8

    `define USB_FUNC_CTRL_PHY_DMPULLDOWN      7
    `define USB_FUNC_CTRL_PHY_DMPULLDOWN_DEFAULT    0
    `define USB_FUNC_CTRL_PHY_DMPULLDOWN_B          7
    `define USB_FUNC_CTRL_PHY_DMPULLDOWN_T          7
    `define USB_FUNC_CTRL_PHY_DMPULLDOWN_W          1
    `define USB_FUNC_CTRL_PHY_DMPULLDOWN_R          7:7

    `define USB_FUNC_CTRL_PHY_DPPULLDOWN      6
    `define USB_FUNC_CTRL_PHY_DPPULLDOWN_DEFAULT    0
    `define USB_FUNC_CTRL_PHY_DPPULLDOWN_B          6
    `define USB_FUNC_CTRL_PHY_DPPULLDOWN_T          6
    `define USB_FUNC_CTRL_PHY_DPPULLDOWN_W          1
    `define USB_FUNC_CTRL_PHY_DPPULLDOWN_R          6:6

    `define USB_FUNC_CTRL_PHY_TERMSELECT      5
    `define USB_FUNC_CTRL_PHY_TERMSELECT_DEFAULT    0
    `define USB_FUNC_CTRL_PHY_TERMSELECT_B          5
    `define USB_FUNC_CTRL_PHY_TERMSELECT_T          5
    `define USB_FUNC_CTRL_PHY_TERMSELECT_W          1
    `define USB_FUNC_CTRL_PHY_TERMSELECT_R          5:5

    `define USB_FUNC_CTRL_PHY_XCVRSELECT_DEFAULT    0
    `define USB_FUNC_CTRL_PHY_XCVRSELECT_B          3
    `define USB_FUNC_CTRL_PHY_XCVRSELECT_T          4
    `define USB_FUNC_CTRL_PHY_XCVRSELECT_W          2
    `define USB_FUNC_CTRL_PHY_XCVRSELECT_R          4:3

    `define USB_FUNC_CTRL_PHY_OPMODE_DEFAULT    0
    `define USB_FUNC_CTRL_PHY_OPMODE_B          1
    `define USB_FUNC_CTRL_PHY_OPMODE_T          2
    `define USB_FUNC_CTRL_PHY_OPMODE_W          2
    `define USB_FUNC_CTRL_PHY_OPMODE_R          2:1

    `define USB_FUNC_CTRL_INT_EN_SOF      0
    `define USB_FUNC_CTRL_INT_EN_SOF_DEFAULT    0
    `define USB_FUNC_CTRL_INT_EN_SOF_B          0
    `define USB_FUNC_CTRL_INT_EN_SOF_T          0
    `define USB_FUNC_CTRL_INT_EN_SOF_W          1
    `define USB_FUNC_CTRL_INT_EN_SOF_R          0:0

`define USB_FUNC_STAT    8'h4

    `define USB_FUNC_STAT_RST      13
    `define USB_FUNC_STAT_RST_DEFAULT    0
    `define USB_FUNC_STAT_RST_B          13
    `define USB_FUNC_STAT_RST_T          13
    `define USB_FUNC_STAT_RST_W          1
    `define USB_FUNC_STAT_RST_R          13:13

    `define USB_FUNC_STAT_LINESTATE_DEFAULT    0
    `define USB_FUNC_STAT_LINESTATE_B          11
    `define USB_FUNC_STAT_LINESTATE_T          12
    `define USB_FUNC_STAT_LINESTATE_W          2
    `define USB_FUNC_STAT_LINESTATE_R          12:11

    `define USB_FUNC_STAT_FRAME_DEFAULT    0
    `define USB_FUNC_STAT_FRAME_B          0
    `define USB_FUNC_STAT_FRAME_T          10
    `define USB_FUNC_STAT_FRAME_W          11
    `define USB_FUNC_STAT_FRAME_R          10:0

`define USB_FUNC_ADDR    8'h8

    `define USB_FUNC_ADDR_DEV_ADDR_DEFAULT    0
    `define USB_FUNC_ADDR_DEV_ADDR_B          0
    `define USB_FUNC_ADDR_DEV_ADDR_T          6
    `define USB_FUNC_ADDR_DEV_ADDR_W          7
    `define USB_FUNC_ADDR_DEV_ADDR_R          6:0

`define USB_EP0_CFG    8'hc

    `define USB_EP0_CFG_INT_RX      3
    `define USB_EP0_CFG_INT_RX_DEFAULT    0
    `define USB_EP0_CFG_INT_RX_B          3
    `define USB_EP0_CFG_INT_RX_T          3
    `define USB_EP0_CFG_INT_RX_W          1
    `define USB_EP0_CFG_INT_RX_R          3:3

    `define USB_EP0_CFG_INT_TX      2
    `define USB_EP0_CFG_INT_TX_DEFAULT    0
    `define USB_EP0_CFG_INT_TX_B          2
    `define USB_EP0_CFG_INT_TX_T          2
    `define USB_EP0_CFG_INT_TX_W          1
    `define USB_EP0_CFG_INT_TX_R          2:2

    `define USB_EP0_CFG_STALL_EP      1
    `define USB_EP0_CFG_STALL_EP_DEFAULT    0
    `define USB_EP0_CFG_STALL_EP_B          1
    `define USB_EP0_CFG_STALL_EP_T          1
    `define USB_EP0_CFG_STALL_EP_W          1
    `define USB_EP0_CFG_STALL_EP_R          1:1

    `define USB_EP0_CFG_ISO      0
    `define USB_EP0_CFG_ISO_DEFAULT    0
    `define USB_EP0_CFG_ISO_B          0
    `define USB_EP0_CFG_ISO_T          0
    `define USB_EP0_CFG_ISO_W          1
    `define USB_EP0_CFG_ISO_R          0:0

`define USB_EP0_TX_CTRL    8'h10

    `define USB_EP0_TX_CTRL_TX_FLUSH      17
    `define USB_EP0_TX_CTRL_TX_FLUSH_DEFAULT    0
    `define USB_EP0_TX_CTRL_TX_FLUSH_B          17
    `define USB_EP0_TX_CTRL_TX_FLUSH_T          17
    `define USB_EP0_TX_CTRL_TX_FLUSH_W          1
    `define USB_EP0_TX_CTRL_TX_FLUSH_R          17:17

    `define USB_EP0_TX_CTRL_TX_START      16
    `define USB_EP0_TX_CTRL_TX_START_DEFAULT    0
    `define USB_EP0_TX_CTRL_TX_START_B          16
    `define USB_EP0_TX_CTRL_TX_START_T          16
    `define USB_EP0_TX_CTRL_TX_START_W          1
    `define USB_EP0_TX_CTRL_TX_START_R          16:16

    `define USB_EP0_TX_CTRL_TX_LEN_DEFAULT    0
    `define USB_EP0_TX_CTRL_TX_LEN_B          0
    `define USB_EP0_TX_CTRL_TX_LEN_T          10
    `define USB_EP0_TX_CTRL_TX_LEN_W          11
    `define USB_EP0_TX_CTRL_TX_LEN_R          10:0

`define USB_EP0_RX_CTRL    8'h14

    `define USB_EP0_RX_CTRL_RX_FLUSH      1
    `define USB_EP0_RX_CTRL_RX_FLUSH_DEFAULT    0
    `define USB_EP0_RX_CTRL_RX_FLUSH_B          1
    `define USB_EP0_RX_CTRL_RX_FLUSH_T          1
    `define USB_EP0_RX_CTRL_RX_FLUSH_W          1
    `define USB_EP0_RX_CTRL_RX_FLUSH_R          1:1

    `define USB_EP0_RX_CTRL_RX_ACCEPT      0
    `define USB_EP0_RX_CTRL_RX_ACCEPT_DEFAULT    0
    `define USB_EP0_RX_CTRL_RX_ACCEPT_B          0
    `define USB_EP0_RX_CTRL_RX_ACCEPT_T          0
    `define USB_EP0_RX_CTRL_RX_ACCEPT_W          1
    `define USB_EP0_RX_CTRL_RX_ACCEPT_R          0:0

`define USB_EP0_STS    8'h18

    `define USB_EP0_STS_TX_ERR      20
    `define USB_EP0_STS_TX_ERR_DEFAULT    0
    `define USB_EP0_STS_TX_ERR_B          20
    `define USB_EP0_STS_TX_ERR_T          20
    `define USB_EP0_STS_TX_ERR_W          1
    `define USB_EP0_STS_TX_ERR_R          20:20

    `define USB_EP0_STS_TX_BUSY      19
    `define USB_EP0_STS_TX_BUSY_DEFAULT    0
    `define USB_EP0_STS_TX_BUSY_B          19
    `define USB_EP0_STS_TX_BUSY_T          19
    `define USB_EP0_STS_TX_BUSY_W          1
    `define USB_EP0_STS_TX_BUSY_R          19:19

    `define USB_EP0_STS_RX_ERR      18
    `define USB_EP0_STS_RX_ERR_DEFAULT    0
    `define USB_EP0_STS_RX_ERR_B          18
    `define USB_EP0_STS_RX_ERR_T          18
    `define USB_EP0_STS_RX_ERR_W          1
    `define USB_EP0_STS_RX_ERR_R          18:18

    `define USB_EP0_STS_RX_SETUP      17
    `define USB_EP0_STS_RX_SETUP_DEFAULT    0
    `define USB_EP0_STS_RX_SETUP_B          17
    `define USB_EP0_STS_RX_SETUP_T          17
    `define USB_EP0_STS_RX_SETUP_W          1
    `define USB_EP0_STS_RX_SETUP_R          17:17

    `define USB_EP0_STS_RX_READY      16
    `define USB_EP0_STS_RX_READY_DEFAULT    0
    `define USB_EP0_STS_RX_READY_B          16
    `define USB_EP0_STS_RX_READY_T          16
    `define USB_EP0_STS_RX_READY_W          1
    `define USB_EP0_STS_RX_READY_R          16:16

    `define USB_EP0_STS_RX_COUNT_DEFAULT    0
    `define USB_EP0_STS_RX_COUNT_B          0
    `define USB_EP0_STS_RX_COUNT_T          10
    `define USB_EP0_STS_RX_COUNT_W          11
    `define USB_EP0_STS_RX_COUNT_R          10:0

`define USB_EP0_DATA    8'h1c

    `define USB_EP0_DATA_DATA_DEFAULT    0
    `define USB_EP0_DATA_DATA_B          0
    `define USB_EP0_DATA_DATA_T          7
    `define USB_EP0_DATA_DATA_W          8
    `define USB_EP0_DATA_DATA_R          7:0

`define USB_EP1_CFG    8'h20

    `define USB_EP1_CFG_INT_RX      3
    `define USB_EP1_CFG_INT_RX_DEFAULT    0
    `define USB_EP1_CFG_INT_RX_B          3
    `define USB_EP1_CFG_INT_RX_T          3
    `define USB_EP1_CFG_INT_RX_W          1
    `define USB_EP1_CFG_INT_RX_R          3:3

    `define USB_EP1_CFG_INT_TX      2
    `define USB_EP1_CFG_INT_TX_DEFAULT    0
    `define USB_EP1_CFG_INT_TX_B          2
    `define USB_EP1_CFG_INT_TX_T          2
    `define USB_EP1_CFG_INT_TX_W          1
    `define USB_EP1_CFG_INT_TX_R          2:2

    `define USB_EP1_CFG_STALL_EP      1
    `define USB_EP1_CFG_STALL_EP_DEFAULT    0
    `define USB_EP1_CFG_STALL_EP_B          1
    `define USB_EP1_CFG_STALL_EP_T          1
    `define USB_EP1_CFG_STALL_EP_W          1
    `define USB_EP1_CFG_STALL_EP_R          1:1

    `define USB_EP1_CFG_ISO      0
    `define USB_EP1_CFG_ISO_DEFAULT    0
    `define USB_EP1_CFG_ISO_B          0
    `define USB_EP1_CFG_ISO_T          0
    `define USB_EP1_CFG_ISO_W          1
    `define USB_EP1_CFG_ISO_R          0:0

`define USB_EP1_TX_CTRL    8'h24

    `define USB_EP1_TX_CTRL_TX_FLUSH      17
    `define USB_EP1_TX_CTRL_TX_FLUSH_DEFAULT    0
    `define USB_EP1_TX_CTRL_TX_FLUSH_B          17
    `define USB_EP1_TX_CTRL_TX_FLUSH_T          17
    `define USB_EP1_TX_CTRL_TX_FLUSH_W          1
    `define USB_EP1_TX_CTRL_TX_FLUSH_R          17:17

    `define USB_EP1_TX_CTRL_TX_START      16
    `define USB_EP1_TX_CTRL_TX_START_DEFAULT    0
    `define USB_EP1_TX_CTRL_TX_START_B          16
    `define USB_EP1_TX_CTRL_TX_START_T          16
    `define USB_EP1_TX_CTRL_TX_START_W          1
    `define USB_EP1_TX_CTRL_TX_START_R          16:16

    `define USB_EP1_TX_CTRL_TX_LEN_DEFAULT    0
    `define USB_EP1_TX_CTRL_TX_LEN_B          0
    `define USB_EP1_TX_CTRL_TX_LEN_T          10
    `define USB_EP1_TX_CTRL_TX_LEN_W          11
    `define USB_EP1_TX_CTRL_TX_LEN_R          10:0

`define USB_EP1_RX_CTRL    8'h28

    `define USB_EP1_RX_CTRL_RX_FLUSH      1
    `define USB_EP1_RX_CTRL_RX_FLUSH_DEFAULT    0
    `define USB_EP1_RX_CTRL_RX_FLUSH_B          1
    `define USB_EP1_RX_CTRL_RX_FLUSH_T          1
    `define USB_EP1_RX_CTRL_RX_FLUSH_W          1
    `define USB_EP1_RX_CTRL_RX_FLUSH_R          1:1

    `define USB_EP1_RX_CTRL_RX_ACCEPT      0
    `define USB_EP1_RX_CTRL_RX_ACCEPT_DEFAULT    0
    `define USB_EP1_RX_CTRL_RX_ACCEPT_B          0
    `define USB_EP1_RX_CTRL_RX_ACCEPT_T          0
    `define USB_EP1_RX_CTRL_RX_ACCEPT_W          1
    `define USB_EP1_RX_CTRL_RX_ACCEPT_R          0:0

`define USB_EP1_STS    8'h2c

    `define USB_EP1_STS_TX_ERR      20
    `define USB_EP1_STS_TX_ERR_DEFAULT    0
    `define USB_EP1_STS_TX_ERR_B          20
    `define USB_EP1_STS_TX_ERR_T          20
    `define USB_EP1_STS_TX_ERR_W          1
    `define USB_EP1_STS_TX_ERR_R          20:20

    `define USB_EP1_STS_TX_BUSY      19
    `define USB_EP1_STS_TX_BUSY_DEFAULT    0
    `define USB_EP1_STS_TX_BUSY_B          19
    `define USB_EP1_STS_TX_BUSY_T          19
    `define USB_EP1_STS_TX_BUSY_W          1
    `define USB_EP1_STS_TX_BUSY_R          19:19

    `define USB_EP1_STS_RX_ERR      18
    `define USB_EP1_STS_RX_ERR_DEFAULT    0
    `define USB_EP1_STS_RX_ERR_B          18
    `define USB_EP1_STS_RX_ERR_T          18
    `define USB_EP1_STS_RX_ERR_W          1
    `define USB_EP1_STS_RX_ERR_R          18:18

    `define USB_EP1_STS_RX_SETUP      17
    `define USB_EP1_STS_RX_SETUP_DEFAULT    0
    `define USB_EP1_STS_RX_SETUP_B          17
    `define USB_EP1_STS_RX_SETUP_T          17
    `define USB_EP1_STS_RX_SETUP_W          1
    `define USB_EP1_STS_RX_SETUP_R          17:17

    `define USB_EP1_STS_RX_READY      16
    `define USB_EP1_STS_RX_READY_DEFAULT    0
    `define USB_EP1_STS_RX_READY_B          16
    `define USB_EP1_STS_RX_READY_T          16
    `define USB_EP1_STS_RX_READY_W          1
    `define USB_EP1_STS_RX_READY_R          16:16

    `define USB_EP1_STS_RX_COUNT_DEFAULT    0
    `define USB_EP1_STS_RX_COUNT_B          0
    `define USB_EP1_STS_RX_COUNT_T          10
    `define USB_EP1_STS_RX_COUNT_W          11
    `define USB_EP1_STS_RX_COUNT_R          10:0

`define USB_EP1_DATA    8'h30

    `define USB_EP1_DATA_DATA_DEFAULT    0
    `define USB_EP1_DATA_DATA_B          0
    `define USB_EP1_DATA_DATA_T          7
    `define USB_EP1_DATA_DATA_W          8
    `define USB_EP1_DATA_DATA_R          7:0

`define USB_EP2_CFG    8'h34

    `define USB_EP2_CFG_INT_RX      3
    `define USB_EP2_CFG_INT_RX_DEFAULT    0
    `define USB_EP2_CFG_INT_RX_B          3
    `define USB_EP2_CFG_INT_RX_T          3
    `define USB_EP2_CFG_INT_RX_W          1
    `define USB_EP2_CFG_INT_RX_R          3:3

    `define USB_EP2_CFG_INT_TX      2
    `define USB_EP2_CFG_INT_TX_DEFAULT    0
    `define USB_EP2_CFG_INT_TX_B          2
    `define USB_EP2_CFG_INT_TX_T          2
    `define USB_EP2_CFG_INT_TX_W          1
    `define USB_EP2_CFG_INT_TX_R          2:2

    `define USB_EP2_CFG_STALL_EP      1
    `define USB_EP2_CFG_STALL_EP_DEFAULT    0
    `define USB_EP2_CFG_STALL_EP_B          1
    `define USB_EP2_CFG_STALL_EP_T          1
    `define USB_EP2_CFG_STALL_EP_W          1
    `define USB_EP2_CFG_STALL_EP_R          1:1

    `define USB_EP2_CFG_ISO      0
    `define USB_EP2_CFG_ISO_DEFAULT    0
    `define USB_EP2_CFG_ISO_B          0
    `define USB_EP2_CFG_ISO_T          0
    `define USB_EP2_CFG_ISO_W          1
    `define USB_EP2_CFG_ISO_R          0:0

`define USB_EP2_TX_CTRL    8'h38

    `define USB_EP2_TX_CTRL_TX_FLUSH      17
    `define USB_EP2_TX_CTRL_TX_FLUSH_DEFAULT    0
    `define USB_EP2_TX_CTRL_TX_FLUSH_B          17
    `define USB_EP2_TX_CTRL_TX_FLUSH_T          17
    `define USB_EP2_TX_CTRL_TX_FLUSH_W          1
    `define USB_EP2_TX_CTRL_TX_FLUSH_R          17:17

    `define USB_EP2_TX_CTRL_TX_START      16
    `define USB_EP2_TX_CTRL_TX_START_DEFAULT    0
    `define USB_EP2_TX_CTRL_TX_START_B          16
    `define USB_EP2_TX_CTRL_TX_START_T          16
    `define USB_EP2_TX_CTRL_TX_START_W          1
    `define USB_EP2_TX_CTRL_TX_START_R          16:16

    `define USB_EP2_TX_CTRL_TX_LEN_DEFAULT    0
    `define USB_EP2_TX_CTRL_TX_LEN_B          0
    `define USB_EP2_TX_CTRL_TX_LEN_T          10
    `define USB_EP2_TX_CTRL_TX_LEN_W          11
    `define USB_EP2_TX_CTRL_TX_LEN_R          10:0

`define USB_EP2_RX_CTRL    8'h3c

    `define USB_EP2_RX_CTRL_RX_FLUSH      1
    `define USB_EP2_RX_CTRL_RX_FLUSH_DEFAULT    0
    `define USB_EP2_RX_CTRL_RX_FLUSH_B          1
    `define USB_EP2_RX_CTRL_RX_FLUSH_T          1
    `define USB_EP2_RX_CTRL_RX_FLUSH_W          1
    `define USB_EP2_RX_CTRL_RX_FLUSH_R          1:1

    `define USB_EP2_RX_CTRL_RX_ACCEPT      0
    `define USB_EP2_RX_CTRL_RX_ACCEPT_DEFAULT    0
    `define USB_EP2_RX_CTRL_RX_ACCEPT_B          0
    `define USB_EP2_RX_CTRL_RX_ACCEPT_T          0
    `define USB_EP2_RX_CTRL_RX_ACCEPT_W          1
    `define USB_EP2_RX_CTRL_RX_ACCEPT_R          0:0

`define USB_EP2_STS    8'h40

    `define USB_EP2_STS_TX_ERR      20
    `define USB_EP2_STS_TX_ERR_DEFAULT    0
    `define USB_EP2_STS_TX_ERR_B          20
    `define USB_EP2_STS_TX_ERR_T          20
    `define USB_EP2_STS_TX_ERR_W          1
    `define USB_EP2_STS_TX_ERR_R          20:20

    `define USB_EP2_STS_TX_BUSY      19
    `define USB_EP2_STS_TX_BUSY_DEFAULT    0
    `define USB_EP2_STS_TX_BUSY_B          19
    `define USB_EP2_STS_TX_BUSY_T          19
    `define USB_EP2_STS_TX_BUSY_W          1
    `define USB_EP2_STS_TX_BUSY_R          19:19

    `define USB_EP2_STS_RX_ERR      18
    `define USB_EP2_STS_RX_ERR_DEFAULT    0
    `define USB_EP2_STS_RX_ERR_B          18
    `define USB_EP2_STS_RX_ERR_T          18
    `define USB_EP2_STS_RX_ERR_W          1
    `define USB_EP2_STS_RX_ERR_R          18:18

    `define USB_EP2_STS_RX_SETUP      17
    `define USB_EP2_STS_RX_SETUP_DEFAULT    0
    `define USB_EP2_STS_RX_SETUP_B          17
    `define USB_EP2_STS_RX_SETUP_T          17
    `define USB_EP2_STS_RX_SETUP_W          1
    `define USB_EP2_STS_RX_SETUP_R          17:17

    `define USB_EP2_STS_RX_READY      16
    `define USB_EP2_STS_RX_READY_DEFAULT    0
    `define USB_EP2_STS_RX_READY_B          16
    `define USB_EP2_STS_RX_READY_T          16
    `define USB_EP2_STS_RX_READY_W          1
    `define USB_EP2_STS_RX_READY_R          16:16

    `define USB_EP2_STS_RX_COUNT_DEFAULT    0
    `define USB_EP2_STS_RX_COUNT_B          0
    `define USB_EP2_STS_RX_COUNT_T          10
    `define USB_EP2_STS_RX_COUNT_W          11
    `define USB_EP2_STS_RX_COUNT_R          10:0

`define USB_EP2_DATA    8'h44

    `define USB_EP2_DATA_DATA_DEFAULT    0
    `define USB_EP2_DATA_DATA_B          0
    `define USB_EP2_DATA_DATA_T          7
    `define USB_EP2_DATA_DATA_W          8
    `define USB_EP2_DATA_DATA_R          7:0

`define USB_EP3_CFG    8'h48

    `define USB_EP3_CFG_INT_RX      3
    `define USB_EP3_CFG_INT_RX_DEFAULT    0
    `define USB_EP3_CFG_INT_RX_B          3
    `define USB_EP3_CFG_INT_RX_T          3
    `define USB_EP3_CFG_INT_RX_W          1
    `define USB_EP3_CFG_INT_RX_R          3:3

    `define USB_EP3_CFG_INT_TX      2
    `define USB_EP3_CFG_INT_TX_DEFAULT    0
    `define USB_EP3_CFG_INT_TX_B          2
    `define USB_EP3_CFG_INT_TX_T          2
    `define USB_EP3_CFG_INT_TX_W          1
    `define USB_EP3_CFG_INT_TX_R          2:2

    `define USB_EP3_CFG_STALL_EP      1
    `define USB_EP3_CFG_STALL_EP_DEFAULT    0
    `define USB_EP3_CFG_STALL_EP_B          1
    `define USB_EP3_CFG_STALL_EP_T          1
    `define USB_EP3_CFG_STALL_EP_W          1
    `define USB_EP3_CFG_STALL_EP_R          1:1

    `define USB_EP3_CFG_ISO      0
    `define USB_EP3_CFG_ISO_DEFAULT    0
    `define USB_EP3_CFG_ISO_B          0
    `define USB_EP3_CFG_ISO_T          0
    `define USB_EP3_CFG_ISO_W          1
    `define USB_EP3_CFG_ISO_R          0:0

`define USB_EP3_TX_CTRL    8'h4c

    `define USB_EP3_TX_CTRL_TX_FLUSH      17
    `define USB_EP3_TX_CTRL_TX_FLUSH_DEFAULT    0
    `define USB_EP3_TX_CTRL_TX_FLUSH_B          17
    `define USB_EP3_TX_CTRL_TX_FLUSH_T          17
    `define USB_EP3_TX_CTRL_TX_FLUSH_W          1
    `define USB_EP3_TX_CTRL_TX_FLUSH_R          17:17

    `define USB_EP3_TX_CTRL_TX_START      16
    `define USB_EP3_TX_CTRL_TX_START_DEFAULT    0
    `define USB_EP3_TX_CTRL_TX_START_B          16
    `define USB_EP3_TX_CTRL_TX_START_T          16
    `define USB_EP3_TX_CTRL_TX_START_W          1
    `define USB_EP3_TX_CTRL_TX_START_R          16:16

    `define USB_EP3_TX_CTRL_TX_LEN_DEFAULT    0
    `define USB_EP3_TX_CTRL_TX_LEN_B          0
    `define USB_EP3_TX_CTRL_TX_LEN_T          10
    `define USB_EP3_TX_CTRL_TX_LEN_W          11
    `define USB_EP3_TX_CTRL_TX_LEN_R          10:0

`define USB_EP3_RX_CTRL    8'h50

    `define USB_EP3_RX_CTRL_RX_FLUSH      1
    `define USB_EP3_RX_CTRL_RX_FLUSH_DEFAULT    0
    `define USB_EP3_RX_CTRL_RX_FLUSH_B          1
    `define USB_EP3_RX_CTRL_RX_FLUSH_T          1
    `define USB_EP3_RX_CTRL_RX_FLUSH_W          1
    `define USB_EP3_RX_CTRL_RX_FLUSH_R          1:1

    `define USB_EP3_RX_CTRL_RX_ACCEPT      0
    `define USB_EP3_RX_CTRL_RX_ACCEPT_DEFAULT    0
    `define USB_EP3_RX_CTRL_RX_ACCEPT_B          0
    `define USB_EP3_RX_CTRL_RX_ACCEPT_T          0
    `define USB_EP3_RX_CTRL_RX_ACCEPT_W          1
    `define USB_EP3_RX_CTRL_RX_ACCEPT_R          0:0

`define USB_EP3_STS    8'h54

    `define USB_EP3_STS_TX_ERR      20
    `define USB_EP3_STS_TX_ERR_DEFAULT    0
    `define USB_EP3_STS_TX_ERR_B          20
    `define USB_EP3_STS_TX_ERR_T          20
    `define USB_EP3_STS_TX_ERR_W          1
    `define USB_EP3_STS_TX_ERR_R          20:20

    `define USB_EP3_STS_TX_BUSY      19
    `define USB_EP3_STS_TX_BUSY_DEFAULT    0
    `define USB_EP3_STS_TX_BUSY_B          19
    `define USB_EP3_STS_TX_BUSY_T          19
    `define USB_EP3_STS_TX_BUSY_W          1
    `define USB_EP3_STS_TX_BUSY_R          19:19

    `define USB_EP3_STS_RX_ERR      18
    `define USB_EP3_STS_RX_ERR_DEFAULT    0
    `define USB_EP3_STS_RX_ERR_B          18
    `define USB_EP3_STS_RX_ERR_T          18
    `define USB_EP3_STS_RX_ERR_W          1
    `define USB_EP3_STS_RX_ERR_R          18:18

    `define USB_EP3_STS_RX_SETUP      17
    `define USB_EP3_STS_RX_SETUP_DEFAULT    0
    `define USB_EP3_STS_RX_SETUP_B          17
    `define USB_EP3_STS_RX_SETUP_T          17
    `define USB_EP3_STS_RX_SETUP_W          1
    `define USB_EP3_STS_RX_SETUP_R          17:17

    `define USB_EP3_STS_RX_READY      16
    `define USB_EP3_STS_RX_READY_DEFAULT    0
    `define USB_EP3_STS_RX_READY_B          16
    `define USB_EP3_STS_RX_READY_T          16
    `define USB_EP3_STS_RX_READY_W          1
    `define USB_EP3_STS_RX_READY_R          16:16

    `define USB_EP3_STS_RX_COUNT_DEFAULT    0
    `define USB_EP3_STS_RX_COUNT_B          0
    `define USB_EP3_STS_RX_COUNT_T          10
    `define USB_EP3_STS_RX_COUNT_W          11
    `define USB_EP3_STS_RX_COUNT_R          10:0

`define USB_EP3_DATA    8'h58

    `define USB_EP3_DATA_DATA_DEFAULT    0
    `define USB_EP3_DATA_DATA_B          0
    `define USB_EP3_DATA_DATA_T          7
    `define USB_EP3_DATA_DATA_W          8
    `define USB_EP3_DATA_DATA_R          7:0

