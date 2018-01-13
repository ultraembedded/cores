`timescale 1ns / 1ns

//-----------------------------------------------------------------
// Module:  Auto generated top
//-----------------------------------------------------------------
module tb_top();

reg          ulpi_clk60_i;
reg          ulpi_rst_i;
reg  [7:0]   ulpi_data_i;
wire [7:0]   ulpi_data_o;
reg          ulpi_dir_i;
reg          ulpi_nxt_i;
wire         ulpi_stp_o;
reg  [7:0]   reg_addr_i;
reg          reg_stb_i;
reg          reg_we_i;
reg  [7:0]   reg_data_i;
wire [7:0]   reg_data_o;
wire         reg_ack_o;
reg          utmi_txvalid_i;
wire         utmi_txready_o;
wire         utmi_rxvalid_o;
wire         utmi_rxactive_o;
wire         utmi_rxerror_o;
wire [7:0]   utmi_data_o;
reg  [7:0]   utmi_data_i;
reg  [1:0]   utmi_xcvrselect_i;
reg          utmi_termselect_i;
reg  [1:0]   utmi_opmode_i;
reg          utmi_dppulldown_i;
reg          utmi_dmpulldown_i;
wire [1:0]   utmi_linestate_o;

//-----------------------------------------------------------------
// DUT
//-----------------------------------------------------------------
ulpi_wrapper dut
(
      .ulpi_clk60_i(ulpi_clk60_i)
    , .ulpi_rst_i(ulpi_rst_i)
    , .ulpi_data_out_i(ulpi_data_i)
    , .ulpi_data_in_o(ulpi_data_o)
    , .ulpi_dir_i(ulpi_dir_i)
    , .ulpi_nxt_i(ulpi_nxt_i)
    , .ulpi_stp_o(ulpi_stp_o)
    , .utmi_txvalid_i(utmi_txvalid_i)
    , .utmi_txready_o(utmi_txready_o)
    , .utmi_rxvalid_o(utmi_rxvalid_o)
    , .utmi_rxactive_o(utmi_rxactive_o)
    , .utmi_rxerror_o(utmi_rxerror_o)
    , .utmi_data_in_o(utmi_data_o)
    , .utmi_data_out_i(utmi_data_i)
    , .utmi_xcvrselect_i(utmi_xcvrselect_i)
    , .utmi_termselect_i(utmi_termselect_i)
    , .utmi_op_mode_i(utmi_opmode_i)
    , .utmi_dppulldown_i(utmi_dppulldown_i)
    , .utmi_dmpulldown_i(utmi_dmpulldown_i)
    , .utmi_linestate_o(utmi_linestate_o)
);

//-----------------------------------------------------------------
// Trace
//-----------------------------------------------------------------
initial 
begin 
    if (`TRACE)
    begin
        $dumpfile("waveform.vcd");
        $dumpvars(0,tb_top);
    end
end

endmodule