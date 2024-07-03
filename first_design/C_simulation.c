#include <stdbool.h>
#include <stdint.h>
//LED跑马灯实现

int main() {
start:
    uint32_t a = 0b0000'0001;
    while (true) {
        a = a << 1;
        if (a == (uint32_t)0b1'0000'0000) {
            goto start;
        }
    }
    return 0;
}


/*************
main:
        push    rbp
        mov     rbp, rsp
.L2:
        mov     DWORD PTR [rbp-4], 1
.L4:
        sal     DWORD PTR [rbp-4]
        cmp     DWORD PTR [rbp-4], 256
        jne     .L4
        jmp     .L2
***************/