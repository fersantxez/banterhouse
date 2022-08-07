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
	.globl _cpct_hflipSpriteMaskedM0
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
;src/render.c:11: void renderSprites(){
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
;src/render.c:16: for (i = 0; i < MAX_SPRITES; i++) {
	ld	-10 (ix), #0x00
00126$:
;src/render.c:17: if (sprites[i].id !=0) {						//only live and renderable sprites
	ld	c,-10 (ix)
	ld	b,#0x00
	ld	l, c
	ld	h, b
	add	hl, hl
	add	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, bc
	ld	bc,#_sprites
	add	hl,bc
	ld	-6 (ix), l
	ld	-5 (ix), h
	ld	a, (hl)
	or	a, a
	jp	Z, 00127$
;src/render.c:18: if (sprites[i].properties & MASK_RENDER) {
	ld	l,-6 (ix)
	ld	h,-5 (ix)
	ld	de, #0x000b
	add	hl, de
	ld	c, (hl)
;src/render.c:46: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y),
	ld	a, -6 (ix)
	add	a, #0x02
	ld	-8 (ix), a
	ld	a, -5 (ix)
	adc	a, #0x00
	ld	-7 (ix), a
	ld	a, -6 (ix)
	add	a, #0x01
	ld	-2 (ix), a
	ld	a, -5 (ix)
	adc	a, #0x00
	ld	-1 (ix), a
;src/render.c:18: if (sprites[i].properties & MASK_RENDER) {
	bit	0, c
	jp	Z,00119$
;src/render.c:33: sprite = sprites[i].sprite_f1; 
	ld	a, -6 (ix)
	add	a, #0x0f
	ld	-4 (ix), a
	ld	a, -5 (ix)
	adc	a, #0x00
	ld	-3 (ix), a
;src/render.c:20: if (sprites[i].properties & MASK_ANIMATE) {
	bit	1, c
	jr	Z,00114$
;src/render.c:28: if (anim_clock > 7) num_frame=2;
	ld	a, #0x07
	ld	iy, #_anim_clock
	sub	a, 0 (iy)
	jr	NC,00102$
	ld	a, #0x02
	jr	00103$
00102$:
;src/render.c:29: else num_frame=1;
	ld	a, #0x01
00103$:
;src/render.c:32: if (num_frame == 1) {
	cp	a, #0x01
	jr	NZ,00111$
;src/render.c:33: sprite = sprites[i].sprite_f1; 
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	jr	00115$
00111$:
;src/render.c:34: } else if (num_frame == 2) {
	cp	a, #0x02
	jr	NZ,00108$
;src/render.c:35: sprite = sprites[i].sprite_f2;
	ld	l,-6 (ix)
	ld	h,-5 (ix)
	ld	de, #0x0011
	add	hl, de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	jr	00115$
00108$:
;src/render.c:36: } else if (num_frame == 3) { 
	sub	a, #0x03
	jr	NZ,00105$
;src/render.c:37: sprite = sprites[i].sprite_f3; 
	ld	l,-6 (ix)
	ld	h,-5 (ix)
	ld	de, #0x0013
	add	hl, de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	jr	00115$
00105$:
;src/render.c:38: } else sprite = sprites[i].sprite_f4;
	ld	l,-6 (ix)
	ld	h,-5 (ix)
	ld	de, #0x0015
	add	hl, de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	jr	00115$
00114$:
;src/render.c:39: } else sprite = sprites[i].sprite_f1;
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
00115$:
;src/render.c:41: if (sprites[i].turned)					//turn sprite around
	ld	l,-6 (ix)
	ld	h,-5 (ix)
	ld	bc, #0x0017
	add	hl, bc
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a
;src/render.c:42: cpct_hflipSpriteMaskedM0(sprites[i].width, sprites[i].height, sprite);
	ld	a, -6 (ix)
	add	a, #0x09
	ld	c, a
	ld	a, -5 (ix)
	adc	a, #0x00
	ld	b, a
	ld	a, -6 (ix)
	add	a, #0x0a
	ld	-4 (ix), a
	ld	a, -5 (ix)
	adc	a, #0x00
	ld	-3 (ix), a
;src/render.c:41: if (sprites[i].turned)					//turn sprite around
	ld	a, h
	or	a,l
	jr	Z,00117$
;src/render.c:42: cpct_hflipSpriteMaskedM0(sprites[i].width, sprites[i].height, sprite);
	ld	a, (bc)
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	push	af
	ld	a, (hl)
	ld	-9 (ix), a
	pop	af
	push	bc
	push	de
	push	de
	push	af
	inc	sp
	ld	a, -9 (ix)
	push	af
	inc	sp
	call	_cpct_hflipSpriteMaskedM0
	pop	de
	pop	bc
00117$:
;src/render.c:47: sprites[i].width, sprites[i].height);
	ld	a, (bc)
	ld	-9 (ix), a
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	ld	a, (hl)
	ld	-4 (ix), a
;src/render.c:46: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y),
	ld	l,-8 (ix)
	ld	h,-7 (ix)
	ld	c, (hl)
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	ld	b, (hl)
	ld	iy, (_mem_start)
	push	de
	ld	a, c
	push	af
	inc	sp
	push	bc
	inc	sp
	push	iy
	call	_cpct_getScreenPtr
	ld	c, l
	ld	b, h
	pop	de
;src/render.c:44: cpct_drawSpriteMasked(sprite,
	ld	h, -9 (ix)
	ld	l, -4 (ix)
	push	hl
	push	bc
	push	de
	call	_cpct_drawSpriteMasked
00119$:
;src/render.c:46: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y),
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	ld	c, (hl)
;src/render.c:51: if (!swap_memvideo) {
	ld	a,(#_swap_memvideo + 0)
	or	a, a
	jr	NZ,00121$
;src/render.c:52: sprites[i].x_prev_B = sprites[i].x;
	ld	a, -6 (ix)
	add	a, #0x07
	ld	l, a
	ld	a, -5 (ix)
	adc	a, #0x00
	ld	h, a
	ld	(hl), c
;src/render.c:53: sprites[i].y_prev_B = sprites[i].y;
	ld	a, -6 (ix)
	add	a, #0x08
	ld	c, a
	ld	a, -5 (ix)
	adc	a, #0x00
	ld	b, a
	ld	l,-8 (ix)
	ld	h,-7 (ix)
	ld	a, (hl)
	ld	(bc), a
	jr	00127$
00121$:
;src/render.c:55: sprites[i].x_prev_A = sprites[i].x;
	ld	a, -6 (ix)
	add	a, #0x05
	ld	l, a
	ld	a, -5 (ix)
	adc	a, #0x00
	ld	h, a
	ld	(hl), c
;src/render.c:56: sprites[i].y_prev_A = sprites[i].y;
	ld	a, -6 (ix)
	add	a, #0x06
	ld	c, a
	ld	a, -5 (ix)
	adc	a, #0x00
	ld	b, a
	ld	l,-8 (ix)
	ld	h,-7 (ix)
	ld	a, (hl)
	ld	(bc), a
00127$:
;src/render.c:16: for (i = 0; i < MAX_SPRITES; i++) {
	inc	-10 (ix)
	ld	a, -10 (ix)
	sub	a, #0x0a
	jp	C, 00126$
	ld	sp, ix
	pop	ix
	ret
;src/render.c:62: void deleteSprites(){
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
;src/render.c:67: for (i = 0; i < MAX_SPRITES; i++) {
	ld	-11 (ix), #0x00
00107$:
;src/render.c:68: if (sprites[i].id !=0) {
	ld	c,-11 (ix)
	ld	b,#0x00
	ld	l, c
	ld	h, b
	add	hl, hl
	add	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, bc
	ld	bc,#_sprites
	add	hl,bc
	ld	-10 (ix), l
	ld	-9 (ix), h
	ld	a, (hl)
	ld	-1 (ix), a
	or	a, a
	jp	Z, 00108$
;src/render.c:69: if (!swap_memvideo){
	ld	a,(#_swap_memvideo + 0)
	or	a, a
	jr	NZ,00102$
;src/render.c:70: x = sprites[i].x_prev_B;
	ld	l,-10 (ix)
	ld	h,-9 (ix)
	ld	de, #0x0007
	add	hl, de
	ld	a, (hl)
	ld	-1 (ix), a
;src/render.c:71: y = sprites[i].y_prev_B;
	ld	l,-10 (ix)
	ld	h,-9 (ix)
	ld	de, #0x0008
	add	hl, de
	ld	a, (hl)
	ld	-2 (ix), a
	jr	00103$
00102$:
;src/render.c:74: x = sprites[i].x_prev_A;
	ld	l,-10 (ix)
	ld	h,-9 (ix)
	ld	de, #0x0005
	add	hl, de
	ld	a, (hl)
	ld	-1 (ix), a
;src/render.c:75: y = sprites[i].y_prev_A;
	ld	l,-10 (ix)
	ld	h,-9 (ix)
	ld	de, #0x0006
	add	hl, de
	ld	a, (hl)
	ld	-2 (ix), a
00103$:
;src/render.c:80: sprites[i].width, sprites[i].height);
	ld	a, -10 (ix)
	ld	-4 (ix), a
	ld	a, -9 (ix)
	ld	-3 (ix), a
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	ld	de, #0x0009
	add	hl, de
	ld	a, (hl)
	ld	-4 (ix), a
	ld	l,-10 (ix)
	ld	h,-9 (ix)
	ld	de, #0x000a
	add	hl, de
	ld	a, (hl)
	ld	-10 (ix), a
;src/render.c:79: cpct_px2byteM0(5,5),						//background color
	ld	hl, #0x0505
	push	hl
	call	_cpct_px2byteM0
	ld	-6 (ix), l
	ld	-5 (ix), #0x00
;src/render.c:78: cpct_getScreenPtr(mem_start, x, y),
	ld	hl, (_mem_start)
	ld	-8 (ix), l
	ld	-7 (ix), h
	ld	h, -2 (ix)
	ld	l, -1 (ix)
	push	hl
	ld	l,-8 (ix)
	ld	h,-7 (ix)
	push	hl
	call	_cpct_getScreenPtr
	ld	-7 (ix), h
	ld	-8 (ix), l
	ld	h, -4 (ix)
	ld	l, -10 (ix)
	push	hl
	ld	l,-6 (ix)
	ld	h,-5 (ix)
	push	hl
	ld	l,-8 (ix)
	ld	h,-7 (ix)
	push	hl
	call	_cpct_drawSolidBox
00108$:
;src/render.c:67: for (i = 0; i < MAX_SPRITES; i++) {
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
