#ifndef _BUTTON_H_
#define _BUTTON_H_

#include <stdint.h>
#include <stdbool.h>

#define BUTTON_ADDRBASE         0x05000000
#define BUTTON_ADDR_LEVEL       0x04

#define BUTTON_REG(addr)    (*((volatile uint32_t *)(addr+BUTTON_ADDRBASE)))

uint8_t detect_falling();

#endif //__BUTTON_H_
