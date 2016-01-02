//-----------------------------------------------------------------
// Module
//-----------------------------------------------------------------
module ulpi_utmi 
(
    input           clk_i, 
    input           rst_i, 

    // ULPI Interface (Input)
    input  [7:0]    ulpi_data_i,
    output [7:0]    ulpi_data_o,
    output          ulpi_dir_o,
    output          ulpi_nxt_o,
    input           ulpi_stp_i,

    // UTMI Interface
    output [7:0]    utmi_data_o,
    output          utmi_txvalid_o,
    input           utmi_txready_i,
    input [7:0]     utmi_data_i,
    input           utmi_rxvalid_i,
    input           utmi_rxactive_i,
    input           utmi_rxerror_i,

    input [1:0]     utmi_linestate_i,

    output          utmi_reset_o,
    output [1:0]    utmi_xcvrselect_o,
    output          utmi_termselect_o,
    output [1:0]    utmi_opmode_o
);

//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
parameter ULPI_VID              = 16'h0424;
parameter ULPI_PID              = 16'h0004;
parameter ULPI_FUNC_CTRL_DEF    = 8'h41;

//-----------------------------------------------------------------
// Register Map
//-----------------------------------------------------------------
localparam ULPI_REG_VID_L       = 6'h00;
localparam ULPI_REG_VID_H       = 6'h01;
localparam ULPI_REG_PID_L       = 6'h02;
localparam ULPI_REG_PID_H       = 6'h03;
localparam ULPI_REG_FUNC_CTRL   = 6'h04;
localparam ULPI_REG_DEBUG       = 6'h15;
localparam ULPI_REG_SCRATCH     = 6'h16;

//-----------------------------------------------------------------
// Registers / Wires
//-----------------------------------------------------------------

// SM states
localparam STATE_W           = 4;
localparam STATE_IDLE        = 4'd0;
localparam STATE_RXCMD       = 4'd1;
localparam STATE_RXDATA      = 4'd2;
localparam STATE_TXCMD       = 4'd3;
localparam STATE_TXDATA      = 4'd4;
localparam STATE_REG_WR      = 4'd5;
localparam STATE_REG_RD      = 4'd6;

reg  [STATE_W-1:0]     state_q;
reg  [STATE_W-1:0]     next_state_r;

// Commands
localparam CMD_IDLE     = 2'b00;
localparam CMD_TX       = 2'b01;
localparam CMD_REG_WR   = 2'b10;
localparam CMD_REG_RD   = 2'b11;

reg [7:0] tx_data_q;
reg       tx_valid_q;

reg [7:0] rx_data_q;
reg       rx_valid_q;

reg [7:0] utmi_data_r;
reg       utmi_txvalid_r;

reg [1:0] linestate_q;

//-----------------------------------------------------------------
// Turnaround detection
//-----------------------------------------------------------------
reg ulpi_dir_q; 
always @ (posedge rst_i or posedge clk_i)
if (rst_i)
    ulpi_dir_q   <= 1'b0;
else
    ulpi_dir_q   <= ulpi_dir_o;

wire turnaround_w = ulpi_dir_q ^ ulpi_dir_o;

//-----------------------------------------------------------------
// Linestate change detect
//-----------------------------------------------------------------
always @ (posedge rst_i or posedge clk_i)
if (rst_i)
    linestate_q   <= 2'b0;
else if ((state_q == STATE_RXCMD) || (state_q == STATE_RXDATA && !rx_valid_q))
    linestate_q   <= utmi_linestate_i;

wire linestate_update_w = (linestate_q != utmi_linestate_i);

