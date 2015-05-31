`timescale 100ps/100ps

//-----------------------------------------------------------------
// Module
//-----------------------------------------------------------------
module top_tb ;

//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
parameter MAX_DELAY      = 0;

//-----------------------------------------------------------------
// Simulation
//-----------------------------------------------------------------
`include "simulation.svh"

`CLOCK_GEN(clk, 100)
`RESET_GEN(rst, 100)

`ifdef TRACE
    `TB_VCD(top_tb, "waveform.vcd")
`endif

`TB_RUN_FOR(10ms)

//-----------------------------------------------------------------
// Registers / Wires
//-----------------------------------------------------------------
wire [31:0]         mem_addr;
wire [31:0]         mem_data_w;
wire [31:0]         mem_data_r;
wire [3:0]          mem_sel;
wire                mem_stb;
wire                mem_cyc;
wire                mem_we;
wire                mem_stall;
wire                mem_ack;

reg                 ftdi_rxf;
reg                 ftdi_txe;
wire                ftdi_rd;
wire                ftdi_wr;
reg [7:0]           ftdi_data;

wire [7:0]          ftdi_data_io_w;

reg [7:0]           mem[*];

reg [7:0]           gpio_in;
wire [7:0]          gpio_out;

//-----------------------------------------------------------------
// mem_write
//-----------------------------------------------------------------
task automatic mem_write(input [31:0] addr, input [7:0] data);
begin
    mem[addr] = data;
end
endtask

//-----------------------------------------------------------------
// mem_read
//-----------------------------------------------------------------
task automatic mem_read(input [31:0] addr, output [7:0] data);
begin
    if (mem.exists(addr))
        data = mem[addr];
    else
        data = 8'bx;
