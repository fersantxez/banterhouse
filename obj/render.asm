;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.6.8 #9946 (Linux)
;--------------------------------------------------------
	.module render
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _renderDelete
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
;src/render.c:8: cpct_drawSpriteMasked(G_pitu, cpct_getScreenPtr( mem_start, coord_x, 0), G_PITU_W/2, G_PITU_H);
	ld	bc, (_mem_start)
	xor	a, a
	push	af
	inc	sp
	ld	a, (_coord_x)
	push	af
	inc	sp
	push	bc
	call	_cpct_getScreenPtr
	ld	bc, #_G_pitu+0
	ld	de, #0x2008
	push	de
	push	hl
	push	bc
	call	_cpct_drawSpriteMasked
	ret
;src/render.c:13: void renderDelete(){
;	---------------------------------
; Function renderDelete
; ---------------------------------
_renderDelete::
;src/render.c:14: cpct_drawSolidBox(cpct_getScreenPtr( mem_start, coord_x-2, 0), cpct_px2byteM0(5,5), G_PITU_W/2, G_PITU_H);
	ld	hl, #0x0505
	push	hl
	call	_cpct_px2byteM0
	ld	c, l
	ld	b, #0x00
	ld	hl,#_coord_x + 0
	ld	e, (hl)
	dec	e
	dec	e
	ld	hl, (_mem_start)
	push	bc
	xor	a, a
	ld	d,a
	push	de
	push	hl
	call	_cpct_getScreenPtr
	pop	bc
	ld	de, #0x2008
	push	de
	push	bc
	push	hl
	call	_cpct_drawSolidBox
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