//-----------------------------------------------------------------
// State Machine
//-----------------------------------------------------------------
always @ *
begin
    next_state_r   = state_q;

    case (state_q)
    //-----------------------------------------
    // STATE_IDLE
    //-----------------------------------------
    STATE_IDLE :
    begin
        if (utmi_rxactive_i)
            next_state_r = STATE_RXCMD;
        else if (ulpi_data_i[7:6] == CMD_TX)
            next_state_r = STATE_TXCMD;
        else if (ulpi_data_i[7:6] == CMD_REG_WR)
            next_state_r = STATE_REG_WR;
        else if (ulpi_data_i[7:6] == CMD_REG_RD)
            next_state_r = STATE_REG_RD;
        else if (linestate_update_w)
            next_state_r = STATE_RXCMD;
    end
    //-----------------------------------------
    // STATE_REG_WR
    //-----------------------------------------
    STATE_REG_WR :
    begin
        next_state_r = STATE_IDLE;
    end
    //-----------------------------------------
    // STATE_REG_RD
    //-----------------------------------------
    STATE_REG_RD :
    begin
        next_state_r = STATE_IDLE;
    end
    //-----------------------------------------
    // STATE_RXCMD
    //-----------------------------------------
    STATE_RXCMD :
    begin
        if (!utmi_rxactive_i)
            next_state_r = STATE_IDLE;
        else    
            next_state_r = STATE_RXDATA;
    end
    //-----------------------------------------
    // STATE_RXDATA
    //-----------------------------------------
    STATE_RXDATA :
    begin
        if (!utmi_rxactive_i)
            next_state_r = STATE_RXCMD;
    end
    //-----------------------------------------
    // STATE_TXCMD
    //-----------------------------------------
    STATE_TXCMD :
    begin
        if (ulpi_nxt_o)
            next_state_r = STATE_TXDATA;
    end
    //-----------------------------------------
    // STATE_TXDATA
    //-----------------------------------------
    STATE_TXDATA :
    begin
        if (ulpi_stp_i)
            next_state_r = STATE_IDLE;
    end
    default:
        ;
    endcase
end

always @ (posedge rst_i or posedge clk_i)
if (rst_i)
    state_q   <= STATE_IDLE;
else if (!turnaround_w)
    state_q   <= next_state_r;

//-----------------------------------------------------------------
// Register Access
//-----------------------------------------------------------------
reg [5:0] reg_addr_q;
always @ (posedge rst_i or posedge clk_i)
if (rst_i)
    reg_addr_q <= 6'b0;
else if (state_q == STATE_IDLE && ulpi_data_i[7:6] == CMD_REG_WR)
    reg_addr_q <= ulpi_data_i[5:0];

wire       reg_wr_w   = (state_q == STATE_REG_WR);
wire [7:0] reg_data_w = ulpi_data_i;
reg [7:0]  reg_data_r;

//-----------------------------------------------------------------
// Register: Function Control
//-----------------------------------------------------------------
reg [7:0] func_ctrl_q;

always @ (posedge rst_i or posedge clk_i)
if (rst_i)
    func_ctrl_q <= ULPI_FUNC_CTRL_DEF;
else if (reg_wr_w && reg_addr_q == ULPI_REG_FUNC_CTRL)
    func_ctrl_q <= ulpi_data_i;
