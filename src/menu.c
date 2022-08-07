#include <cpctelera.h>
#include "graphics.h"
#include "main.h"

void menu () {
    //Paint border and clear Screen
    cpct_setBorder(HW_WHITE);
    cpct_memset(mem_start, cpct_px2byteM0(5,5), 0x4000); //5=WHITE ordinal from palette; 0x4000 is VMEM_SIZE

    //Logo
	cpct_drawSprite(G_logo,
		cpctm_screenPtr(CPCT_VMEM_START, 25, 50),
		G_LOGO_W,G_LOGO_H);

	//Press key message
	cpct_setDrawCharM0 (10, 7); //fg color=15, bg color=5. CPCT>1.5 requires initializing before "drawString"
	cpct_drawStringM0("Press S to Start", cpctm_screenPtr(CPCT_VMEM_START, 10, 160 )); //X=(byte 10)=(pixel 20);Y=(line 160)

	//If a key is pressed at launch wait until it isn't
	do {
		cpct_scanKeyboard_f();
	} while (cpct_isAnyKeyPressed_f());
	//Scan keyboard until key S is pressed
	while (!cpct_isKeyPressed(Key_S)) //any key: cpct_isAnyKeyPressed_f())
		cpct_scanKeyboard_f();
}