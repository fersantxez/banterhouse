;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.6.8 #9946 (Linux)
;--------------------------------------------------------
	.module menu
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _menu
	.globl _cpct_setPALColour
	.globl _cpct_drawStringM0
	.globl _cpct_setDrawCharM0
	.globl _cpct_drawSprite
	.globl _cpct_px2byteM0
	.globl _cpct_isAnyKeyPressed_f
	.globl _cpct_isKeyPressed
	.globl _cpct_scanKeyboard_f
	.globl _cpct_memset
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
;src/menu.c:5: void menu () {
;	---------------------------------
; Function menu
; ---------------------------------
_menu::
;src/menu.c:7: cpct_setBorder(HW_WHITE);
	ld	hl, #0x0010
	push	hl
	call	_cpct_setPALColour
;src/menu.c:8: cpct_memset(mem_start, cpct_px2byteM0(5,5), 0x4000); //5 is ordinal for WHITE from palette in M0 with 16c
	ld	hl, #0x0505
	push	hl
	call	_cpct_px2byteM0
	ld	d, l
	ld	bc, (_mem_start)
	ld	hl, #0x4000
	push	hl
	push	de
	inc	sp
	push	bc
	call	_cpct_memset
;src/menu.c:11: cpct_drawSprite(G_logo,
	ld	hl, #0x2020
	push	hl
	ld	hl, #0xd1f9
	push	hl
	ld	hl, #_G_logo
	push	hl
	call	_cpct_drawSprite
;src/menu.c:16: cpct_setDrawCharM0 (10, 7); //fg color=15, bg color=5. CPCT>1.5 requires initializing before "drawString"
	ld	hl, #0x070a
	push	hl
	call	_cpct_setDrawCharM0
;src/menu.c:17: cpct_drawStringM0("Press S to Start", cpctm_screenPtr(CPCT_VMEM_START, 10, 160 )); //X=(byte 10)=(pixel 20);Y=(line 160)
	ld	hl, #0xc64a
	push	hl
	ld	hl, #___str_0
	push	hl
	call	_cpct_drawStringM0
;src/menu.c:20: do {
00101$:
;src/menu.c:21: cpct_scanKeyboard_f();
	call	_cpct_scanKeyboard_f
;src/menu.c:22: } while (cpct_isAnyKeyPressed_f());
	call	_cpct_isAnyKeyPressed_f
	ld	a, l
	or	a, a
	jr	NZ,00101$
;src/menu.c:24: while (!cpct_isKeyPressed(Key_S)) //any key: cpct_isAnyKeyPressed_f())
00104$:
	ld	hl, #0x1007
	call	_cpct_isKeyPressed
	ld	a, l
	or	a, a
	ret	NZ
;src/menu.c:25: cpct_scanKeyboard_f();
	call	_cpct_scanKeyboard_f
	jr	00104$
___str_0:
	.ascii "Press S to Start"
	.db 0x00
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
