/* render.h
*/
#ifndef _RENDER_H_
#define _RENDER_H_

void renderSprites();		//Draw all sprites in storage masked, save their curr position as prev to delete in next cycle
void deleteSprites();		//Render squares with the background on the prev position of every sprite


#endif