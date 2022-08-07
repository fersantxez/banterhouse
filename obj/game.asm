;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.6.8 #9946 (Linux)
;--------------------------------------------------------
	.module game
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _game
	.globl _renderSprites
	.globl _renderDelete
	.globl _cpct_setVideoMemoryPage
	.globl _cpct_setPALColour
	.globl _cpct_waitVSYNC
	.globl _cpct_px2byteM0
	.globl _cpct_memset
	.globl _coord_x
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_coord_x::
	.ds 1
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
;src/game.c:8: void game(){
;	---------------------------------
; Function game
; ---------------------------------
_game::
;src/game.c:9: cpct_setBorder(HW_BLACK);
	ld	hl, #0x1410
	push	hl
	call	_cpct_setPALColour
;src/game.c:11: cpct_memset ((u8*)CPCT_LVMEM_START, cpct_px2byteM0(5, 5), 0x8000); //5 is ordinal for WHITE from palette in M0 with 16c
	ld	hl, #0x0505
	push	hl
	call	_cpct_px2byteM0
	ld	b, l
	ld	hl, #0x8000
	push	hl
	push	bc
	inc	sp
	ld	l, #0x00
	push	hl
	call	_cpct_memset
;src/game.c:13: coord_x = 0;
	ld	hl,#_coord_x + 0
	ld	(hl), #0x00
;src/game.c:15: while (1) {
00107$:
;src/game.c:17: if (!swap_memvideo) { 				//switch
	ld	a,(#_swap_memvideo + 0)
	or	a, a
	jr	NZ,00102$
;src/game.c:18: mem_start = (u8*) 0x8000;//CPCT_LVMEM_START;		//lower page
	ld	hl, #0x8000
	ld	(_mem_start), hl
;src/game.c:19: mem_page = cpct_page80;					//FIXME:: can probably delete??
	ld	hl,#_mem_page + 0
	ld	(hl), #0x20
	jr	00103$
00102$:
;src/game.c:21: mem_start = (u8*) 0xC000;//CPCT_VMEM_START;		//upper,regular VMEM page
	ld	hl, #0xc000
	ld	(_mem_start), hl
;src/game.c:22: mem_page = cpct_pageC0;
	ld	hl,#_mem_page + 0
	ld	(hl), #0x30
00103$:
;src/game.c:25: renderDelete();							//delete the sprites--- only the changed ones?
	call	_renderDelete
;src/game.c:26: renderSprites();						//paint the new sprites???
	call	_renderSprites
;src/game.c:27: swap_memvideo = ~swap_memvideo; 		//flip the switch
	ld	iy, #_swap_memvideo
	ld	a, 0 (iy)
	cpl
	ld	0 (iy), a
;src/game.c:29: cpct_waitVSYNC();						//Wait until CRTC has printed a full frame to "repaint"
	call	_cpct_waitVSYNC
;src/game.c:30: cpct_setVideoMemoryPage(mem_page);		//Tell CRTC to "paint" the new page--FIXME: can this use "mem_start" instead?
	ld	iy, #_mem_page
	ld	l, 0 (iy)
	call	_cpct_setVideoMemoryPage
;src/game.c:32: coord_x++; 								//scroll right
	ld	iy, #_coord_x
	inc	0 (iy)
;src/game.c:33: if (coord_x == 72) 						//end of screen
	ld	a, 0 (iy)
	sub	a, #0x48
	jr	NZ,00107$
;src/game.c:34: break;
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
