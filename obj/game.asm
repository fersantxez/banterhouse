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
	.globl _collisions
	.globl _init_level
	.globl _moveSprites
	.globl _AI
	.globl _keyboard
	.globl _deleteSprites
	.globl _renderSprites
	.globl _cpct_etm_drawTilemap4x8_ag
	.globl _cpct_etm_setDrawTilemap4x8_ag
	.globl _cpct_setVideoMemoryPage
	.globl _cpct_setPALColour
	.globl _cpct_waitVSYNC
	.globl _cpct_px2byteM0
	.globl _cpct_isKeyPressed
	.globl _cpct_scanKeyboard_f
	.globl _cpct_memcpy
	.globl _cpct_memset
	.globl _map
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
	.ds 240
_anim_clock::
	.ds 1
_map::
	.ds 460
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
;src/game.c:19: void keyboard(){
;	---------------------------------
; Function keyboard
; ---------------------------------
_keyboard::
;src/game.c:22: sprites[0].moveV = sprites[0].moveH = 0; 							//start with no movement
	ld	hl, #(_sprites + 0x0004)
	ld	(hl), #0x00
	ld	hl, #(_sprites + 0x0003)
	ld	(hl), #0x00
;src/game.c:25: cpct_scanKeyboard_f();
	call	_cpct_scanKeyboard_f
;src/game.c:26: if (cpct_isKeyPressed(Key_CursorUp) || cpct_isKeyPressed(Key_Q) || cpct_isKeyPressed(Joy0_Up)){	
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
;src/game.c:27: sprites[0].moveV = -1;		
	ld	hl, #(_sprites + 0x0003)
	ld	(hl), #0xff
00102$:
;src/game.c:29: if (cpct_isKeyPressed(Key_CursorDown) || cpct_isKeyPressed(Key_A) || cpct_isKeyPressed(Joy0_Down)){
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
;src/game.c:30: sprites[0].moveV = 1;
	ld	hl, #(_sprites + 0x0003)
	ld	(hl), #0x01
00106$:
;src/game.c:32: if (cpct_isKeyPressed(Key_CursorLeft) || cpct_isKeyPressed(Key_O) || cpct_isKeyPressed(Joy0_Left)){
	ld	hl, #0x0101
	call	_cpct_isKeyPressed
;src/game.c:34: sprites[0].turned = 1;
;src/game.c:32: if (cpct_isKeyPressed(Key_CursorLeft) || cpct_isKeyPressed(Key_O) || cpct_isKeyPressed(Joy0_Left)){
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
;src/game.c:33: sprites[0].moveH = -1;
	ld	hl, #(_sprites + 0x0004)
	ld	(hl), #0xff
;src/game.c:34: sprites[0].turned = 1;
	ld	hl, #(_sprites + 0x0017)
	ld	(hl), #0x01
00110$:
;src/game.c:36: if (cpct_isKeyPressed(Key_CursorRight) || cpct_isKeyPressed(Key_P) || cpct_isKeyPressed(Joy0_Right)){
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
;src/game.c:37: sprites[0].moveH = 1;
	ld	hl, #(_sprites + 0x0004)
	ld	(hl), #0x01
;src/game.c:38: sprites[0].turned = 0;
	ld	hl, #(_sprites + 0x0017)
	ld	(hl), #0x00
00114$:
;src/game.c:42: if (sprites[0].moveH !=0 || sprites[0].moveV !=0)					//sprite moved
	ld	hl, #(_sprites + 0x0004) + 0
	ld	c, (hl)
;src/game.c:43: sprites[0].properties = sprites[0].properties | MASK_ANIMATE; 	//mark for animation
	ld	de, #_sprites + 11
	ld	a, (de)
	ld	b, a
;src/game.c:42: if (sprites[0].moveH !=0 || sprites[0].moveV !=0)					//sprite moved
	ld	a, c
	or	a, a
	jr	NZ,00117$
	ld	a, (#(_sprites + 0x0003) + 0)
	or	a, a
	jr	Z,00118$
00117$:
;src/game.c:43: sprites[0].properties = sprites[0].properties | MASK_ANIMATE; 	//mark for animation
	ld	a, b
	set	1, a
	ld	(de), a
	ret
00118$:
;src/game.c:45: sprites[0].properties = sprites[0].properties & ~MASK_ANIMATE;	//unmark for animation;
	res	1, b
	ld	a, b
	ld	(de), a
	ret
;src/game.c:50: void AI(){
;	---------------------------------
; Function AI
; ---------------------------------
_AI::
;src/game.c:51: }
	ret
;src/game.c:55: void moveSprites() {
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
;src/game.c:59: for (i=0; i < MAX_SPRITES; i++) {
	ld	-10 (ix), #0x00
00116$:
;src/game.c:60: if (sprites[i].id !=0) {			//check only live sprites to optimize CPU (non-zero)
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
	ld	-5 (ix), l
	ld	-4 (ix), h
	ld	a, (hl)
	ld	-3 (ix), a
	or	a, a
	jp	Z, 00117$
;src/game.c:61: collision = 0;
	ld	-8 (ix), #0x00
;src/game.c:63: x = sprites[i].x;
	ld	a, -5 (ix)
	add	a, #0x01
	ld	-2 (ix), a
	ld	a, -4 (ix)
	adc	a, #0x00
	ld	-1 (ix), a
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	ld	c, (hl)
;src/game.c:64: y = sprites[i].y;
	ld	a, -5 (ix)
	add	a, #0x02
	ld	-7 (ix), a
	ld	a, -4 (ix)
	adc	a, #0x00
	ld	-6 (ix), a
	ld	l,-7 (ix)
	ld	h,-6 (ix)
	ld	b, (hl)
;src/game.c:66: x = x + (sprites[i].moveH);
	ld	l,-5 (ix)
	ld	h,-4 (ix)
	ld	de, #0x0004
	add	hl, de
	ld	l, (hl)
	add	hl, bc
	ld	c, l
;src/game.c:67: y = y + (4*sprites[i].moveV);	//vertical movement: Y is *px, X is *byte. M0 so Y is 4 times slower
	ld	l,-5 (ix)
	ld	h,-4 (ix)
	inc	hl
	inc	hl
	inc	hl
	ld	a, (hl)
	add	a, a
	add	a, a
	ld	e, a
	ld	l, b
	add	hl, de
	ld	-9 (ix), l
;src/game.c:70: if (x > (GAME_AREA_RIGHT - sprites[i].width))
	ld	l,-5 (ix)
	ld	h,-4 (ix)
	ld	de, #0x000a
	add	hl, de
	ld	e, (hl)
	ld	d, #0x00
	ld	a, #0x50
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
	jp	PO, 00149$
	xor	a, #0x80
00149$:
	jp	P, 00104$
;src/game.c:71: collision = collision | RIGHT_COLLISION;
	ld	-8 (ix), #0x02
;src/game.c:73: collision = collision | LEFT_COLLISION;
00104$:
;src/game.c:75: if (y > (GAME_AREA_BOTTOM - sprites[i].height))
	ld	l,-5 (ix)
	ld	h,-4 (ix)
	ld	de, #0x0009
	add	hl, de
	ld	e, (hl)
	ld	d, #0x00
	ld	a, #0xc8
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
	jp	PO, 00150$
	xor	a, #0x80
00150$:
	jp	P, 00106$
;src/game.c:76: collision = collision | BOTTOM_COLLISION;
	set	0, -8 (ix)
00106$:
;src/game.c:77: if (y < GAME_AREA_TOP)
	ld	a, -9 (ix)
	sub	a, #0x10
	jr	NC,00108$
;src/game.c:78: collision = collision | TOP_COLLISION;
	ld	a, -8 (ix)
	or	a, #0x05
	ld	-8 (ix), a
00108$:
;src/game.c:82: if ((collision & LEFT_RIGHT_COLLISION) == 0)		//if not hitting right, move up/down
	bit	1, -8 (ix)
	jr	NZ,00110$
;src/game.c:83: sprites[i].x = x;								//keep x as it was
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	ld	(hl), c
00110$:
;src/game.c:85: if ((collision & TOP_BOTTOM_COLLISION) == 0)		//if not hitting top, move sideways //
	bit	0, -8 (ix)
	jr	NZ,00117$
;src/game.c:86: sprites[i].y = y;								//keep y as it was
	ld	l,-7 (ix)
	ld	h,-6 (ix)
	ld	a, -9 (ix)
	ld	(hl), a
00117$:
;src/game.c:59: for (i=0; i < MAX_SPRITES; i++) {
	inc	-10 (ix)
	ld	a, -10 (ix)
	sub	a, #0x0a
	jp	C, 00116$
	ld	sp, ix
	pop	ix
	ret
;src/game.c:94: void init_level() {
;	---------------------------------
; Function init_level
; ---------------------------------
_init_level::
;src/game.c:100: cpct_memcpy((u8*)map, (u8*)G_map, G_map_W*G_map_H);
	ld	hl, #0x01cc
	push	hl
	ld	hl, #_G_map
	push	hl
	ld	hl, #_map
	push	hl
	call	_cpct_memcpy
;src/game.c:102: cpct_etm_setDrawTilemap4x8_ag( G_map_W, G_map_H, G_map_W, G_tileset_00); //3rd param (20,G_map_W) is how many tiles per line
	ld	hl, #_G_tileset_00
	push	hl
	ld	hl, #0x0014
	push	hl
	ld	h, #0x17
	push	hl
	call	_cpct_etm_setDrawTilemap4x8_ag
;src/game.c:104: cpct_etm_drawTilemap4x8_ag( cpctm_screenPtr((u8*) CPCT_VMEM_START, GAME_AREA_LEFT, GAME_AREA_TOP), map );
	ld	hl, #_map
	push	hl
	ld	hl, #0xc0a0
	push	hl
	call	_cpct_etm_drawTilemap4x8_ag
;src/game.c:105: cpct_etm_drawTilemap4x8_ag( cpctm_screenPtr((u8*) CPCT_LVMEM_START, GAME_AREA_LEFT, GAME_AREA_TOP), map );
	ld	hl, #_map
	push	hl
	ld	hl, #0x80a0
	push	hl
	call	_cpct_etm_drawTilemap4x8_ag
	ret
;src/game.c:111: void collisions() {
;	---------------------------------
; Function collisions
; ---------------------------------
_collisions::
;src/game.c:112: }
	ret
;src/game.c:117: void init_game() {
;	---------------------------------
; Function init_game
; ---------------------------------
_init_game::
;src/game.c:120: sprites[0].id = 1;												//mark the sprite "alive" (non-zero)
	ld	hl, #_sprites
	ld	(hl), #0x01
;src/game.c:121: sprites[0].x = GAME_AREA_LEFT;									//init position to 0,0
	ld	hl, #(_sprites + 0x0001)
	ld	(hl), #0x00
;src/game.c:122: sprites[0].y = GAME_AREA_TOP;
	ld	hl, #(_sprites + 0x0002)
	ld	(hl), #0x10
;src/game.c:123: sprites[0].moveV = sprites[0].moveH = 0;						//init movement to none
	ld	hl, #(_sprites + 0x0004)
	ld	(hl), #0x00
	ld	hl, #(_sprites + 0x0003)
	ld	(hl), #0x00
;src/game.c:125: sprites[0].x_prev_A = sprites[0].x_prev_B = GAME_AREA_LEFT;		//init prev position to 0,0
	ld	hl, #(_sprites + 0x0007)
	ld	(hl), #0x00
	ld	hl, #(_sprites + 0x0005)
	ld	(hl), #0x00
;src/game.c:126: sprites[0].y_prev_A = sprites[0].y_prev_B = GAME_AREA_TOP;
	ld	hl, #(_sprites + 0x0008)
	ld	(hl), #0x10
	ld	hl, #(_sprites + 0x0006)
	ld	(hl), #0x10
;src/game.c:127: sprites[0].height = G_PITU_H;
	ld	hl, #(_sprites + 0x0009)
	ld	(hl), #0x20
;src/game.c:128: sprites[0].width = G_PITU_W;									//!?! /2: - M0, length in bytes = /2 in px
	ld	hl, #(_sprites + 0x000a)
	ld	(hl), #0x07
;src/game.c:129: sprites[0].properties = 0;										//bitmasked properties - init to 0
	ld	bc, #_sprites + 11
	xor	a, a
	ld	(bc), a
;src/game.c:130: sprites[0].properties = sprites[0].properties | MASK_RENDER;	//init to "render" on screen
	ld	a, (bc)
	set	0, a
	ld	(bc), a
;src/game.c:131: sprites[0].frames = 2;											//main sprite has two "moves" to animate
	ld	hl, #(_sprites + 0x000e)
	ld	(hl), #0x02
;src/game.c:132: sprites[0].sprite_f1 = (u8*)G_pitu; 							//first render for sprite. &G_pitu[0]
	ld	hl, #_G_pitu
	ld	((_sprites + 0x000f)), hl
;src/game.c:133: sprites[0].sprite_f2 = (u8*)G_pitu_walk;
	ld	hl, #_G_pitu_walk
	ld	((_sprites + 0x0011)), hl
;src/game.c:134: sprites[0].sprite_f3 = (u8*)G_pitu_jump;
	ld	hl, #_G_pitu_jump
	ld	((_sprites + 0x0013)), hl
;src/game.c:135: sprites[0].sprite_f3 = (u8*)G_blast;
	ld	hl, #_G_blast
	ld	((_sprites + 0x0013)), hl
;src/game.c:136: sprites[0].turned = 0;											//start looking right/front
	ld	hl, #(_sprites + 0x0017)
	ld	(hl), #0x00
;src/game.c:139: for (i = 1; i < MAX_SPRITES; i++)
	ld	c, #0x01
00102$:
;src/game.c:140: sprites[i].id=0;
	ld	b,#0x00
	ld	l, c
	ld	h, b
	add	hl, hl
	add	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	de, #_sprites
	add	hl, de
	ld	(hl), #0x00
;src/game.c:139: for (i = 1; i < MAX_SPRITES; i++)
	inc	c
	ld	a, c
	sub	a, #0x0a
	jr	C,00102$
;src/game.c:142: anim_clock=1;
	ld	hl,#_anim_clock + 0
	ld	(hl), #0x01
	ret
;src/game.c:148: void game(){
;	---------------------------------
; Function game
; ---------------------------------
_game::
;src/game.c:150: cpct_setBorder(HW_WHITE);
	ld	hl, #0x0010
	push	hl
	call	_cpct_setPALColour
;src/game.c:152: cpct_memset ((u8*)CPCT_LVMEM_START, cpct_px2byteM0(5, 5), 0x8000); //5 is ordinal for WHITE from palette in M0 with 16c
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
;src/game.c:153: init_level();								//render first level background
	call	_init_level
;src/game.c:155: while (1) {
00107$:
;src/game.c:158: if (!swap_memvideo) { 					//switch
	ld	a,(#_swap_memvideo + 0)
	or	a, a
	jr	NZ,00102$
;src/game.c:159: mem_start = (u8*) CPCT_LVMEM_START;	//lower VMEM page
	ld	hl, #0x8000
	ld	(_mem_start), hl
;src/game.c:160: mem_page = cpct_page80;				//FIXME:: can probably delete??
	ld	hl,#_mem_page + 0
	ld	(hl), #0x20
	jr	00103$
00102$:
;src/game.c:162: mem_start = (u8*) CPCT_VMEM_START;	//upper,regular VMEM page
	ld	hl, #0xc000
	ld	(_mem_start), hl
;src/game.c:163: mem_page = cpct_pageC0;
	ld	hl,#_mem_page + 0
	ld	(hl), #0x30
00103$:
;src/game.c:167: keyboard(); 							//user movement
	call	_keyboard
;src/game.c:169: moveSprites();
	call	_moveSprites
;src/game.c:170: deleteSprites();
	call	_deleteSprites
;src/game.c:171: renderSprites();
	call	_renderSprites
;src/game.c:174: cpct_waitVSYNC();						//Wait until CRTC has printed a full frame to "repaint"
	call	_cpct_waitVSYNC
;src/game.c:175: cpct_setVideoMemoryPage(mem_page);		//Tell CRTC to "paint" the new page--FIXME: can this use "mem_start" instead?
	ld	iy, #_mem_page
	ld	l, 0 (iy)
	call	_cpct_setVideoMemoryPage
;src/game.c:176: swap_memvideo = ~swap_memvideo; 		//flip the switch
	ld	iy, #_swap_memvideo
	ld	a, 0 (iy)
	cpl
	ld	0 (iy), a
;src/game.c:178: anim_clock+=ANIM_SPEED;
	ld	iy, #_anim_clock
	inc	0 (iy)
	inc	0 (iy)
;src/game.c:179: if (anim_clock > ANIM_CYCLE)
	ld	a, #0x10
	sub	a, 0 (iy)
	jr	NC,00107$
;src/game.c:180: anim_clock=1;
	ld	0 (iy), #0x01
	jr	00107$
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
