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
	.globl _init_game
	.globl _moveSprites
	.globl _AI
	.globl _keyboard
	.globl _deleteSprites
	.globl _renderSprites
	.globl _cpct_setVideoMemoryPage
	.globl _cpct_setPALColour
	.globl _cpct_waitVSYNC
	.globl _cpct_px2byteM0
	.globl _cpct_isKeyPressed
	.globl _cpct_scanKeyboard_f
	.globl _cpct_memset
	.globl _anim_clock
	.globl _sprites
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_sprites::
	.ds 250
_anim_clock::
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
;src/game.c:14: void keyboard(){
;	---------------------------------
; Function keyboard
; ---------------------------------
_keyboard::
;src/game.c:17: sprites[0].moveV = sprites[0].moveH = 0; 							//start with no movement
	ld	hl, #(_sprites + 0x0004)
	ld	(hl), #0x00
	ld	hl, #(_sprites + 0x0003)
	ld	(hl), #0x00
;src/game.c:20: cpct_scanKeyboard_f();
	call	_cpct_scanKeyboard_f
;src/game.c:21: if (cpct_isKeyPressed(Key_CursorUp) || cpct_isKeyPressed(Key_Q) || cpct_isKeyPressed(Joy0_Up)){	
	ld	hl, #0x0100
	call	_cpct_isKeyPressed
	ld	a, l
	or	a, a
	jr	NZ,00101$
	ld	hl, #0x0808
	call	_cpct_isKeyPressed
	ld	a, l
	or	a, a
	jr	NZ,00101$
	ld	hl, #0x0109
	call	_cpct_isKeyPressed
	ld	a, l
	or	a, a
	jr	Z,00102$
00101$:
;src/game.c:22: sprites[0].moveV = -1;		
	ld	hl, #(_sprites + 0x0003)
	ld	(hl), #0xff
00102$:
;src/game.c:24: if (cpct_isKeyPressed(Key_CursorDown) || cpct_isKeyPressed(Key_A) || cpct_isKeyPressed(Joy0_Down)){
	ld	hl, #0x0400
	call	_cpct_isKeyPressed
	ld	a, l
	or	a, a
	jr	NZ,00105$
	ld	hl, #0x2008
	call	_cpct_isKeyPressed
	ld	a, l
	or	a, a
	jr	NZ,00105$
	ld	hl, #0x0209
	call	_cpct_isKeyPressed
	ld	a, l
	or	a, a
	jr	Z,00106$
00105$:
;src/game.c:25: sprites[0].moveV = 1;
	ld	hl, #(_sprites + 0x0003)
	ld	(hl), #0x01
00106$:
;src/game.c:27: if (cpct_isKeyPressed(Key_CursorLeft) || cpct_isKeyPressed(Key_O) || cpct_isKeyPressed(Joy0_Left)){
	ld	hl, #0x0101
	call	_cpct_isKeyPressed
	ld	a, l
	or	a, a
	jr	NZ,00109$
	ld	hl, #0x0404
	call	_cpct_isKeyPressed
	ld	a, l
	or	a, a
	jr	NZ,00109$
	ld	hl, #0x0409
	call	_cpct_isKeyPressed
	ld	a, l
	or	a, a
	jr	Z,00110$
00109$:
;src/game.c:28: sprites[0].moveH = -1;
	ld	hl, #(_sprites + 0x0004)
	ld	(hl), #0xff
00110$:
;src/game.c:31: if (cpct_isKeyPressed(Key_CursorRight) || cpct_isKeyPressed(Key_P) || cpct_isKeyPressed(Joy0_Right)){
	ld	hl, #0x0200
	call	_cpct_isKeyPressed
	ld	a, l
	or	a, a
	jr	NZ,00113$
	ld	hl, #0x0803
	call	_cpct_isKeyPressed
	ld	a, l
	or	a, a
	jr	NZ,00113$
	ld	hl, #0x0809
	call	_cpct_isKeyPressed
	ld	a, l
	or	a, a
	jr	Z,00114$
00113$:
;src/game.c:32: sprites[0].moveH = 1;
	ld	hl, #(_sprites + 0x0004)
	ld	(hl), #0x01
00114$:
;src/game.c:37: if (sprites[0].moveH !=0 || sprites[0].moveV !=0)					//sprite moved
	ld	hl, #(_sprites + 0x0004) + 0
	ld	c, (hl)
;src/game.c:38: sprites[0].properties = sprites[0].properties | MASK_ANIMATE; 	//mark for animation
	ld	de, #_sprites + 11
	ld	a, (de)
	ld	b, a
;src/game.c:37: if (sprites[0].moveH !=0 || sprites[0].moveV !=0)					//sprite moved
	ld	a, c
	or	a, a
	jr	NZ,00117$
	ld	a, (#(_sprites + 0x0003) + 0)
	or	a, a
	jr	Z,00118$
00117$:
;src/game.c:38: sprites[0].properties = sprites[0].properties | MASK_ANIMATE; 	//mark for animation
	ld	a, b
	set	1, a
	ld	(de), a
	ret
00118$:
;src/game.c:40: sprites[0].properties = sprites[0].properties & ~MASK_ANIMATE;	//unmark for animation;
	res	1, b
	ld	a, b
	ld	(de), a
	ret
;src/game.c:45: void AI(){
;	---------------------------------
; Function AI
; ---------------------------------
_AI::
;src/game.c:46: }
	ret
;src/game.c:50: void moveSprites() {
;	---------------------------------
; Function moveSprites
; ---------------------------------
_moveSprites::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-10
	add	hl, sp
	ld	sp, hl
;src/game.c:54: for (i=0; i < MAX_SPRITES; i++) {
	ld	-8 (ix), #0x00
00112$:
;src/game.c:55: if (sprites[i].id !=0) {			//check only live sprites to optimize CPU (non-zero)
	ld	c,-8 (ix)
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
	ld	-7 (ix), l
	ld	-6 (ix), h
	ld	a, (hl)
	ld	-1 (ix), a
	or	a, a
	jp	Z, 00113$
;src/game.c:56: collision = 0;
	ld	-10 (ix), #0x00
;src/game.c:58: x = sprites[i].x;
	ld	a, -7 (ix)
	add	a, #0x01
	ld	-3 (ix), a
	ld	a, -6 (ix)
	adc	a, #0x00
	ld	-2 (ix), a
	ld	l,-3 (ix)
	ld	h,-2 (ix)
	ld	b, (hl)
;src/game.c:59: y = sprites[i].y;
	ld	a, -7 (ix)
	add	a, #0x02
	ld	-5 (ix), a
	ld	a, -6 (ix)
	adc	a, #0x00
	ld	-4 (ix), a
	ld	l,-5 (ix)
	ld	h,-4 (ix)
	ld	c, (hl)
;src/game.c:61: y = y + (4*sprites[i].moveV);	//vertical movement: Y is *px, X is *byte. M0 so Y is 4 times slower
	ld	l,-7 (ix)
	ld	h,-6 (ix)
	inc	hl
	inc	hl
	inc	hl
	ld	a, (hl)
	add	a, a
	add	a, a
	ld	l, a
	add	hl, bc
	ld	c, l
;src/game.c:62: x = x + (sprites[i].moveH);
	ld	l,-7 (ix)
	ld	h,-6 (ix)
	ld	de, #0x0004
	add	hl, de
	ld	e, (hl)
	ld	l, b
	add	hl, de
	ld	-9 (ix), l
;src/game.c:65: if (y > (GAME_AREA_BOTTOM - sprites[i].height))
	ld	l,-7 (ix)
	ld	h,-6 (ix)
	ld	de, #0x0009
	add	hl, de
	ld	e, (hl)
	ld	d, #0x00
	ld	a, #0xc8
	sub	a, e
	ld	b, a
	ld	a, #0x00
	sbc	a, d
	ld	e, a
	ld	l, c
	ld	d, #0x00
	ld	a, b
	sub	a, l
	ld	a, e
	sbc	a, d
	jp	PO, 00141$
	xor	a, #0x80
00141$:
	jp	P, 00102$
;src/game.c:66: collision = collision | TOP_BOTTOM_COLLISION; //signal top collision w/bitmask
	ld	-10 (ix), #0x01
00102$:
;src/game.c:68: if (x > (GAME_AREA_RIGHT - sprites[i].width))
	ld	l,-7 (ix)
	ld	h,-6 (ix)
	ld	de, #0x000a
	add	hl, de
	ld	e, (hl)
	ld	d, #0x00
	ld	a, #0x50
	sub	a, e
	ld	e, a
	ld	a, #0x00
	sbc	a, d
	ld	d, a
	ld	l, -9 (ix)
	ld	h, #0x00
	ld	a, e
	sub	a, l
	ld	a, d
	sbc	a, h
	jp	PO, 00142$
	xor	a, #0x80
00142$:
	jp	P, 00104$
;src/game.c:69: collision = collision | LEFT_RIGHT_COLLISION; //signal right collision w/bitmask
	set	1, -10 (ix)
00104$:
;src/game.c:74: if ((collision & TOP_BOTTOM_COLLISION) == 0)		//if not hitting top, move sideways
	bit	0, -10 (ix)
	jr	NZ,00106$
;src/game.c:75: sprites[i].y = y;
	ld	l,-5 (ix)
	ld	h,-4 (ix)
	ld	(hl), c
00106$:
;src/game.c:76: if ((collision & LEFT_RIGHT_COLLISION) == 0)		//if not hitting right, move up/down
	bit	1, -10 (ix)
	jr	NZ,00113$
;src/game.c:77: sprites[i].x = x;
	ld	l,-3 (ix)
	ld	h,-2 (ix)
	ld	a, -9 (ix)
	ld	(hl), a
00113$:
;src/game.c:54: for (i=0; i < MAX_SPRITES; i++) {
	inc	-8 (ix)
	ld	a, -8 (ix)
	sub	a, #0x0a
	jp	C, 00112$
	ld	sp, ix
	pop	ix
	ret
;src/game.c:85: void init_game() {
;	---------------------------------
; Function init_game
; ---------------------------------
_init_game::
;src/game.c:88: sprites[0].id = 1;												//mark the sprite "alive" (non-zero)
	ld	hl, #_sprites
	ld	(hl), #0x01
;src/game.c:89: sprites[0].x = sprites[0].y = 0;								//init position to 0,0
	ld	hl, #(_sprites + 0x0002)
	ld	(hl), #0x00
	ld	hl, #(_sprites + 0x0001)
	ld	(hl), #0x00
;src/game.c:90: sprites[0].moveV = sprites[0].moveH = 0;						//init movement to none
	ld	hl, #(_sprites + 0x0004)
	ld	(hl), #0x00
	ld	hl, #(_sprites + 0x0003)
	ld	(hl), #0x00
;src/game.c:92: sprites[0].x_prev_A = sprites[0].y_prev_A = sprites[0].x_prev_B = sprites[0].y_prev_B = 0;
	ld	hl, #(_sprites + 0x0008)
	ld	(hl), #0x00
	ld	hl, #(_sprites + 0x0007)
	ld	(hl), #0x00
	ld	hl, #(_sprites + 0x0006)
	ld	(hl), #0x00
	ld	hl, #(_sprites + 0x0005)
	ld	(hl), #0x00
;src/game.c:93: sprites[0].height = G_PITU_H;
	ld	hl, #(_sprites + 0x0009)
	ld	(hl), #0x20
;src/game.c:94: sprites[0].width = G_PITU_W;									//!?! /2: - M0, length in bytes = /2 in px
	ld	hl, #(_sprites + 0x000a)
	ld	(hl), #0x08
;src/game.c:95: sprites[0].properties = 0;										//bitmasked properties - init to 0
	ld	bc, #_sprites + 11
	xor	a, a
	ld	(bc), a
;src/game.c:96: sprites[0].properties = sprites[0].properties | MASK_RENDER;	//init to "render" on screen
	ld	a, (bc)
	set	0, a
	ld	(bc), a
;src/game.c:97: sprites[0].frames = 2;											//main sprite has two "moves" to animate
	ld	hl, #(_sprites + 0x000e)
	ld	(hl), #0x02
;src/game.c:98: sprites[0].sprite_f1 = (u8*)G_pitu; 							//first render for sprite. &G_pitu[0]
	ld	hl, #_G_pitu
	ld	((_sprites + 0x000f)), hl
;src/game.c:99: sprites[0].sprite_f2 = (u8*)G_pitu_walk;
	ld	hl, #_G_pitu_walk
	ld	((_sprites + 0x0011)), hl
;src/game.c:100: sprites[0].sprite_f3 = (u8*)G_pitu_jump;
	ld	hl, #_G_pitu_jump
	ld	((_sprites + 0x0013)), hl
;src/game.c:101: sprites[0].sprite_f3 = (u8*)G_blast;
	ld	hl, #_G_blast
	ld	((_sprites + 0x0013)), hl
;src/game.c:102: sprites[0].turned = 0;											//start looking right/front
	ld	hl, #0x0000
	ld	((_sprites + 0x0017)), hl
;src/game.c:105: for (i = 1; i < MAX_SPRITES; i++)
	ld	c, #0x01
00102$:
;src/game.c:106: sprites[i].id=0;
	ld	b,#0x00
	ld	l, c
	ld	h, b
	add	hl, hl
	add	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, bc
	ld	de, #_sprites
	add	hl, de
	ld	(hl), #0x00
;src/game.c:105: for (i = 1; i < MAX_SPRITES; i++)
	inc	c
	ld	a, c
	sub	a, #0x0a
	jr	C,00102$
;src/game.c:108: anim_clock=1;
	ld	hl,#_anim_clock + 0
	ld	(hl), #0x01
	ret
;src/game.c:114: void game(){
;	---------------------------------
; Function game
; ---------------------------------
_game::
;src/game.c:116: cpct_setBorder(HW_WHITE);
	ld	hl, #0x0010
	push	hl
	call	_cpct_setPALColour
;src/game.c:118: cpct_memset ((u8*)CPCT_LVMEM_START, cpct_px2byteM0(5, 5), 0x8000); //5 is ordinal for WHITE from palette in M0 with 16c
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
;src/game.c:120: while (1) {
00107$:
;src/game.c:123: if (!swap_memvideo) { 					//switch
	ld	a,(#_swap_memvideo + 0)
	or	a, a
	jr	NZ,00102$
;src/game.c:124: mem_start = (u8*) CPCT_LVMEM_START;	//lower VMEM page
	ld	hl, #0x8000
	ld	(_mem_start), hl
;src/game.c:125: mem_page = cpct_page80;				//FIXME:: can probably delete??
	ld	hl,#_mem_page + 0
	ld	(hl), #0x20
	jr	00103$
00102$:
;src/game.c:127: mem_start = (u8*) CPCT_VMEM_START;	//upper,regular VMEM page
	ld	hl, #0xc000
	ld	(_mem_start), hl
;src/game.c:128: mem_page = cpct_pageC0;
	ld	hl,#_mem_page + 0
	ld	(hl), #0x30
00103$:
;src/game.c:132: keyboard(); 							//user movement
	call	_keyboard
;src/game.c:134: moveSprites();
	call	_moveSprites
;src/game.c:135: deleteSprites();
	call	_deleteSprites
;src/game.c:136: renderSprites();
	call	_renderSprites
;src/game.c:139: cpct_waitVSYNC();						//Wait until CRTC has printed a full frame to "repaint"
	call	_cpct_waitVSYNC
;src/game.c:140: cpct_setVideoMemoryPage(mem_page);		//Tell CRTC to "paint" the new page--FIXME: can this use "mem_start" instead?
	ld	iy, #_mem_page
	ld	l, 0 (iy)
	call	_cpct_setVideoMemoryPage
;src/game.c:141: swap_memvideo = ~swap_memvideo; 		//flip the switch
	ld	iy, #_swap_memvideo
	ld	a, 0 (iy)
	cpl
	ld	0 (iy), a
;src/game.c:143: anim_clock+=ANIM_SPEED;
	ld	iy, #_anim_clock
	inc	0 (iy)
;src/game.c:144: if (anim_clock > ANIM_CYCLE)
	ld	a, #0x10
	sub	a, 0 (iy)
	jr	NC,00107$
;src/game.c:145: anim_clock=1;
	ld	0 (iy), #0x01
	jr	00107$
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
