/* main.h
*/

//Double buffer config
#define CPCT_LVMEM_START 0x8000 		//lower VMEM page start; higher is standard CPCT_VMEM_START=0xC000

//Game config
#define MAX_SPRITES 10

#define GAME_AREA_TOP 0
#define GAME_AREA_BOTTOM 200
#define GAME_AREA_LEFT 0
#define GAME_AREA_RIGHT 80

#define TOP_BOTTOM_COLLISION 0x01
#define LEFT_RIGHT_COLLISION 0x02

#define MASK_RENDER 0b00000001			//BITMASK to signal which sprites to render (e.g. still on screen)
#define MASK_ANIMATE 0b00000010			//BITMASK to signal which sprites to animate

#define ANIM_CYCLE 16					//max animation frames
#define ANIM_SPEED 1 					//1-4; 4 is faster

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
	u8* turned;							//0 = looking right/front; 1 = looking left (turned)
} TSprite;

extern TSprite sprites[MAX_SPRITES];	//stores all sprites in the game

extern u8 anim_clock;					//animation clock (1 -> ANIMATION_CYCLE)