//-----------------------------------------------------------------
//                        SPDIF Transmitter
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
module spdif

//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
    parameter CLK_RATE_KHZ          = 50000,
    parameter AUDIO_RATE            = 44100,
    parameter AUDIO_CLK_SRC         = "EXTERNAL", // INTERNAL or EXTERNAL

    // Generated params
    parameter WHOLE_CYCLES          = (CLK_RATE_KHZ*1000) / (AUDIO_RATE*128),
    parameter ERROR_BASE            = 10000,
    parameter [63:0] ERRORS_PER_BIT = ((CLK_RATE_KHZ * 1000 * ERROR_BASE) / (AUDIO_RATE*128)) - (WHOLE_CYCLES * ERROR_BASE)
)

//-----------------------------------------------------------------
// Ports
//-----------------------------------------------------------------
(
    input           clk_i,
    input           rst_i,

    // Audio clock source (only used when AUDIO_CLK_SRC=EXTERNAL)
    input           audio_clk_i,

    // Output
    output          spdif_o,

    // Audio interface (16-bit x 2 = RL)
    input [31:0]    sample_i,
    output          sample_req_o
);

//-----------------------------------------------------------------
// External clock source
//-----------------------------------------------------------------
wire    bit_clock_w;
generate 
if (AUDIO_CLK_SRC == "EXTERNAL")
begin
    // Toggling flop in audio_clk_i domain
    reg toggle_aud_clk_q;

    always @ (posedge rst_i or posedge audio_clk_i)
    if (rst_i)
        toggle_aud_clk_q <= 1'b0;
    else
        toggle_aud_clk_q <= ~toggle_aud_clk_q;

    // Resync toggle_aud_clk_q to clk_i domain
    reg resync_toggle_ms_q;
    reg resync_toggle_q;

    always @ (posedge rst_i or posedge clk_i)
        if (rst_i)
        begin
            resync_toggle_ms_q  <= 1'b0;
            resync_toggle_q     <= 1'b0;
        end
        else
        begin
            resync_toggle_ms_q  <= toggle_aud_clk_q;
            resync_toggle_q     <= resync_toggle_ms_q;
        end

    reg last_toggle_q;
    always @ (posedge rst_i or posedge clk_i)
    if (rst_i)
        last_toggle_q   <= 1'b0;
    else
        last_toggle_q   <= resync_toggle_q;

    // Single cycle pulse on every rising edge of audio_clk_i
    assign bit_clock_w = last_toggle_q ^ resync_toggle_q;
end
//-----------------------------------------------------------------
// Internal clock source
//-----------------------------------------------------------------
else
begin
    reg [31:0]  count_q;
    reg [31:0]  error_q;
    reg         bit_clk_q;

    // Clock pulse generator
    always @ (posedge rst_i or posedge clk_i)
    begin
       if (rst_i)
       begin
            count_q     <= 32'd0;
            error_q     <= 32'd0;
            bit_clk_q   <= 1'b1;
       end
       else
       begin
            case (count_q)
            0 :
            begin
                bit_clk_q   <= 1'b1;
                count_q     <= count_q + 32'd1;
            end

            WHOLE_CYCLES-1:
            begin
                if (error_q < (ERROR_BASE - ERRORS_PER_BIT))
                begin
                    error_q <= error_q + ERRORS_PER_BIT;
                    count_q <= 32'd0;
                end
                else
                begin
                    error_q <= error_q + ERRORS_PER_BIT - ERROR_BASE;
                    count_q <= count_q + 32'd1;
                end

                bit_clk_q   <= 1'b0;
            end

            WHOLE_CYCLES:
            begin
                count_q     <= 32'd0;
                bit_clk_q   <= 1'b0;
            end

            default:
            begin
                count_q     <= count_q + 32'd1;
                bit_clk_q   <= 1'b0;
            end
            endcase
       end
    end

    assign bit_clock_w = bit_clk_q;
end
endgenerate

//-----------------------------------------------------------------
// Core SPDIF
//-----------------------------------------------------------------
spdif_core
u_core
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .bit_out_en_i(bit_clock_w),

    .spdif_o(spdif_o),

    .sample_i(sample_i),
    .sample_req_o(sample_req_o)
);

endmodule
