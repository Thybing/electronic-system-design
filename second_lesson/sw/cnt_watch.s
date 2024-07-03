start:  
        lui  x5, 0x02000            # x5 for switch base addr
        lui  x6, 0x03000            # x6 for buzzer base addr
        lui  x7, 0x04000            # x7 for segled base addr
        li   x9, 0x01               # x9 = 1 for const
        li   x10,0x1f               # x10 = 0x1f for cmp to decoder
        li   x11,0x0f               # x11 = 0x0f for cmp to decoder
        addi x8, x0, 0x5            # x8 = 5 for buzzer cmp
init:
        li   x1, 0x20               # x1 for display
        sw   x0, 0x04(x6)           # write 0 to x6 + 0x04
        sw   x1, 0x04(x7)           # write x1 to x7 + 0x04
loop:   
        li   x3, 0x6DDB33           # x3 = 0x28B000
delay:  
        addi x3, x3, -1             # x3 --
        beq  x3, x0, cnt_d          # if (x3 == 0) goto shift (24)
        jal  x4, delay              # goto delay (-20)
cnt_d:  
        lw   x12,0x04(x5)           # x12 == switch level
        beq  x12,x9, init           # if (x12 == 1) goto init
        beq  x1, x0, loop           # if (x1 == 0) goto loop
        addi x1, x1, -1             # x1 --
        beq  x1, x10, decoder19     # goto decoder19
        beq  x1, x11, decoder09     # goto decoder09
display:
        sw   x1, 0x04(x7)           # write x1 to x7 + 0x04
        beq  x1, x8, buzzer         # if(x1 == 5) enable buzzer
        jal  x4, loop               # goto loop
buzzer: 
        sw   x9, 0x04(x6)           # write 1 to x6 + 0x04
        jal  x4, loop               # goto loop
decoder19:
        li   x1, 0x19               # x1 = 0x19
        jal  x4, display            # goto display
decoder09:
        li   x1, 0x09               # x1 = 0x09
        jal  x4, display            # goto display
