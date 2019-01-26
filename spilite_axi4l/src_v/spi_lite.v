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

`include "spi_lite_defs.v"

//-----------------------------------------------------------------
// Module:  SPI-Lite Peripheral (Xilinx IP emulation)
//-----------------------------------------------------------------
module spi_lite
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
    ,input          spi_miso_i

    // Outputs
    ,output         cfg_awready_o
    ,output         cfg_wready_o
    ,output         cfg_bvalid_o
    ,output [1:0]   cfg_bresp_o
    ,output         cfg_arready_o
    ,output         cfg_rvalid_o
    ,output [31:0]  cfg_rdata_o
    ,output [1:0]   cfg_rresp_o
    ,output         spi_clk_o
    ,output         spi_mosi_o
    ,output [7:0]   spi_cs_o
    ,output         intr_o
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
// Register spi_dgier
//-----------------------------------------------------------------
reg spi_dgier_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    spi_dgier_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_DGIER))
    spi_dgier_wr_q <= 1'b1;
else
    spi_dgier_wr_q <= 1'b0;

// spi_dgier_gie [internal]
reg        spi_dgier_gie_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    spi_dgier_gie_q <= 1'd`SPI_DGIER_GIE_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_DGIER))
    spi_dgier_gie_q <= cfg_wdata_i[`SPI_DGIER_GIE_R];

wire        spi_dgier_gie_out_w = spi_dgier_gie_q;


//-----------------------------------------------------------------
// Register spi_ipisr
//-----------------------------------------------------------------
reg spi_ipisr_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    spi_ipisr_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_IPISR))
    spi_ipisr_wr_q <= 1'b1;
else
    spi_ipisr_wr_q <= 1'b0;

// spi_ipisr_tx_empty [external]
wire        spi_ipisr_tx_empty_out_w = wr_data_q[`SPI_IPISR_TX_EMPTY_R];


//-----------------------------------------------------------------
// Register spi_ipier
//-----------------------------------------------------------------
reg spi_ipier_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    spi_ipier_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_IPIER))
    spi_ipier_wr_q <= 1'b1;
else
    spi_ipier_wr_q <= 1'b0;

// spi_ipier_tx_empty [internal]
reg        spi_ipier_tx_empty_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    spi_ipier_tx_empty_q <= 1'd`SPI_IPIER_TX_EMPTY_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_IPIER))
    spi_ipier_tx_empty_q <= cfg_wdata_i[`SPI_IPIER_TX_EMPTY_R];

wire        spi_ipier_tx_empty_out_w = spi_ipier_tx_empty_q;


//-----------------------------------------------------------------
// Register spi_srr
//-----------------------------------------------------------------
reg spi_srr_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    spi_srr_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_SRR))
    spi_srr_wr_q <= 1'b1;
else
    spi_srr_wr_q <= 1'b0;

// spi_srr_reset [auto_clr]
reg [31:0]  spi_srr_reset_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    spi_srr_reset_q <= 32'd`SPI_SRR_RESET_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_SRR))
    spi_srr_reset_q <= cfg_wdata_i[`SPI_SRR_RESET_R];
else
    spi_srr_reset_q <= 32'd`SPI_SRR_RESET_DEFAULT;

wire [31:0]  spi_srr_reset_out_w = spi_srr_reset_q;


//-----------------------------------------------------------------
// Register spi_cr
//-----------------------------------------------------------------
reg spi_cr_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    spi_cr_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_CR))
    spi_cr_wr_q <= 1'b1;
else
    spi_cr_wr_q <= 1'b0;

