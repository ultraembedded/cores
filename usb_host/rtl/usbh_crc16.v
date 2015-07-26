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
// Module: 16-bit CRC used by USB data packets
//-----------------------------------------------------------------
module usbh_crc16
(
    input [15:0]    crc_i,
    input [7:0]     data_i,
    output [15:0]   crc_o
);

//-----------------------------------------------------------------
// Implementation
//-----------------------------------------------------------------
assign crc_o[15] =    data_i[0] ^ data_i[1] ^ data_i[2] ^ data_i[3] ^ data_i[4] ^
                        data_i[5] ^ data_i[6] ^ data_i[7] ^ crc_i[7] ^ crc_i[6] ^
                        crc_i[5] ^ crc_i[4] ^ crc_i[3] ^ crc_i[2] ^
                        crc_i[1] ^ crc_i[0];
assign crc_o[14] =    data_i[0] ^ data_i[1] ^ data_i[2] ^ data_i[3] ^ data_i[4] ^ data_i[5] ^
                        data_i[6] ^ crc_i[6] ^ crc_i[5] ^ crc_i[4] ^
                        crc_i[3] ^ crc_i[2] ^ crc_i[1] ^ crc_i[0];
assign crc_o[13] =    data_i[6] ^ data_i[7] ^ crc_i[7] ^ crc_i[6];
assign crc_o[12] =    data_i[5] ^ data_i[6] ^ crc_i[6] ^ crc_i[5];
assign crc_o[11] =    data_i[4] ^ data_i[5] ^ crc_i[5] ^ crc_i[4];
assign crc_o[10] =    data_i[3] ^ data_i[4] ^ crc_i[4] ^ crc_i[3];
assign crc_o[9] =     data_i[2] ^ data_i[3] ^ crc_i[3] ^ crc_i[2];
assign crc_o[8] =     data_i[1] ^ data_i[2] ^ crc_i[2] ^ crc_i[1];
assign crc_o[7] =     data_i[0] ^ data_i[1] ^ crc_i[15] ^ crc_i[1] ^ crc_i[0];
assign crc_o[6] =     data_i[0] ^ crc_i[14] ^ crc_i[0];
assign crc_o[5] =     crc_i[13];
assign crc_o[4] =     crc_i[12];
assign crc_o[3] =     crc_i[11];
assign crc_o[2] =     crc_i[10];
assign crc_o[1] =     crc_i[9];
assign crc_o[0] =     data_i[0] ^ data_i[1] ^ data_i[2] ^ data_i[3] ^ data_i[4] ^ data_i[5] ^
                        data_i[6] ^ data_i[7] ^ crc_i[8] ^ crc_i[7] ^ crc_i[6] ^
                        crc_i[5] ^ crc_i[4] ^ crc_i[3] ^ crc_i[2] ^
                        crc_i[1] ^ crc_i[0];

endmodule
