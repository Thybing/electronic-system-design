start:    addi x1, x0, 0         # x1 = 0; // for led display      
loop:     lui  x3, 0x14B         # x3 = 0x14B<<12                 
          addi x0, x0, 0         # nop
          addi x3, x3, -0x5E0    # x3 = x3 - 0x5E0 =450000          
          addi x0, x0, 0         # nop 
delay:    addi x3, x3, -1        # x3 --
          addi x0, x0, 0         # nop
          beq  x3, x0, inc_led   # if (x3 == 0) goto inc_led
          addi x0, x0, 0         # nop  
          addi x0, x0, 0         # nop
          jal  x4, delay         # goto delay
          addi x0, x0, 0         # nop
          addi x0, x0, 0         # nop   
inc_led:  addi x1, x1, 1         # x1 ++;                       
          addi x0, x0, 0         # nop
          sw   x1, 0x100(x0)     # [0x100] = x1;                   
          addi x0, x0, 0         # nop   
          jal  x4, loop          # goto loop                       
          addi x0, x0, 0         # nop
          addi x0, x0, 0         # nop 