// spi_cr_loop [internal]
reg        spi_cr_loop_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    spi_cr_loop_q <= 1'd`SPI_CR_LOOP_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_CR))
    spi_cr_loop_q <= cfg_wdata_i[`SPI_CR_LOOP_R];

wire        spi_cr_loop_out_w = spi_cr_loop_q;


// spi_cr_spe [internal]
reg        spi_cr_spe_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    spi_cr_spe_q <= 1'd`SPI_CR_SPE_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_CR))
    spi_cr_spe_q <= cfg_wdata_i[`SPI_CR_SPE_R];

wire        spi_cr_spe_out_w = spi_cr_spe_q;


// spi_cr_master [internal]
reg        spi_cr_master_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    spi_cr_master_q <= 1'd`SPI_CR_MASTER_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_CR))
    spi_cr_master_q <= cfg_wdata_i[`SPI_CR_MASTER_R];

wire        spi_cr_master_out_w = spi_cr_master_q;


// spi_cr_cpol [internal]
reg        spi_cr_cpol_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    spi_cr_cpol_q <= 1'd`SPI_CR_CPOL_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_CR))
    spi_cr_cpol_q <= cfg_wdata_i[`SPI_CR_CPOL_R];

wire        spi_cr_cpol_out_w = spi_cr_cpol_q;


// spi_cr_cpha [internal]
reg        spi_cr_cpha_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    spi_cr_cpha_q <= 1'd`SPI_CR_CPHA_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_CR))
    spi_cr_cpha_q <= cfg_wdata_i[`SPI_CR_CPHA_R];

wire        spi_cr_cpha_out_w = spi_cr_cpha_q;


// spi_cr_txfifo_rst [auto_clr]
reg        spi_cr_txfifo_rst_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    spi_cr_txfifo_rst_q <= 1'd`SPI_CR_TXFIFO_RST_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_CR))
    spi_cr_txfifo_rst_q <= cfg_wdata_i[`SPI_CR_TXFIFO_RST_R];
else
    spi_cr_txfifo_rst_q <= 1'd`SPI_CR_TXFIFO_RST_DEFAULT;

wire        spi_cr_txfifo_rst_out_w = spi_cr_txfifo_rst_q;


// spi_cr_rxfifo_rst [auto_clr]
reg        spi_cr_rxfifo_rst_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    spi_cr_rxfifo_rst_q <= 1'd`SPI_CR_RXFIFO_RST_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_CR))
    spi_cr_rxfifo_rst_q <= cfg_wdata_i[`SPI_CR_RXFIFO_RST_R];
else
    spi_cr_rxfifo_rst_q <= 1'd`SPI_CR_RXFIFO_RST_DEFAULT;

wire        spi_cr_rxfifo_rst_out_w = spi_cr_rxfifo_rst_q;


// spi_cr_manual_ss [internal]
reg        spi_cr_manual_ss_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    spi_cr_manual_ss_q <= 1'd`SPI_CR_MANUAL_SS_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_CR))
    spi_cr_manual_ss_q <= cfg_wdata_i[`SPI_CR_MANUAL_SS_R];

wire        spi_cr_manual_ss_out_w = spi_cr_manual_ss_q;


// spi_cr_trans_inhibit [internal]
reg        spi_cr_trans_inhibit_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    spi_cr_trans_inhibit_q <= 1'd`SPI_CR_TRANS_INHIBIT_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_CR))
    spi_cr_trans_inhibit_q <= cfg_wdata_i[`SPI_CR_TRANS_INHIBIT_R];

wire        spi_cr_trans_inhibit_out_w = spi_cr_trans_inhibit_q;


// spi_cr_lsb_first [internal]
reg        spi_cr_lsb_first_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    spi_cr_lsb_first_q <= 1'd`SPI_CR_LSB_FIRST_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_CR))
    spi_cr_lsb_first_q <= cfg_wdata_i[`SPI_CR_LSB_FIRST_R];

wire        spi_cr_lsb_first_out_w = spi_cr_lsb_first_q;


//-----------------------------------------------------------------
// Register spi_sr
//-----------------------------------------------------------------
reg spi_sr_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    spi_sr_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_SR))
    spi_sr_wr_q <= 1'b1;
else
    spi_sr_wr_q <= 1'b0;





//-----------------------------------------------------------------
// Register spi_dtr
//-----------------------------------------------------------------
reg spi_dtr_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    spi_dtr_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_DTR))
    spi_dtr_wr_q <= 1'b1;
else
    spi_dtr_wr_q <= 1'b0;

// spi_dtr_data [external]
wire [7:0]  spi_dtr_data_out_w = wr_data_q[`SPI_DTR_DATA_R];


