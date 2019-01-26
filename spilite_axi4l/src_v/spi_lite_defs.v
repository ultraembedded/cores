//-----------------------------------------------------------------
//                   SPI-Lite SPI Master Interface
//                              V1.0
//                        Ultra-Embedded.com
//                        Copyright 2017-2019
//
//                 Email: admin@ultra-embedded.com
//
//                       License: LGPL
//-----------------------------------------------------------------
//
// This source file may be used and distributed without         
// restriction provided that this copyright statement is not    
// removed from the file and that any derivative work contains  
// the original copyright notice and the associated disclaimer. 
//
// This source file is free software; you can redistribute it   
// and/or modify it under the terms of the GNU Lesser General   
// Public License as published by the Free Software Foundation; 
// either version 2.1 of the License, or (at your option) any   
// later version.
//
// This source is distributed in the hope that it will be       
// useful, but WITHOUT ANY WARRANTY; without even the implied   
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
// PURPOSE.  See the GNU Lesser General Public License for more 
// details.
//
// You should have received a copy of the GNU Lesser General    
// Public License along with this source; if not, write to the 
// Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
// Boston, MA  02111-1307  USA
//-----------------------------------------------------------------

//-----------------------------------------------------------------
//                          Generated File
//-----------------------------------------------------------------

`define SPI_DGIER    8'h1c

    `define SPI_DGIER_GIE      31
    `define SPI_DGIER_GIE_DEFAULT    0
    `define SPI_DGIER_GIE_B          31
    `define SPI_DGIER_GIE_T          31
    `define SPI_DGIER_GIE_W          1
    `define SPI_DGIER_GIE_R          31:31

`define SPI_IPISR    8'h20

    `define SPI_IPISR_TX_EMPTY      2
    `define SPI_IPISR_TX_EMPTY_DEFAULT    0
    `define SPI_IPISR_TX_EMPTY_B          2
    `define SPI_IPISR_TX_EMPTY_T          2
    `define SPI_IPISR_TX_EMPTY_W          1
    `define SPI_IPISR_TX_EMPTY_R          2:2

`define SPI_IPIER    8'h28

    `define SPI_IPIER_TX_EMPTY      2
    `define SPI_IPIER_TX_EMPTY_DEFAULT    0
    `define SPI_IPIER_TX_EMPTY_B          2
    `define SPI_IPIER_TX_EMPTY_T          2
    `define SPI_IPIER_TX_EMPTY_W          1
    `define SPI_IPIER_TX_EMPTY_R          2:2

`define SPI_SRR    8'h40

    `define SPI_SRR_RESET_DEFAULT    0
    `define SPI_SRR_RESET_B          0
    `define SPI_SRR_RESET_T          31
    `define SPI_SRR_RESET_W          32
    `define SPI_SRR_RESET_R          31:0

`define SPI_CR    8'h60

    `define SPI_CR_LOOP      0
    `define SPI_CR_LOOP_DEFAULT    0
    `define SPI_CR_LOOP_B          0
    `define SPI_CR_LOOP_T          0
    `define SPI_CR_LOOP_W          1
    `define SPI_CR_LOOP_R          0:0

    `define SPI_CR_SPE      1
    `define SPI_CR_SPE_DEFAULT    0
    `define SPI_CR_SPE_B          1
    `define SPI_CR_SPE_T          1
    `define SPI_CR_SPE_W          1
    `define SPI_CR_SPE_R          1:1

    `define SPI_CR_MASTER      2
    `define SPI_CR_MASTER_DEFAULT    0
    `define SPI_CR_MASTER_B          2
    `define SPI_CR_MASTER_T          2
    `define SPI_CR_MASTER_W          1
    `define SPI_CR_MASTER_R          2:2

    `define SPI_CR_CPOL      3
    `define SPI_CR_CPOL_DEFAULT    0
    `define SPI_CR_CPOL_B          3
    `define SPI_CR_CPOL_T          3
    `define SPI_CR_CPOL_W          1
    `define SPI_CR_CPOL_R          3:3

    `define SPI_CR_CPHA      4
    `define SPI_CR_CPHA_DEFAULT    0
    `define SPI_CR_CPHA_B          4
    `define SPI_CR_CPHA_T          4
    `define SPI_CR_CPHA_W          1
    `define SPI_CR_CPHA_R          4:4

    `define SPI_CR_TXFIFO_RST      5
    `define SPI_CR_TXFIFO_RST_DEFAULT    0
    `define SPI_CR_TXFIFO_RST_B          5
    `define SPI_CR_TXFIFO_RST_T          5
    `define SPI_CR_TXFIFO_RST_W          1
    `define SPI_CR_TXFIFO_RST_R          5:5

    `define SPI_CR_RXFIFO_RST      6
    `define SPI_CR_RXFIFO_RST_DEFAULT    0
    `define SPI_CR_RXFIFO_RST_B          6
    `define SPI_CR_RXFIFO_RST_T          6
    `define SPI_CR_RXFIFO_RST_W          1
    `define SPI_CR_RXFIFO_RST_R          6:6

    `define SPI_CR_MANUAL_SS      7
    `define SPI_CR_MANUAL_SS_DEFAULT    0
    `define SPI_CR_MANUAL_SS_B          7
    `define SPI_CR_MANUAL_SS_T          7
    `define SPI_CR_MANUAL_SS_W          1
    `define SPI_CR_MANUAL_SS_R          7:7

    `define SPI_CR_TRANS_INHIBIT      8
    `define SPI_CR_TRANS_INHIBIT_DEFAULT    0
    `define SPI_CR_TRANS_INHIBIT_B          8
    `define SPI_CR_TRANS_INHIBIT_T          8
    `define SPI_CR_TRANS_INHIBIT_W          1
    `define SPI_CR_TRANS_INHIBIT_R          8:8

    `define SPI_CR_LSB_FIRST      9
    `define SPI_CR_LSB_FIRST_DEFAULT    0
    `define SPI_CR_LSB_FIRST_B          9
    `define SPI_CR_LSB_FIRST_T          9
    `define SPI_CR_LSB_FIRST_W          1
    `define SPI_CR_LSB_FIRST_R          9:9

