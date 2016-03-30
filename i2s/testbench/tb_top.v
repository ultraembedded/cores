`timescale 1ns / 1ns

//-----------------------------------------------------------------
// Module:  Auto generated top
//-----------------------------------------------------------------
module tb_top();

reg          clk_i;
reg          rst_i;
reg          audio_clk_i;
reg          audio_rst_i;
wire         i2s_mclk_o;
wire         i2s_bclk_o;
wire         i2s_ws_o;
wire         i2s_data_o;
reg  [31:0]   sample_i;
wire         sample_req_o;

//-----------------------------------------------------------------
// DUT
//-----------------------------------------------------------------
i2s dut
(
      .clk_i(clk_i)
    , .rst_i(rst_i)
    , .audio_clk_i(audio_clk_i)
    , .audio_rst_i(audio_rst_i)
    , .i2s_mclk_o(i2s_mclk_o)
    , .i2s_bclk_o(i2s_bclk_o)
    , .i2s_ws_o(i2s_ws_o)
    , .i2s_data_o(i2s_data_o)
    , .sample_i(sample_i)
    , .sample_req_o(sample_req_o)
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