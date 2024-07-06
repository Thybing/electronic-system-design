#include "../include/ring.h"
#include "../include/xprintf.h"

#define MUSIC_SCORE_CAPACITY 128

#include "music_score.txt"

char * p_cur_note = music_score;
bool is_ringing;

void ring_init(){
    is_ringing = false;
    p_cur_note = music_score;
    buzzer_init();
}

enum Ring_status start_ring(){
    if(is_ringing == false){
        p_cur_note = music_score;
        is_ringing = true;
    }
    if(is_buzzer_idle() && is_ringing){
        while(true){
            if(*p_cur_note == 0){
                is_ringing = false;
                p_cur_note = music_score;
                return ring_end;
            }
            if(buzzer_set_freq(*p_cur_note)){
                ++p_cur_note;
                buzzer_ring_a_beat();
                return ring_ringing;
            }else{
                ++p_cur_note;
            }
        }
    }else{
        return ring_ringing;
    }
}