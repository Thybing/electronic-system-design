#include <stdint.h>

#include "../include/uart.h"
#include "../include/xprintf.h"
#include "../include/process_func.h"
#include "../include/buzzer.h"


int main()
{
    digital_clock_init();
    while (true){
        refresh_time();
        check_alarm();
        if(g_main_status == SHOW_TIME){
            seg_show_cur_time();
            button_action(SHOW_TIME);
        }else if(g_main_status == SET_TIME){
            seg_show_tar_time();
            button_action(SET_TIME);
        }else if(g_main_status == SET_ALARM){
            seg_show_alarm_time();
            button_action(SET_ALARM);
        }
    }
    
}
