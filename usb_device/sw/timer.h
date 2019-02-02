#ifndef __TIMER_H__
#define __TIMER_H__

//-----------------------------------------------------------------
// Types
//-----------------------------------------------------------------
typedef unsigned long   t_time;


// TODO: Implementation specific millisecond timer...
static t_time  timer_now(void) {  return 0; }
static void    timer_sleep(int timeMs) { }

#endif
