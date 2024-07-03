# Test the tiny RISC-V processor.  
# Instr SET : add, slt, addi, lw, sw, lui, beq, jal


start:    addi x1, x0, 0         # x1 = 0; // for led display      

loop:     li   x3, 0x100000      # x3 = 0x100000               

delay:    addi x3, x3, -1        # x3 --
          beq  x3, x0, inc_led   # if (x3 == 0) goto inc_led
          jal  x4, delay         # goto delay
      
inc_led:  addi x1, x1, 1         # x1 ++;                       
          sw   x1, 0x100(x0)     # [0x100] = x1;                   
          jal  x4, loop          # goto loop                       










