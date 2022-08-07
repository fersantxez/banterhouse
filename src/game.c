#include <cpctelera.h>
#include "main.h"
#include "render.h"
#include "graphics.h"

u8 coord_x; //current sprite position

void game(){
	cpct_setBorder(HW_BLACK);
	//clear screen from "LVMEM" to "VMEM" for "double buffer" - 0x8000 to 0xFFFF: 0x8000 long
	cpct_memset ((u8*)CPCT_LVMEM_START, cpct_px2byteM0(5, 5), 0x8000); //5 is ordinal for WHITE from palette in M0 with 16c

	coord_x = 0;

	while (1) {
		//Change screen to be painted in next sync
		if (!swap_memvideo) { 				//switch
			mem_start = (u8*) CPCT_LVMEM_START;		//lower page
			mem_page = cpct_page80;					//FIXME:: can probably delete??
		} else {
			mem_start = (u8*) CPCT_VMEM_START;		//upper,regular VMEM page
			mem_page = cpct_pageC0;
		}

	renderDelete();							//delete the sprites--- only the changed ones?
	renderSprites();						//paint the new sprites???
	swap_memvideo = ~swap_memvideo; 		//flip the switch
	//Wait for screen ready
	cpct_waitVSYNC();						//Wait until CRTC has printed a full frame to "repaint"
	cpct_setVideoMemoryPage(mem_page);		//Tell CRTC to "paint" the new page--FIXME: can this use "mem_start" instead?

	coord_x++; 								//scroll right
	if (coord_x == 72) 						//end of screen
		break;

	}
}