#ifndef _UART_H_
#define _UART_H_

#define UART0_BASE      0x02000000
#define UART0_CTRL      0x00 
#define UART0_STATUS    0x04
#define UART0_BAUD      0x08
#define UART0_TXDATA    0x0c
#define UART0_RXDATA    0x10

#define TIME_OUT_FLAG   0xff

#define UART0_REG(addr) (*((volatile uint32_t *)(addr+UART0_BASE)))

void uart_init();
void uart_putc(uint8_t c);
uint8_t uart_getc(uint32_t run_time_out);

#endif
