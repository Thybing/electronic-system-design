#include <stdint.h>

#include "../include/uart.h"
#include "../include/xprintf.h"

#define SEGLED_BASE        0x03000000
#define SEGLED_DATA        0x00
#define SEGLED_REG(addr)   (*((volatile uint32_t *)(addr+SEGLED_BASE)))


int main()
{
    uart_init();
    xprintf("Press Key:\n");
    while(1){
        uint8_t code;
        code = uart_getc();
        xprintf("%c", code);
        SEGLED_REG(SEGLED_DATA) = code;
    }

}
