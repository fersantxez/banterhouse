/* main.h
*/

#ifndef _MAIN_H_
#define _MAIN_H_

//Double buffer config
#define CPCT_LVMEM_START 0x8000 		//lower VMEM page start; higher is standard CPCT_VMEM_START=0xC000

//Game config
#define MAX_SPRITES 10

#define GAME_AREA_TOP 16				//leave room for a scoreboard etc. 0-16 (2 chars)
#define GAME_AREA_BOTTOM 200
#define GAME_AREA_LEFT 0
#define GAME_AREA_RIGHT 80

//FIXME: This should be in the header file from the map but now it's not generated automatically
#define g_map_W 20
#define g_map_H 23

#define MAX_TILES_SOLID 31				//tiles are grouped by nature and sorted by row in tileset
#define MAX_TILES_LETHAL 47				//tiles 0-31 (first two rows) are solid, 32-47 are lethal. 47+ decoration

#define TILE_BACKGROUND 0
#define TILE_SOLID 1
#define TILE_LETHAL 2

#define MASK_RENDER 		0b00000001	//BITMASK to signal which sprites to render (e.g. still on screen)
#define MASK_ANIMATE 		0b00000010	//BITMASK to signal which sprites to animate

#define RIGHT_COLLISION			0b00000010
#define LEFT_COLLISION 			0b00001010
#define LEFT_RIGHT_COLLISION	0b00000010
#define BOTTOM_COLLISION 		0b00000001
#define TOP_COLLISION 			0b00000101
#define TOP_BOTTOM_COLLISION 	0b00000001

#define ANIM_CYCLE 16					//max animation frames
#define ANIM_SPEED 2 					//1-4; 4 is faster

//Double buffer storage
extern u8* mem_start;					//current vmem_start - 0xC000/CPCT_VMEM_START for page 1,0x8000/CPCT_LVMEM_START for page 0
extern u8 mem_page;   					//used for CRTC to know which page to start on - can be deduced from above
extern u8 swap_memvideo; 				//boolean switch one to the other

//Position and movement of all entities in the game
typedef struct {
	u8 id;								//0=DONT USE; 1=USER
	u8 x;								//X position for entity
	u8 y;								//Y position for entity
	i8 moveV; 							//0=NOOP; -1=UP; 1=DOWN
	i8 moveH;							//0=NOOP; -1=LEFT; 1=RIGHT
	u8 x_prev_A;						//prev X position, page 0 (double buffer)
	u8 y_prev_A;						//prev Y position, page 0 (double buffer)
	u8 x_prev_B;						//prev X position, page 1 (double buffer)
	u8 y_prev_B;						//prev Y position, page 1 (double buffer)
	u8 height;							//entity height
	u8 width;							//entity width
	u8 properties;						//defines each entity properties
	i8 data1;							//extra - use for AI
	i8 data2;							//extra - use for AI
	u8 frames;							//how many movement frames a sprite has
	u8* sprite_f1;						//sprite frame 1 "e.g. normal"
	u8* sprite_f2;						//sprite frame 2 "e.g. walking"
	u8* sprite_f3;						//sprite frame 3 "e.g. jumping"
	u8* sprite_f4;						//sprite frame 4 "e.g. dying"
	u8 turned;							//0 = looking right/front; 1 = looking left (turned)
} TSprite;

extern TSprite sprites[MAX_SPRITES];	//stores all sprites in the game
extern u8 anim_clock;					//animation clock (1 -> ANIMATION_CYCLE)
extern u8 map[g_map_W*g_map_H];					//FIXME: Use G_map_W/H instead. //buffer to store current level background

#endif