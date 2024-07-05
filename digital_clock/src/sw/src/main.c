#include <stdint.h>

#include "../include/uart.h"
#include "../include/xprintf.h"
#include "../include/seg_show.h"
#include "../include/sec_clock.h"


int main()
{
    uart_init();
    xprintf("Press Key:\n");

    for(int i = 0;i < 4;++i){
        set_scan_seg_state(i,SEG_STATUS_NUM);
        set_scan_seg_num(i,i);
    }
    set_scan_seg_state(2,SEG_STATUS_NUM | SEG_STATUS_DOT);
    set_scan_seg_state(3,SEG_STATUS_NUM | SEG_STATUS_DOT | SEG_STATUS_SP_CHAR);
    set_static_seg(0x8f);

    set_sec_clock_init_time(0x000000ff);

    int cnt = 0xfff;
    while(1){
        xprintf("cur_tim:%u\n",get_sec_clock_cur_time());
        --cnt;
        if(cnt == 0) break;
    }

    xprintf("break\n");

    set_sec_clock_init_time(86390);
    sec_clock_clr();

    while (1){
        xprintf("cur_tim:%u\n",get_sec_clock_cur_time());
        xprintf("run_tim:%u\n",get_sec_clock_run_time());
    }
    
}
