#include <stdint.h>

#include "../include/uart.h"
#include "../include/xprintf.h"
#include "../include/buzzer.h"

#define SEGLED_BASE        0x03000000
#define SEGLED_DATA        0x00
#define SEGLED_REG(addr)   (*((volatile uint32_t *)(addr+SEGLED_BASE)))

#define FIFO_CAPACITY           128
#define FIFO_ENQUEUE(addr_head,pfront,size,ch) \
    do{ \
        if((size) < FIFO_CAPACITY) {\
            *((addr_head) + ((((pfront) - (addr_head)) + (size)) % FIFO_CAPACITY)) = (ch);\
            ++(size);\
        } \
    }while(0)
#define FIFO_DEQUEUE(addr_head,pfront,size)   \
    do{ \
        if((size) > 0){ \
            ++(pfront);\
            --(size);\
            if((pfront) == (addr_head) + FIFO_CAPACITY){\
                (pfront) = (addr_head);\
            }\
        }\
    } while(0)
#define FIFO_FRONT(pfront,size) \
    ((size) > 0 ? *(pfront) : 0)

int main()
{
    char fifo[FIFO_CAPACITY];
    char *  fifo_head = (char *)fifo;
    uint8_t fifo_size = 0;

    uart_init();
    buzzer_init();
    xprintf("Press Key:\n");
    while(1){
        while(1){
            uint8_t code;
            code = uart_getc();
            if(code == TIME_OUT_FLAG){
                break;
            }
            FIFO_ENQUEUE(fifo,fifo_head,fifo_size,code);
            // xprintf("fifo_size:%d",fifo_size);
        }
        while(is_buzzer_idle() && fifo_size > 0){
            xprintf("fifo_front:%c",FIFO_FRONT(fifo_head,fifo_size));
            if(buzzer_set_freq(FIFO_FRONT(fifo_head,fifo_size))){
                buzzer_ring_a_beat();
            }
            FIFO_DEQUEUE(fifo,fifo_head,fifo_size);
            while(!is_buzzer_idle());
        }
    }
}