//-----------------------------------------------------------------
// Register spi_drr
//-----------------------------------------------------------------
reg spi_drr_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    spi_drr_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_DRR))
    spi_drr_wr_q <= 1'b1;
else
    spi_drr_wr_q <= 1'b0;


//-----------------------------------------------------------------
// Register spi_ssr
//-----------------------------------------------------------------
reg spi_ssr_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    spi_ssr_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_SSR))
    spi_ssr_wr_q <= 1'b1;
else
    spi_ssr_wr_q <= 1'b0;

// spi_ssr_value [internal]
reg [7:0]  spi_ssr_value_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    spi_ssr_value_q <= 8'd`SPI_SSR_VALUE_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_SSR))
    spi_ssr_value_q <= cfg_wdata_i[`SPI_SSR_VALUE_R];

wire [7:0]  spi_ssr_value_out_w = spi_ssr_value_q;


wire        spi_ipisr_tx_empty_in_w;
wire        spi_sr_rx_empty_in_w;
wire        spi_sr_rx_full_in_w;
wire        spi_sr_tx_empty_in_w;
wire        spi_sr_tx_full_in_w;
wire [7:0]  spi_drr_data_in_w;


//-----------------------------------------------------------------
// Read mux
//-----------------------------------------------------------------
reg [31:0] data_r;

always @ *
begin
    data_r = 32'b0;

    case (cfg_araddr_i[7:0])

    `SPI_DGIER:
    begin
        data_r[`SPI_DGIER_GIE_R] = spi_dgier_gie_q;
    end
    `SPI_IPISR:
    begin
        data_r[`SPI_IPISR_TX_EMPTY_R] = spi_ipisr_tx_empty_in_w;
    end
    `SPI_IPIER:
    begin
        data_r[`SPI_IPIER_TX_EMPTY_R] = spi_ipier_tx_empty_q;
    end
    `SPI_SRR:
    begin
    end
    `SPI_CR:
    begin
        data_r[`SPI_CR_LOOP_R] = spi_cr_loop_q;
        data_r[`SPI_CR_SPE_R] = spi_cr_spe_q;
        data_r[`SPI_CR_MASTER_R] = spi_cr_master_q;
        data_r[`SPI_CR_CPOL_R] = spi_cr_cpol_q;
        data_r[`SPI_CR_CPHA_R] = spi_cr_cpha_q;
        data_r[`SPI_CR_MANUAL_SS_R] = spi_cr_manual_ss_q;
        data_r[`SPI_CR_TRANS_INHIBIT_R] = spi_cr_trans_inhibit_q;
        data_r[`SPI_CR_LSB_FIRST_R] = spi_cr_lsb_first_q;
    end
    `SPI_SR:
    begin
        data_r[`SPI_SR_RX_EMPTY_R] = spi_sr_rx_empty_in_w;
        data_r[`SPI_SR_RX_FULL_R] = spi_sr_rx_full_in_w;
        data_r[`SPI_SR_TX_EMPTY_R] = spi_sr_tx_empty_in_w;
        data_r[`SPI_SR_TX_FULL_R] = spi_sr_tx_full_in_w;
    end
    `SPI_DRR:
    begin
        data_r[`SPI_DRR_DATA_R] = spi_drr_data_in_w;
    end
    `SPI_SSR:
    begin
        data_r[`SPI_SSR_VALUE_R] = spi_ssr_value_q;
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

wire spi_cr_rd_req_w = read_en_w & (cfg_araddr_i[7:0] == `SPI_CR);
wire spi_drr_rd_req_w = read_en_w & (cfg_araddr_i[7:0] == `SPI_DRR);

wire spi_ipisr_wr_req_w = spi_ipisr_wr_q;
wire spi_cr_wr_req_w = spi_cr_wr_q;
wire spi_dtr_wr_req_w = spi_dtr_wr_q;
wire spi_drr_wr_req_w = spi_drr_wr_q;

//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
parameter [31:0] C_SCK_RATIO = 32'd32;

//-----------------------------------------------------------------
// TX FIFO
//-----------------------------------------------------------------
wire       sw_reset_w      = spi_srr_reset_out_w == 32'h0000000A;
wire       tx_fifo_flush_w = sw_reset_w | spi_cr_txfifo_rst_out_w;
wire       rx_fifo_flush_w = sw_reset_w | spi_cr_rxfifo_rst_out_w;

wire       tx_accept_w;
wire       tx_ready_w;
wire [7:0] tx_data_raw_w;
wire       tx_pop_w;

spi_lite_fifo
#(
    .WIDTH(8),
    .DEPTH(4),
    .ADDR_W(2)
)
u_tx_fifo
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .flush_i(tx_fifo_flush_w),

    .data_in_i(spi_dtr_data_out_w),
    .push_i(spi_dtr_wr_req_w),
    .accept_o(tx_accept_w),

    .pop_i(tx_pop_w),
    .data_out_o(tx_data_raw_w),
    .valid_o(tx_ready_w)
);

