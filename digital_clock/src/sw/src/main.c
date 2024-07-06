#include <stdint.h>

#include "../include/uart.h"
#include "../include/xprintf.h"
#include "../include/seg_show.h"
#include "../include/sec_clock.h"
#include "../include/button.h"


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

    set_sec_clock_init_time(0x00000000);

    while (1){
        refresh_button_level();
        uint8_t detection = detect_falling();
        if(detection != 0){
            xprintf("falling:%x\n",detection);
        }
    }
    
}
