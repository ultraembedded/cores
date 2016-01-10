`define USB_BUFFER_CFG    8'h0

	`define USB_BUFFER_CFG_DEV_DEFAULT    0
    `define USB_BUFFER_CFG_DEV_B          24
    `define USB_BUFFER_CFG_DEV_T          30
    `define USB_BUFFER_CFG_DEV_W          7
    `define USB_BUFFER_CFG_DEV_R          30:24

	`define USB_BUFFER_CFG_EP_DEFAULT    0
    `define USB_BUFFER_CFG_EP_B          16
    `define USB_BUFFER_CFG_EP_T          19
    `define USB_BUFFER_CFG_EP_W          4
    `define USB_BUFFER_CFG_EP_R          19:16

	`define USB_BUFFER_CFG_SPEED_DEFAULT    0
    `define USB_BUFFER_CFG_SPEED_B          7
    `define USB_BUFFER_CFG_SPEED_T          8
    `define USB_BUFFER_CFG_SPEED_W          2
    `define USB_BUFFER_CFG_SPEED_R          8:7

    `define USB_BUFFER_CFG_EXCLUDE_EP      6
	`define USB_BUFFER_CFG_EXCLUDE_EP_DEFAULT    0
    `define USB_BUFFER_CFG_EXCLUDE_EP_B          6
    `define USB_BUFFER_CFG_EXCLUDE_EP_T          6
    `define USB_BUFFER_CFG_EXCLUDE_EP_W          1
    `define USB_BUFFER_CFG_EXCLUDE_EP_R          6:6

    `define USB_BUFFER_CFG_MATCH_EP      5
	`define USB_BUFFER_CFG_MATCH_EP_DEFAULT    0
    `define USB_BUFFER_CFG_MATCH_EP_B          5
    `define USB_BUFFER_CFG_MATCH_EP_T          5
    `define USB_BUFFER_CFG_MATCH_EP_W          1
    `define USB_BUFFER_CFG_MATCH_EP_R          5:5

    `define USB_BUFFER_CFG_EXCLUDE_DEV      4
	`define USB_BUFFER_CFG_EXCLUDE_DEV_DEFAULT    0
    `define USB_BUFFER_CFG_EXCLUDE_DEV_B          4
    `define USB_BUFFER_CFG_EXCLUDE_DEV_T          4
    `define USB_BUFFER_CFG_EXCLUDE_DEV_W          1
    `define USB_BUFFER_CFG_EXCLUDE_DEV_R          4:4

    `define USB_BUFFER_CFG_MATCH_DEV      3
	`define USB_BUFFER_CFG_MATCH_DEV_DEFAULT    0
    `define USB_BUFFER_CFG_MATCH_DEV_B          3
    `define USB_BUFFER_CFG_MATCH_DEV_T          3
    `define USB_BUFFER_CFG_MATCH_DEV_W          1
    `define USB_BUFFER_CFG_MATCH_DEV_R          3:3

    `define USB_BUFFER_CFG_IGNORE_SOF      2
	`define USB_BUFFER_CFG_IGNORE_SOF_DEFAULT    0
    `define USB_BUFFER_CFG_IGNORE_SOF_B          2
    `define USB_BUFFER_CFG_IGNORE_SOF_T          2
    `define USB_BUFFER_CFG_IGNORE_SOF_W          1
    `define USB_BUFFER_CFG_IGNORE_SOF_R          2:2

    `define USB_BUFFER_CFG_CONT      1
	`define USB_BUFFER_CFG_CONT_DEFAULT    0
    `define USB_BUFFER_CFG_CONT_B          1
    `define USB_BUFFER_CFG_CONT_T          1
    `define USB_BUFFER_CFG_CONT_W          1
    `define USB_BUFFER_CFG_CONT_R          1:1

    `define USB_BUFFER_CFG_ENABLED      0
	`define USB_BUFFER_CFG_ENABLED_DEFAULT    0
    `define USB_BUFFER_CFG_ENABLED_B          0
    `define USB_BUFFER_CFG_ENABLED_T          0
    `define USB_BUFFER_CFG_ENABLED_W          1
    `define USB_BUFFER_CFG_ENABLED_R          0:0

`define USB_BUFFER_STS    8'h4

    `define USB_BUFFER_STS_OVERFLOW      3
	`define USB_BUFFER_STS_OVERFLOW_DEFAULT    0
    `define USB_BUFFER_STS_OVERFLOW_B          3
    `define USB_BUFFER_STS_OVERFLOW_T          3
    `define USB_BUFFER_STS_OVERFLOW_W          1
    `define USB_BUFFER_STS_OVERFLOW_R          3:3

    `define USB_BUFFER_STS_MEM_STALL      2
	`define USB_BUFFER_STS_MEM_STALL_DEFAULT    0
    `define USB_BUFFER_STS_MEM_STALL_B          2
    `define USB_BUFFER_STS_MEM_STALL_T          2
    `define USB_BUFFER_STS_MEM_STALL_W          1
    `define USB_BUFFER_STS_MEM_STALL_R          2:2

    `define USB_BUFFER_STS_WRAPPED      1
	`define USB_BUFFER_STS_WRAPPED_DEFAULT    0
    `define USB_BUFFER_STS_WRAPPED_B          1
    `define USB_BUFFER_STS_WRAPPED_T          1
    `define USB_BUFFER_STS_WRAPPED_W          1
    `define USB_BUFFER_STS_WRAPPED_R          1:1

    `define USB_BUFFER_STS_TRIG      0
	`define USB_BUFFER_STS_TRIG_DEFAULT    0
    `define USB_BUFFER_STS_TRIG_B          0
    `define USB_BUFFER_STS_TRIG_T          0
    `define USB_BUFFER_STS_TRIG_W          1
    `define USB_BUFFER_STS_TRIG_R          0:0

`define USB_BUFFER_BASE    8'h8

	`define USB_BUFFER_BASE_ADDR_DEFAULT    0
    `define USB_BUFFER_BASE_ADDR_B          0
    `define USB_BUFFER_BASE_ADDR_T          31
    `define USB_BUFFER_BASE_ADDR_W          32
    `define USB_BUFFER_BASE_ADDR_R          31:0

`define USB_BUFFER_END    8'hc

	`define USB_BUFFER_END_ADDR_DEFAULT    0
    `define USB_BUFFER_END_ADDR_B          0
    `define USB_BUFFER_END_ADDR_T          31
    `define USB_BUFFER_END_ADDR_W          32
    `define USB_BUFFER_END_ADDR_R          31:0

`define USB_BUFFER_CURRENT    8'h10

	`define USB_BUFFER_CURRENT_ADDR_DEFAULT    0
    `define USB_BUFFER_CURRENT_ADDR_B          0
    `define USB_BUFFER_CURRENT_ADDR_T          31
    `define USB_BUFFER_CURRENT_ADDR_W          32
    `define USB_BUFFER_CURRENT_ADDR_R          31:0

`define USB_BUFFER_READ    8'h14

	`define USB_BUFFER_READ_ADDR_DEFAULT    0
    `define USB_BUFFER_READ_ADDR_B          0
    `define USB_BUFFER_READ_ADDR_T          31
    `define USB_BUFFER_READ_ADDR_W          32
    `define USB_BUFFER_READ_ADDR_R          31:0

