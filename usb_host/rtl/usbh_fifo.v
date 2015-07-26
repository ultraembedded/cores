//-----------------------------------------------------------------
//                        USB Full Speed Host
//                              V0.1
//                        Ultra-Embedded.com
//                          Copyright 2015
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
// Module: USB FIFO - simple FIFO
//-----------------------------------------------------------------
module usbh_fifo

//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
    parameter           WIDTH   = 8,
    parameter           DEPTH   = 4,
    parameter           ADDR_W  = 2
)

//-----------------------------------------------------------------
// Ports
//-----------------------------------------------------------------
(
    input               clk_i,
    input               rst_i,

    input [WIDTH-1:0]   data_i,
    input               push_i,

    output              full_o,
    output              empty_o,

    output [WIDTH-1:0]  data_o,
    input               pop_i,

    input               flush_i
);

//-----------------------------------------------------------------
// Defs / Params
//-----------------------------------------------------------------
localparam COUNT_W      = ADDR_W + 1;

//-----------------------------------------------------------------
// Registers
//-----------------------------------------------------------------
reg [WIDTH-1:0]         ram [DEPTH-1:0];
reg [ADDR_W-1:0]        rd_ptr_q;
reg [ADDR_W-1:0]        wr_ptr_q;
reg [COUNT_W-1:0]       count_q;

//-----------------------------------------------------------------
// Sequential
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
begin
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
        if (push_i && !full_o)
        begin
            ram[wr_ptr_q] <= data_i;
            wr_ptr_q      <= wr_ptr_q + 1;
        end

        // Pop
        if (pop_i && !empty_o)
            rd_ptr_q    <= rd_ptr_q + 1;

        // Count up
        if ((push_i && !full_o) && !(pop_i && !empty_o))
            count_q     <= count_q + 1;
        // Count down
        else if (!(push_i && !full_o) && (pop_i && !empty_o))
            count_q     <= count_q - 1;
    end
end

//-------------------------------------------------------------------
// Assignments
//-------------------------------------------------------------------
assign full_o    = (count_q == DEPTH);
assign empty_o   = (count_q == 0);

assign data_o    = ram[rd_ptr_q];

endmodule