assign spi_sr_tx_empty_in_w = ~tx_ready_w;
assign spi_sr_tx_full_in_w  = ~tx_accept_w;

// Reverse order if LSB first
wire [7:0] tx_data_w = spi_cr_lsb_first_out_w ? 
    {
      tx_data_raw_w[0]
    , tx_data_raw_w[1]
    , tx_data_raw_w[2]
    , tx_data_raw_w[3]
    , tx_data_raw_w[4]
    , tx_data_raw_w[5]
    , tx_data_raw_w[6]
    , tx_data_raw_w[7]
    } : tx_data_raw_w;

//-----------------------------------------------------------------
// RX FIFO
//-----------------------------------------------------------------
wire       rx_accept_w;
wire       rx_ready_w;
wire [7:0] rx_data_w;
wire       rx_push_w;

spi_lite_fifo
#(
    .WIDTH(8),
    .DEPTH(4),
    .ADDR_W(2)
)
u_rx_fifo
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .flush_i(rx_fifo_flush_w),

    .data_in_i(rx_data_w),
    .push_i(rx_push_w),
    .accept_o(rx_accept_w),

    .pop_i(spi_drr_rd_req_w),
    .data_out_o(spi_drr_data_in_w),
    .valid_o(rx_ready_w)
);

assign spi_sr_rx_empty_in_w = ~rx_ready_w;
assign spi_sr_rx_full_in_w  = ~rx_accept_w;

//-----------------------------------------------------------------
// Configuration
//-----------------------------------------------------------------
wire [31:0]     clk_div_w = C_SCK_RATIO;

//-----------------------------------------------------------------
// Registers
//-----------------------------------------------------------------
reg   active_q;
reg [5:0] bit_count_q;
reg [7:0]   shift_reg_q;
reg [31:0]    clk_div_q;
reg   done_q;

// Xilinx placement pragmas:
//synthesis attribute IOB of spi_clk_q is "TRUE"
//synthesis attribute IOB of spi_mosi_q is "TRUE"
//synthesis attribute IOB of spi_cs_o is "TRUE"
reg   spi_clk_q;
reg   spi_mosi_q;

//-----------------------------------------------------------------
// Implementation
//-----------------------------------------------------------------
wire enable_w = spi_cr_spe_out_w & spi_cr_master_out_w & ~spi_cr_trans_inhibit_out_w;

