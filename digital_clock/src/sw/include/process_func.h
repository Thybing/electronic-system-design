#ifndef _PROCESS_FUNC_H_
#define _PROCESS_FUNC_H_

#include <stdint.h>
#include <stdbool.h>

#include "../include/uart.h"
#include "../include/xprintf.h"
#include "../include/seg_show.h"
#include "../include/sec_clock.h"
#include "../include/button.h"

enum main_status{
    SHOW_TIME = 0,
    SHOW_SET_TIME,
    SHOW_ALARM_TIME
};

struct time
{
    uint8_t hour;
    uint8_t min;
    uint8_t sec;
};

void digital_clock_init();
struct time timestamp_to_time(uint32_t timestamp);
void seg_show_cur_time(uint32_t timestamp);
void seg_show_tar_time(uint32_t timestamp);
void seg_show_alarm_time(uint32_t timestamp);

#endif //_PROCESS_FUNC_H_