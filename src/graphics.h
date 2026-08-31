#ifndef _GRAPHICS_H_
#define _GRAPHICS_H_

#include <types.h>
extern const u8 g_palette[16];

//Mode 0: 1 byte holds 2 pixels in width (4bits / pixel)--> widths in bytes are half than in pixels

#define G_PITU_W 8 									//Account for "px to byte" translation for CPC video mode
#define G_PITU_H 32
extern const unsigned char g_pitu[16 * 32];			//16 * 32] pixels - each horizontal pixel is 4 bits
extern unsigned char g_pitu_rev[16 * 32];

#define G_PITU_WALK_W 8
#define G_PITU_WALK_H 32
extern const unsigned char g_pitu_walk[16 * 32];
extern unsigned char g_pitu_walk_rev[16 * 32];

#define G_ALBERTO_W 8
#define G_ALBERTO_H 32
extern const unsigned char g_alberto[16 * 32];
extern unsigned char g_alberto_rev[16 * 32];

#define G_ALBERTO_WALK_W 8
#define G_ALBERTO_WALK_H 32
extern const unsigned char g_alberto_walk[16 * 32];
extern unsigned char g_alberto_walk_rev[16 * 32];

#define G_LOGO_W 63                              // Mode 0 bytes: 126 pixels
#define G_LOGO_H 34
extern const unsigned char g_logo[G_LOGO_W * G_LOGO_H];

#endif
