#include <cpctelera.h>
#include "main.h"
#include "render.h"
#include "graphics.h"

u8 coord_x; //current sprite position

TSprite sprites[MAX_SPRITES];
u8 cycle;

void init_game() {
	// Initialize storage and config for sprites/game elements

	u8 i; //index

	//init user
	sprites[0].id = 1;												//mark the sprite "alive"
	sprites[0].x = sprites[0].y = 0;								//init position to 0,0
	sprites[0].moveV = sprites[0].moveH = 0;						//init movement to none
	//used to delete prev positions of moving sprites in both (A,B) VMEM pages (double buffer)
	sprites[0].x_prev_A = sprites[0].y_prev_A = sprites[0].x_prev_B = sprites[0].y_prev_B = 0;
	sprites[0].height = G_PITU_H;
	sprites[0].width = G_PITU_W/2;									//!?! /2: - M0, length in bytes = /2 in px
	sprites[0].properties = 0;										//bitmasked properties - init to 0
	sprites[0].properties = sprites[0].properties | MASK_RENDER;	//init to "render"
	sprites[0].sprite_f1 = (u8*)&G_pitu[0]; //&G_pitu[0]			//first position render
	sprites[0].sprite_f2 = (u8*)G_pitu_walk;
	sprites[0].sprite_f3 = (u8*)G_pitu_jump;
	sprites[0].sprite_f3 = (u8*)G_blast;
	//sprites[0].turned = 0

	//clean up memory for sprites - start at zero (e.g. after reset)
	for (i = 1; i < MAX_SPRITES; i++)
		sprites[i].id=0;

	cycle=0;

}

void keyboard(){
	sprites[0].moveV = sprites[0].moveH = 0; 						//start with no movement

	cpct_scanKeyboard_f();											//read keyboard/joystick
	if (cpct_isKeyPressed(Key_CursorUp) || cpct_isKeyPressed(Key_Q) || cpct_isKeyPressed(Joy0_Up)){	
		sprites[0].moveV = -1;		
	}
	if (cpct_isKeyPressed(Key_CursorDown) || cpct_isKeyPressed(Key_A) || cpct_isKeyPressed(Joy0_Down)){
		sprites[0].moveV = 1;
	}
	if (cpct_isKeyPressed(Key_CursorLeft) || cpct_isKeyPressed(Key_O) || cpct_isKeyPressed(Joy0_Left)){
		sprites[0].moveH = -1;
		//sprites[0].turned = 1;
	}
	if (cpct_isKeyPressed(Key_CursorRight) || cpct_isKeyPressed(Key_P) || cpct_isKeyPressed(Joy0_Right)){
		sprites[0].moveH = 1;
		//sprites[0].turned = 1;
	}
}

void AI(){
}

void moveSprites() {
	u8 i,x,y,collision;

	for (i=0; i < MAX_SPRITES; i++) {
		if (sprites[i].id !=0) {			//check only live sprites to optimize CPU (non-zero)
			collision = 0;

			x = sprites[i].x;
			y = sprites[i].y;

			y = y + (4*sprites[i].moveV);	//vertical movement: Y is *px, X is *byte. M0 so Y is 4 times slower
			x = x + (sprites[i].moveH);

			//If outside GAME AREA signal collision
			/*if (y > (GAME_AREA_BOTTOM - sprites[i].height))
				collision = collision | 0x01; //top or down collision
			if (x > (GAME_AREA_RIGHT - sprites[i].width))
				collision = collision } 0x02; //left of right collision
			*/
			//Treat vertical and horizonal collision differently for effect
			if ((collision & 0x01) == 0)
				sprites[i].y = y;
			if ((collision & 0x02) == 0)
				sprites[i].x = x;
		}
	}
}

void game(){
	cpct_setBorder(HW_WHITE);
	//clear screen from "LVMEM" to "VMEM" for "double buffer" - 0x8000 to 0xFFFF: 0x8000 long
	cpct_memset ((u8*)CPCT_LVMEM_START, cpct_px2byteM0(5, 5), 0x8000); //5 is ordinal for WHITE from palette in M0 with 16c

	coord_x = 0;

	while (1) {

		//double buffer: switch screen to be painted in next sync
		if (!swap_memvideo) { 				//switch
			mem_start = (u8*) CPCT_LVMEM_START;		//lower VMEM page
			mem_page = cpct_page80;					//FIXME:: can probably delete??
		} else {
			mem_start = (u8*) CPCT_VMEM_START;		//upper,regular VMEM page
			mem_page = cpct_pageC0;
		}

		//collisions(); 						//check collisions before next move
		keyboard(); 							//user movement
		//AI();									//decide next move for bad guys
		moveSprites();
		deleteSprites();
		renderSprites();

		//Wait for screen ready
		cpct_waitVSYNC();						//Wait until CRTC has printed a full frame to "repaint"
		cpct_setVideoMemoryPage(mem_page);		//Tell CRTC to "paint" the new page--FIXME: can this use "mem_start" instead?
		swap_memvideo = ~swap_memvideo; 		//flip the switch

		cycle++;
		if (cycle == 16)
			cycle=0;
		}
}