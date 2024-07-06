#include "../include/button.h"

uint8_t pre_button_level = 0xff;
uint8_t cur_button_level = 0xff;

void refresh_button_level(){
    pre_button_level = cur_button_level;
    cur_button_level = BUTTON_REG(BUTTON_ADDR_LEVEL);
}

uint8_t detect_falling(){
    refresh_button_level();
    return (pre_button_level ^ cur_button_level) & pre_button_level;
}