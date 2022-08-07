;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.6.8 #9946 (Linux)
;--------------------------------------------------------
	.module main
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _init_game
	.globl _menu
	.globl _cpct_setPalette
	.globl _cpct_setVideoMode
	.globl _cpct_setStackLocation
	.globl _cpct_disableFirmware
	.globl _swap_memvideo
	.globl _mem_page
	.globl _mem_start
	.globl _paleta
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_mem_start::
	.ds 2
_mem_page::
	.ds 1
_swap_memvideo::
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
;src/main.c:37: void main(void) {
;	---------------------------------
; Function main
; ---------------------------------
_main::
;src/main.c:40: cpct_setStackLocation ((u8*) 0x7FFF); //Move stack to right before double buffer 0X8000
	ld	hl, #0x7fff
	call	_cpct_setStackLocation
;src/main.c:41: cpct_disableFirmware();
	call	_cpct_disableFirmware
;src/main.c:43: cpct_setVideoMode(0); //160x200; 16 colors in screen
	ld	l, #0x00
	call	_cpct_setVideoMode
;src/main.c:44: cpct_setPalette(paleta,16);
	ld	hl, #0x0010
	push	hl
	ld	hl, #_paleta
	push	hl
	call	_cpct_setPalette
;src/main.c:46: while (1) {
00102$:
;src/main.c:48: swap_memvideo = 0;
	ld	hl,#_swap_memvideo + 0
	ld	(hl), #0x00
;src/main.c:49: mem_start = (u8*) CPCT_VMEM_START;
	ld	hl, #0xc000
	ld	(_mem_start), hl
;src/main.c:50: mem_page = cpct_pageC0; //this likely can be obtained from above, but...
	ld	hl,#_mem_page + 0
	ld	(hl), #0x30
;src/main.c:52: menu();
	call	_menu
;src/main.c:53: init_game();
	call	_init_game
;src/main.c:54: game();
	call	_game
	jr	00102$
_paleta:
	.db #0x14	; 20
	.db #0x0b	; 11
	.db #0x17	; 23
	.db #0x13	; 19
	.db #0x1b	; 27
	.db #0x00	; 0
	.db #0x12	; 18
	.db #0x19	; 25
	.db #0x03	; 3
	.db #0x1c	; 28
	.db #0x05	; 5
	.db #0x0f	; 15
	.db #0x0e	; 14
	.db #0x07	; 7
	.db #0x1e	; 30
	.db #0x04	; 4
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
