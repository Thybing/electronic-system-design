#include "../include/seg_show.h"

void set_static_seg(uint8_t num){
    SEG_REG(SEG_ADDR_STATIC_DATA)   =   num;
}

void set_scan_seg_num(uint8_t index,uint8_t num){
    uint32_t old_reg = SEG_REG(SEG_ADDR_SCAN_DATA);
    uint32_t bit_choose = 0x0000000f;
    bit_choose <<= (index * 8);
    bit_choose = ~bit_choose;
    old_reg    &= bit_choose;
    old_reg    |= (((uint32_t)num & 0x0fU) << (index * 8U));
    SEG_REG(SEG_ADDR_SCAN_DATA) = old_reg;
}

void set_scan_seg_state(uint8_t index,uint8_t state){
    uint32_t old_reg = SEG_REG(SEG_ADDR_SCAN_DATA);
    uint32_t bit_choose = 0x000000f0;
    bit_choose <<= (index * 8);
    bit_choose = ~bit_choose;
    old_reg    &= bit_choose;
    old_reg    |= ((((uint32_t)state << 4) & 0xf0) << (index * 8));
    SEG_REG(SEG_ADDR_SCAN_DATA) = old_reg;
}