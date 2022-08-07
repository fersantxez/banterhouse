#ifndef _GRAPHICS_H_
#define _GRAPHICS_H_

#include <types.h>
extern const u8 g_palette[16];

//Mode 0: 1 byte holds 2 pixels in width (4bits / pixel)--> widths in bytes are half than in pixels

#define G_PITU_W 7 									//Account for "px to byte" translation for CPC video mode
#define G_PITU_H 32
extern const unsigned char G_pitu[14 * 32];			//14 * 32] pixels - each horizontal pixel is 4 bits

#define G_PITU_REV_W 7
#define G_PITU_REV_H 32
extern const unsigned char G_pitu_rev[14 * 32];

#define G_PITU_WALK_W 7
#define G_PITU_WALK_H 32
extern const unsigned char G_pitu_walk[14 * 32];

#define G_PITU_WALK_REV_W 7
#define G_PITU_WALK_REV_H 32
extern const unsigned char G_pitu_walk_rev[14 * 32];

#define G_PITU_JUMP_W 7
#define G_PITU_JUMP_H 32
extern const unsigned char G_pitu_jump[14 * 32];

#define G_PITU_JUMP_REV_W 7
#define G_PITU_JUMP_REV_H 32
extern const unsigned char G_pitu_jump_rev[14 * 32];

#define G_ALBERTO_W 7
#define G_ALBERTO_H 32
extern const unsigned char G_alberto[14 * 32];

#define G_ALBERTO_REV_W 7
#define G_ALBERTO_REV_H 32
extern const unsigned char G_alberto[14 * 32];

#define G_ALBERTO_WALK_W 7
#define G_ALBERTO_WALK_H 32
extern const unsigned char G_alberto_walk[14 * 32];

#define G_ALBERTO_WALK_REV_W 7
#define G_ALBERTO_WALK_REV_H 32
extern const unsigned char G_alberto_walk[14 * 32];

#define G_BLAST_W 7
#define G_BLAST_H 30
extern const unsigned char G_blast[14 * 30];

#define G_BEER_W 4
#define G_BEER_H 11
extern const unsigned char G_beer[8 * 11];

#define G_BEER_REV_W 4
#define G_BEER_REV_H 11
extern const unsigned char G_beer[8 * 11];

#define G_LOGO_W 32
#define G_LOGO_H 32
extern const unsigned char G_logo[64*32]; //[64 * 32] px

#endif