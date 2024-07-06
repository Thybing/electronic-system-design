#ifndef _BUZZER_H_
#define _BUZZER_H_

#include <stdint.h>
#include <stdbool.h>

#define BUZZER0_BASE      0x06000000
#define BUZZER0_VER       0x00 
#define BUZZER0_STATUS    0x04
#define BUZZER0_DIVTAR    0x08
#define BUZZER0_DELAY_TAR 0x0c
#define BUZZER0_DELAY_CNT 0x10
#define BUZZER0_DELAY_CLR 0x14

#define C4_PSC      95556
#define D4_PSC      85130
#define E4_PSC      75842
#define F4_PSC      71586
#define G4_PSC      63776
#define A4_PSC      56818
#define B4_PSC      50618
#define REST        0x3f3f3f3f

#define BEAT_PERIOD_PSC     6250000

#define BUZZER0_REG(addr) (*((volatile uint32_t *)(addr + BUZZER0_BASE)))

void buzzer_init();
bool buzzer_set_freq(char i_freq);
void buzzer_ring_a_beat();
bool is_buzzer_idle();

#endif
