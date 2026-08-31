#ifndef BANTERHOUSE_WORLD_DATA_H
#define BANTERHOUSE_WORLD_DATA_H

#include "bh_types.h"

#define BH_NONE      255
#define BH_PHONE_X    12
#define BH_PHONE_Y   118
#define BH_COFFEE_X   62
#define BH_COFFEE_Y   42
#define BH_IDEA_X     37
#define BH_IDEA_Y    106
#define BH_TRAY_X     38
#define BH_TRAY_Y    112

extern const u8* const bh_level_names[10];
extern const u8 bh_boss_x[4];
extern const u8 bh_boss_y[4];

u8 bh_world_count_pieces(u16 pieces);
u8 bh_world_pickup_id(u8 level, u8 room);
u8 bh_world_level_ready(u8 level, u16 pieces);

#endif