// Something to do, SPI enabled...
wire start_w = enable_w & ~active_q & ~done_q & tx_ready_w;

// Loopback more or normal
wire miso_w = spi_cr_loop_out_w ? spi_mosi_o : spi_miso_i;

// SPI Clock Generator
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    clk_div_q <= 32'd0;
else if (start_w || sw_reset_w || clk_div_q == 32'd0)
    clk_div_q <= clk_div_w;
else
    clk_div_q <= clk_div_q - 32'd1;

wire clk_en_w = (clk_div_q == 32'd0);

//-----------------------------------------------------------------
// Sample, Drive pulse generation
//-----------------------------------------------------------------
reg sample_r;
reg drive_r;

always @ *
begin
    sample_r = 1'b0;
    drive_r  = 1'b0;

    // SPI = IDLE
    if (start_w)    
        drive_r  = ~spi_cr_cpha_out_w; // Drive initial data (CPHA=0)
    // SPI = ACTIVE
    else if (active_q && clk_en_w)
    begin
        // Sample
        // CPHA=0, sample on the first edge
        // CPHA=1, sample on the second edge
        if (bit_count_q[0] == spi_cr_cpha_out_w)
            sample_r = 1'b1;
        // Drive (CPHA = 1)
        else if (spi_cr_cpha_out_w)
            drive_r = 1'b1;
        // Drive (CPHA = 0)
        else 
            drive_r = (bit_count_q != 6'b0) && (bit_count_q != 6'd15);
    end
end

//-----------------------------------------------------------------
// Shift register
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
begin
    shift_reg_q    <= 8'b0;
    spi_clk_q      <= 1'b0;
    spi_mosi_q     <= 1'b0;
end
else
begin
    // SPI = RESET (or potentially update CPOL)
    if (sw_reset_w || (spi_cr_wr_req_w & !start_w))
    begin
        shift_reg_q    <= 8'b0;
        spi_clk_q      <= spi_cr_cpol_out_w;
    end
    // SPI = IDLE
    else if (start_w)
    begin
        spi_clk_q      <= spi_cr_cpol_out_w;

        // CPHA = 0
        if (drive_r)
        begin
            spi_mosi_q    <= tx_data_w[7];
            shift_reg_q   <= {tx_data_w[6:0], 1'b0};
        end
        // CPHA = 1
        else
            shift_reg_q   <= tx_data_w;
    end
    // SPI = ACTIVE
    else if (active_q && clk_en_w)
    begin
        // Toggle SPI clock output
        if (!spi_cr_loop_out_w)
            spi_clk_q <= ~spi_clk_q;

        // Drive MOSI
        if (drive_r)
        begin
            spi_mosi_q  <= shift_reg_q[7];
            shift_reg_q <= {shift_reg_q[6:0],1'b0};
        end
        // Sample MISO
        else if (sample_r)
            shift_reg_q[0] <= miso_w;
    end
end

//-----------------------------------------------------------------
// Bit counter
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
begin
    bit_count_q    <= 6'b0;
    active_q       <= 1'b0;
    done_q         <= 1'b0;
end
else if (sw_reset_w)
begin
    bit_count_q    <= 6'b0;
    active_q       <= 1'b0;
    done_q         <= 1'b0;
end
else if (start_w)
begin
    bit_count_q    <= 6'b0;
    active_q       <= 1'b1;
    done_q         <= 1'b0;
end
else if (active_q && clk_en_w)
begin
    // End of SPI transfer reached
    if (bit_count_q == 6'd15)
    begin
        // Go back to IDLE active_q
        active_q  <= 1'b0;

        // Set transfer complete flags
        done_q   <= 1'b1;
    end
    // Increment cycle counter
    else 
        bit_count_q <= bit_count_q + 6'd1;
end
else
    done_q         <= 1'b0;

// Delayed done_q for FIFO level check
reg check_tx_level_q;
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    check_tx_level_q <= 1'b0;
else
    check_tx_level_q <= done_q;

// Interrupt
reg intr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    intr_q <= 1'b0;
else if (check_tx_level_q && spi_ipier_tx_empty_out_w && spi_ipisr_tx_empty_in_w)
    intr_q <= 1'b1;
else if (spi_ipisr_wr_req_w && spi_ipisr_tx_empty_out_w)
    intr_q <= 1'b0;

assign spi_ipisr_tx_empty_in_w = spi_sr_tx_empty_in_w;

//-----------------------------------------------------------------
// Assignments
//-----------------------------------------------------------------
assign spi_clk_o            = spi_clk_q;
assign spi_mosi_o           = spi_mosi_q;

// Reverse order if LSB first
assign rx_data_w = spi_cr_lsb_first_out_w ? 
    {
      shift_reg_q[0]
    , shift_reg_q[1]
    , shift_reg_q[2]
    , shift_reg_q[3]
    , shift_reg_q[4]
    , shift_reg_q[5]
    , shift_reg_q[6]
    , shift_reg_q[7]
    } : shift_reg_q;


assign rx_push_w            = done_q;
assign tx_pop_w             = done_q;

assign spi_cs_o             = spi_ssr_value_out_w;
assign intr_o               = spi_dgier_gie_out_w & intr_q;

endmodule

//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------

module spi_lite_fifo
//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
    parameter WIDTH   = 8,
    parameter DEPTH   = 4,
    parameter ADDR_W  = 2
)
//-----------------------------------------------------------------
// Ports
//-----------------------------------------------------------------
(
    // Inputs
     input               clk_i
    ,input               rst_i
    ,input  [WIDTH-1:0]  data_in_i
    ,input               push_i
    ,input               pop_i
    ,input               flush_i

    // Outputs
    ,output [WIDTH-1:0]  data_out_o
    ,output              accept_o
    ,output              valid_o
);

//-----------------------------------------------------------------
// Local Params
//-----------------------------------------------------------------
localparam COUNT_W = ADDR_W + 1;

//-----------------------------------------------------------------
// Registers
//-----------------------------------------------------------------
reg [WIDTH-1:0]   ram_q[DEPTH-1:0];
reg [ADDR_W-1:0]  rd_ptr_q;
reg [ADDR_W-1:0]  wr_ptr_q;
reg [COUNT_W-1:0] count_q;

//-----------------------------------------------------------------
// Sequential
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
begin
    count_q   <= {(COUNT_W) {1'b0}};
    rd_ptr_q  <= {(ADDR_W) {1'b0}};
    wr_ptr_q  <= {(ADDR_W) {1'b0}};
end
else if (flush_i)
begin
    count_q   <= {(COUNT_W) {1'b0}};
    rd_ptr_q  <= {(ADDR_W) {1'b0}};
    wr_ptr_q  <= {(ADDR_W) {1'b0}};
end
else
begin
    // Push
    if (push_i & accept_o)
    begin
        ram_q[wr_ptr_q] <= data_in_i;
        wr_ptr_q        <= wr_ptr_q + 1;
    end

    // Pop
    if (pop_i & valid_o)
        rd_ptr_q      <= rd_ptr_q + 1;

    // Count up
    if ((push_i & accept_o) & ~(pop_i & valid_o))
        count_q <= count_q + 1;
    // Count down
    else if (~(push_i & accept_o) & (pop_i & valid_o))
        count_q <= count_q - 1;
end

//-------------------------------------------------------------------
// Combinatorial
//-------------------------------------------------------------------
/* verilator lint_off WIDTH */
assign valid_o       = (count_q != 0);
assign accept_o      = (count_q != DEPTH);
/* verilator lint_on WIDTH */

assign data_out_o    = ram_q[rd_ptr_q];



endmodule
