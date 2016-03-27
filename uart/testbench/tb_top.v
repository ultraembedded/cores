`timescale 1ns / 1ns

//-----------------------------------------------------------------
// Module:  Auto generated top
//-----------------------------------------------------------------
module tb_top();

reg          clk_i;
reg          rst_i;
wire         intr_o;
wire         tx_o;
reg          rx_i;
reg  [7:0]   addr_i;
wire [31:0]   data_o;
reg  [31:0]   data_i;
reg          we_i;
reg          stb_i;
wire         ack_o;

//-----------------------------------------------------------------
// DUT
//-----------------------------------------------------------------
uart_wb dut
(
      .clk_i(clk_i)
    , .rst_i(rst_i)
    , .intr_o(intr_o)
    , .tx_o(tx_o)
    , .rx_i(rx_i)
    , .addr_i(addr_i)
    , .data_o(data_o)
    , .data_i(data_i)
    , .we_i(we_i)
    , .stb_i(stb_i)
    , .ack_o(ack_o)
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