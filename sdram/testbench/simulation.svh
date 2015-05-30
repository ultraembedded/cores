`timescale 1ns/1ps

//-----------------------------------------------------------------
// assert_task
//-----------------------------------------------------------------
task automatic assert_task(input v, string file, int line, input string s);
begin
    if (!v)
    begin
        $display("ASSERT: %s:%0d - %s", file, line, s);
        $finish(1);
    end
end
endtask

//-----------------------------------------------------------------
// ASSERT
//-----------------------------------------------------------------
`define ASSERT(v)    assert_task(v, `__FILE__, `__LINE__, `"v`")

//-----------------------------------------------------------------
// ASSERT_ALWAYS
//-----------------------------------------------------------------
`define ASSERT_ALWAYS(condition) \
    generate \
        if(1) \
        begin \
        wire test = condition; \
        always @(test)\
         `ASSERT(condition); \
        end \
    endgenerate

//-----------------------------------------------------------------
// TB_TIMEOUT
//-----------------------------------------------------------------
`define TB_TIMEOUT(CLK, RST, VALID, TIMEOUT) \
    integer v_timeout_cycles;   \
                            \
    always @(posedge ``RST or posedge ``CLK)   \
    if (``RST)   \
        v_timeout_cycles <= 0; \
    else  \
    begin  \
        if (``VALID)  \
        begin  \
            v_timeout_cycles <= 0; \
        end  \
        else  \
        begin  \
            v_timeout_cycles <= v_timeout_cycles + 1; \
            `ASSERT(v_timeout_cycles < ``TIMEOUT);  \
        end  \
    end


//-----------------------------------------------------------------
// CLOCK_GEN
//-----------------------------------------------------------------
`define CLOCK_GEN(NAME, CYCLE)     \
    reg ``NAME;      \
    initial \
    begin \
       ``NAME <= 0; \
       forever # (``CYCLE / 2) ``NAME = ~``NAME; \
    end

//-----------------------------------------------------------------
// RESET_GEN
//-----------------------------------------------------------------
`define RESET_GEN(NAME, DELAY)     \
    reg ``NAME;      \
    initial \
    begin \
       ``NAME <= 1; \
       # ``DELAY    \
       ``NAME <= 0; \
    end

//-----------------------------------------------------------------
// TB_VCD
//-----------------------------------------------------------------
`define TB_VCD(TOP, NAME)     \
    initial \
    begin \
       $dumpfile(``NAME);  \
       $dumpvars(0,``TOP); \
    end

//-----------------------------------------------------------------
// TB_RUN_FOR
//-----------------------------------------------------------------
`define TB_RUN_FOR(TIME)    initial #``TIME $finish;