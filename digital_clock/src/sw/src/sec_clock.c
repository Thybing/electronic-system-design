#include "../include/sec_clock.h"

uint32_t get_sec_clock_run_time(){
    return SEC_CLOCK_REG(SEC_CLOCK_ADDR_RUN_TIME);
}

void sec_clock_clr(){
    SEC_CLOCK_REG(SEC_CLOCK_ADDR_CLR) = 0x01U;
}

void set_sec_clock_init_time(uint32_t init_time){
    SEC_CLOCK_REG(SEC_CLOCK_ADDR_INIT_TIME) = init_time;
    sec_clock_clr();
}

uint32_t get_sec_clock_init_time(){
    return SEC_CLOCK_REG(SEC_CLOCK_ADDR_INIT_TIME);
}

uint32_t get_sec_clock_cur_time(){
    return (get_sec_clock_init_time() + get_sec_clock_run_time() + DAY_SECOND) % DAY_SECOND;
}