#ifndef BANTERHOUSE_ROOM_VISUALS_H
#define BANTERHOUSE_ROOM_VISUALS_H

#include "bh_types.h"

typedef struct {
   u8 x, y, width, height, colour;
} BHBackdropRect;

typedef struct {
   u16 first_rect;
   u8 rect_count;
   u8 paper, ink, accent, shadow;
} BHRoomVisual;

extern const BHBackdropRect bh_backdrop_rects[];
extern const BHRoomVisual bh_room_visuals[30];
extern const u8* const bh_room_labels[30];

#endif
