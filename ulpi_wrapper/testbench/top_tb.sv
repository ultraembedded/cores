`timescale 1ns/100ps

//-----------------------------------------------------------------
// Module
//-----------------------------------------------------------------
module top_tb ;

//-----------------------------------------------------------------
// Simulation
//-----------------------------------------------------------------
`include "simulation.svh"

`CLOCK_GEN(clk, 16.666)
`RESET_GEN(rst, 16.666)

`ifdef TRACE
    `TB_VCD(top_tb, "waveform.vcd")
`endif

`TB_RUN_FOR(10ms)

//-----------------------------------------------------------------
// Registers / Wires
//-----------------------------------------------------------------
reg  [7:0]  utmi_link_data_in;
wire [7:0]  utmi_link_data_out;
reg         utmi_link_txvalid;
wire        utmi_link_txready;
wire        utmi_link_rxvalid;
wire        utmi_link_rxactive;
wire        utmi_link_rxerror;
wire [1:0]  utmi_link_linestate;

wire [7:0]  utmi_phy_data_out;
reg [7:0]   utmi_phy_data_in;
reg [1:0]   utmi_phy_linestate;
wire        utmi_phy_txvalid;
reg         utmi_phy_txready;
reg         utmi_phy_rxvalid;
reg         utmi_phy_rxactive;

wire [7:0]  ulpi_data_in;
wire [7:0]  ulpi_data_out;
wire        ulpi_dir;
wire        ulpi_nxt;
wire        ulpi_stp;

reg [7:0]   queue_for_link[$];
reg [7:0]   queue_for_phy[$];


