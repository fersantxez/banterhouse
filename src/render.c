/* render.c
*/

#include <cpctelera.h>
#include <math.h>
#include <float.h>
#include "main.h"
#include "graphics.h"
#include "game.h"

void renderSprites(){

	u8 i, num_frame;
	u8* sprite;

	for (i = 0; i < MAX_SPRITES; i++) {
		if (sprites[i].id !=0) {						//only live and renderable sprites
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

				if (sprites[i].turned)					//turn sprite around
					cpct_hflipSpriteMaskedM0(sprites[i].width, sprites[i].height, sprite);

				cpct_drawSpriteMasked(sprite,
					//on current *mem_start* plus sprite size
					cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y),
					sprites[i].width, sprites[i].height);

				if (sprites[i].turned)					//turn back to normal (looking right)
					cpct_hflipSpriteMaskedM0(sprites[i].width, sprites[i].height, sprite);

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


