#include <cpctelera.h>
#include "main.h"
#include "graphics.h"
#include "game.h"

void renderSprites(){
	//drawSpriteMasked! sprite built w/"Mask Data Inline" in RGAS - double size!
	cpct_drawSpriteMasked(G_pitu, cpct_getScreenPtr( mem_start, coord_x, 0), G_PITU_W/2, G_PITU_H);
}

//Paint a square of W:G_PITU_W and H:G_PITU_H with the background color to delete the sprite
//We delete the sprite in "coord_x-2" because we're deleting the position we were in two frames ago
void renderDelete(){
	cpct_drawSolidBox(cpct_getScreenPtr( mem_start, coord_x-2, 0), cpct_px2byteM0(5,5), G_PITU_W/2, G_PITU_H);
}

