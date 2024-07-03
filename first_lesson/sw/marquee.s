start:      addi x1, x0, 1          # x1 = 1; // for led display
            addi x0, x0, 0         # nop
            addi x6, x0, 0x100;    # x6 = 0b 1_0000_0000 for compare
            addi x0, x0, 0         # nop
            sw   x1, 0x100(x0)     # [0x100] = x1;                   
            addi x0, x0, 0         # nop
            addi x5, x0, 1         # x5 = 1; // for shift count
            addi x0, x0, 0         # nop
loop:       lui  x3, 0x14B         # x3 = 0x14B<<12                 
            addi x0, x0, 0         # nop
            addi x3, x3, -0x5E0    # x3 = x3 - 0x5E0 =450000          
            addi x0, x0, 0         # nop k
delay:      addi x3, x3, -1        # x3 --
            addi x0, x0, 0         # nop
            beq  x3, x0, shift     # if (x3 == 0) goto shift (24)
            addi x0, x0, 0         # nop  
            addi x0, x0, 0         # nop
            jal  x4, delay         # goto delay (-20)
            addi x0, x0, 0         # nop
            addi x0, x0, 0         # nop   
shift:      sll  x1, x1, x5        # x1 << x5
            addi x0, x0, 0         # nop
            beq  x1, x6, start     # if (x1 == 1_0000_0000) goto start (-88)
            addi x0, x0, 0         # nop  
            addi x0, x0, 0         # nop  
            sw   x1, 0x100(x0)     # [0x100] = x1;                   
            addi x0, x0, 0         # nop   
            jal  x4, loop          # goto loop (-76)                 
            addi x0, x0, 0         # nop
            addi x0, x0, 0         # nop 
