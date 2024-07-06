#ifndef _PROCESS_FUNC_H_
#define _PROCESS_FUNC_H_

#include <stdint.h>
#include <stdbool.h>

#include "../include/uart.h"
#include "../include/xprintf.h"
#include "../include/seg_show.h"
#include "../include/sec_clock.h"
#include "../include/button.h"
#include "../include/ring.h"

enum Main_status{
    SHOW_TIME = 0,
    SET_TIME,
    SET_ALARM
};

struct time
{
    uint8_t hour;
    uint8_t min;
    uint8_t sec;
};

extern enum Main_status g_main_status;

void digital_clock_init();

void refresh_time();
void check_alarm();

void seg_show_cur_time();
void seg_show_tar_time();
void seg_show_alarm_time();

void button_action(enum Main_status main_status);

struct time timestamp_to_time(uint32_t timestamp);

#endif //_PROCESS_FUNC_H_