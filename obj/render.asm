;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.6.8 #9946 (Linux)
;--------------------------------------------------------
	.module render
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _deleteSprites
	.globl _renderSprites
	.globl _redrawTile
	.globl _cpct_etm_drawTilemap4x8_ag
	.globl _cpct_etm_setDrawTilemap4x8_ag
	.globl _cpct_getScreenPtr
	.globl _cpct_drawSpriteMasked
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area _DABS (ABS)
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area _HOME
	.area _GSINIT
	.area _GSFINAL
	.area _GSINIT
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area _HOME
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
;src/render.c:12: void redrawTile(u8* mem_start, u8 x, u8 y, u8 width, u8 height) {
;	---------------------------------
; Function redrawTile
; ---------------------------------
_redrawTile::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
	dec	sp
;src/render.c:20: new_x = x - (x % 4);									//x is bytes not pixels - M0
	ld	a, 6 (ix)
	and	a, #0x03
	ld	c, a
	ld	a, 6 (ix)
	sub	a, c
	ld	-3 (ix), a
;src/render.c:21: new_y = y - (y % 8) - GAME_AREA_TOP;					//remove the space for scoreboard
	ld	a, 7 (ix)
	and	a, #0x07
	ld	c, a
	ld	a, 7 (ix)
	sub	a, c
	add	a, #0xf0
	ld	e, a
;src/render.c:25: new_width = (width / 4);
	ld	c, 8 (ix)
	srl	c
	srl	c
;src/render.c:26: if (width % 4)
	ld	a, 8 (ix)
	and	a, #0x03
	jr	Z,00102$
;src/render.c:27: new_width++;
	inc	c
00102$:
;src/render.c:29: new_height = (height / 8);
	ld	b, 9 (ix)
	srl	b
	srl	b
	srl	b
;src/render.c:30: if (height % 8)
	ld	a, 9 (ix)
	and	a, #0x07
	jr	Z,00104$
;src/render.c:31: new_height++;
	inc	b
00104$:
;src/render.c:34: first_tile = (new_y / 8) * 20 + (new_x / 4); 				//from "coords" to tiles
	ld	a, e
	rrca
	rrca
	rrca
	and	a, #0x1f
	push	de
	ld	e,a
	ld	d,#0x00
	ld	l, e
	ld	h, d
	add	hl, hl
	add	hl, hl
	add	hl, de
	add	hl, hl
	add	hl, hl
	pop	de
	ld	a, -3 (ix)
	rrca
	rrca
	and	a, #0x3f
	ld	-2 (ix), a
	ld	-1 (ix), #0x00
	ld	a, l
	add	a, -2 (ix)
	ld	l, a
	ld	a, h
	adc	a, -1 (ix)
	ld	h, a
	inc	sp
	inc	sp
	push	hl
;src/render.c:36: cpct_etm_setDrawTilemap4x8_ag( new_width, new_height, 20, G_tileset_00 );
	push	de
	ld	hl, #_G_tileset_00
	push	hl
	ld	hl, #0x0014
	push	hl
	push	bc
	call	_cpct_etm_setDrawTilemap4x8_ag
	pop	de
;src/render.c:37: cpct_etm_drawTilemap4x8_ag( (u8*)cpct_getScreenPtr( mem_start, new_x, new_y + GAME_AREA_TOP), &map[first_tile] );
	ld	a, -5 (ix)
	add	a, #<(_map)
	ld	c, a
	ld	a, -4 (ix)
	adc	a, #>(_map)
	ld	b, a
	ld	a, e
	add	a, #0x10
	ld	h, a
	ld	e,4 (ix)
	ld	d,5 (ix)
	push	bc
	push	hl
	inc	sp
	ld	a, -3 (ix)
	push	af
	inc	sp
	push	de
	call	_cpct_getScreenPtr
	push	hl
	call	_cpct_etm_drawTilemap4x8_ag
	ld	sp, ix
	pop	ix
	ret
;src/render.c:40: void renderSprites(){
;	---------------------------------
; Function renderSprites
; ---------------------------------
_renderSprites::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-10
	add	hl, sp
	ld	sp, hl
;src/render.c:45: for (i = 0; i < MAX_SPRITES; i++) {
	ld	-10 (ix), #0x00
00126$:
;src/render.c:46: if (sprites[i].id !=0) {							//only live and renderable sprites
	ld	c,-10 (ix)
	ld	b,#0x00
	ld	l, c
	ld	h, b
	add	hl, hl
	add	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	bc,#_sprites
	add	hl,bc
	ld	-4 (ix), l
	ld	-3 (ix), h
	ld	a, (hl)
	or	a, a
	jp	Z, 00127$
;src/render.c:47: if (sprites[i].properties & MASK_RENDER) {
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	ld	de, #0x000b
	add	hl, de
	ld	c, (hl)
;src/render.c:76: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y),
	ld	a, -4 (ix)
	add	a, #0x02
	ld	-6 (ix), a
	ld	a, -3 (ix)
	adc	a, #0x00
	ld	-5 (ix), a
	ld	a, -4 (ix)
	add	a, #0x01
	ld	-8 (ix), a
	ld	a, -3 (ix)
	adc	a, #0x00
	ld	-7 (ix), a
;src/render.c:47: if (sprites[i].properties & MASK_RENDER) {
	bit	0, c
	jp	Z,00119$
;src/render.c:62: sprite = sprites[i].sprite_f1; 
	ld	a, -4 (ix)
	add	a, #0x0f
	ld	-2 (ix), a
	ld	a, -3 (ix)
	adc	a, #0x00
	ld	-1 (ix), a
;src/render.c:49: if (sprites[i].properties & MASK_ANIMATE) {
	bit	1, c
	jr	Z,00114$
;src/render.c:57: if (anim_clock > 7) num_frame=2;
	ld	a, #0x07
	ld	iy, #_anim_clock
	sub	a, 0 (iy)
	jr	NC,00102$
	ld	a, #0x02
	jr	00103$
00102$:
;src/render.c:58: else num_frame=1;
	ld	a, #0x01
00103$:
;src/render.c:61: if (num_frame == 1) {
	cp	a, #0x01
	jr	NZ,00111$
;src/render.c:62: sprite = sprites[i].sprite_f1; 
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	jr	00115$
00111$:
;src/render.c:63: } else if (num_frame == 2) {
	cp	a, #0x02
	jr	NZ,00108$
;src/render.c:64: sprite = sprites[i].sprite_f2;
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	ld	de, #0x0011
	add	hl, de
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	jr	00115$
00108$:
;src/render.c:65: } else if (num_frame == 3) { 
	sub	a, #0x03
	jr	NZ,00105$
;src/render.c:66: sprite = sprites[i].sprite_f3; 
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	ld	de, #0x0013
	add	hl, de
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	jr	00115$
00105$:
;src/render.c:67: } else sprite = sprites[i].sprite_f4;
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	ld	de, #0x0015
	add	hl, de
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	jr	00115$
00114$:
;src/render.c:68: } else sprite = sprites[i].sprite_f1;
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
00115$:
;src/render.c:70: if (sprites[i].turned)							//turn sprite around
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	ld	de, #0x0017
	add	hl, de
	ld	a, (hl)
	or	a, a
	jr	Z,00117$
;src/render.c:72: sprite = sprite + ((G_PITU_W*2)*G_PITU_H);	//find next sprite in memory, "rev" version
	ld	hl, #0x01c0
	add	hl,bc
	ld	c, l
	ld	b, h
00117$:
;src/render.c:77: sprites[i].width, sprites[i].height);
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	ld	de, #0x0009
	add	hl, de
	ld	a, (hl)
	ld	-2 (ix), a
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	ld	de, #0x000a
	add	hl, de
	ld	a, (hl)
	ld	-9 (ix), a
;src/render.c:76: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y),
	ld	l,-6 (ix)
	ld	h,-5 (ix)
	ld	e, (hl)
	ld	l,-8 (ix)
	ld	h,-7 (ix)
	ld	d, (hl)
	ld	iy, (_mem_start)
	push	bc
	ld	a, e
	push	af
	inc	sp
	push	de
	inc	sp
	push	iy
	call	_cpct_getScreenPtr
	ex	de,hl
	pop	bc
;src/render.c:74: cpct_drawSpriteMasked(sprite,
	ld	h, -2 (ix)
	ld	l, -9 (ix)
	push	hl
	push	de
	push	bc
	call	_cpct_drawSpriteMasked
00119$:
;src/render.c:76: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y),
	ld	l,-8 (ix)
	ld	h,-7 (ix)
	ld	c, (hl)
;src/render.c:82: if (!swap_memvideo) {
	ld	a,(#_swap_memvideo + 0)
	or	a, a
	jr	NZ,00121$
;src/render.c:83: sprites[i].x_prev_B = sprites[i].x;
	ld	a, -4 (ix)
	add	a, #0x07
	ld	l, a
	ld	a, -3 (ix)
	adc	a, #0x00
	ld	h, a
	ld	(hl), c
;src/render.c:84: sprites[i].y_prev_B = sprites[i].y;
	ld	a, -4 (ix)
	add	a, #0x08
	ld	c, a
	ld	a, -3 (ix)
	adc	a, #0x00
	ld	b, a
	ld	l,-6 (ix)
	ld	h,-5 (ix)
	ld	a, (hl)
	ld	(bc), a
	jr	00127$
00121$:
;src/render.c:86: sprites[i].x_prev_A = sprites[i].x;
	ld	a, -4 (ix)
	add	a, #0x05
	ld	l, a
	ld	a, -3 (ix)
	adc	a, #0x00
	ld	h, a
	ld	(hl), c
;src/render.c:87: sprites[i].y_prev_A = sprites[i].y;
	ld	a, -4 (ix)
	add	a, #0x06
	ld	c, a
	ld	a, -3 (ix)
	adc	a, #0x00
	ld	b, a
	ld	l,-6 (ix)
	ld	h,-5 (ix)
	ld	a, (hl)
	ld	(bc), a
00127$:
;src/render.c:45: for (i = 0; i < MAX_SPRITES; i++) {
	inc	-10 (ix)
	ld	a, -10 (ix)
	sub	a, #0x0a
	jp	C, 00126$
	ld	sp, ix
	pop	ix
	ret
;src/render.c:93: void deleteSprites(){
;	---------------------------------
; Function deleteSprites
; ---------------------------------
_deleteSprites::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
;src/render.c:98: for (i = 0; i < MAX_SPRITES; i++) {
	ld	c, #0x00
00107$:
;src/render.c:99: if (sprites[i].id !=0) {
	ld	b,#0x00
	ld	l, c
	ld	h, b
	add	hl, hl
	add	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ex	de,hl
	ld	hl, #_sprites
	add	hl,de
	ex	de,hl
	ld	a, (de)
	or	a, a
	jr	Z,00108$
;src/render.c:100: if (!swap_memvideo){
	ld	a,(#_swap_memvideo + 0)
	or	a, a
	jr	NZ,00102$
;src/render.c:101: x = sprites[i].x_prev_B;
	push	de
	pop	iy
	ld	a, 7 (iy)
	ld	-2 (ix), a
;src/render.c:102: y = sprites[i].y_prev_B;
	push	de
	pop	iy
	ld	a, 8 (iy)
	ld	-1 (ix), a
	jr	00103$
00102$:
;src/render.c:105: x = sprites[i].x_prev_A;
	push	de
	pop	iy
	ld	a, 5 (iy)
	ld	-2 (ix), a
;src/render.c:106: y = sprites[i].y_prev_A;
	push	de
	pop	iy
	ld	a, 6 (iy)
	ld	-1 (ix), a
00103$:
;src/render.c:113: redrawTile(mem_start, x, y, sprites[i].width, sprites[i].height);
	push	de
	pop	iy
	ld	a, 9 (iy)
	ex	de,hl
	ld	de, #0x000a
	add	hl, de
	ld	e, (hl)
	push	bc
	ld	d,a
	push	de
	ld	h, -1 (ix)
	ld	l, -2 (ix)
	push	hl
	ld	hl, (_mem_start)
	push	hl
	call	_redrawTile
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
	pop	bc
00108$:
;src/render.c:98: for (i = 0; i < MAX_SPRITES; i++) {
	inc	c
	ld	a, c
	sub	a, #0x0a
	jr	C,00107$
	ld	sp, ix
	pop	ix
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
