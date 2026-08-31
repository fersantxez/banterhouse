#ifndef BANTERHOUSE_GAME_H
#define BANTERHOUSE_GAME_H

#include <types.h>

typedef enum {
   BH_VERY_EASY = 0,
   BH_EASY,
   BH_NORMAL,
   BH_HARD,
   BH_VERY_HARD,
   BH_DIFFICULTY_COUNT
} BHDifficulty;

extern BHDifficulty bh_difficulty;

void bh_menu(void);
void bh_game(void);

#endif
