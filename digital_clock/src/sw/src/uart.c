#include <stdint.h>

#include "../include/uart.h"
#include "../include/xprintf.h"


// send one char to uart
void uart_putc(uint8_t c)
{
    while (UART0_REG(UART0_STATUS) & 0x1);
    UART0_REG(UART0_TXDATA) = c;
}

// Block, get one char from uart.
uint8_t uart_getc(uint32_t run_time_out)
{
    uint32_t    time_out_counter = 0;
    UART0_REG(UART0_STATUS) &= ~0x2;
    while (!(UART0_REG(UART0_STATUS) & 0x2)){
        if(++time_out_counter > run_time_out) return TIME_OUT_FLAG;
    };
    return (UART0_REG(UART0_RXDATA) & 0xff);
}

// 115200bps, 8 N 1
void uart_init()
{
    // enable tx and rx
    UART0_REG(UART0_CTRL) = 0x3;

    xdev_out(uart_putc);
}
