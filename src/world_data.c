#include "world_data.h"

/* World copy and compact lookup tables live with immutable graphics below the
 * resident kernel. This preserves the 4 KiB stack/framebuffer safety margin. */
#ifdef __SDCC
#pragma constseg BH_GFX
#endif

/* Named byte arrays keep the CPC text API unsigned while remaining clean under
 * host compilers where plain char has a distinct pointer type. */
static const u8 level_name_0[] = "TODO CLARISIMO";
static const u8 level_name_1[] = "UNA PALABRA MENOS";
static const u8 level_name_2[] = "ROJO DISCRETO";
static const u8 level_name_3[] = "FINAL BUENO";
static const u8 level_name_4[] = "REUNION PREVIA";
static const u8 level_name_5[] = "PREMIO A NOSOTROS";
static const u8 level_name_6[] = "PARA AYER";
static const u8 level_name_7[] = "EL RANKING";
static const u8 level_name_8[] = "DEFINITIVA 12";
static const u8 level_name_9[] = "EL CONSEJO";

const u8* const bh_level_names[10] = {
   level_name_0, level_name_1, level_name_2, level_name_3, level_name_4,
   level_name_5, level_name_6, level_name_7, level_name_8, level_name_9
};

const u8 bh_boss_x[4] = {10, 29, 49, 67};
const u8 bh_boss_y[4] = {43, 84, 43, 84};

u8 bh_world_count_pieces(u16 pieces) {
   u8 index;
   u8 count = 0;
   u16 mask = 1;
   for (index = 0; index < 12; ++index) {
      if (pieces & mask) ++count;
      mask <<= 1;
   }
   return count;
}

u8 bh_world_pickup_id(u8 level, u8 room) {
   if (level == 0) return room < 2 ? room : BH_NONE;
   if (level < 9 && room == 1) return level + 1;
   return BH_NONE;
}

u8 bh_world_level_ready(u8 level, u16 pieces) {
   if (level == 0) return (pieces & 3) == 3;
   if (level < 9) return (pieces & (((u16)1) << (level + 1))) != 0;
   return 0;
}
