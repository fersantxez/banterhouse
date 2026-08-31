#ifndef BANTERHOUSE_MAIN_H
#define BANTERHOUSE_MAIN_H

#include <types.h>

#define BH_SCREEN_W        80
#define BH_SCREEN_H        200
#define BH_LVMEM_START  0x8000
#define BH_HUD_H           16
#define BH_PLAY_TOP        18
#define BH_PLAY_BOTTOM     168
#define BH_PLAYER_W         8
#define BH_PLAYER_H        32
#define BH_MAX_X           72
#define BH_LEVELS          10
#define BH_ROOMS_PER_LEVEL  3

extern const u8 bh_palette[16];

#endif
