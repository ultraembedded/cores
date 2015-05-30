//-----------------------------------------------------------------
// Module
//-----------------------------------------------------------------
module wb_master 
(
    input                               clk_i, 
    input                               rst_i, 

    // Wishbone I/F
    output reg [31:0]                   addr_o,
    output reg [31:0]                   data_o,
    input [31:0]                        data_i,    
    output reg [3:0]                    sel_o,
    output reg [2:0]                    cti_o,
    output reg                          cyc_o,
    output reg                          stb_o,
    output reg                          we_o,
    input                               ack_i,
    input                               stall_i
);

//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
parameter MIN_ADDRESS       = 0;
parameter MAX_ADDRESS       = 8192;
parameter BURST_ENABLED     = 1;
parameter READ_ONLY         = 0;
parameter WRITE_ONLY        = 0;
parameter SEQUENTIAL_ONLY   = 0;
parameter RANDOM_DELAY      = 1;
parameter DELAY_RATE        = 3;

`include "simulation.svh"

//-----------------------------------------------------------------
// Request Queue
//-----------------------------------------------------------------
typedef struct
{
    reg [31:0] address;
    reg [31:0] data;
    reg [3:0]  sel;
    reg        we;
} request_t;

request_t requests[$];

//-----------------------------------------------------------------
// Memory
//-----------------------------------------------------------------
reg [31:0] mem[*];

//-----------------------------------------------------------------
// write
//-----------------------------------------------------------------
task automatic write(input [31:0] addr, input [31:0] data);
begin
    mem[addr[31:2]] = data;
end
endtask

//-----------------------------------------------------------------
// read
//-----------------------------------------------------------------
task automatic read(input [31:0] addr, output [31:0] data);
begin
    if (mem.exists(addr[31:2]))
        data = mem[addr[31:2]];
    else
        data = 32'bx;
end
endtask

//-----------------------------------------------------------------
// write_bytes
//-----------------------------------------------------------------
task automatic write_bytes(input [31:0] addr, input [31:0] data, input [31:0] sel);
begin
    reg [31:0] new_data;

    read(addr, new_data);

    if (sel[3])
        new_data[31:24] = data[31:24];
    if (sel[2])
        new_data[23:16] = data[23:16];
    if (sel[1])
        new_data[15:8]  = data[15:8];
    if (sel[0])
        new_data[7:0]   = data[7:0];

    write(addr, new_data);
end
endtask

//-----------------------------------------------------------------
// compare
//-----------------------------------------------------------------
task automatic compare(input [31:0] addr, input [31:0] data, input [31:0] sel, output match);
begin
    reg [31:0] new_data;

    read(addr, new_data);

    match = 1;

    if (sel[3])
        if (new_data[31:24] !== data[31:24])
            match = 0;

    if (sel[2])
        if (new_data[23:16] !== data[23:16])
            match = 0;

    if (sel[1])
        if (new_data[15:8] !== data[15:8])
            match = 0;

    if (sel[0])
        if (new_data[7:0] !== data[7:0])
            match = 0;

    if (!match)
    begin
        $display("ERROR: Expected %x Got %x Mask %x", new_data, data, sel);
    end            
end
endtask

//-----------------------------------------------------------------
// request
//-----------------------------------------------------------------
initial
begin
    request_t  req;
    reg        burst;
    reg [2:0]  burst_cnt;

    addr_o = 32'bz;
    data_o = 32'bz;
    sel_o  = 4'bz;
    we_o   = 1'bz;
    stb_o  = 1'b0;
    cti_o  = 3'bz;
    burst  = 1'b0;
    burst_cnt = 0;

    req.address = 0;

    forever
    begin
        @(posedge clk_i);

        // Command presented and accepted
        if (stb_o && !stall_i)
        begin
            requests.push_back(req);

            addr_o = 32'bz;
            data_o = 32'bz;
            sel_o  = 4'bz;
            we_o   = 1'bz;
            cti_o  = 3'bz;
            stb_o  = 1'b0;
        end

        // Continuation of a burst
        if (!stb_o && burst)
        begin
            req.address = req.address + 4;
            req.data    = req.we ? $urandom : 32'bz;

            addr_o = req.address;
            addr_o[1:0] = 2'b0;
            data_o = req.data;            
            cti_o  = (burst_cnt == 1) ? 3'b111 : 3'b010;
            sel_o  = req.sel;
            we_o   = req.we;    
            stb_o  = 1'b1;       

            burst_cnt   = burst_cnt - 1;
            if (burst_cnt == 0)
                burst   = 0;
        end

        // Ready to issue a new command?
        if (!stb_o)
        begin

            if (RANDOM_DELAY)
            begin
                repeat ($urandom_range(DELAY_RATE,0)) @(posedge clk_i);
            end

            if (SEQUENTIAL_ONLY)
                req.address = req.address + 4;
            else
                req.address = $urandom_range(MAX_ADDRESS,MIN_ADDRESS);

            if (READ_ONLY)
                req.we  = 1'b0;
            else if (WRITE_ONLY)
                req.we  = 1'b1;
            else
                req.we  = $urandom;
            req.data    = req.we ? $urandom : 32'bz;

            if (BURST_ENABLED)
            begin
                burst       = $urandom;
                burst_cnt   = 7;                
            end
            else
                burst       = 0;

            req.sel     = (!burst && req.we) ? $urandom : 4'b1111;

            addr_o = req.address;
            addr_o[1:0] = 2'b0;
            data_o = req.data;
            sel_o  = req.sel;
            we_o   = req.we;
            cti_o  = (!burst) ? 3'b111 : 3'b010;
            stb_o  = 1'b1;            
        end    
    end
end

//-----------------------------------------------------------------
// response
//-----------------------------------------------------------------
always @(posedge clk_i)
begin
    request_t  req;
    if (ack_i)
    begin
        `ASSERT(requests.size() > 0);

        req = requests.pop_front();

        // Write
        if (req.we)
        begin
            write_bytes(req.address, req.data, req.sel);
        end
        // Read
        else
        begin
            reg match;
            compare(req.address, data_i, req.sel, match);
            `ASSERT(match);
        end            
    end
end

always @ *
begin
    cyc_o  = stb_o || (requests.size() > 0);
end

endmodule
