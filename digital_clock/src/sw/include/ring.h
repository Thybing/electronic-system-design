#ifndef _RING_H_
#define _RING_H_

#include <stdint.h>
#include <stdbool.h>

#include "buzzer.h"

enum Ring_status{
    ring_rest = 0,
    ring_ringing,
    ring_end
};

void ring_init();
enum Ring_status start_ring();

#endif //_RING_H_