//-----------------------------------------------------------------
// DUT
//-----------------------------------------------------------------
// UTMI -> ULPI
ulpi_wrapper
u_utmi_ulpi
(
    // ULPI Interface (Output)
    .ulpi_clk60_i(clk),
    .ulpi_rst_i(rst),
    .ulpi_data_i(ulpi_data_in),
    .ulpi_data_o(ulpi_data_out),
    .ulpi_dir_i(ulpi_dir),
    .ulpi_nxt_i(ulpi_nxt),
    .ulpi_stp_o(ulpi_stp),

    // UTMI Control Pins
    .utmi_xcvrselect_i(2'b11),
    .utmi_termselect_i(1'b0),
    .utmi_opmode_i(2'b0),
    .utmi_dppulldown_i(1'b0),
    .utmi_dmpulldown_i(1'b0),

    // UTMI Interface
    .utmi_data_i(utmi_link_data_in),
    .utmi_txvalid_i(utmi_link_txvalid),
    .utmi_txready_o(utmi_link_txready),
    .utmi_data_o(utmi_link_data_out),
    .utmi_rxvalid_o(utmi_link_rxvalid),
    .utmi_rxactive_o(utmi_link_rxactive),
    .utmi_rxerror_o(utmi_link_rxerror),
    .utmi_linestate_o(utmi_link_linestate)
);

//-----------------------------------------------------------------
// TB Components
//-----------------------------------------------------------------
// ULPI -> UTMI
ulpi_utmi
u_ulpi_utmi
(
    .clk_i(clk),
    .rst_i(rst),

    // ULPI Interface (Input)
    .ulpi_data_i(ulpi_data_out),
    .ulpi_data_o(ulpi_data_in),
    .ulpi_dir_o(ulpi_dir),
    .ulpi_nxt_o(ulpi_nxt),
    .ulpi_stp_i(ulpi_stp),

    // UTMI Interface (Output)
    .utmi_data_o(utmi_phy_data_out),
    .utmi_txvalid_o(utmi_phy_txvalid),
    .utmi_txready_i(utmi_phy_txready),
    .utmi_data_i(utmi_phy_data_in),
    .utmi_rxvalid_i(utmi_phy_rxvalid),
    .utmi_rxactive_i(utmi_phy_rxactive),
    .utmi_rxerror_i(1'b0),
    .utmi_linestate_i(utmi_phy_linestate),

    // UTMI Control Pins
    .utmi_reset_o(),
    .utmi_xcvrselect_o(),
    .utmi_termselect_o(),
    .utmi_opmode_o()
);

//-----------------------------------------------------------------
// Master selector
//-----------------------------------------------------------------
integer master_sel;
reg new_master_sel;

reg switch_pending;

always @(posedge clk or posedge rst)
begin
    if (rst)
    begin
        master_sel      <= 0;
        new_master_sel  <= 1'b1;
        switch_pending  <= 1'b0;
    end
    else
    begin
        if (switch_pending)
        begin
            if (!utmi_phy_rxactive && !utmi_phy_txvalid &&
                !utmi_link_rxactive && !utmi_link_txvalid &&
                queue_for_link.size() == 0 && queue_for_phy.size() == 0)
            begin
                master_sel      <= !master_sel;
                switch_pending  <= 1'b0;
            end
        end
        else if ($urandom_range(1000,0) == 0)
        begin
            switch_pending  <= 1'b1;
        end
    end
end

//-----------------------------------------------------------------
// LINK: Traffic generator
//-----------------------------------------------------------------
always @(posedge clk or posedge rst)
begin
    if (rst)
    begin
        utmi_link_data_in  <= 8'h00;
        utmi_link_txvalid  <= 1'b0;
    end
    else
    begin
        // LINK -> PHY
        if ($urandom_range(8,0) == 0 && ~utmi_link_txvalid && (master_sel == 0) && !switch_pending)
        begin
            reg [3:0] pid;
            pid = $urandom;
            utmi_link_data_in[7:4]  <= ~pid;
            utmi_link_data_in[3:0]  <= pid;
            utmi_link_txvalid       <= 1'b1;
        end
        else if (utmi_link_txvalid && utmi_link_txready)
        begin
            // End of packet
            if ($urandom_range(8,0) == 0)
            begin
                utmi_link_txvalid <= 1'b0;
            end
            // Next data byte in packet
            else if (!switch_pending)
            begin
                utmi_link_data_in  <= $urandom_range(255,0);
                utmi_link_txvalid <= 1'b1;
            end
            else
            begin
                utmi_link_txvalid <= 1'b0;
            end
        end
    end
end

//-----------------------------------------------------------------
// PHY: Traffic generator
//-----------------------------------------------------------------
reg utmi_phy_rxactive_d;
integer phy_backoff;

always @(posedge clk or posedge rst)
begin
    if (rst)
    begin
        utmi_phy_data_in   <= 8'h00;
        utmi_phy_rxactive  <= 1'b0;
        utmi_phy_rxvalid   <= 1'b0;
        utmi_phy_txready   <= 1'b0;
        utmi_phy_rxactive_d <= 1'b0;
        utmi_phy_linestate <= 2'b0;
        phy_backoff <= 0;
    end
    else
    begin
        utmi_phy_txready   <= $urandom;
        utmi_phy_linestate <= 2'b01;
        utmi_phy_rxactive_d <= utmi_phy_rxactive;

        // PHY -> LINK
        if ($urandom_range(8,0) == 0 && ~utmi_phy_rxactive && (master_sel == 1) && !switch_pending && phy_backoff == 0)
        begin
            utmi_phy_rxactive      <= 1'b1;
        end
        else if (utmi_phy_rxactive && utmi_phy_rxactive_d)
        begin
            utmi_phy_rxvalid       <= 1'b0;

            // End of packet
            if ($urandom_range(8,0) == 0)
            begin
                utmi_phy_rxactive   <= 1'b0;
                phy_backoff <= 8;
            end
            // Next data byte in packet
            else if (!switch_pending && $urandom_range(8,0) != 0)
            begin
                utmi_phy_data_in  <= $urandom_range(255,0);
                utmi_phy_rxvalid  <= 1'b1;
            end
        end
        else if (phy_backoff > 0)
            phy_backoff <= phy_backoff - 1;
    end
end


//-----------------------------------------------------------------
// LINK: Checker
//-----------------------------------------------------------------
always @(posedge clk)
begin
    if (!rst)
    begin
        if (utmi_link_txvalid && utmi_link_txready)
        begin
            queue_for_phy.push_back(utmi_link_data_in);
        end

        if (utmi_link_rxvalid && utmi_link_rxactive)
        begin
            reg [7:0] head;

            `ASSERT(queue_for_link.size() > 0);

            head = queue_for_link.pop_front();
            `ASSERT(head === utmi_link_data_out);
        end
    end
end

//-----------------------------------------------------------------
// PHY: Checker
//-----------------------------------------------------------------
always @(posedge clk)
begin
    if (!rst)
    begin
        if (utmi_phy_rxactive && utmi_phy_rxvalid)
        begin
            queue_for_link.push_back(utmi_phy_data_in);
        end

        if (utmi_phy_txvalid && utmi_phy_txready)
        begin
            reg [7:0] head;

            `ASSERT(queue_for_phy.size() > 0);

            head = queue_for_phy.pop_front();
            `ASSERT(head === utmi_phy_data_out);
        end
    end
end

`TB_TIMEOUT(clk, rst, !utmi_link_rxvalid && !utmi_phy_rxvalid, 10000);

endmodule
