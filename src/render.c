/* render.c
*/

#include <cpctelera.h>
#include <math.h>
#include <float.h>
#include "main.h"
#include "graphics.h"
#include "game.h"
#include "tileset.h"

void redrawTile(u8* mem_start, u8 x, u8 y, u8 width, u8 height) {
	u8 new_x;												//x aligned to a tile start
	u8 new_y;												//y aligned to a tile start
	u8 new_width;											//number of tiles the sprite fills
	u8 new_height;
	u16 first_tile;											//first tile the sprite is filling

	//ensure x and y are the beginning of a tile (tiles are 8x8)
	new_x = x - (x % 4);									//x is bytes not pixels - M0
	new_y = y - (y % 8) - GAME_AREA_TOP;					//remove the space for scoreboard

	//find out # of tiles that make height and width
	//if not aligned with a tile we need to also pick the next one
	new_width = (width / 4);
	if (width % 4)
		new_width++;

	new_height = (height / 8);
	if (height % 8)
		new_height++;

	//first tile of tilemap to render (20 is number of tiles per row)
	first_tile = (new_y / 8) * 20 + (new_x / 4); 				//from "coords" to tiles

	cpct_etm_setDrawTilemap4x8_ag( new_width, new_height, 20, G_tileset_00 );
	cpct_etm_drawTilemap4x8_ag( (u8*)cpct_getScreenPtr( mem_start, new_x, new_y + GAME_AREA_TOP), &map[first_tile] );
}

void renderSprites(){

	u8 i, num_frame;
	u8* sprite;

	for (i = 0; i < MAX_SPRITES; i++) {
		if (sprites[i].id !=0) {							//only live and renderable sprites
			if (sprites[i].properties & MASK_RENDER) {
				//print the appropriate frame depending on cycle and how many frames a sprite has 
				if (sprites[i].properties & MASK_ANIMATE) {

					//FIXME: this errors out with "error 101: too many parameters "
					//int frame;
					//frame=((sprites[i].frames*anim_clock)/ANIM_CYCLE);
					//num_frame=ceil(frame);
					
					//quick fix for this specific scenario:
					if (anim_clock > 7) num_frame=2;
					else num_frame=1;

					//FIXME: my eyes hurt
					if (num_frame == 1) {
						sprite = sprites[i].sprite_f1; 
						} else if (num_frame == 2) {
							sprite = sprites[i].sprite_f2;
							} else if (num_frame == 3) { 
								sprite = sprites[i].sprite_f3; 
								} else sprite = sprites[i].sprite_f4;
				} else sprite = sprites[i].sprite_f1;

				if (sprites[i].turned)							//turn sprite around
					//cpct_hflipSpriteMaskedM0(sprites[i].width, sprites[i].height, sprite);
					sprite = sprite + ((G_PITU_W*2)*G_PITU_H);	//find next sprite in memory, "rev" version

				cpct_drawSpriteMasked(sprite,
					//on current *mem_start* plus sprite size
					cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y),
					sprites[i].width, sprites[i].height);

			}

			//Save position in the sprite struct to erase after movement 
			if (!swap_memvideo) {
				sprites[i].x_prev_B = sprites[i].x;
				sprites[i].y_prev_B = sprites[i].y;
			} else {
				sprites[i].x_prev_A = sprites[i].x;
				sprites[i].y_prev_A = sprites[i].y;
			}
		}
	}
}

void deleteSprites(){

	u8 x, y;
	u8 i;

	for (i = 0; i < MAX_SPRITES; i++) {
		if (sprites[i].id !=0) {
			if (!swap_memvideo){
				x = sprites[i].x_prev_B;
				y = sprites[i].y_prev_B;
			}
			else {
				x = sprites[i].x_prev_A;
				y = sprites[i].y_prev_A;
			}
			/*This won't work with a non-solid background:
			cpct_drawSolidBox(
				cpct_getScreenPtr(mem_start, x, y),
				cpct_px2byteM0(5,5),						//background color
				sprites[i].width, sprites[i].height);*/
			redrawTile(mem_start, x, y, sprites[i].width, sprites[i].height);
		}
	}
}