end
endtask
//-----------------------------------------------------------------
// write_to_ftdi
//-----------------------------------------------------------------
task automatic write_to_ftdi(input [31:0] addr, input [11:0] len);
begin
    integer i;
    reg [7:0] data;
    reg [31:0] addr_tmp;

    repeat ($urandom_range(MAX_DELAY,0)) @(posedge clk);

    ftdi_rxf        <= 1'b0;
    ftdi_data       <= {len[11:8], 4'h1}; // WRITE

    @(posedge ftdi_rd);
    ftdi_rxf        <= 1'b1;

    repeat ($urandom_range(MAX_DELAY,0)) @(posedge clk);

    ftdi_rxf        <= 1'b0;
    ftdi_data       <= len[7:0]; // LEN

    @(posedge ftdi_rd);
    ftdi_rxf        <= 1'b1;

    repeat ($urandom_range(MAX_DELAY,0)) @(posedge clk);

    // ADDR
    addr_tmp = addr;
    for (i=0;i<4;i=i+1)
    begin
        ftdi_rxf   <= 1'b0;

        data = addr_tmp[31:24];
        addr_tmp = {addr_tmp[23:0], 8'b0};

        $display("ADDR%d: %x", i, data);
        ftdi_data  <= data; // DATA

        @(posedge ftdi_rd);
        ftdi_rxf        <= 1'b1;

        repeat ($urandom_range(MAX_DELAY,0)) @(posedge clk);
    end

    // DATA
    addr_tmp = addr;
    for (i=0;i<len;i=i+1)
    begin
        ftdi_rxf   <= 1'b0;

        data = $urandom;

        $display("BYTE%d: %x", i, data);
        ftdi_data  <= data; // DATA

        mem_write(addr_tmp, data);
        addr_tmp += 1;

        @(posedge ftdi_rd);
        ftdi_rxf    <= 1'b1;

        repeat ($urandom_range(MAX_DELAY,0)) @(posedge clk);
    end 
end
endtask
//-----------------------------------------------------------------
// write_gp
//-----------------------------------------------------------------
task automatic write_gp(input [7:0] gp);
begin
    integer i;
    reg [7:0] data;
    reg [31:0] addr_tmp;

    repeat ($urandom_range(MAX_DELAY,0)) @(posedge clk);

    ftdi_rxf        <= 1'b0;
    ftdi_data       <= {4'b0, 4'h3}; // GP_WR

    @(posedge ftdi_rd);
    ftdi_rxf        <= 1'b1;

    repeat ($urandom_range(MAX_DELAY,0)) @(posedge clk);

    ftdi_rxf   <= 1'b0;

    data = $urandom;

    ftdi_data  <= data; // DATA

    mem_write(addr_tmp, data);
    addr_tmp += 1;

    @(posedge ftdi_rd);
    ftdi_rxf    <= 1'b1;

    repeat ($urandom_range(MAX_DELAY,0)) @(posedge clk);

    repeat (2) @(posedge clk);
    `ASSERT(gpio_out == data);
end
endtask
//-----------------------------------------------------------------
// read_gp
//-----------------------------------------------------------------
task automatic read_gp(output [7:0] gp);
begin
    integer i;
    reg [7:0] data;
    reg [31:0] addr_tmp;

    repeat ($urandom_range(MAX_DELAY,0)) @(posedge clk);

    ftdi_rxf        <= 1'b0;
    ftdi_data       <= {4'b0, 4'h4}; // GP_RD

    @(posedge ftdi_rd);
    ftdi_rxf        <= 1'b1;

    repeat ($urandom_range(MAX_DELAY,0)) @(posedge clk);

    ftdi_txe   <= 1'b0;

    @(posedge ftdi_wr);

    $display("GPIO_IN: %x", u_dut.u_sync.tx_data_q);
    
    ftdi_txe    <= 1'b1;

    repeat ($urandom_range(MAX_DELAY,0)) @(posedge clk);
end
endtask
//-----------------------------------------------------------------
// check_mem
//-----------------------------------------------------------------
task automatic check_mem(input [31:0] addr, input [31:0] len);
begin
    integer   i;
    reg [7:0] data;
    reg [7:0] actual_data;

    // Compare
    for (i=0;i<len;i=i+1)
    begin

        mem_read(addr, data);
        u_wbs.read8(addr, actual_data);

        if (data !== actual_data)
        begin
            $display("Error @ %x: %x != %x", addr, data, actual_data);
            $finish;
        end

        addr += 1;

    end   
end
endtask
//-----------------------------------------------------------------
// read_from_ftdi
//-----------------------------------------------------------------
task automatic read_from_ftdi(input [31:0] addr, input [11:0] len);
begin
    integer i;
    reg [7:0] data;
    reg [31:0] addr_tmp;

    repeat ($urandom_range(MAX_DELAY,0)) @(posedge clk);

    ftdi_rxf        <= 1'b0;
    ftdi_data       <= {len[11:8], 4'h2}; // READ

    @(posedge ftdi_rd);
    ftdi_rxf        <= 1'b1;

    repeat ($urandom_range(MAX_DELAY,0)) @(posedge clk);

    ftdi_rxf        <= 1'b0;
    ftdi_data       <= len[7:0]; // LEN

    @(posedge ftdi_rd);
    ftdi_rxf        <= 1'b1;

    repeat ($urandom_range(MAX_DELAY,0)) @(posedge clk);

    // ADDR
    addr_tmp = addr;
    for (i=0;i<4;i=i+1)
    begin
        ftdi_rxf   <= 1'b0;

        data = addr_tmp[31:24];
        addr_tmp = {addr_tmp[23:0], 8'b0};

        $display("ADDR%d: %x", i, data);
        ftdi_data  <= data; // DATA

        @(posedge ftdi_rd);
        ftdi_rxf        <= 1'b1;

        repeat ($urandom_range(MAX_DELAY,0)) @(posedge clk);
    end

    // DATA
    addr_tmp = addr;
    for (i=0;i<len;i=i+1)
    begin
        ftdi_txe   <= 1'b0;

        @(posedge ftdi_wr);

        data = $urandom;

        $display("READ%d: %x", i, u_dut.u_sync.tx_data_q);
        // TODO: COMP
        mem_write(addr_tmp, u_dut.u_sync.tx_data_q);
        addr_tmp += 1;
        
        ftdi_txe    <= 1'b1;

        repeat ($urandom_range(MAX_DELAY,0)) @(posedge clk);
    end 
end
endtask

//-----------------------------------------------------------------
// Testbench
//-----------------------------------------------------------------
initial
begin
    reg [7:0] tmp;

    ftdi_rxf        = 1'b1;
    ftdi_data       = 8'bz;
    ftdi_txe        = 1'b1;

    gpio_in         = 8'h55;

    forever
    begin
        repeat (10) @(posedge clk);

        write_to_ftdi(32'h00000000, 16);
        write_gp(4'ha);
        write_to_ftdi(32'h00000010, 16);

        read_gp(tmp);
        `ASSERT(tmp == 8'h55);

        repeat (100) @(posedge clk);
        check_mem(32'h00000000, 32);

        read_from_ftdi(32'h00000000, 16);

        repeat (100) @(posedge clk);
        check_mem(32'h00000000, 16);

        write_to_ftdi(32'h00000100, 15);
        repeat (100) @(posedge clk);
        check_mem(32'h00000100, 15);

        write_to_ftdi(32'h00000201, 14);
        repeat (100) @(posedge clk);
        check_mem(32'h00000201, 14);

        write_to_ftdi(32'h00000001, 1);
        repeat (100) @(posedge clk);
        check_mem(32'h00000001, 1);        

        $finish;
    end
end

//-----------------------------------------------------------------
// Instantiation
//-----------------------------------------------------------------
assign ftdi_data_io_w = !ftdi_rd ? ftdi_data : 8'bz;

ftdi_if
u_dut
(
    .clk_i(clk),
    .rst_i(rst),

    // FTDI (async FIFO interface)
    .ftdi_rxf_i(ftdi_rxf),
    .ftdi_txe_i(ftdi_txe),
    .ftdi_siwua_o(),
    .ftdi_wr_o(ftdi_wr),
    .ftdi_rd_o(ftdi_rd),
    .ftdi_d_io(ftdi_data_io_w),

    // General Purpose
    .gp_o(gpio_out),
    .gp_i(gpio_in),

    // Wishbone Interface
    .mem_addr_o(mem_addr),
    .mem_data_o(mem_data_w),
    .mem_data_i(mem_data_r),
    .mem_sel_o(mem_sel),
    .mem_we_o(mem_we),
    .mem_cyc_o(mem_cyc),
    .mem_stb_o(mem_stb),
    .mem_stall_i(mem_stall),
    .mem_ack_i(mem_ack)
);

wb_slave
#(
    .RANDOM_STALLS(1),
    .MAX_RESP_RATE(0)
)
u_wbs
(
    .clk_i(clk),
    .rst_i(rst),
    
    .addr_i(mem_addr), 
    .data_i(mem_data_w), 
    .data_o(mem_data_r), 
    .sel_i(mem_sel), 
    .cyc_i(mem_cyc), 
    .stb_i(mem_stb), 
    .cti_i(3'b111),
    .we_i(mem_we), 
    .stall_o(mem_stall),
    .ack_o(mem_ack)         
);

endmodule
