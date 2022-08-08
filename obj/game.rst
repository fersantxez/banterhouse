                              1 ;--------------------------------------------------------
                              2 ; File Created by SDCC : free open source ANSI-C Compiler
                              3 ; Version 3.6.8 #9946 (Linux)
                              4 ;--------------------------------------------------------
                              5 	.module game
                              6 	.optsdcc -mz80
                              7 	
                              8 ;--------------------------------------------------------
                              9 ; Public variables in this module
                             10 ;--------------------------------------------------------
                             11 	.globl _game
                             12 	.globl _init_game
                             13 	.globl _moveSprites
                             14 	.globl _AI
                             15 	.globl _keyboard
                             16 	.globl _deleteSprites
                             17 	.globl _renderSprites
                             18 	.globl _cpct_setVideoMemoryPage
                             19 	.globl _cpct_setPALColour
                             20 	.globl _cpct_waitVSYNC
                             21 	.globl _cpct_px2byteM0
                             22 	.globl _cpct_isKeyPressed
                             23 	.globl _cpct_scanKeyboard_f
                             24 	.globl _cpct_memset
                             25 	.globl _anim_clock
                             26 	.globl _sprites
                             27 ;--------------------------------------------------------
                             28 ; special function registers
                             29 ;--------------------------------------------------------
                             30 ;--------------------------------------------------------
                             31 ; ram data
                             32 ;--------------------------------------------------------
                             33 	.area _DATA
   68F6                      34 _sprites::
   68F6                      35 	.ds 240
   69E6                      36 _anim_clock::
   69E6                      37 	.ds 1
                             38 ;--------------------------------------------------------
                             39 ; ram data
                             40 ;--------------------------------------------------------
                             41 	.area _INITIALIZED
                             42 ;--------------------------------------------------------
                             43 ; absolute external ram data
                             44 ;--------------------------------------------------------
                             45 	.area _DABS (ABS)
                             46 ;--------------------------------------------------------
                             47 ; global & static initialisations
                             48 ;--------------------------------------------------------
                             49 	.area _HOME
                             50 	.area _GSINIT
                             51 	.area _GSFINAL
                             52 	.area _GSINIT
                             53 ;--------------------------------------------------------
                             54 ; Home
                             55 ;--------------------------------------------------------
                             56 	.area _HOME
                             57 	.area _HOME
                             58 ;--------------------------------------------------------
                             59 ; code
                             60 ;--------------------------------------------------------
                             61 	.area _CODE
                             62 ;src/game.c:14: void keyboard(){
                             63 ;	---------------------------------
                             64 ; Function keyboard
                             65 ; ---------------------------------
   43CC                      66 _keyboard::
                             67 ;src/game.c:17: sprites[0].moveV = sprites[0].moveH = 0; 							//start with no movement
   43CC 21 FA 68      [10]   68 	ld	hl, #(_sprites + 0x0004)
   43CF 36 00         [10]   69 	ld	(hl), #0x00
   43D1 21 F9 68      [10]   70 	ld	hl, #(_sprites + 0x0003)
   43D4 36 00         [10]   71 	ld	(hl), #0x00
                             72 ;src/game.c:20: cpct_scanKeyboard_f();
   43D6 CD 99 65      [17]   73 	call	_cpct_scanKeyboard_f
                             74 ;src/game.c:21: if (cpct_isKeyPressed(Key_CursorUp) || cpct_isKeyPressed(Key_Q) || cpct_isKeyPressed(Joy0_Up)){	
   43D9 21 00 01      [10]   75 	ld	hl, #0x0100
   43DC CD 8D 65      [17]   76 	call	_cpct_isKeyPressed
   43DF 7D            [ 4]   77 	ld	a, l
   43E0 B7            [ 4]   78 	or	a, a
   43E1 20 14         [12]   79 	jr	NZ,00101$
   43E3 21 08 08      [10]   80 	ld	hl, #0x0808
   43E6 CD 8D 65      [17]   81 	call	_cpct_isKeyPressed
   43E9 7D            [ 4]   82 	ld	a, l
   43EA B7            [ 4]   83 	or	a, a
   43EB 20 0A         [12]   84 	jr	NZ,00101$
   43ED 21 09 01      [10]   85 	ld	hl, #0x0109
   43F0 CD 8D 65      [17]   86 	call	_cpct_isKeyPressed
   43F3 7D            [ 4]   87 	ld	a, l
   43F4 B7            [ 4]   88 	or	a, a
   43F5 28 05         [12]   89 	jr	Z,00102$
   43F7                      90 00101$:
                             91 ;src/game.c:22: sprites[0].moveV = -1;		
   43F7 21 F9 68      [10]   92 	ld	hl, #(_sprites + 0x0003)
   43FA 36 FF         [10]   93 	ld	(hl), #0xff
   43FC                      94 00102$:
                             95 ;src/game.c:24: if (cpct_isKeyPressed(Key_CursorDown) || cpct_isKeyPressed(Key_A) || cpct_isKeyPressed(Joy0_Down)){
   43FC 21 00 04      [10]   96 	ld	hl, #0x0400
   43FF CD 8D 65      [17]   97 	call	_cpct_isKeyPressed
   4402 7D            [ 4]   98 	ld	a, l
   4403 B7            [ 4]   99 	or	a, a
   4404 20 14         [12]  100 	jr	NZ,00105$
   4406 21 08 20      [10]  101 	ld	hl, #0x2008
   4409 CD 8D 65      [17]  102 	call	_cpct_isKeyPressed
   440C 7D            [ 4]  103 	ld	a, l
   440D B7            [ 4]  104 	or	a, a
   440E 20 0A         [12]  105 	jr	NZ,00105$
   4410 21 09 02      [10]  106 	ld	hl, #0x0209
   4413 CD 8D 65      [17]  107 	call	_cpct_isKeyPressed
   4416 7D            [ 4]  108 	ld	a, l
   4417 B7            [ 4]  109 	or	a, a
   4418 28 05         [12]  110 	jr	Z,00106$
   441A                     111 00105$:
                            112 ;src/game.c:25: sprites[0].moveV = 1;
   441A 21 F9 68      [10]  113 	ld	hl, #(_sprites + 0x0003)
   441D 36 01         [10]  114 	ld	(hl), #0x01
   441F                     115 00106$:
                            116 ;src/game.c:27: if (cpct_isKeyPressed(Key_CursorLeft) || cpct_isKeyPressed(Key_O) || cpct_isKeyPressed(Joy0_Left)){
   441F 21 01 01      [10]  117 	ld	hl, #0x0101
   4422 CD 8D 65      [17]  118 	call	_cpct_isKeyPressed
                            119 ;src/game.c:29: sprites[0].turned = 1;
                            120 ;src/game.c:27: if (cpct_isKeyPressed(Key_CursorLeft) || cpct_isKeyPressed(Key_O) || cpct_isKeyPressed(Joy0_Left)){
   4425 7D            [ 4]  121 	ld	a, l
   4426 B7            [ 4]  122 	or	a, a
   4427 20 14         [12]  123 	jr	NZ,00109$
   4429 21 04 04      [10]  124 	ld	hl, #0x0404
   442C CD 8D 65      [17]  125 	call	_cpct_isKeyPressed
   442F 7D            [ 4]  126 	ld	a, l
   4430 B7            [ 4]  127 	or	a, a
   4431 20 0A         [12]  128 	jr	NZ,00109$
   4433 21 09 04      [10]  129 	ld	hl, #0x0409
   4436 CD 8D 65      [17]  130 	call	_cpct_isKeyPressed
   4439 7D            [ 4]  131 	ld	a, l
   443A B7            [ 4]  132 	or	a, a
   443B 28 0A         [12]  133 	jr	Z,00110$
   443D                     134 00109$:
                            135 ;src/game.c:28: sprites[0].moveH = -1;
   443D 21 FA 68      [10]  136 	ld	hl, #(_sprites + 0x0004)
   4440 36 FF         [10]  137 	ld	(hl), #0xff
                            138 ;src/game.c:29: sprites[0].turned = 1;
   4442 21 0D 69      [10]  139 	ld	hl, #(_sprites + 0x0017)
   4445 36 01         [10]  140 	ld	(hl), #0x01
   4447                     141 00110$:
                            142 ;src/game.c:31: if (cpct_isKeyPressed(Key_CursorRight) || cpct_isKeyPressed(Key_P) || cpct_isKeyPressed(Joy0_Right)){
   4447 21 00 02      [10]  143 	ld	hl, #0x0200
   444A CD 8D 65      [17]  144 	call	_cpct_isKeyPressed
   444D 7D            [ 4]  145 	ld	a, l
   444E B7            [ 4]  146 	or	a, a
   444F 20 14         [12]  147 	jr	NZ,00113$
   4451 21 03 08      [10]  148 	ld	hl, #0x0803
   4454 CD 8D 65      [17]  149 	call	_cpct_isKeyPressed
   4457 7D            [ 4]  150 	ld	a, l
   4458 B7            [ 4]  151 	or	a, a
   4459 20 0A         [12]  152 	jr	NZ,00113$
   445B 21 09 08      [10]  153 	ld	hl, #0x0809
   445E CD 8D 65      [17]  154 	call	_cpct_isKeyPressed
   4461 7D            [ 4]  155 	ld	a, l
   4462 B7            [ 4]  156 	or	a, a
   4463 28 0A         [12]  157 	jr	Z,00114$
   4465                     158 00113$:
                            159 ;src/game.c:32: sprites[0].moveH = 1;
   4465 21 FA 68      [10]  160 	ld	hl, #(_sprites + 0x0004)
   4468 36 01         [10]  161 	ld	(hl), #0x01
                            162 ;src/game.c:33: sprites[0].turned = 0;
   446A 21 0D 69      [10]  163 	ld	hl, #(_sprites + 0x0017)
   446D 36 00         [10]  164 	ld	(hl), #0x00
   446F                     165 00114$:
                            166 ;src/game.c:37: if (sprites[0].moveH !=0 || sprites[0].moveV !=0)					//sprite moved
   446F 21 FA 68      [10]  167 	ld	hl, #(_sprites + 0x0004) + 0
   4472 4E            [ 7]  168 	ld	c, (hl)
                            169 ;src/game.c:38: sprites[0].properties = sprites[0].properties | MASK_ANIMATE; 	//mark for animation
   4473 11 01 69      [10]  170 	ld	de, #_sprites + 11
   4476 1A            [ 7]  171 	ld	a, (de)
   4477 47            [ 4]  172 	ld	b, a
                            173 ;src/game.c:37: if (sprites[0].moveH !=0 || sprites[0].moveV !=0)					//sprite moved
   4478 79            [ 4]  174 	ld	a, c
   4479 B7            [ 4]  175 	or	a, a
   447A 20 06         [12]  176 	jr	NZ,00117$
   447C 3A F9 68      [13]  177 	ld	a, (#(_sprites + 0x0003) + 0)
   447F B7            [ 4]  178 	or	a, a
   4480 28 05         [12]  179 	jr	Z,00118$
   4482                     180 00117$:
                            181 ;src/game.c:38: sprites[0].properties = sprites[0].properties | MASK_ANIMATE; 	//mark for animation
   4482 78            [ 4]  182 	ld	a, b
   4483 CB CF         [ 8]  183 	set	1, a
   4485 12            [ 7]  184 	ld	(de), a
   4486 C9            [10]  185 	ret
   4487                     186 00118$:
                            187 ;src/game.c:40: sprites[0].properties = sprites[0].properties & ~MASK_ANIMATE;	//unmark for animation;
   4487 CB 88         [ 8]  188 	res	1, b
   4489 78            [ 4]  189 	ld	a, b
   448A 12            [ 7]  190 	ld	(de), a
   448B C9            [10]  191 	ret
                            192 ;src/game.c:45: void AI(){
                            193 ;	---------------------------------
                            194 ; Function AI
                            195 ; ---------------------------------
   448C                     196 _AI::
                            197 ;src/game.c:46: }
   448C C9            [10]  198 	ret
                            199 ;src/game.c:50: void moveSprites() {
                            200 ;	---------------------------------
                            201 ; Function moveSprites
                            202 ; ---------------------------------
   448D                     203 _moveSprites::
   448D DD E5         [15]  204 	push	ix
   448F DD 21 00 00   [14]  205 	ld	ix,#0
   4493 DD 39         [15]  206 	add	ix,sp
   4495 21 F6 FF      [10]  207 	ld	hl, #-10
   4498 39            [11]  208 	add	hl, sp
   4499 F9            [ 6]  209 	ld	sp, hl
                            210 ;src/game.c:54: for (i=0; i < MAX_SPRITES; i++) {
   449A DD 36 F8 00   [19]  211 	ld	-8 (ix), #0x00
   449E                     212 00116$:
                            213 ;src/game.c:55: if (sprites[i].id !=0) {			//check only live sprites to optimize CPU (non-zero)
   449E DD 4E F8      [19]  214 	ld	c,-8 (ix)
   44A1 06 00         [ 7]  215 	ld	b,#0x00
   44A3 69            [ 4]  216 	ld	l, c
   44A4 60            [ 4]  217 	ld	h, b
   44A5 29            [11]  218 	add	hl, hl
   44A6 09            [11]  219 	add	hl, bc
   44A7 29            [11]  220 	add	hl, hl
   44A8 29            [11]  221 	add	hl, hl
   44A9 29            [11]  222 	add	hl, hl
   44AA 01 F6 68      [10]  223 	ld	bc,#_sprites
   44AD 09            [11]  224 	add	hl,bc
   44AE DD 75 FE      [19]  225 	ld	-2 (ix), l
   44B1 DD 74 FF      [19]  226 	ld	-1 (ix), h
   44B4 7E            [ 7]  227 	ld	a, (hl)
   44B5 DD 77 FB      [19]  228 	ld	-5 (ix), a
   44B8 B7            [ 4]  229 	or	a, a
   44B9 CA 8B 45      [10]  230 	jp	Z, 00117$
                            231 ;src/game.c:56: collision = 0;
   44BC DD 36 F6 00   [19]  232 	ld	-10 (ix), #0x00
                            233 ;src/game.c:58: x = sprites[i].x;
   44C0 DD 7E FE      [19]  234 	ld	a, -2 (ix)
   44C3 C6 01         [ 7]  235 	add	a, #0x01
   44C5 DD 77 F9      [19]  236 	ld	-7 (ix), a
   44C8 DD 7E FF      [19]  237 	ld	a, -1 (ix)
   44CB CE 00         [ 7]  238 	adc	a, #0x00
   44CD DD 77 FA      [19]  239 	ld	-6 (ix), a
   44D0 DD 6E F9      [19]  240 	ld	l,-7 (ix)
   44D3 DD 66 FA      [19]  241 	ld	h,-6 (ix)
   44D6 4E            [ 7]  242 	ld	c, (hl)
                            243 ;src/game.c:59: y = sprites[i].y;
   44D7 DD 7E FE      [19]  244 	ld	a, -2 (ix)
   44DA C6 02         [ 7]  245 	add	a, #0x02
   44DC DD 77 FC      [19]  246 	ld	-4 (ix), a
   44DF DD 7E FF      [19]  247 	ld	a, -1 (ix)
   44E2 CE 00         [ 7]  248 	adc	a, #0x00
   44E4 DD 77 FD      [19]  249 	ld	-3 (ix), a
   44E7 DD 6E FC      [19]  250 	ld	l,-4 (ix)
   44EA DD 66 FD      [19]  251 	ld	h,-3 (ix)
   44ED 46            [ 7]  252 	ld	b, (hl)
                            253 ;src/game.c:61: x = x + (sprites[i].moveH);
   44EE DD 6E FE      [19]  254 	ld	l,-2 (ix)
   44F1 DD 66 FF      [19]  255 	ld	h,-1 (ix)
   44F4 11 04 00      [10]  256 	ld	de, #0x0004
   44F7 19            [11]  257 	add	hl, de
   44F8 6E            [ 7]  258 	ld	l, (hl)
   44F9 09            [11]  259 	add	hl, bc
   44FA 4D            [ 4]  260 	ld	c, l
                            261 ;src/game.c:62: y = y + (4*sprites[i].moveV);	//vertical movement: Y is *px, X is *byte. M0 so Y is 4 times slower
   44FB DD 6E FE      [19]  262 	ld	l,-2 (ix)
   44FE DD 66 FF      [19]  263 	ld	h,-1 (ix)
   4501 23            [ 6]  264 	inc	hl
   4502 23            [ 6]  265 	inc	hl
   4503 23            [ 6]  266 	inc	hl
   4504 7E            [ 7]  267 	ld	a, (hl)
   4505 87            [ 4]  268 	add	a, a
   4506 87            [ 4]  269 	add	a, a
   4507 5F            [ 4]  270 	ld	e, a
   4508 68            [ 4]  271 	ld	l, b
   4509 19            [11]  272 	add	hl, de
   450A DD 75 F7      [19]  273 	ld	-9 (ix), l
                            274 ;src/game.c:65: if (x > (GAME_AREA_RIGHT - sprites[i].width))
   450D DD 6E FE      [19]  275 	ld	l,-2 (ix)
   4510 DD 66 FF      [19]  276 	ld	h,-1 (ix)
   4513 11 0A 00      [10]  277 	ld	de, #0x000a
   4516 19            [11]  278 	add	hl, de
   4517 5E            [ 7]  279 	ld	e, (hl)
   4518 16 00         [ 7]  280 	ld	d, #0x00
   451A 3E 50         [ 7]  281 	ld	a, #0x50
   451C 93            [ 4]  282 	sub	a, e
   451D 47            [ 4]  283 	ld	b, a
   451E 3E 00         [ 7]  284 	ld	a, #0x00
   4520 9A            [ 4]  285 	sbc	a, d
   4521 5F            [ 4]  286 	ld	e, a
   4522 69            [ 4]  287 	ld	l, c
   4523 16 00         [ 7]  288 	ld	d, #0x00
   4525 78            [ 4]  289 	ld	a, b
   4526 95            [ 4]  290 	sub	a, l
   4527 7B            [ 4]  291 	ld	a, e
   4528 9A            [ 4]  292 	sbc	a, d
   4529 E2 2E 45      [10]  293 	jp	PO, 00149$
   452C EE 80         [ 7]  294 	xor	a, #0x80
   452E                     295 00149$:
   452E F2 35 45      [10]  296 	jp	P, 00104$
                            297 ;src/game.c:66: collision = collision | RIGHT_COLLISION;
   4531 DD 36 F6 02   [19]  298 	ld	-10 (ix), #0x02
                            299 ;src/game.c:68: collision = collision | LEFT_COLLISION;
   4535                     300 00104$:
                            301 ;src/game.c:70: if (y > (GAME_AREA_BOTTOM - sprites[i].height))
   4535 DD 6E FE      [19]  302 	ld	l,-2 (ix)
   4538 DD 66 FF      [19]  303 	ld	h,-1 (ix)
   453B 11 09 00      [10]  304 	ld	de, #0x0009
   453E 19            [11]  305 	add	hl, de
   453F 5E            [ 7]  306 	ld	e, (hl)
   4540 16 00         [ 7]  307 	ld	d, #0x00
   4542 3E C8         [ 7]  308 	ld	a, #0xc8
   4544 93            [ 4]  309 	sub	a, e
   4545 5F            [ 4]  310 	ld	e, a
   4546 3E 00         [ 7]  311 	ld	a, #0x00
   4548 9A            [ 4]  312 	sbc	a, d
   4549 57            [ 4]  313 	ld	d, a
   454A DD 6E F7      [19]  314 	ld	l, -9 (ix)
   454D 26 00         [ 7]  315 	ld	h, #0x00
   454F 7B            [ 4]  316 	ld	a, e
   4550 95            [ 4]  317 	sub	a, l
   4551 7A            [ 4]  318 	ld	a, d
   4552 9C            [ 4]  319 	sbc	a, h
   4553 E2 58 45      [10]  320 	jp	PO, 00150$
   4556 EE 80         [ 7]  321 	xor	a, #0x80
   4558                     322 00150$:
   4558 F2 5F 45      [10]  323 	jp	P, 00106$
                            324 ;src/game.c:71: collision = collision | BOTTOM_COLLISION;
   455B DD CB F6 C6   [23]  325 	set	0, -10 (ix)
   455F                     326 00106$:
                            327 ;src/game.c:72: if (y < GAME_AREA_TOP)
   455F DD 7E F7      [19]  328 	ld	a, -9 (ix)
   4562 D6 10         [ 7]  329 	sub	a, #0x10
   4564 30 08         [12]  330 	jr	NC,00108$
                            331 ;src/game.c:73: collision = collision | TOP_COLLISION;
   4566 DD 7E F6      [19]  332 	ld	a, -10 (ix)
   4569 F6 05         [ 7]  333 	or	a, #0x05
   456B DD 77 F6      [19]  334 	ld	-10 (ix), a
   456E                     335 00108$:
                            336 ;src/game.c:77: if ((collision & LEFT_RIGHT_COLLISION) == 0)		//if not hitting right, move up/down
   456E DD CB F6 4E   [20]  337 	bit	1, -10 (ix)
   4572 20 07         [12]  338 	jr	NZ,00110$
                            339 ;src/game.c:78: sprites[i].x = x;								//keep x as it was
   4574 DD 6E F9      [19]  340 	ld	l,-7 (ix)
   4577 DD 66 FA      [19]  341 	ld	h,-6 (ix)
   457A 71            [ 7]  342 	ld	(hl), c
   457B                     343 00110$:
                            344 ;src/game.c:80: if ((collision & TOP_BOTTOM_COLLISION) == 0)		//if not hitting top, move sideways //
   457B DD CB F6 46   [20]  345 	bit	0, -10 (ix)
   457F 20 0A         [12]  346 	jr	NZ,00117$
                            347 ;src/game.c:81: sprites[i].y = y;								//keep y as it was
   4581 DD 6E FC      [19]  348 	ld	l,-4 (ix)
   4584 DD 66 FD      [19]  349 	ld	h,-3 (ix)
   4587 DD 7E F7      [19]  350 	ld	a, -9 (ix)
   458A 77            [ 7]  351 	ld	(hl), a
   458B                     352 00117$:
                            353 ;src/game.c:54: for (i=0; i < MAX_SPRITES; i++) {
   458B DD 34 F8      [23]  354 	inc	-8 (ix)
   458E DD 7E F8      [19]  355 	ld	a, -8 (ix)
   4591 D6 0A         [ 7]  356 	sub	a, #0x0a
   4593 DA 9E 44      [10]  357 	jp	C, 00116$
   4596 DD F9         [10]  358 	ld	sp, ix
   4598 DD E1         [14]  359 	pop	ix
   459A C9            [10]  360 	ret
                            361 ;src/game.c:89: void init_game() {
                            362 ;	---------------------------------
                            363 ; Function init_game
                            364 ; ---------------------------------
   459B                     365 _init_game::
                            366 ;src/game.c:92: sprites[0].id = 1;												//mark the sprite "alive" (non-zero)
   459B 21 F6 68      [10]  367 	ld	hl, #_sprites
   459E 36 01         [10]  368 	ld	(hl), #0x01
                            369 ;src/game.c:93: sprites[0].x = GAME_AREA_LEFT;									//init position to 0,0
   45A0 21 F7 68      [10]  370 	ld	hl, #(_sprites + 0x0001)
   45A3 36 00         [10]  371 	ld	(hl), #0x00
                            372 ;src/game.c:94: sprites[0].y = GAME_AREA_TOP;
   45A5 21 F8 68      [10]  373 	ld	hl, #(_sprites + 0x0002)
   45A8 36 10         [10]  374 	ld	(hl), #0x10
                            375 ;src/game.c:95: sprites[0].moveV = sprites[0].moveH = 0;						//init movement to none
   45AA 21 FA 68      [10]  376 	ld	hl, #(_sprites + 0x0004)
   45AD 36 00         [10]  377 	ld	(hl), #0x00
   45AF 21 F9 68      [10]  378 	ld	hl, #(_sprites + 0x0003)
   45B2 36 00         [10]  379 	ld	(hl), #0x00
                            380 ;src/game.c:97: sprites[0].x_prev_A = sprites[0].y_prev_A = sprites[0].x_prev_B = sprites[0].y_prev_B = 0;
   45B4 21 FE 68      [10]  381 	ld	hl, #(_sprites + 0x0008)
   45B7 36 00         [10]  382 	ld	(hl), #0x00
   45B9 21 FD 68      [10]  383 	ld	hl, #(_sprites + 0x0007)
   45BC 36 00         [10]  384 	ld	(hl), #0x00
   45BE 21 FC 68      [10]  385 	ld	hl, #(_sprites + 0x0006)
   45C1 36 00         [10]  386 	ld	(hl), #0x00
   45C3 21 FB 68      [10]  387 	ld	hl, #(_sprites + 0x0005)
   45C6 36 00         [10]  388 	ld	(hl), #0x00
                            389 ;src/game.c:98: sprites[0].height = G_PITU_H;
   45C8 21 FF 68      [10]  390 	ld	hl, #(_sprites + 0x0009)
   45CB 36 20         [10]  391 	ld	(hl), #0x20
                            392 ;src/game.c:99: sprites[0].width = G_PITU_W;									//!?! /2: - M0, length in bytes = /2 in px
   45CD 21 00 69      [10]  393 	ld	hl, #(_sprites + 0x000a)
   45D0 36 07         [10]  394 	ld	(hl), #0x07
                            395 ;src/game.c:100: sprites[0].properties = 0;										//bitmasked properties - init to 0
   45D2 01 01 69      [10]  396 	ld	bc, #_sprites + 11
   45D5 AF            [ 4]  397 	xor	a, a
   45D6 02            [ 7]  398 	ld	(bc), a
                            399 ;src/game.c:101: sprites[0].properties = sprites[0].properties | MASK_RENDER;	//init to "render" on screen
   45D7 0A            [ 7]  400 	ld	a, (bc)
   45D8 CB C7         [ 8]  401 	set	0, a
   45DA 02            [ 7]  402 	ld	(bc), a
                            403 ;src/game.c:102: sprites[0].frames = 2;											//main sprite has two "moves" to animate
   45DB 21 04 69      [10]  404 	ld	hl, #(_sprites + 0x000e)
   45DE 36 02         [10]  405 	ld	(hl), #0x02
                            406 ;src/game.c:103: sprites[0].sprite_f1 = (u8*)G_pitu; 							//first render for sprite. &G_pitu[0]
   45E0 21 8E 46      [10]  407 	ld	hl, #_G_pitu
   45E3 22 05 69      [16]  408 	ld	((_sprites + 0x000f)), hl
                            409 ;src/game.c:104: sprites[0].sprite_f2 = (u8*)G_pitu_walk;
   45E6 21 0E 4A      [10]  410 	ld	hl, #_G_pitu_walk
   45E9 22 07 69      [16]  411 	ld	((_sprites + 0x0011)), hl
                            412 ;src/game.c:105: sprites[0].sprite_f3 = (u8*)G_pitu_jump;
   45EC 21 8E 4D      [10]  413 	ld	hl, #_G_pitu_jump
   45EF 22 09 69      [16]  414 	ld	((_sprites + 0x0013)), hl
                            415 ;src/game.c:106: sprites[0].sprite_f3 = (u8*)G_blast;
   45F2 21 0E 58      [10]  416 	ld	hl, #_G_blast
   45F5 22 09 69      [16]  417 	ld	((_sprites + 0x0013)), hl
                            418 ;src/game.c:107: sprites[0].turned = 0;											//start looking right/front
   45F8 21 0D 69      [10]  419 	ld	hl, #(_sprites + 0x0017)
   45FB 36 00         [10]  420 	ld	(hl), #0x00
                            421 ;src/game.c:110: for (i = 1; i < MAX_SPRITES; i++)
   45FD 0E 01         [ 7]  422 	ld	c, #0x01
   45FF                     423 00102$:
                            424 ;src/game.c:111: sprites[i].id=0;
   45FF 06 00         [ 7]  425 	ld	b,#0x00
   4601 69            [ 4]  426 	ld	l, c
   4602 60            [ 4]  427 	ld	h, b
   4603 29            [11]  428 	add	hl, hl
   4604 09            [11]  429 	add	hl, bc
   4605 29            [11]  430 	add	hl, hl
   4606 29            [11]  431 	add	hl, hl
   4607 29            [11]  432 	add	hl, hl
   4608 11 F6 68      [10]  433 	ld	de, #_sprites
   460B 19            [11]  434 	add	hl, de
   460C 36 00         [10]  435 	ld	(hl), #0x00
                            436 ;src/game.c:110: for (i = 1; i < MAX_SPRITES; i++)
   460E 0C            [ 4]  437 	inc	c
   460F 79            [ 4]  438 	ld	a, c
   4610 D6 0A         [ 7]  439 	sub	a, #0x0a
   4612 38 EB         [12]  440 	jr	C,00102$
                            441 ;src/game.c:113: anim_clock=1;
   4614 21 E6 69      [10]  442 	ld	hl,#_anim_clock + 0
   4617 36 01         [10]  443 	ld	(hl), #0x01
   4619 C9            [10]  444 	ret
                            445 ;src/game.c:119: void game(){
                            446 ;	---------------------------------
                            447 ; Function game
                            448 ; ---------------------------------
   461A                     449 _game::
                            450 ;src/game.c:121: cpct_setBorder(HW_WHITE);
   461A 21 10 00      [10]  451 	ld	hl, #0x0010
   461D E5            [11]  452 	push	hl
   461E CD 03 66      [17]  453 	call	_cpct_setPALColour
                            454 ;src/game.c:123: cpct_memset ((u8*)CPCT_LVMEM_START, cpct_px2byteM0(5, 5), 0x8000); //5 is ordinal for WHITE from palette in M0 with 16c
   4621 21 05 05      [10]  455 	ld	hl, #0x0505
   4624 E5            [11]  456 	push	hl
   4625 CD C9 67      [17]  457 	call	_cpct_px2byteM0
   4628 45            [ 4]  458 	ld	b, l
   4629 21 00 80      [10]  459 	ld	hl, #0x8000
   462C E5            [11]  460 	push	hl
   462D C5            [11]  461 	push	bc
   462E 33            [ 6]  462 	inc	sp
   462F 2E 00         [ 7]  463 	ld	l, #0x00
   4631 E5            [11]  464 	push	hl
   4632 CD E5 67      [17]  465 	call	_cpct_memset
                            466 ;src/game.c:125: while (1) {
   4635                     467 00107$:
                            468 ;src/game.c:128: if (!swap_memvideo) { 					//switch
   4635 3A EA 69      [13]  469 	ld	a,(#_swap_memvideo + 0)
   4638 B7            [ 4]  470 	or	a, a
   4639 20 0D         [12]  471 	jr	NZ,00102$
                            472 ;src/game.c:129: mem_start = (u8*) CPCT_LVMEM_START;	//lower VMEM page
   463B 21 00 80      [10]  473 	ld	hl, #0x8000
   463E 22 E7 69      [16]  474 	ld	(_mem_start), hl
                            475 ;src/game.c:130: mem_page = cpct_page80;				//FIXME:: can probably delete??
   4641 21 E9 69      [10]  476 	ld	hl,#_mem_page + 0
   4644 36 20         [10]  477 	ld	(hl), #0x20
   4646 18 0B         [12]  478 	jr	00103$
   4648                     479 00102$:
                            480 ;src/game.c:132: mem_start = (u8*) CPCT_VMEM_START;	//upper,regular VMEM page
   4648 21 00 C0      [10]  481 	ld	hl, #0xc000
   464B 22 E7 69      [16]  482 	ld	(_mem_start), hl
                            483 ;src/game.c:133: mem_page = cpct_pageC0;
   464E 21 E9 69      [10]  484 	ld	hl,#_mem_page + 0
   4651 36 30         [10]  485 	ld	(hl), #0x30
   4653                     486 00103$:
                            487 ;src/game.c:137: keyboard(); 							//user movement
   4653 CD CC 43      [17]  488 	call	_keyboard
                            489 ;src/game.c:139: moveSprites();
   4656 CD 8D 44      [17]  490 	call	_moveSprites
                            491 ;src/game.c:140: deleteSprites();
   4659 CD 89 64      [17]  492 	call	_deleteSprites
                            493 ;src/game.c:141: renderSprites();
   465C CD 0D 63      [17]  494 	call	_renderSprites
                            495 ;src/game.c:144: cpct_waitVSYNC();						//Wait until CRTC has printed a full frame to "repaint"
   465F CD C1 67      [17]  496 	call	_cpct_waitVSYNC
                            497 ;src/game.c:145: cpct_setVideoMemoryPage(mem_page);		//Tell CRTC to "paint" the new page--FIXME: can this use "mem_start" instead?
   4662 FD 21 E9 69   [14]  498 	ld	iy, #_mem_page
   4666 FD 6E 00      [19]  499 	ld	l, 0 (iy)
   4669 CD 5C 67      [17]  500 	call	_cpct_setVideoMemoryPage
                            501 ;src/game.c:146: swap_memvideo = ~swap_memvideo; 		//flip the switch
   466C FD 21 EA 69   [14]  502 	ld	iy, #_swap_memvideo
   4670 FD 7E 00      [19]  503 	ld	a, 0 (iy)
   4673 2F            [ 4]  504 	cpl
   4674 FD 77 00      [19]  505 	ld	0 (iy), a
                            506 ;src/game.c:148: anim_clock+=ANIM_SPEED;
   4677 FD 21 E6 69   [14]  507 	ld	iy, #_anim_clock
   467B FD 34 00      [23]  508 	inc	0 (iy)
   467E FD 34 00      [23]  509 	inc	0 (iy)
                            510 ;src/game.c:149: if (anim_clock > ANIM_CYCLE)
   4681 3E 10         [ 7]  511 	ld	a, #0x10
   4683 FD 96 00      [19]  512 	sub	a, 0 (iy)
   4686 30 AD         [12]  513 	jr	NC,00107$
                            514 ;src/game.c:150: anim_clock=1;
   4688 FD 36 00 01   [19]  515 	ld	0 (iy), #0x01
   468C 18 A7         [12]  516 	jr	00107$
                            517 	.area _CODE
                            518 	.area _INITIALIZER
                            519 	.area _CABS (ABS)
