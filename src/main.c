/* main.c
*/

#include <cpctelera.h>
#include "main.h"
#include "menu.h"
#include "game.h"


/* Palette:
Definition of palette in code needs HW values. 
Can get FW values from RGAS and map to FW_XX then to HW_XX
https://www.cpcwiki.eu/index.php/Video_modes#Colour_attributes
e.g. with these coming from RGAS as FW_VALUES in image_conversion.mk:
PALETTE={\
   FW_BLACK FW_BRIGHT_WHITE FW_SKY_BLUE FW_BRIGHT_CYAN\
   FW_PASTEL_CYAN FW_WHITE FW_BRIGHT_GREEN FW_PASTEL_GREEN\
   FW_PASTEL_YELLOW FW_RED FW_PURPLE FW_PASTEL_MAGENTA\
   FW_ORANGE FW_PINK FW_YELLOW FW_BLUE\
   }
*/
const u8 paleta[16] = {\
   HW_BLACK, HW_BRIGHT_WHITE, HW_SKY_BLUE, HW_BRIGHT_CYAN,\
   HW_PASTEL_CYAN, HW_WHITE, HW_BRIGHT_GREEN, HW_PASTEL_GREEN,\
   HW_PASTEL_YELLOW, HW_RED, HW_PURPLE, HW_PASTEL_MAGENTA,\
   HW_ORANGE, HW_PINK, HW_YELLOW, HW_BLUE\
   };

u8* mem_start;          //current vmem_start - 0xC000/CPCT_VMEM_START or 0x8000/CPCT_LVMEM_START for "page" 0 or 1
u8 mem_page;            //used for CRTC to know which page to start on - can be deduced from above
u8 swap_memvideo;       //boolean switch one to the other

u8 map [g_map_W*g_map_H];                                          //buffer to store current level background
TSprite sprites [MAX_SPRITES];
u8 anim_clock;


//====
#define CHART_ROWS 9             //"map" of screens to form larger "chart"
#define CHART_COLUMNS 8             //9*8 = 72 rooms total 

u8 current_room;
u8 chart_done[(CHART_ROWS*CHART_COLUMNS)/8];   //1 "done" bit per room, so 8 rooms per byte.

//only need 4 exits per room. Each byte holds two roomS.
//each bit represents whether the up, down, left, right exits are open/exist
//room 1 is open right and down: 0101
//room 2 is open left and right: 0011
//so first byte is 0b01010011

/* MAP STRUCTURE
*-*-* S-* * *-*
|   | | | | | |
*-*-*-*-*-*-*-*
  | |     |   |
*-* *-*-*-* *-*
            |  
*-*-*-* *-* *-*
|     | | |   |
*-* *-*-* *-* *
  |   | |   | |
*-* *-* * *-*-*
|              
*-*-* *-*-*-* *
  |   |     | |
*-*-*-*-* *-* *
    |     | | |
*-*-*-* E-* *-*

*/

//FIXME: Ideally this would be randomly initialized on game start
const u8 chart[(CHART_ROWS*CHART_COLUMNS)/2] = {
0b01010011, 0b01100101, 0b01100100, 0b01010110,
0b10000101, 0b11111010, 0b10001101, 0b10101100,
0b00011010, 0b10010011, 0b00111010, 0b01011010,
0b01010011, 0b00110110, 0b01010110, 0b10010110,
0b10010110, 0b00011111, 0b11101001, 0b01101100,
0b01011010, 0b00011010, 0b10000001, 0b10111010,
0b10010111, 0b00100101, 0b00110011, 0b01100100,
0b00011011, 0b01111011, 0b00100101, 0b11101100,
0b00010011, 0b10110010, 0b00011010, 0b10011010
};





//====
void main(void) {
   u8* pvmem;                                   // Pointer to video memory

   cpct_setStackLocation ((u8*) 0x7FFF);        //Move stack to right before double buffer 0X8000
   cpct_disableFirmware();

   cpct_setVideoMode(0); //160x200; 16 colors in screen
   cpct_setPalette(paleta,16);

   while (1) {
      //Initialize double buffer
      //FIXME: these three vars can likely can be reduced to one
      swap_memvideo = 0;                        //set DB switch to "zero" (upper VMEM page first)
      mem_start = (u8*) CPCT_VMEM_START;        //upper, standard VMEM page first
      mem_page = cpct_pageC0;                   //upper, C0 page

      menu();
      initGame();
      game();
   }
   
}
