#ifndef BANTERHOUSE_DIFFICULTY_H
#define BANTERHOUSE_DIFFICULTY_H

#include "bh_types.h"

typedef enum {
   BH_VERY_EASY = 0,
   BH_EASY,
   BH_NORMAL,
   BH_HARD,
   BH_VERY_HARD,
   BH_DIFFICULTY_COUNT
} BHDifficulty;

typedef struct {
   u8 ai_mask;
   u8 vision;
   u8 warning;
   u8 cooldown;
   u8 follow_rooms;
   u8 carga_limit;
   u8 initial_cafes;
   u8 boss_window;
} BHProfile;

extern const BHProfile bh_profiles[BH_DIFFICULTY_COUNT];
extern BHDifficulty bh_difficulty;

#endif
