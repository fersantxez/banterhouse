/* render.c
*/

#include <cpctelera.h>
#include "main.h"
#include "graphics.h"
#include "game.h"

void renderSprites(){

	u8 i;
	u8* sprite;

	for (i = 0; i < MAX_SPRITES; i++) {
		if (sprites[i].id !=0) {						//only live and renderable sprites
			if (sprites[i].properties & MASK_RENDER){
				sprite = sprites[i].sprite_f1;

				cpct_drawSpriteMasked(sprite,
					//on current *mem_start* plus sprite size
					//FIXME: screen limit overflow not working well
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
			cpct_drawSolidBox(
				cpct_getScreenPtr(mem_start, x, y),
				cpct_px2byteM0(5,5),						//background color
				sprites[i].width, sprites[i].height);
		}
	}
}


