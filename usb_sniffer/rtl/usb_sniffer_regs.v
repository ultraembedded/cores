
`include "usb_sniffer_regs_defs.v"

//-----------------------------------------------------------------
// Module:  Auto generated register interface
//-----------------------------------------------------------------
module usb_sniffer_regs
(
    input          clk_i,
    input          rst_i,

    // Register Ports
    output [6:0]   usb_buffer_cfg_dev_o,
    output [3:0]   usb_buffer_cfg_ep_o,
    output [1:0]   usb_buffer_cfg_speed_o,
    output         usb_buffer_cfg_exclude_ep_o,
    output         usb_buffer_cfg_match_ep_o,
    output         usb_buffer_cfg_exclude_dev_o,
    output         usb_buffer_cfg_match_dev_o,
    output         usb_buffer_cfg_ignore_sof_o,
    output         usb_buffer_cfg_cont_o,
    output         usb_buffer_cfg_enabled_o,
    output [31:0]  usb_buffer_base_addr_o,
    output [31:0]  usb_buffer_end_addr_o,
    input          usb_buffer_sts_overflow_i,
    input          usb_buffer_sts_mem_stall_i,
    input          usb_buffer_sts_wrapped_i,
    input          usb_buffer_sts_trig_i,
    input  [31:0]  usb_buffer_current_addr_i,
    output [31:0]  usb_buffer_read_addr_o,

    // Wishbone interface (classic mode, synchronous slave)
    input [7:0]    addr_i,
    input [31:0]   data_i,
    output [31:0]  data_o,
    input          we_i,
    input          stb_i,
    output         ack_o
);

//-----------------------------------------------------------------
// Retime write data
//-----------------------------------------------------------------
reg [31:0] data_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    data_q <= 32'b0;
else
    data_q <= data_i;

//-----------------------------------------------------------------
// Request Logic
//-----------------------------------------------------------------
wire read_en_w;
wire write_en_w;

assign read_en_w  = stb_i & ~we_i & ~ack_o;
assign write_en_w = stb_i &  we_i & ~ack_o;


//-----------------------------------------------------------------
// Register usb_buffer_cfg
//-----------------------------------------------------------------
reg usb_buffer_cfg_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_buffer_cfg_wr_q <= 1'b0;
else if (write_en_w && (addr_i == `USB_BUFFER_CFG))
    usb_buffer_cfg_wr_q <= 1'b1;
else
    usb_buffer_cfg_wr_q <= 1'b0;

