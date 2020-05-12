//-----------------------------------------------------------------
// Module - USB Sniffer Block
//-----------------------------------------------------------------
module usb_sniffer
(
    // General - 60MHz clock and async reset (active high)
    input           clk_i,
    input           rst_i,

    // Peripheral Interface
    input  [7:0]    addr_i,
    input  [31:0]   data_i,
    output [31:0]   data_o,
    input           we_i,
    input           stb_i,
    output          ack_o,

    // UTMI interface
    input [7:0]     utmi_data_i,
    input           utmi_rxvalid_i,
    input           utmi_rxactive_i,
    input           utmi_rxerror_i,
    input [1:0]     utmi_linestate_i,
    output [1:0]    utmi_op_mode_o,
    output [1:0]    utmi_xcvrselect_o,
    output          utmi_termselect_o,
    output          utmi_dppulldown_o,
    output          utmi_dmpulldown_o,

    // Wishbone (Master - Write Only)
    output [31:0]   mem_addr_o,
    output [3:0]    mem_sel_o,
    output [31:0]   mem_data_o,
    output          mem_stb_o,
    output          mem_we_o,
    input           mem_stall_i,
    input           mem_ack_i
);

//-----------------------------------------------------------------
// Log word format
//-----------------------------------------------------------------
// TYPE = LOG_CTRL_TYPE_SOF/RST
`define LOG_SOF_FRAME_W         11
`define LOG_SOF_FRAME_L         0
`define LOG_SOF_FRAME_H         (`LOG_SOF_FRAME_L + `LOG_SOF_FRAME_W - 1)
`define LOG_RST_STATE_W         1
`define LOG_RST_STATE_L         (`LOG_SOF_FRAME_H + 1)
`define LOG_RST_STATE_H         (`LOG_RST_STATE_L + `LOG_RST_STATE_W - 1)

// TYPE = LOG_CTRL_TYPE_TOKEN | LOG_CTRL_TYPE_HSHAKE | LOG_CTRL_TYPE_DATA
`define LOG_TOKEN_PID_W         4
`define LOG_TOKEN_PID_L         0
`define LOG_TOKEN_PID_H         (`LOG_TOKEN_PID_L + `LOG_TOKEN_PID_W - 1)

