/* main.c
*/

#include <cpctelera.h>
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
      init_game();
      game();
   }
   
}
