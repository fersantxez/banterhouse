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
	.globl _cpct_getScreenPtr
	.globl _cpct_drawSpriteMasked
	.globl _cpct_drawSolidBox
	.globl _cpct_px2byteM0
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
;src/render.c:6: void renderSprites(){
;	---------------------------------
; Function renderSprites
; ---------------------------------
_renderSprites::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-11
	add	hl, sp
	ld	sp, hl
;src/render.c:10: for (i = 0; i < MAX_SPRITES; i++) {
	ld	b, #0x00
00109$:
;src/render.c:11: if (sprites[i].id !=0) {			//only live and renderable sprites
	ld	e,b
	ld	d,#0x00
	ld	l, e
	ld	h, d
	add	hl, hl
	add	hl, hl
	add	hl, de
	add	hl, hl
	add	hl, de
	add	hl, hl
	ex	de,hl
	ld	hl, #_sprites
	add	hl,de
	ex	de,hl
	ld	a, (de)
	or	a, a
	jp	Z, 00110$
;src/render.c:12: if (sprites[i].properties & MASK_RENDER){
	push	de
	pop	iy
	ld	c, 11 (iy)
;src/render.c:16: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y), //on current *mem_start* plus sprite size
	ld	hl, #0x0002
	add	hl,de
	ld	-7 (ix), l
	ld	-6 (ix), h
	ld	hl, #0x0001
	add	hl,de
	ld	-5 (ix), l
	ld	-4 (ix), h
;src/render.c:12: if (sprites[i].properties & MASK_RENDER){
	bit	0, c
	jr	Z,00102$
;src/render.c:13: sprite = sprites[i].sprite_f1;
	push	de
	pop	iy
	ld	a, 14 (iy)
	ld	-11 (ix), a
	ld	a, 15 (iy)
	ld	-10 (ix), a
;src/render.c:17: sprites[i].width, sprites[i].height);
	push	de
	pop	iy
	ld	a, 9 (iy)
	ld	-3 (ix), a
	push	de
	pop	iy
	ld	a, 10 (iy)
	ld	-2 (ix), a
;src/render.c:16: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y), //on current *mem_start* plus sprite size
	ld	l,-7 (ix)
	ld	h,-6 (ix)
	ld	a, (hl)
	ld	-1 (ix), a
	ld	l,-5 (ix)
	ld	h,-4 (ix)
	ld	c, (hl)
	ld	iy, (_mem_start)
	push	bc
	push	de
	ld	b, -1 (ix)
	push	bc
	push	iy
	call	_cpct_getScreenPtr
	pop	de
	pop	bc
	push	hl
	pop	iy
;src/render.c:15: cpct_drawSpriteMasked(sprite,
	ld	a, -11 (ix)
	ld	-9 (ix), a
	ld	a, -10 (ix)
	ld	-8 (ix), a
	push	bc
	push	de
	ld	h, -3 (ix)
	ld	l, -2 (ix)
	push	hl
	push	iy
	ld	l,-9 (ix)
	ld	h,-8 (ix)
	push	hl
	call	_cpct_drawSpriteMasked
	pop	de
	pop	bc
00102$:
;src/render.c:16: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y), //on current *mem_start* plus sprite size
	ld	l,-5 (ix)
	ld	h,-4 (ix)
	ld	c, (hl)
;src/render.c:21: if (!swap_memvideo) {
	ld	a,(#_swap_memvideo + 0)
	or	a, a
	jr	NZ,00104$
;src/render.c:22: sprites[i].x_prev_B = sprites[i].x;
	ld	hl, #0x0007
	add	hl, de
	ld	(hl), c
;src/render.c:23: sprites[i].y_prev_B = sprites[i].y;
	ld	hl, #0x0008
	add	hl,de
	ex	de,hl
	ld	l,-7 (ix)
	ld	h,-6 (ix)
	ld	a, (hl)
	ld	(de), a
	jr	00110$
00104$:
;src/render.c:25: sprites[i].x_prev_A = sprites[i].x;
	ld	hl, #0x0005
	add	hl, de
	ld	(hl), c
;src/render.c:26: sprites[i].y_prev_A = sprites[i].y;
	ld	hl, #0x0006
	add	hl,de
	ex	de,hl
	ld	l,-7 (ix)
	ld	h,-6 (ix)
	ld	a, (hl)
	ld	(de), a
00110$:
;src/render.c:10: for (i = 0; i < MAX_SPRITES; i++) {
	inc	b
	ld	a, b
	sub	a, #0x0a
	jp	C, 00109$
	ld	sp, ix
	pop	ix
	ret
;src/render.c:33: void deleteSprites(){
;	---------------------------------
; Function deleteSprites
; ---------------------------------
_deleteSprites::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-11
	add	hl, sp
	ld	sp, hl
;src/render.c:37: for (i = 0; i < MAX_SPRITES; i++) {
	ld	-11 (ix), #0x00
00107$:
;src/render.c:38: if (sprites[i].id !=0) {
	ld	c,-11 (ix)
	ld	b,#0x00
	ld	l, c
	ld	h, b
	add	hl, hl
	add	hl, hl
	add	hl, bc
	add	hl, hl
	add	hl, bc
	add	hl, hl
	ld	bc,#_sprites
	add	hl,bc
	ld	-9 (ix), l
	ld	-8 (ix), h
	ld	a, (hl)
	ld	-10 (ix), a
	or	a, a
	jp	Z, 00108$
;src/render.c:39: if (!swap_memvideo){
	ld	a,(#_swap_memvideo + 0)
	or	a, a
	jr	NZ,00102$
;src/render.c:40: x = sprites[i].x_prev_B;
	pop	bc
	pop	hl
	push	hl
	push	bc
	ld	de, #0x0007
	add	hl, de
	ld	a, (hl)
	ld	-10 (ix), a
;src/render.c:41: y = sprites[i].y_prev_B;
	pop	bc
	pop	hl
	push	hl
	push	bc
	ld	de, #0x0008
	add	hl, de
	ld	a, (hl)
	ld	-1 (ix), a
	jr	00103$
00102$:
;src/render.c:44: x = sprites[i].x_prev_A;
	pop	bc
	pop	hl
	push	hl
	push	bc
	ld	de, #0x0005
	add	hl, de
	ld	a, (hl)
	ld	-10 (ix), a
;src/render.c:45: y = sprites[i].y_prev_A;
	pop	bc
	pop	hl
	push	hl
	push	bc
	ld	de, #0x0006
	add	hl, de
	ld	a, (hl)
	ld	-1 (ix), a
00103$:
;src/render.c:50: sprites[i].width, sprites[i].height);
	ld	a, -9 (ix)
	ld	-3 (ix), a
	ld	a, -8 (ix)
	ld	-2 (ix), a
	ld	l,-3 (ix)
	ld	h,-2 (ix)
	ld	de, #0x0009
	add	hl, de
	ld	a, (hl)
	ld	-3 (ix), a
	ld	l,-9 (ix)
	ld	h,-8 (ix)
	ld	de, #0x000a
	add	hl, de
	ld	a, (hl)
	ld	-9 (ix), a
;src/render.c:49: cpct_px2byteM0(5,5), 
	ld	hl, #0x0505
	push	hl
	call	_cpct_px2byteM0
	ld	-5 (ix), l
	ld	-4 (ix), #0x00
;src/render.c:48: cpct_getScreenPtr(mem_start, x, y),
	ld	hl, (_mem_start)
	ld	-7 (ix), l
	ld	-6 (ix), h
	ld	h, -1 (ix)
	ld	l, -10 (ix)
	push	hl
	ld	l,-7 (ix)
	ld	h,-6 (ix)
	push	hl
	call	_cpct_getScreenPtr
	ld	-6 (ix), h
	ld	-7 (ix), l
	ld	h, -3 (ix)
	ld	l, -9 (ix)
	push	hl
	ld	l,-5 (ix)
	ld	h,-4 (ix)
	push	hl
	ld	l,-7 (ix)
	ld	h,-6 (ix)
	push	hl
	call	_cpct_drawSolidBox
00108$:
;src/render.c:37: for (i = 0; i < MAX_SPRITES; i++) {
	inc	-11 (ix)
	ld	a, -11 (ix)
	sub	a, #0x0a
	jp	C, 00107$
	ld	sp, ix
	pop	ix
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