else
    func_ctrl_q <= {3'b0, func_ctrl_q[4:0]};

assign utmi_xcvrselect_o = func_ctrl_q[1:0];
assign utmi_termselect_o = func_ctrl_q[2];
assign utmi_opmode_o     = func_ctrl_q[4:3];
assign utmi_reset_o      = func_ctrl_q[5];

//-----------------------------------------------------------------
// Register: Scratch
//-----------------------------------------------------------------
reg [7:0] reg_scratch_q;

always @ (posedge rst_i or posedge clk_i)
if (rst_i)
    reg_scratch_q <= 8'b0;
else if (reg_wr_w && reg_addr_q == ULPI_REG_SCRATCH)
    reg_scratch_q <= ulpi_data_i;

//-----------------------------------------------------------------
// Register read mux
//-----------------------------------------------------------------
always @ *
begin
    reg_data_r = 8'b0;

    case (reg_addr_q)
        ULPI_REG_VID_L:     reg_data_r = ULPI_VID[7:0];
        ULPI_REG_VID_H:     reg_data_r = ULPI_VID[15:8];
        ULPI_REG_PID_L:     reg_data_r = ULPI_PID[7:0];
        ULPI_REG_PID_H:     reg_data_r = ULPI_PID[15:8];
        ULPI_REG_FUNC_CTRL: reg_data_r = func_ctrl_q;
        ULPI_REG_DEBUG:     reg_data_r = {6'b0, utmi_linestate_i};
        ULPI_REG_SCRATCH:   reg_data_r = reg_scratch_q;
        default:            reg_data_r = 8'b0;
    endcase
end

//-----------------------------------------------------------------
// Receive Buffer
//-----------------------------------------------------------------
always @ (posedge rst_i or posedge clk_i)
if (rst_i)
begin
    rx_data_q  <= 8'b0;
    rx_valid_q <= 1'b0;
end
else if (utmi_rxactive_i && utmi_rxvalid_i)
begin
    rx_data_q  <= utmi_data_i;
    rx_valid_q <= 1'b1;
end
else
    rx_valid_q <= 1'b0;

//-----------------------------------------------------------------
// Output Mux
//-----------------------------------------------------------------
reg [7:0] ulpi_data_r;
reg       ulpi_dir_r;
reg       ulpi_nxt_r;

always @ *
begin
    ulpi_data_r = 8'b0;
    ulpi_dir_r  = 1'b0;
    ulpi_nxt_r  = 1'b0;

    case (state_q)
    //-----------------------------------------
    // STATE_IDLE
    //-----------------------------------------
    STATE_IDLE :
    begin
        if (utmi_rxactive_i)
        begin
            ulpi_dir_r  = 1'b0;
            ulpi_nxt_r  = 1'b0;
        end
        else if (ulpi_data_i[7:6] == CMD_TX)
        begin
            ulpi_dir_r  = 1'b0;
            ulpi_nxt_r  = 1'b0;
        end
        else if (ulpi_data_i[7:6] == CMD_REG_WR)
        begin
            ulpi_dir_r  = 1'b0;
            ulpi_nxt_r  = 1'b1;
        end
    end
    STATE_RXCMD:
    begin
        ulpi_dir_r  = 1'b1;
        ulpi_data_r[1:0] = utmi_linestate_i;
        case ({utmi_rxactive_i, utmi_rxerror_i})
            2'b00:   ulpi_data_r[5:4] = 2'b00;
            2'b10:   ulpi_data_r[5:4] = 2'b01;
            2'b11:   ulpi_data_r[5:4] = 2'b11;
            default: ulpi_data_r[5:4] = 2'b00;
        endcase

        ulpi_nxt_r = 1'b0;
    end
    STATE_REG_WR:
    begin
        ulpi_dir_r  = 1'b0;
        ulpi_nxt_r  = 1'b1;
    end
    STATE_REG_RD:
    begin
        ulpi_dir_r  = 1'b1;
        ulpi_nxt_r  = 1'b0;
        ulpi_data_r = reg_data_r;
    end
    STATE_TXCMD:
    begin
        ulpi_dir_r  = 1'b0;
        ulpi_nxt_r  = /*!turnaround_w && */utmi_txready_i;
    end
    STATE_TXDATA:
    begin
        ulpi_dir_r  = 1'b0;
        ulpi_nxt_r  = utmi_txready_i;    
    end
    STATE_RXDATA:
    begin
        if (rx_valid_q)
        begin
            ulpi_dir_r  = 1'b1;
            ulpi_data_r = rx_data_q;
            ulpi_nxt_r  = 1'b1;
        end
        else
        begin
            ulpi_dir_r  = 1'b1;
            ulpi_data_r[1:0] = utmi_linestate_i;
            case ({utmi_rxactive_i, utmi_rxerror_i})
                2'b00:   ulpi_data_r[5:4] = 2'b00;
                2'b10:   ulpi_data_r[5:4] = 2'b01;
                2'b11:   ulpi_data_r[5:4] = 2'b11;
                default: ulpi_data_r[5:4] = 2'b00;
            endcase

            ulpi_nxt_r = 1'b0;
        end
    end
    default:
        ;
    endcase
end

assign ulpi_data_o = ulpi_data_r;
assign ulpi_dir_o  = ulpi_dir_r;
assign ulpi_nxt_o  = ulpi_nxt_r;

//-----------------------------------------------------------------
// UTMI Output
//-----------------------------------------------------------------
always @ *
begin
    utmi_data_r     = 8'b0;
    utmi_txvalid_r  = 1'b0;

    case (state_q)
    STATE_TXCMD:
    begin
        utmi_data_r    = {~ulpi_data_i[3:0], ulpi_data_i[3:0]};
        utmi_txvalid_r = !turnaround_w;
    end
    STATE_TXDATA:
    begin
        utmi_data_r    = ulpi_data_i;
        utmi_txvalid_r = !ulpi_stp_i;
    end
    default:
        ;
    endcase
end

assign utmi_data_o    = utmi_data_r;
assign utmi_txvalid_o = utmi_txvalid_r;

endmodule