// TYPE = LOG_CTRL_TYPE_TOKEN
`define LOG_TOKEN_DATA_W        16
`define LOG_TOKEN_DATA_L        (`LOG_TOKEN_PID_H + 1)
`define LOG_TOKEN_DATA_H        (`LOG_TOKEN_DATA_L + `LOG_TOKEN_DATA_W - 1)

// TYPE = LOG_CTRL_TYPE_DATA
`define LOG_DATA_LEN_W          16
`define LOG_DATA_LEN_L          (`LOG_TOKEN_PID_H + 1)
`define LOG_DATA_LEN_H          (`LOG_DATA_LEN_L + `LOG_DATA_LEN_W - 1)

// TYPE = LOG_CTRL_TYPE_TOKEN | LOG_CTRL_TYPE_HSHAKE | LOG_CTRL_TYPE_DATA | LOG_CTRL_TYPE_SOF
`define LOG_CTRL_CYCLE_W        8
`define LOG_CTRL_CYCLE_L        20
`define LOG_CTRL_CYCLE_H        (`LOG_CTRL_CYCLE_L + `LOG_CTRL_CYCLE_W - 1)

`define LOG_CTRL_TYPE_W          4
`define LOG_CTRL_TYPE_L          28
`define LOG_CTRL_TYPE_H          31
`define LOG_CTRL_TYPE_SOF        4'd1
`define LOG_CTRL_TYPE_RST        4'd2
`define LOG_CTRL_TYPE_TOKEN      4'd3
`define LOG_CTRL_TYPE_HSHAKE     4'd4
`define LOG_CTRL_TYPE_DATA       4'd5

//-----------------------------------------------------------------
// USB PID tokens
//-----------------------------------------------------------------
// Tokens
`define PID_OUT                  8'hE1
`define PID_IN                   8'h69
`define PID_SOF                  8'hA5
`define PID_SETUP                8'h2D

// Data
`define PID_DATA0                8'hC3
`define PID_DATA1                8'h4B
`define PID_DATA2                8'h87
`define PID_MDATA                8'h0F

// Handshake
`define PID_ACK                  8'hD2
`define PID_NAK                  8'h5A
`define PID_STALL                8'h1E
`define PID_NYET                 8'h96

// Special
`define PID_PRE                  8'h3C
`define PID_ERR                  8'h3C
`define PID_SPLIT                8'h78
`define PID_PING                 8'hB4

//-----------------------------------------------------------------
// Registers / Writes
//-----------------------------------------------------------------
wire [31:0] buffer_base_w;
wire [31:0] buffer_end_w;
wire [31:0] buffer_curr_w;
wire [31:0] buffer_read_w;
wire        buffer_full_w;
wire        cfg_ignore_sof_w;
wire        cfg_cont_w;
wire        cfg_enabled_w;
wire        cfg_match_dev_w;
wire        cfg_match_ep_w;
wire        cfg_exclude_dev_w;
wire        cfg_exclude_ep_w;
wire [6:0]  cfg_dev_w;
wire [3:0]  cfg_ep_w;
wire [1:0]  cfg_speed_w;
wire        sts_triggered_w;
wire        sts_wrapped_w;
wire        sts_mem_stall_w;
wire        sts_overflow_w;

wire        rst_change_w;
wire        usb_rst_w;

wire [6:0]  current_dev_w;
wire [3:0]  current_ep_w;

//-----------------------------------------------------------------
// Register Interface
//-----------------------------------------------------------------
usb_sniffer_regs
u_regs
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    // Config
    .usb_buffer_base_addr_o(buffer_base_w),
    .usb_buffer_end_addr_o(buffer_end_w),
    .usb_buffer_cfg_ignore_sof_o(cfg_ignore_sof_w),
    .usb_buffer_cfg_cont_o(cfg_cont_w),
    .usb_buffer_cfg_enabled_o(cfg_enabled_w),
    .usb_buffer_cfg_dev_o(cfg_dev_w),
    .usb_buffer_cfg_ep_o(cfg_ep_w),
    .usb_buffer_cfg_match_dev_o(cfg_match_dev_w),
    .usb_buffer_cfg_match_ep_o(cfg_match_ep_w),
    .usb_buffer_cfg_exclude_dev_o(cfg_exclude_dev_w),
    .usb_buffer_cfg_exclude_ep_o(cfg_exclude_ep_w),
    .usb_buffer_cfg_speed_o(cfg_speed_w),

    // Status
    .usb_buffer_sts_trig_i(sts_triggered_w),
    .usb_buffer_sts_wrapped_i(sts_wrapped_w),
    .usb_buffer_current_addr_i(buffer_curr_w),
    .usb_buffer_sts_mem_stall_i(sts_mem_stall_w),
    .usb_buffer_read_addr_o(buffer_read_w),
    .usb_buffer_sts_overflow_i(sts_overflow_w),

    // Wishbone interface (classic mode, synchronous slave)
    .addr_i(addr_i),
    .data_i(data_i),
    .data_o(data_o),
    .we_i(we_i),
    .stb_i(stb_i),
    .ack_o(ack_o)
);

//-----------------------------------------------------------------
// USB Speed Select
//-----------------------------------------------------------------
`define USB_SPEED_HS   2'b00
`define USB_SPEED_FS   2'b01
`define USB_SPEED_LS   2'b10

reg [1:0] xcvrselect_r;
reg       termselect_r;
reg [1:0] op_mode_r;
reg       dppulldown_r;
reg       dmpulldown_r;

always @ *
begin
    xcvrselect_r = 2'b00;
    termselect_r = 1'b0;
    op_mode_r    = 2'b01;
    dppulldown_r = 1'b1;
    dmpulldown_r = 1'b1;

    case (cfg_speed_w)
    `USB_SPEED_HS:
    begin
        xcvrselect_r = 2'b00;
        termselect_r = 1'b0;
        op_mode_r    = 2'b01;
        dppulldown_r = 1'b1;
        dmpulldown_r = 1'b1;
    end
    `USB_SPEED_FS:
    begin
        xcvrselect_r = 2'b01;
        termselect_r = 1'b0;
        op_mode_r    = 2'b01;
        dppulldown_r = 1'b1;
        dmpulldown_r = 1'b1;
    end
    `USB_SPEED_LS:
    begin
        xcvrselect_r = 2'b10;
        termselect_r = 1'b0;
        op_mode_r    = 2'b01;
        dppulldown_r = 1'b1;
        dmpulldown_r = 1'b1;
    end    
    default :
        ;
    endcase
end

assign utmi_op_mode_o    = op_mode_r;
assign utmi_xcvrselect_o = xcvrselect_r;
assign utmi_termselect_o = termselect_r;
assign utmi_dppulldown_o = dppulldown_r;
assign utmi_dmpulldown_o = dmpulldown_r;

//-----------------------------------------------------------------
// Device / Endpoint filtering
//-----------------------------------------------------------------
reg dev_match_r;
reg ep_match_r;

always @ *
begin
    if (cfg_match_dev_w)
        dev_match_r = (current_dev_w == cfg_dev_w);
    else if (cfg_exclude_dev_w)
        dev_match_r = (current_dev_w != cfg_dev_w);
    else
        dev_match_r = 1'b1;

    if (cfg_match_ep_w)
        ep_match_r = (current_ep_w == cfg_ep_w);
    else if (cfg_exclude_ep_w)
        ep_match_r = (current_ep_w != cfg_ep_w);
    else
        ep_match_r = 1'b1;
end

wire dev_match_w = dev_match_r;
wire ep_match_w  = ep_match_r;

//-----------------------------------------------------------------
// Start / End of packet detection
//-----------------------------------------------------------------
reg active_q;

always @ (posedge rst_i or posedge clk_i)
if (rst_i)
    active_q <= 1'b0;
// IDLE
else if (!active_q)
begin 
    // Rx data
    if (utmi_rxvalid_i && utmi_rxactive_i && cfg_enabled_w)
        active_q <= 1'b1;
end
// ACTIVE
else
begin
    // End of packet
    if (!utmi_rxactive_i)
        active_q <= 1'b0;
end

wire sample_byte_w  = utmi_rxvalid_i && utmi_rxactive_i;
wire start_packet_w = !active_q && sample_byte_w && cfg_enabled_w;
wire end_packet_w   = active_q  && !utmi_rxactive_i;

//-----------------------------------------------------------------
// State machine
//-----------------------------------------------------------------
`define STATE_W  4

// Current state
localparam STATE_RX_IDLE                 = 4'd0;
localparam STATE_RX_TOKEN2               = 4'd1;
localparam STATE_RX_TOKEN3               = 4'd2;
localparam STATE_RX_TOKEN_COMPLETE       = 4'd3;
localparam STATE_RX_SOF2                 = 4'd4;
localparam STATE_RX_SOF3                 = 4'd5;
localparam STATE_RX_SOF_COMPLETE         = 4'd6;
localparam STATE_RX_DATA                 = 4'd7;
localparam STATE_RX_DATA_COMPLETE        = 4'd8;
localparam STATE_RX_HSHAKE_COMPLETE      = 4'd9;
localparam STATE_RX_DATA_IGNORE          = 4'd10;
localparam STATE_UPDATE_RST              = 4'd11;

reg [`STATE_W-1:0] state_q;
reg [`STATE_W-1:0] next_state_r;

always @ *
begin
    next_state_r = state_q;

    //-----------------------------------------
    // State Machine
    //-----------------------------------------
    case (state_q)

    //-----------------------------------------
    // IDLE
    //-----------------------------------------
    STATE_RX_IDLE :
    begin
        if (start_packet_w)
        begin
            // Decode PID
            case (utmi_data_i)

            // Token
            `PID_OUT, `PID_IN, `PID_SETUP, `PID_PING:
                next_state_r  = STATE_RX_TOKEN2;

            // Token: SOF
            `PID_SOF:
                next_state_r  = STATE_RX_SOF2;

            // Data
            `PID_DATA0, `PID_DATA1, `PID_DATA2, `PID_MDATA:
            begin
                if (dev_match_w && ep_match_w)
                    next_state_r  = STATE_RX_DATA;
                else
                    next_state_r  = STATE_RX_DATA_IGNORE;
            end

            // Handshake
            `PID_ACK, `PID_NAK, `PID_STALL, `PID_NYET:
            begin
                if (dev_match_w && ep_match_w)
                    next_state_r  = STATE_RX_HSHAKE_COMPLETE;
                else            
                    next_state_r  = STATE_RX_DATA_IGNORE;
            end

            // Special - currently ignored
            `PID_PRE, `PID_SPLIT:
            begin
                next_state_r  = STATE_RX_DATA_IGNORE;
            end            

            default :
                ;
            endcase

            // Buffer full and not set continuous mode? Drop data
            if (buffer_full_w)
                next_state_r  = STATE_RX_DATA_IGNORE;
        end
        // Reset state change, record status
        else if (rst_change_w && !buffer_full_w && cfg_enabled_w)
            next_state_r  = STATE_UPDATE_RST;
    end

    //-----------------------------------------
    // SOF (BYTE 2)
    //-----------------------------------------
    STATE_RX_SOF2 :
    begin
        if (sample_byte_w)
            next_state_r = STATE_RX_SOF3;
        else if (!utmi_rxactive_i)
            next_state_r = STATE_RX_IDLE;
    end

    //-----------------------------------------
    // SOF (BYTE 3)
    //-----------------------------------------
    STATE_RX_SOF3 :
    begin
        if (sample_byte_w)
            next_state_r = STATE_RX_SOF_COMPLETE;
        else if (!utmi_rxactive_i)
            next_state_r = STATE_RX_IDLE;
    end

    //-----------------------------------------
    // TOKEN (BYTE 2)
    //-----------------------------------------
    STATE_RX_TOKEN2 :
    begin
        if (sample_byte_w)
            next_state_r = STATE_RX_TOKEN3;
        else if (!utmi_rxactive_i)
            next_state_r = STATE_RX_IDLE;
    end

    //-----------------------------------------
    // TOKEN (BYTE 3)
    //-----------------------------------------
    STATE_RX_TOKEN3 :
    begin
        if (sample_byte_w)
            next_state_r = STATE_RX_TOKEN_COMPLETE;
        else if (!utmi_rxactive_i)
            next_state_r = STATE_RX_IDLE;
    end

    //-----------------------------------------
    // RX_DATA
    //-----------------------------------------
    STATE_RX_DATA :
    begin
        // Buffer overflow
        if (buffer_full_w)
            next_state_r = STATE_RX_DATA_IGNORE;
        // Receive complete
        else if (!utmi_rxactive_i)
            next_state_r = STATE_RX_DATA_COMPLETE;
    end

    //-----------------------------------------
    // *_COMPLETE
    //-----------------------------------------
    STATE_RX_DATA_COMPLETE,
    STATE_RX_TOKEN_COMPLETE,
    STATE_RX_HSHAKE_COMPLETE,
    STATE_RX_SOF_COMPLETE :
    begin
        next_state_r  = STATE_RX_IDLE;
    end

    //-----------------------------------------
    // RX_DATA_IGNORE
    //-----------------------------------------
    STATE_RX_DATA_IGNORE :
    begin
        // Receive complete
        if (!utmi_rxactive_i)
            next_state_r = STATE_RX_IDLE;
    end

    //-----------------------------------------
    // UPDATE_RST
    //-----------------------------------------
    STATE_UPDATE_RST :
    begin
        next_state_r = STATE_RX_IDLE;
    end

    default :
       ;

    endcase
end

// Update state
always @ (posedge rst_i or posedge clk_i)
if (rst_i)
    state_q <= STATE_RX_IDLE;
else
    state_q <= next_state_r;

//-----------------------------------------------------------------
// USB Reset Condition
//-----------------------------------------------------------------
reg [14:0] se0_cnt_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    se0_cnt_q <= 15'b0;
else if (utmi_linestate_i == 2'b0)
begin
    if (!se0_cnt_q[14])
        se0_cnt_q <= se0_cnt_q + 15'd1;
end    
else
    se0_cnt_q <= 15'b0;

assign usb_rst_w = se0_cnt_q[14];

reg usb_rst_q;
always @ (posedge rst_i or posedge clk_i)
if (rst_i)
    usb_rst_q <= 1'b0;
else if (state_q == STATE_RX_IDLE && !start_packet_w)
    usb_rst_q <= usb_rst_w;

assign rst_change_w = usb_rst_q ^ usb_rst_w;

//-----------------------------------------------------------------
// Capture PID
//-----------------------------------------------------------------
reg [7:0] pid_q;

always @ (posedge rst_i or posedge clk_i)
if (rst_i)
    pid_q <= 8'b0;
else if (state_q == STATE_RX_IDLE && sample_byte_w)
    pid_q <= utmi_data_i;
else if (state_q == STATE_RX_IDLE)
    pid_q <= 8'b0;

//-----------------------------------------------------------------
// SOF Frame Number
//-----------------------------------------------------------------
reg [10:0] frame_number_q;

always @ (posedge rst_i or posedge clk_i)
if (rst_i)
    frame_number_q          <= 11'b0;
else if (state_q == STATE_RX_SOF2 && sample_byte_w)
    frame_number_q[7:0]     <= utmi_data_i;
else if (state_q == STATE_RX_SOF3 && sample_byte_w)
    frame_number_q[10:8]    <= utmi_data_i[2:0];

//-----------------------------------------------------------------
// Token data
//-----------------------------------------------------------------
reg [15:0] token_data_q;

always @ (posedge rst_i or posedge clk_i)
if (rst_i)
    token_data_q        <= 16'b0;
else if (state_q == STATE_RX_TOKEN2 && sample_byte_w)
    token_data_q[7:0]   <= utmi_data_i;
else if (state_q == STATE_RX_TOKEN3 && sample_byte_w)
    token_data_q[15:8]  <= utmi_data_i;    

assign current_dev_w = token_data_q[6:0];
assign current_ep_w  = token_data_q[10:7];

//-----------------------------------------------------------------
// Data Counter
//-----------------------------------------------------------------
reg [15:0] data_count_q;

always @ (posedge rst_i or posedge clk_i)
if (rst_i)
    data_count_q <= 16'b0;
else if (state_q == STATE_RX_IDLE)
    data_count_q <= 16'b0;
else if (state_q == STATE_RX_DATA && sample_byte_w)
    data_count_q <= data_count_q + 16'd1;

//-----------------------------------------------------------------
// Buffer write word
//-----------------------------------------------------------------
reg [31:0] buffer_q;
reg        buffer_wr_q;

reg [31:0] buffer_r;
reg        buffer_wr_r;

reg [15:0] cycle_q;

always @ *
begin
    buffer_r    = 32'b0;
    buffer_wr_r = 1'b0;

    // Logging SOFs?
    if (state_q == STATE_RX_SOF_COMPLETE && !cfg_ignore_sof_w)
    begin
        buffer_r[`LOG_SOF_FRAME_H:`LOG_SOF_FRAME_L]   = frame_number_q;
        buffer_r[`LOG_CTRL_CYCLE_H:`LOG_CTRL_CYCLE_L] = cycle_q[15:8];
        buffer_r[`LOG_CTRL_TYPE_H:`LOG_CTRL_TYPE_L]   = `LOG_CTRL_TYPE_SOF;
        buffer_wr_r = 1'b1;
    end
    // Token
    else if (state_q == STATE_RX_TOKEN_COMPLETE)
    begin
        buffer_r[`LOG_TOKEN_PID_H:`LOG_TOKEN_PID_L]   = pid_q[3:0];
        buffer_r[`LOG_CTRL_CYCLE_H:`LOG_CTRL_CYCLE_L] = cycle_q[15:8];
        buffer_r[`LOG_TOKEN_DATA_H:`LOG_TOKEN_DATA_L] = token_data_q;
        buffer_r[`LOG_CTRL_TYPE_H:`LOG_CTRL_TYPE_L]   = `LOG_CTRL_TYPE_TOKEN;
        buffer_wr_r = dev_match_w && ep_match_w;
    end
    // Handshake
    else if (state_q == STATE_RX_HSHAKE_COMPLETE)
    begin
        buffer_r[`LOG_TOKEN_PID_H:`LOG_TOKEN_PID_L]   = pid_q[3:0];
        buffer_r[`LOG_CTRL_CYCLE_H:`LOG_CTRL_CYCLE_L] = cycle_q[15:8];
        buffer_r[`LOG_CTRL_TYPE_H:`LOG_CTRL_TYPE_L]   = `LOG_CTRL_TYPE_HSHAKE;
        buffer_wr_r = 1'b1;
    end
    // Reset event
    else if (state_q == STATE_UPDATE_RST)
    begin
        buffer_r[`LOG_SOF_FRAME_H:`LOG_SOF_FRAME_L] = frame_number_q;
        buffer_r[`LOG_CTRL_CYCLE_H:`LOG_CTRL_CYCLE_L] = cycle_q[15:8];
        buffer_r[`LOG_RST_STATE_H:`LOG_RST_STATE_L] = usb_rst_q;
        buffer_r[`LOG_CTRL_TYPE_H:`LOG_CTRL_TYPE_L] = `LOG_CTRL_TYPE_RST;
        buffer_wr_r = 1'b1;
    end
    // End of data transfer
    else if (state_q == STATE_RX_DATA_COMPLETE)
    begin
        buffer_r[`LOG_TOKEN_PID_H:`LOG_TOKEN_PID_L]   = pid_q[3:0];
        buffer_r[`LOG_CTRL_CYCLE_H:`LOG_CTRL_CYCLE_L] = cycle_q[15:8];
        buffer_r[`LOG_DATA_LEN_H:`LOG_DATA_LEN_L]     = data_count_q;
        buffer_r[`LOG_CTRL_TYPE_H:`LOG_CTRL_TYPE_L]   = `LOG_CTRL_TYPE_DATA;
        buffer_wr_r = 1'b1;
    end
    // Receiving data
    else if (state_q == STATE_RX_DATA)
    begin
        // Capture new data, building up a word
        if (sample_byte_w)
        begin
            case (data_count_q[1:0])
                2'd0: buffer_r = {24'b0, utmi_data_i};
                2'd1: buffer_r = {16'b0, utmi_data_i, buffer_q[7:0]};
                2'd2: buffer_r = {8'b0, utmi_data_i, buffer_q[15:0]};
                2'd3: buffer_r = {utmi_data_i, buffer_q[23:0]};
            endcase
        end
        // Hold current
        else
            buffer_r = buffer_q;

        // Every 4 bytes, or the last byte
        buffer_wr_r = (sample_byte_w && (data_count_q[1:0] == 2'd3)) || 
                      (!utmi_rxactive_i && data_count_q[1:0] != 2'd0);
    end
end

always @ (posedge rst_i or posedge clk_i)
if (rst_i)
    buffer_q <= 32'b0;
else if (!buffer_wr_q || !mem_stall_i)
    buffer_q <= buffer_r;

always @ (posedge rst_i or posedge clk_i)
if (rst_i)
    buffer_wr_q <= 1'b0;
else if (!buffer_wr_q || !mem_stall_i)
    buffer_wr_q <= buffer_wr_r;

//-----------------------------------------------------------------
// Cycle Counter: Delta ticks since last log entry
//-----------------------------------------------------------------
always @ (posedge rst_i or posedge clk_i)
if (rst_i)
    cycle_q <= 16'b0;
// Reset cycle counter on header write
else if (buffer_wr_r && (state_q != STATE_RX_DATA))
    cycle_q <= 16'b0;
else if (cycle_q != 16'hFFFF)
    cycle_q <= cycle_q + 16'd1;

//-----------------------------------------------------------------
// Enable Reset
//-----------------------------------------------------------------
reg cfg_enabled_q;

always @ (posedge rst_i or posedge clk_i)
if (rst_i)
    cfg_enabled_q <= 1'b0;
else
    cfg_enabled_q <= cfg_enabled_w;

wire cfg_enable_reset_w = !cfg_enabled_q & cfg_enabled_w;

//-----------------------------------------------------------------
// Next Address
//-----------------------------------------------------------------
reg [31:0] next_addr_q;
reg        buffer_full_q;

always @ (posedge rst_i or posedge clk_i)
if (rst_i)
    buffer_full_q <= 1'b0;
else
    buffer_full_q <= buffer_full_w;

wire buffer_full_clr_w = buffer_full_q & !buffer_full_w;

always @ (posedge rst_i or posedge clk_i)
if (rst_i) 
    next_addr_q <= 32'b0;
else if (cfg_enable_reset_w)
    next_addr_q <= buffer_base_w + 32'd4;
else if ((buffer_wr_q && !mem_stall_i && !buffer_full_w) || buffer_full_clr_w)
begin
    if (next_addr_q == buffer_end_w)
        next_addr_q <= buffer_base_w;
    else
        next_addr_q <= next_addr_q + 32'd4;
end

//-----------------------------------------------------------------
// Write Address
//-----------------------------------------------------------------
reg [31:0] write_addr_q;

always @ (posedge rst_i or posedge clk_i)
if (rst_i) 
    write_addr_q <= 32'b0;
else if (cfg_enable_reset_w)
    write_addr_q <= buffer_base_w;
else if (buffer_wr_q && !mem_stall_i)
    write_addr_q <= next_addr_q;

//-----------------------------------------------------------------
// Current Address: Record last ctrl log entry (not data words)
//-----------------------------------------------------------------
reg [31:0] buff_curr_addr_q;

always @ (posedge rst_i or posedge clk_i)
if (rst_i) 
    buff_curr_addr_q <= 32'b0;
else if (cfg_enable_reset_w)
    buff_curr_addr_q <= buffer_base_w;
// Control word writes actually occur in IDLE...
else if ((state_q == STATE_RX_IDLE) && buffer_wr_q)
    buff_curr_addr_q <= write_addr_q;

assign buffer_curr_w = buff_curr_addr_q;

//-----------------------------------------------------------------
// Wrap detection
//-----------------------------------------------------------------
reg wrap_detect_q;

always @ (posedge rst_i or posedge clk_i)
if (rst_i) 
    wrap_detect_q <= 1'b0;
else if (cfg_enable_reset_w)
    wrap_detect_q <= 1'b0;
else if (buffer_wr_q && write_addr_q == buffer_end_w)
    wrap_detect_q <= 1'b1;

assign sts_wrapped_w = wrap_detect_q;

//-----------------------------------------------------------------
// Write detection
//-----------------------------------------------------------------
reg write_detect_q;

always @ (posedge rst_i or posedge clk_i)
if (rst_i) 
    write_detect_q <= 1'b0;
else if (cfg_enable_reset_w)
    write_detect_q <= 1'b0;
else if (mem_stb_o && !mem_stall_i)
    write_detect_q <= 1'b1;

assign sts_triggered_w = write_detect_q;

//-----------------------------------------------------------------
// Memory Access
//-----------------------------------------------------------------
assign mem_addr_o = write_addr_q;
assign mem_sel_o  = 4'b1111;
assign mem_data_o = buffer_q;
assign mem_stb_o  = buffer_wr_q;
assign mem_we_o   = 1'b1;

//-----------------------------------------------------------------
// Memory stall detect
//-----------------------------------------------------------------
reg mem_stalled_q;

always @ (posedge rst_i or posedge clk_i)
if (rst_i) 
    mem_stalled_q <= 1'b0;
else if (cfg_enable_reset_w)
    mem_stalled_q <= 1'b0;
else if (mem_stb_o && mem_stall_i && buffer_wr_r)
    mem_stalled_q <= 1'b1;

assign sts_mem_stall_w = mem_stalled_q;

//-----------------------------------------------------------------
// Memory overflow detect
//-----------------------------------------------------------------
assign buffer_full_w = (next_addr_q == buffer_read_w) && write_detect_q && !cfg_cont_w;

reg overflow_q;
always @ (posedge rst_i or posedge clk_i)
if (rst_i) 
    overflow_q <= 1'b0;
else if (cfg_enable_reset_w)
    overflow_q <= 1'b0;
else if (buffer_full_w)
    overflow_q <= 1'b1;

assign sts_overflow_w = overflow_q;

endmodule
