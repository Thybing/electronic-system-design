#include "../include/process_func.h"

enum Main_status g_main_status;

uint32_t cur_timestamp;
uint32_t tar_timestamp;
uint32_t alarm_timestamp;
uint32_t alarm_timestamp_tmp;

bool alarm_enable;
bool alarm_triggle;

void digital_clock_init(){
    //uart_init
    uart_init();

    //seg_led_init 
    for(int i = 0;i < 4;++i){
        set_scan_seg_state(i,SEG_STATUS_NUM);
        set_scan_seg_num(i,0);
    }
    set_scan_seg_state(1,SEG_STATUS_NUM | SEG_STATUS_DOT);
    set_static_seg(0x00);

    //clock_init
    set_sec_clock_init_time(0x00000000);

    //alarm_init
    alarm_enable = false;
    alarm_triggle = false;

    //ring_init
    ring_init();
}

void refresh_time(){
    cur_timestamp = get_sec_clock_cur_time();
}

void check_alarm(){
    if(alarm_enable && (alarm_timestamp == cur_timestamp)){
        alarm_triggle = true;
    }
    if(alarm_triggle){
        enum Ring_status ring_ret = start_ring();
        if(ring_ret == ring_end){
            alarm_triggle = false;
        }
        xprintf("\n########ding~ding~ding~#########\n");
    }
}

void seg_show_cur_time(){
    struct time show_time = timestamp_to_time(cur_timestamp);

    set_scan_seg_num(0,show_time.hour / 10);
    set_scan_seg_num(1,show_time.hour % 10);
    set_scan_seg_num(2,show_time.min / 10);
    set_scan_seg_num(3,show_time.min % 10);

    uint8_t static_show = (show_time.sec % 10) + ((show_time.sec / 10) * 16);
    set_static_seg(static_show);
}

void seg_show_tar_time(){
    struct time show_time = timestamp_to_time(tar_timestamp);

    set_scan_seg_num(0,show_time.hour / 10);
    set_scan_seg_num(1,show_time.hour % 10);
    set_scan_seg_num(2,show_time.min / 10);
    set_scan_seg_num(3,show_time.min % 10);

    uint8_t static_show = (show_time.sec % 10) + ((show_time.sec / 10) * 16);
    set_static_seg(static_show);
}

void seg_show_alarm_time(){
    struct time show_time = timestamp_to_time(alarm_timestamp_tmp);

    set_scan_seg_num(0,show_time.hour / 10);
    set_scan_seg_num(1,show_time.hour % 10);
    set_scan_seg_num(2,show_time.min / 10);
    set_scan_seg_num(3,show_time.min % 10);

    uint8_t static_show = (show_time.sec % 10) + ((show_time.sec / 10) * 16);
    set_static_seg(static_show);
}

void button_action(enum Main_status main_status){
    uint8_t button_triggle = detect_falling();
    if(button_triggle == 0)
        return;

    if(main_status == SHOW_TIME){
        if(button_triggle & (0x01 << 7)){
            tar_timestamp = cur_timestamp;
            g_main_status = SET_TIME;
            xprintf("*************setting time************\n");
        }
        if(button_triggle & (0x01 << 6)){
            alarm_timestamp_tmp = alarm_timestamp;
            g_main_status = SET_ALARM;
            xprintf("*************setting alart************\n");
        }
        if(button_triggle & (0x01 << 4)){
            alarm_enable = true;
            xprintf("*************alart enable************\n");
        }
        if(button_triggle & (0x01 << 3)){
            alarm_enable = false;
            alarm_triggle = false;
            xprintf("*************alart disable************\n");
        }
    }else if(main_status == SET_TIME){
        if(button_triggle & (0x01 << 7))
            tar_timestamp += 3600;
        if(button_triggle & (0x01 << 6))
            tar_timestamp += 60;
        if(button_triggle & (0x01 << 5))
            tar_timestamp += 1;
        if(button_triggle & (0x01 << 4))
            tar_timestamp -= 3600;
        if(button_triggle & (0x01 << 3))
            tar_timestamp -= 60;
        if(button_triggle & (0x01 << 2))
            tar_timestamp -= 1;

        ///////prevent over/underflow
        tar_timestamp += DAY_SECOND;
        tar_timestamp %= DAY_SECOND;
        
        if(button_triggle & (0x01 << 1)){
            g_main_status = SHOW_TIME;
            xprintf("*************cancel************\n");
        }
        if(button_triggle & (0x01 << 0)){
            set_sec_clock_init_time(tar_timestamp);
            g_main_status = SHOW_TIME;
            xprintf("***********set new time************\n");
        }

        tar_timestamp += DAY_SECOND;
        tar_timestamp %= DAY_SECOND;
    }else if(main_status == SET_ALARM){
        if(button_triggle & (0x01 << 7))
            alarm_timestamp_tmp += 3600;
        if(button_triggle & (0x01 << 6))
            alarm_timestamp_tmp += 60;
        if(button_triggle & (0x01 << 5))
            alarm_timestamp_tmp += 1;
        if(button_triggle & (0x01 << 4))
            alarm_timestamp_tmp -= 3600;
        if(button_triggle & (0x01 << 3))
            alarm_timestamp_tmp -= 60;
        if(button_triggle & (0x01 << 2))
            alarm_timestamp_tmp -= 1;

        ///////prevent over/underflow
        alarm_timestamp_tmp += DAY_SECOND;
        alarm_timestamp_tmp %= DAY_SECOND;

        if(button_triggle & (0x01 << 1)){
            g_main_status = SHOW_TIME;
            xprintf("*************cancel************\n");
        }
        if(button_triggle & (0x01 << 0)){
            alarm_timestamp = alarm_timestamp_tmp;
            g_main_status = SHOW_TIME;
            xprintf("***********set new alart************\n");
        }
    }
}

struct time timestamp_to_time(uint32_t timestamp){
    struct time ret_time;
    ret_time.hour = timestamp / 3600;
    ret_time.min = (timestamp % 3600) / 60;
    ret_time.sec = timestamp % 60;
    return ret_time;
}