#include <stdint.h>
#include <stdbool.h>
#include "../include/buzzer.h"

void buzzer_init(){
    BUZZER0_REG(BUZZER0_STATUS)     = 1;
    BUZZER0_REG(BUZZER0_DIVTAR)     = REST;
    BUZZER0_REG(BUZZER0_DELAY_TAR)  = BEAT_PERIOD_PSC;
    BUZZER0_REG(BUZZER0_DELAY_CLR)  = 0;
}

bool buzzer_set_freq(char i_freq){
    if(i_freq >= '0' && i_freq <= '7'){
        switch (i_freq)
        {
        case '0':BUZZER0_REG(BUZZER0_DIVTAR) = REST;  break;
        case '1':BUZZER0_REG(BUZZER0_DIVTAR) = C4_PSC;break;
        case '2':BUZZER0_REG(BUZZER0_DIVTAR) = D4_PSC;break;
        case '3':BUZZER0_REG(BUZZER0_DIVTAR) = E4_PSC;break;
        case '4':BUZZER0_REG(BUZZER0_DIVTAR) = F4_PSC;break;
        case '5':BUZZER0_REG(BUZZER0_DIVTAR) = G4_PSC;break;
        case '6':BUZZER0_REG(BUZZER0_DIVTAR) = A4_PSC;break;
        case '7':BUZZER0_REG(BUZZER0_DIVTAR) = B4_PSC;break;
        default:
            break;
        }
        return true;
    }
    return false;
}

void buzzer_ring_a_beat(){
    BUZZER0_REG(BUZZER0_DELAY_CLR)  =   1;
}

bool is_buzzer_idle(){
    return ((BUZZER0_REG(BUZZER0_DELAY_CNT) >= BEAT_PERIOD_PSC));
}