`define SPI_SR    8'h64

    `define SPI_SR_RX_EMPTY      0
    `define SPI_SR_RX_EMPTY_DEFAULT    0
    `define SPI_SR_RX_EMPTY_B          0
    `define SPI_SR_RX_EMPTY_T          0
    `define SPI_SR_RX_EMPTY_W          1
    `define SPI_SR_RX_EMPTY_R          0:0

    `define SPI_SR_RX_FULL      1
    `define SPI_SR_RX_FULL_DEFAULT    0
    `define SPI_SR_RX_FULL_B          1
    `define SPI_SR_RX_FULL_T          1
    `define SPI_SR_RX_FULL_W          1
    `define SPI_SR_RX_FULL_R          1:1

    `define SPI_SR_TX_EMPTY      2
    `define SPI_SR_TX_EMPTY_DEFAULT    0
    `define SPI_SR_TX_EMPTY_B          2
    `define SPI_SR_TX_EMPTY_T          2
    `define SPI_SR_TX_EMPTY_W          1
    `define SPI_SR_TX_EMPTY_R          2:2

    `define SPI_SR_TX_FULL      3
    `define SPI_SR_TX_FULL_DEFAULT    0
    `define SPI_SR_TX_FULL_B          3
    `define SPI_SR_TX_FULL_T          3
    `define SPI_SR_TX_FULL_W          1
    `define SPI_SR_TX_FULL_R          3:3

`define SPI_DTR    8'h68

    `define SPI_DTR_DATA_DEFAULT    0
    `define SPI_DTR_DATA_B          0
    `define SPI_DTR_DATA_T          7
    `define SPI_DTR_DATA_W          8
    `define SPI_DTR_DATA_R          7:0

`define SPI_DRR    8'h6c

    `define SPI_DRR_DATA_DEFAULT    0
    `define SPI_DRR_DATA_B          0
    `define SPI_DRR_DATA_T          7
    `define SPI_DRR_DATA_W          8
    `define SPI_DRR_DATA_R          7:0

`define SPI_SSR    8'h70

    `define SPI_SSR_VALUE_DEFAULT    1
    `define SPI_SSR_VALUE_B          0
    `define SPI_SSR_VALUE_T          7
    `define SPI_SSR_VALUE_W          8
    `define SPI_SSR_VALUE_R          7:0

