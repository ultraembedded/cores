`timescale 1ns / 1ns

//-----------------------------------------------------------------
// Module:  Auto generated top
//-----------------------------------------------------------------
module tb_top();

reg          clk_i;
reg          rst_i;
reg          audio_clk_i;
wire         spdif_o;
reg  [31:0]   sample_i;
wire         sample_req_o;

//-----------------------------------------------------------------
// DUT
//-----------------------------------------------------------------
spdif dut
(
      .clk_i(clk_i)
    , .rst_i(rst_i)
    , .audio_clk_i(audio_clk_i)
    , .spdif_o(spdif_o)
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