// usb_buffer_cfg_dev [internal]
reg [6:0]  usb_buffer_cfg_dev_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_buffer_cfg_dev_q <= 7'd`USB_BUFFER_CFG_DEV_DEFAULT;
else if (write_en_w && (addr_i == `USB_BUFFER_CFG))
    usb_buffer_cfg_dev_q <= data_i[`USB_BUFFER_CFG_DEV_R];

assign usb_buffer_cfg_dev_o = usb_buffer_cfg_dev_q;


// usb_buffer_cfg_ep [internal]
reg [3:0]  usb_buffer_cfg_ep_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_buffer_cfg_ep_q <= 4'd`USB_BUFFER_CFG_EP_DEFAULT;
else if (write_en_w && (addr_i == `USB_BUFFER_CFG))
    usb_buffer_cfg_ep_q <= data_i[`USB_BUFFER_CFG_EP_R];

assign usb_buffer_cfg_ep_o = usb_buffer_cfg_ep_q;


// usb_buffer_cfg_speed [internal]
reg [1:0]  usb_buffer_cfg_speed_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_buffer_cfg_speed_q <= 2'd`USB_BUFFER_CFG_SPEED_DEFAULT;
else if (write_en_w && (addr_i == `USB_BUFFER_CFG))
    usb_buffer_cfg_speed_q <= data_i[`USB_BUFFER_CFG_SPEED_R];

assign usb_buffer_cfg_speed_o = usb_buffer_cfg_speed_q;


// usb_buffer_cfg_exclude_ep [internal]
reg        usb_buffer_cfg_exclude_ep_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_buffer_cfg_exclude_ep_q <= 1'd`USB_BUFFER_CFG_EXCLUDE_EP_DEFAULT;
else if (write_en_w && (addr_i == `USB_BUFFER_CFG))
    usb_buffer_cfg_exclude_ep_q <= data_i[`USB_BUFFER_CFG_EXCLUDE_EP_R];

assign usb_buffer_cfg_exclude_ep_o = usb_buffer_cfg_exclude_ep_q;


// usb_buffer_cfg_match_ep [internal]
reg        usb_buffer_cfg_match_ep_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_buffer_cfg_match_ep_q <= 1'd`USB_BUFFER_CFG_MATCH_EP_DEFAULT;
else if (write_en_w && (addr_i == `USB_BUFFER_CFG))
    usb_buffer_cfg_match_ep_q <= data_i[`USB_BUFFER_CFG_MATCH_EP_R];

assign usb_buffer_cfg_match_ep_o = usb_buffer_cfg_match_ep_q;


// usb_buffer_cfg_exclude_dev [internal]
reg        usb_buffer_cfg_exclude_dev_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_buffer_cfg_exclude_dev_q <= 1'd`USB_BUFFER_CFG_EXCLUDE_DEV_DEFAULT;
else if (write_en_w && (addr_i == `USB_BUFFER_CFG))
    usb_buffer_cfg_exclude_dev_q <= data_i[`USB_BUFFER_CFG_EXCLUDE_DEV_R];

assign usb_buffer_cfg_exclude_dev_o = usb_buffer_cfg_exclude_dev_q;


// usb_buffer_cfg_match_dev [internal]
reg        usb_buffer_cfg_match_dev_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_buffer_cfg_match_dev_q <= 1'd`USB_BUFFER_CFG_MATCH_DEV_DEFAULT;
else if (write_en_w && (addr_i == `USB_BUFFER_CFG))
    usb_buffer_cfg_match_dev_q <= data_i[`USB_BUFFER_CFG_MATCH_DEV_R];

assign usb_buffer_cfg_match_dev_o = usb_buffer_cfg_match_dev_q;


// usb_buffer_cfg_ignore_sof [internal]
reg        usb_buffer_cfg_ignore_sof_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_buffer_cfg_ignore_sof_q <= 1'd`USB_BUFFER_CFG_IGNORE_SOF_DEFAULT;
else if (write_en_w && (addr_i == `USB_BUFFER_CFG))
    usb_buffer_cfg_ignore_sof_q <= data_i[`USB_BUFFER_CFG_IGNORE_SOF_R];

assign usb_buffer_cfg_ignore_sof_o = usb_buffer_cfg_ignore_sof_q;


// usb_buffer_cfg_cont [internal]
reg        usb_buffer_cfg_cont_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_buffer_cfg_cont_q <= 1'd`USB_BUFFER_CFG_CONT_DEFAULT;
else if (write_en_w && (addr_i == `USB_BUFFER_CFG))
    usb_buffer_cfg_cont_q <= data_i[`USB_BUFFER_CFG_CONT_R];

assign usb_buffer_cfg_cont_o = usb_buffer_cfg_cont_q;


// usb_buffer_cfg_enabled [internal]
reg        usb_buffer_cfg_enabled_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_buffer_cfg_enabled_q <= 1'd`USB_BUFFER_CFG_ENABLED_DEFAULT;
else if (write_en_w && (addr_i == `USB_BUFFER_CFG))
    usb_buffer_cfg_enabled_q <= data_i[`USB_BUFFER_CFG_ENABLED_R];

assign usb_buffer_cfg_enabled_o = usb_buffer_cfg_enabled_q;


//-----------------------------------------------------------------
// Register usb_buffer_base
//-----------------------------------------------------------------
reg usb_buffer_base_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_buffer_base_wr_q <= 1'b0;
else if (write_en_w && (addr_i == `USB_BUFFER_BASE))
    usb_buffer_base_wr_q <= 1'b1;
else
    usb_buffer_base_wr_q <= 1'b0;

// usb_buffer_base_addr [internal]
reg [31:0]  usb_buffer_base_addr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_buffer_base_addr_q <= 32'd`USB_BUFFER_BASE_ADDR_DEFAULT;
else if (write_en_w && (addr_i == `USB_BUFFER_BASE))
    usb_buffer_base_addr_q <= data_i[`USB_BUFFER_BASE_ADDR_R];

assign usb_buffer_base_addr_o = usb_buffer_base_addr_q;


//-----------------------------------------------------------------
// Register usb_buffer_end
//-----------------------------------------------------------------
reg usb_buffer_end_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_buffer_end_wr_q <= 1'b0;
else if (write_en_w && (addr_i == `USB_BUFFER_END))
    usb_buffer_end_wr_q <= 1'b1;
else
    usb_buffer_end_wr_q <= 1'b0;

// usb_buffer_end_addr [internal]
reg [31:0]  usb_buffer_end_addr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_buffer_end_addr_q <= 32'd`USB_BUFFER_END_ADDR_DEFAULT;
else if (write_en_w && (addr_i == `USB_BUFFER_END))
    usb_buffer_end_addr_q <= data_i[`USB_BUFFER_END_ADDR_R];

assign usb_buffer_end_addr_o = usb_buffer_end_addr_q;


//-----------------------------------------------------------------
// Register usb_buffer_sts
//-----------------------------------------------------------------
reg usb_buffer_sts_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_buffer_sts_wr_q <= 1'b0;
else if (write_en_w && (addr_i == `USB_BUFFER_STS))
    usb_buffer_sts_wr_q <= 1'b1;
else
    usb_buffer_sts_wr_q <= 1'b0;





//-----------------------------------------------------------------
// Register usb_buffer_current
//-----------------------------------------------------------------
reg usb_buffer_current_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_buffer_current_wr_q <= 1'b0;
else if (write_en_w && (addr_i == `USB_BUFFER_CURRENT))
    usb_buffer_current_wr_q <= 1'b1;
else
    usb_buffer_current_wr_q <= 1'b0;


//-----------------------------------------------------------------
// Register usb_buffer_read
//-----------------------------------------------------------------
reg usb_buffer_read_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_buffer_read_wr_q <= 1'b0;
else if (write_en_w && (addr_i == `USB_BUFFER_READ))
    usb_buffer_read_wr_q <= 1'b1;
else
    usb_buffer_read_wr_q <= 1'b0;

// usb_buffer_read_addr [internal]
reg [31:0]  usb_buffer_read_addr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_buffer_read_addr_q <= 32'd`USB_BUFFER_READ_ADDR_DEFAULT;
else if (write_en_w && (addr_i == `USB_BUFFER_READ))
    usb_buffer_read_addr_q <= data_i[`USB_BUFFER_READ_ADDR_R];

assign usb_buffer_read_addr_o = usb_buffer_read_addr_q;



//-----------------------------------------------------------------
// Read mux
//-----------------------------------------------------------------
reg [31:0] data_r;

always @ *
begin
    data_r = 32'b0;

    case (addr_i)

    `USB_BUFFER_CFG :
    begin
        data_r[`USB_BUFFER_CFG_DEV_R] = usb_buffer_cfg_dev_q;
        data_r[`USB_BUFFER_CFG_EP_R] = usb_buffer_cfg_ep_q;
        data_r[`USB_BUFFER_CFG_SPEED_R] = usb_buffer_cfg_speed_q;
        data_r[`USB_BUFFER_CFG_EXCLUDE_EP_R] = usb_buffer_cfg_exclude_ep_q;
        data_r[`USB_BUFFER_CFG_MATCH_EP_R] = usb_buffer_cfg_match_ep_q;
        data_r[`USB_BUFFER_CFG_EXCLUDE_DEV_R] = usb_buffer_cfg_exclude_dev_q;
        data_r[`USB_BUFFER_CFG_MATCH_DEV_R] = usb_buffer_cfg_match_dev_q;
        data_r[`USB_BUFFER_CFG_IGNORE_SOF_R] = usb_buffer_cfg_ignore_sof_q;
        data_r[`USB_BUFFER_CFG_CONT_R] = usb_buffer_cfg_cont_q;
        data_r[`USB_BUFFER_CFG_ENABLED_R] = usb_buffer_cfg_enabled_q;
    end
    `USB_BUFFER_BASE :
    begin
        data_r[`USB_BUFFER_BASE_ADDR_R] = usb_buffer_base_addr_q;
    end
    `USB_BUFFER_END :
    begin
        data_r[`USB_BUFFER_END_ADDR_R] = usb_buffer_end_addr_q;
    end
    `USB_BUFFER_STS :
    begin
        data_r[`USB_BUFFER_STS_OVERFLOW_R] = usb_buffer_sts_overflow_i;
        data_r[`USB_BUFFER_STS_MEM_STALL_R] = usb_buffer_sts_mem_stall_i;
        data_r[`USB_BUFFER_STS_WRAPPED_R] = usb_buffer_sts_wrapped_i;
        data_r[`USB_BUFFER_STS_TRIG_R] = usb_buffer_sts_trig_i;
    end
    `USB_BUFFER_CURRENT :
    begin
        data_r[`USB_BUFFER_CURRENT_ADDR_R] = usb_buffer_current_addr_i;
    end
    `USB_BUFFER_READ :
    begin
        data_r[`USB_BUFFER_READ_ADDR_R] = usb_buffer_read_addr_q;
    end
    default :
        data_r = 32'b0;
    endcase
end

//-----------------------------------------------------------------
// Retime read response
//-----------------------------------------------------------------
reg [31:0] rd_data_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    rd_data_q <= 32'b0;
else
    rd_data_q <= data_r;

assign data_o = rd_data_q;

//-----------------------------------------------------------------
// Wishbone Ack
//-----------------------------------------------------------------
reg ack_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    ack_q <= 1'b0;
else if (write_en_w || read_en_w)
    ack_q <= 1'b1;
else
    ack_q <= 1'b0;

assign ack_o = ack_q;



endmodule
