#include <stdint.h>
#include <stdbool.h>
#include "../include/buzzer.h"

void buzzer_init(){
    BUZZER0_REG(BUZZER0_STATUS)     = 1;
    BUZZER0_REG(BUZZER0_DIVTAR)     = 0;
    BUZZER0_REG(BUZZER0_DELAY_TAR)  = BEAT_PERIOD_PSC;
    BUZZER0_REG(BUZZER0_DELAY_CLR)  = 0;
}

void buzzer_set_freq(uint32_t i_psc){
    BUZZER0_REG(BUZZER0_DIVTAR)     =   i_psc;
}

void buzzer_ring_a_beat(){
    BUZZER0_REG(BUZZER0_DELAY_CLR)  =   1;
}

bool buzzer_beat_end(){
    return (!(BUZZER0_REG(BUZZER0_DELAY_CNT) >= BEAT_PERIOD_PSC));
}
