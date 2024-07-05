#ifndef _SEG_SHOW_
#define _SEG_SHOW_

#include <stdint.h>
#include <stdbool.h>

#define SEG_ADDRBASE            0x03000000
#define SEG_ADDR_SCAN_DATA      0x04
#define SEG_ADDR_STATIC_DATA    0x08

#define SEG_REG(addr)   (*((volatile uint32_t *)(addr+SEG_ADDRBASE)))

#define SEG_STATUS_NUM      0x08
#define SEG_STATUS_DOT      0x04
#define SEG_STATUS_SP_CHAR  0x02

void set_static_seg(uint8_t num);
void set_scan_seg_num(uint8_t index,uint8_t num);
void set_scan_seg_state(uint8_t index,uint8_t state);

#endif //_SEG_SHOW_