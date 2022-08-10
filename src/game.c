/* game.c
*/

#include <cpctelera.h>
#include "main.h"
#include "render.h"
#include "graphics.h"

#include "tileset.h"
#include "scr01.h"

/* FIXME: Doc me how
*/
void keyboard(){
	// Read keyboard and move user's sprite

	sprites[0].moveV = sprites[0].moveH = 0; 							//start with no movement

	//sprite movement: read keyboard/joystick and update movement registers
	cpct_scanKeyboard_f();
	if (cpct_isKeyPressed(Key_CursorUp) || cpct_isKeyPressed(Key_Q) || cpct_isKeyPressed(Joy0_Up)){	
		sprites[0].moveV = -1;		
	}
	if (cpct_isKeyPressed(Key_CursorDown) || cpct_isKeyPressed(Key_A) || cpct_isKeyPressed(Joy0_Down)){
		sprites[0].moveV = 1;
	}
	if (cpct_isKeyPressed(Key_CursorLeft) || cpct_isKeyPressed(Key_O) || cpct_isKeyPressed(Joy0_Left)){
		sprites[0].moveH = -1;
		sprites[0].turned = 1;
	}
	if (cpct_isKeyPressed(Key_CursorRight) || cpct_isKeyPressed(Key_P) || cpct_isKeyPressed(Joy0_Right)){
		sprites[0].moveH = 1;
		sprites[0].turned = 0;
	}

	//sprite animation: if sprite moved, mark for animation
	if (sprites[0].moveH !=0 || sprites[0].moveV !=0)					//sprite moved
		sprites[0].properties = sprites[0].properties | MASK_ANIMATE; 	//mark for animation
	else
		sprites[0].properties = sprites[0].properties & ~MASK_ANIMATE;	//unmark for animation;
}

/* FIXME: Doc me how
*/
void AI(){
}

/* FIXME: Doc me how
*/
void moveSprites() {

	u8 i,x,y,collision;

	for (i=0; i < MAX_SPRITES; i++) {
		if (sprites[i].id !=0) {			//check only live sprites to optimize CPU (non-zero)
			collision = 0;

			x = sprites[i].x;
			y = sprites[i].y;

			x = x + (sprites[i].moveH);
			y = y + (4*sprites[i].moveV);	//vertical movement: Y is *px, X is *byte. M0 so Y is 4 times slower

			//GAME AREA: If outside, signal collision with corresponding bitmask
			if (x > (GAME_AREA_RIGHT - sprites[i].width))
				collision = collision | RIGHT_COLLISION;
			if (x < GAME_AREA_LEFT)
				collision = collision | LEFT_COLLISION;

			if (y > (GAME_AREA_BOTTOM - sprites[i].height))
				collision = collision | BOTTOM_COLLISION;
			if (y < GAME_AREA_TOP)
				collision = collision | TOP_COLLISION;
			
			//Treat vertical and horizonal collision differently so that
			//diagonal collision doesn't block both directions
			if ((collision & LEFT_RIGHT_COLLISION) == 0)		//if not hitting right, move up/down
				sprites[i].x = x;								//keep x as it was
			//FIXME: not working - always believes there's TOPDOWN collision so not moving up or down
			if ((collision & TOP_BOTTOM_COLLISION) == 0)		//if not hitting top, move sideways //
				sprites[i].y = y;								//keep y as it was
		}
	}
}

/*	FIXME: Doc me how
	Initialize screen from tilemap for each level
*/
void init_level() {
	u8* map_ptr;
	map_ptr = (u8 *)scr01_end; //FIXME: need better naming

	//copy map to buffer - used for decompressing into memory when compression is used
	//cpct_memcpy((u8*)&map[0], (u8*)&g_map[0], g_map_W*g_map_H);	//no compression
	cpct_zx7b_decrunch_s((void *)(&map[0]+((g_map_W*g_map_H)-1)),(void *)map_ptr);

	//initalize tilemap - can use 2x4 if tiles are small
	cpct_etm_setDrawTilemap4x8_ag( g_map_W, g_map_H, g_map_W, &g_tileset_00[0]); //3rd param (20,g_map_W) is how many tiles per line
	//render the tilemap on both Video Mem pages (double buffer)
	cpct_etm_drawTilemap4x8_ag( cpctm_screenPtr((u8*) CPCT_VMEM_START, GAME_AREA_LEFT, GAME_AREA_TOP), &map[0] );
	cpct_etm_drawTilemap4x8_ag( cpctm_screenPtr((u8*) CPCT_LVMEM_START, GAME_AREA_LEFT, GAME_AREA_TOP), &map[0] );

}

/*	FIXME: Doc me how
*/
void collisions() {
}

/*	FIXME: Doc me how
	Initialize storage and config for sprites/game elements
*/
void init_game() {
	u8 i; //index

	sprites[0].id = 1;												//mark the sprite "alive" (non-zero)
	sprites[0].x = GAME_AREA_LEFT;									//init position to 0,0
	sprites[0].y = GAME_AREA_TOP;
	sprites[0].moveV = sprites[0].moveH = 0;						//init movement to none
	//refs to prev positions of moving sprites in both (A,B) VMEM pages (double buffer) - init to 0
	sprites[0].x_prev_A = sprites[0].x_prev_B = GAME_AREA_LEFT;		//init prev position to 0,0
	sprites[0].y_prev_A = sprites[0].y_prev_B = GAME_AREA_TOP;
	sprites[0].height = G_PITU_H;
	sprites[0].width = G_PITU_W;									//!?! /2: - M0, length in bytes = /2 in px
	sprites[0].properties = 0;										//bitmasked properties - init to 0
	sprites[0].properties = sprites[0].properties | MASK_RENDER;	//init to "render" on screen
	sprites[0].frames = 2;											//main sprite has two "moves" to animate
	sprites[0].sprite_f1 = (u8*)g_pitu; 							//first render for sprite. &G_pitu[0]
	sprites[0].sprite_f2 = (u8*)g_pitu_walk;
	sprites[0].sprite_f3 = (u8*)g_pitu_jump;
	sprites[0].sprite_f3 = (u8*)g_blast;
	sprites[0].turned = 0;											//start looking right/front

	//zero out memory for sprites (e.g. after reset)
	for (i = 1; i < MAX_SPRITES; i++)
		sprites[i].id=0;

	anim_clock=1;

}

/* FIXME: Doc me how
*/
void game(){

	cpct_setBorder(HW_WHITE);
	//clear screen from "LVMEM" to "VMEM" for "double buffer" - 0x8000 to 0xFFFF: 0x8000 long
	cpct_memset ((u8*)CPCT_LVMEM_START, cpct_px2byteM0(5, 5), 0x8000); //5 is ordinal for WHITE from palette in M0 with 16c
	init_level();								//render first level background

	while (1) {

		//double buffer: switch screen to be painted in next sync
		if (!swap_memvideo) { 					//switch
			mem_start = (u8*) CPCT_LVMEM_START;	//lower VMEM page
			mem_page = cpct_page80;				//FIXME:: can probably delete??
		} else {
			mem_start = (u8*) CPCT_VMEM_START;	//upper,regular VMEM page
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

		anim_clock+=ANIM_SPEED;
		if (anim_clock > ANIM_CYCLE)
			anim_clock=1;
		}
}