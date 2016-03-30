//-----------------------------------------------------------------
//                           I2S Master
//                              V0.1
//                        Ultra-Embedded.com
//                          Copyright 2012
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
module i2s
(
    // Main clock (min 2x audio_clk_i)
    input           clk_i,
    input           rst_i,

    // Audio clock (MCLK x 2):
    // For 44.1KHz: 22.5792MHz
    // For 48KHz:   24.576MHz
    input           audio_clk_i,
    input           audio_rst_i,

    // I2S DAC Interface
    output          i2s_mclk_o,
    output          i2s_bclk_o,
    output          i2s_ws_o,
    output          i2s_data_o,

    // Audio interface (16-bit x 2 = RL)
    // (synchronous to clk_i)
    input [31:0]    sample_i,
    output          sample_req_o
);

//-----------------------------------------------------------------
// Registers
//-----------------------------------------------------------------
reg [4:0]       bit_count_q;

// Registered audio input data
reg [31:0]      sample_q;

// Xilinx: Place output flop in IOB
//synthesis attribute IOB of mclk_q is "TRUE"
//synthesis attribute IOB of ws_q is "TRUE"
//synthesis attribute IOB of bclk_q is "TRUE"
//synthesis attribute IOB of data_q is "TRUE"
reg             mclk_q;
reg             bclk_q;
reg             ws_q;
reg             data_q;

reg             sample_req_q;
reg             next_data_q;

//-----------------------------------------------------------------
// MCLK
//-----------------------------------------------------------------
reg [7:0] clock_div_q;

always @(posedge audio_clk_i or posedge audio_rst_i) 
if (rst_i) 
begin
    mclk_q      <= 1'b0;
    clock_div_q <= 8'b0;
end 
else
begin
    mclk_q      <= !mclk_q;
    clock_div_q <= clock_div_q + 8'd1;
end

reg clk_en0_ms_q;
reg clk_en1_q;
reg clk_en2_q;

// Resync clk enable pulse to clk_i domain
always @(posedge clk_i or posedge rst_i) 
if (rst_i)
begin
    clk_en0_ms_q <= 1'b0;
    clk_en1_q    <= 1'b0;
    clk_en2_q    <= 1'b0;
end
else
begin
    clk_en0_ms_q <= (clock_div_q == 8'd0);
    clk_en1_q    <= clk_en0_ms_q;
    clk_en2_q    <= clk_en1_q;
end

// BCLK is div256 of MCLK
wire bclk_en_w = !clk_en2_q && clk_en1_q;

//-----------------------------------------------------------------
// I2S Output Generator
//-----------------------------------------------------------------
always @(posedge clk_i or posedge rst_i) 
begin
    if (rst_i == 1'b1) 
    begin
        sample_q        <= 32'b0;
        bit_count_q     <= 5'd0;
        data_q          <= 1'b0;
        ws_q            <= 1'b0;
        bclk_q          <= 1'b0;
        next_data_q     <= 1'b0;
        sample_req_q    <= 1'b0;
    end 
    else if (bclk_en_w)
    begin
        // BCLK 1->0 - Falling Edge
        if (bclk_q)
        begin
            bclk_q      <= 1'b0;

            data_q      <= next_data_q;
            next_data_q <= sample_q[5'd31 - bit_count_q];

            // Word select
            ws_q        <= bit_count_q[4];

            // Increment bit position counter
            bit_count_q <= bit_count_q + 5'd1;
        end
        // BCLK 0->1 - Rising Edge
        else
        begin
            bclk_q <= 1'b1;

            // Last bit in first half, buffer remainder and pop word
            if (bit_count_q == 5'd0)
            begin
                sample_q     <= {sample_i[15:0], sample_i[31:16]};
                sample_req_q <= 1'b1;
            end
        end
    end
    else
        sample_req_q <= 1'b0;
end

//-----------------------------------------------------------------
// I2S DAC Interface
//----------------------------------------------------------------- 
assign i2s_mclk_o = mclk_q;
assign i2s_ws_o   = ws_q;
assign i2s_bclk_o = bclk_q;
assign i2s_data_o = data_q;

assign sample_req_o = sample_req_q;

endmodule
