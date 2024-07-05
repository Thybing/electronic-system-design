#ifndef _SEC_CLOCK_H_
#define _SEC_CLOCK_H_

#include <stdint.h>
#include <stdbool.h>

#define SEC_CLOCK_ADDRBASE          0x04000000
#define SEC_CLOCK_ADDR_RUN_TIME     0x04
#define SEC_CLOCK_ADDR_CLR          0x08
#define SEC_CLOCK_ADDR_INIT_TIME    0x0c

#define SEC_CLOCK_REG(addr)     (*((volatile uint32_t *)(addr+SEC_CLOCK_ADDRBASE)))

#define DAY_SECOND          86400

uint32_t get_sec_clock_run_time();
void sec_clock_clr();
void set_sec_clock_init_time(uint32_t init_time);
uint32_t get_sec_clock_init_time();
uint32_t get_sec_clock_cur_time();

#endif //_SEC_CLOCK_H_