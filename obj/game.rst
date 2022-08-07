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
   5F5E                      34 _sprites::
   5F5E                      35 	.ds 240
   604E                      36 _anim_clock::
   604E                      37 	.ds 1
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
   4110                      66 _keyboard::
                             67 ;src/game.c:17: sprites[0].moveV = sprites[0].moveH = 0; 							//start with no movement
   4110 21 62 5F      [10]   68 	ld	hl, #(_sprites + 0x0004)
   4113 36 00         [10]   69 	ld	(hl), #0x00
   4115 21 61 5F      [10]   70 	ld	hl, #(_sprites + 0x0003)
   4118 36 00         [10]   71 	ld	(hl), #0x00
                             72 ;src/game.c:20: cpct_scanKeyboard_f();
   411A CD C3 5B      [17]   73 	call	_cpct_scanKeyboard_f
                             74 ;src/game.c:21: if (cpct_isKeyPressed(Key_CursorUp) || cpct_isKeyPressed(Key_Q) || cpct_isKeyPressed(Joy0_Up)){	
   411D 21 00 01      [10]   75 	ld	hl, #0x0100
   4120 CD B7 5B      [17]   76 	call	_cpct_isKeyPressed
   4123 7D            [ 4]   77 	ld	a, l
   4124 B7            [ 4]   78 	or	a, a
   4125 20 14         [12]   79 	jr	NZ,00101$
   4127 21 08 08      [10]   80 	ld	hl, #0x0808
   412A CD B7 5B      [17]   81 	call	_cpct_isKeyPressed
   412D 7D            [ 4]   82 	ld	a, l
   412E B7            [ 4]   83 	or	a, a
   412F 20 0A         [12]   84 	jr	NZ,00101$
   4131 21 09 01      [10]   85 	ld	hl, #0x0109
   4134 CD B7 5B      [17]   86 	call	_cpct_isKeyPressed
   4137 7D            [ 4]   87 	ld	a, l
   4138 B7            [ 4]   88 	or	a, a
   4139 28 05         [12]   89 	jr	Z,00102$
   413B                      90 00101$:
                             91 ;src/game.c:22: sprites[0].moveV = -1;		
   413B 21 61 5F      [10]   92 	ld	hl, #(_sprites + 0x0003)
   413E 36 FF         [10]   93 	ld	(hl), #0xff
   4140                      94 00102$:
                             95 ;src/game.c:24: if (cpct_isKeyPressed(Key_CursorDown) || cpct_isKeyPressed(Key_A) || cpct_isKeyPressed(Joy0_Down)){
   4140 21 00 04      [10]   96 	ld	hl, #0x0400
   4143 CD B7 5B      [17]   97 	call	_cpct_isKeyPressed
   4146 7D            [ 4]   98 	ld	a, l
   4147 B7            [ 4]   99 	or	a, a
   4148 20 14         [12]  100 	jr	NZ,00105$
   414A 21 08 20      [10]  101 	ld	hl, #0x2008
   414D CD B7 5B      [17]  102 	call	_cpct_isKeyPressed
   4150 7D            [ 4]  103 	ld	a, l
   4151 B7            [ 4]  104 	or	a, a
   4152 20 0A         [12]  105 	jr	NZ,00105$
   4154 21 09 02      [10]  106 	ld	hl, #0x0209
   4157 CD B7 5B      [17]  107 	call	_cpct_isKeyPressed
   415A 7D            [ 4]  108 	ld	a, l
   415B B7            [ 4]  109 	or	a, a
   415C 28 05         [12]  110 	jr	Z,00106$
   415E                     111 00105$:
                            112 ;src/game.c:25: sprites[0].moveV = 1;
   415E 21 61 5F      [10]  113 	ld	hl, #(_sprites + 0x0003)
   4161 36 01         [10]  114 	ld	(hl), #0x01
   4163                     115 00106$:
                            116 ;src/game.c:27: if (cpct_isKeyPressed(Key_CursorLeft) || cpct_isKeyPressed(Key_O) || cpct_isKeyPressed(Joy0_Left)){
   4163 21 01 01      [10]  117 	ld	hl, #0x0101
   4166 CD B7 5B      [17]  118 	call	_cpct_isKeyPressed
                            119 ;src/game.c:29: sprites[0].turned = 1;
                            120 ;src/game.c:27: if (cpct_isKeyPressed(Key_CursorLeft) || cpct_isKeyPressed(Key_O) || cpct_isKeyPressed(Joy0_Left)){
   4169 7D            [ 4]  121 	ld	a, l
   416A B7            [ 4]  122 	or	a, a
   416B 20 14         [12]  123 	jr	NZ,00109$
   416D 21 04 04      [10]  124 	ld	hl, #0x0404
   4170 CD B7 5B      [17]  125 	call	_cpct_isKeyPressed
   4173 7D            [ 4]  126 	ld	a, l
   4174 B7            [ 4]  127 	or	a, a
   4175 20 0A         [12]  128 	jr	NZ,00109$
   4177 21 09 04      [10]  129 	ld	hl, #0x0409
   417A CD B7 5B      [17]  130 	call	_cpct_isKeyPressed
   417D 7D            [ 4]  131 	ld	a, l
   417E B7            [ 4]  132 	or	a, a
   417F 28 0A         [12]  133 	jr	Z,00110$
   4181                     134 00109$:
                            135 ;src/game.c:28: sprites[0].moveH = -1;
   4181 21 62 5F      [10]  136 	ld	hl, #(_sprites + 0x0004)
   4184 36 FF         [10]  137 	ld	(hl), #0xff
                            138 ;src/game.c:29: sprites[0].turned = 1;
   4186 21 75 5F      [10]  139 	ld	hl, #(_sprites + 0x0017)
   4189 36 01         [10]  140 	ld	(hl), #0x01
   418B                     141 00110$:
                            142 ;src/game.c:31: if (cpct_isKeyPressed(Key_CursorRight) || cpct_isKeyPressed(Key_P) || cpct_isKeyPressed(Joy0_Right)){
   418B 21 00 02      [10]  143 	ld	hl, #0x0200
   418E CD B7 5B      [17]  144 	call	_cpct_isKeyPressed
   4191 7D            [ 4]  145 	ld	a, l
   4192 B7            [ 4]  146 	or	a, a
   4193 20 14         [12]  147 	jr	NZ,00113$
   4195 21 03 08      [10]  148 	ld	hl, #0x0803
   4198 CD B7 5B      [17]  149 	call	_cpct_isKeyPressed
   419B 7D            [ 4]  150 	ld	a, l
   419C B7            [ 4]  151 	or	a, a
   419D 20 0A         [12]  152 	jr	NZ,00113$
   419F 21 09 08      [10]  153 	ld	hl, #0x0809
   41A2 CD B7 5B      [17]  154 	call	_cpct_isKeyPressed
   41A5 7D            [ 4]  155 	ld	a, l
   41A6 B7            [ 4]  156 	or	a, a
   41A7 28 0A         [12]  157 	jr	Z,00114$
   41A9                     158 00113$:
                            159 ;src/game.c:32: sprites[0].moveH = 1;
   41A9 21 62 5F      [10]  160 	ld	hl, #(_sprites + 0x0004)
   41AC 36 01         [10]  161 	ld	(hl), #0x01
                            162 ;src/game.c:33: sprites[0].turned = 0;
   41AE 21 75 5F      [10]  163 	ld	hl, #(_sprites + 0x0017)
   41B1 36 00         [10]  164 	ld	(hl), #0x00
   41B3                     165 00114$:
                            166 ;src/game.c:37: if (sprites[0].moveH !=0 || sprites[0].moveV !=0)					//sprite moved
   41B3 21 62 5F      [10]  167 	ld	hl, #(_sprites + 0x0004) + 0
   41B6 4E            [ 7]  168 	ld	c, (hl)
                            169 ;src/game.c:38: sprites[0].properties = sprites[0].properties | MASK_ANIMATE; 	//mark for animation
   41B7 11 69 5F      [10]  170 	ld	de, #_sprites + 11
   41BA 1A            [ 7]  171 	ld	a, (de)
   41BB 47            [ 4]  172 	ld	b, a
                            173 ;src/game.c:37: if (sprites[0].moveH !=0 || sprites[0].moveV !=0)					//sprite moved
   41BC 79            [ 4]  174 	ld	a, c
   41BD B7            [ 4]  175 	or	a, a
   41BE 20 06         [12]  176 	jr	NZ,00117$
   41C0 3A 61 5F      [13]  177 	ld	a, (#(_sprites + 0x0003) + 0)
   41C3 B7            [ 4]  178 	or	a, a
   41C4 28 05         [12]  179 	jr	Z,00118$
   41C6                     180 00117$:
                            181 ;src/game.c:38: sprites[0].properties = sprites[0].properties | MASK_ANIMATE; 	//mark for animation
   41C6 78            [ 4]  182 	ld	a, b
   41C7 CB CF         [ 8]  183 	set	1, a
   41C9 12            [ 7]  184 	ld	(de), a
   41CA C9            [10]  185 	ret
   41CB                     186 00118$:
                            187 ;src/game.c:40: sprites[0].properties = sprites[0].properties & ~MASK_ANIMATE;	//unmark for animation;
   41CB CB 88         [ 8]  188 	res	1, b
   41CD 78            [ 4]  189 	ld	a, b
   41CE 12            [ 7]  190 	ld	(de), a
   41CF C9            [10]  191 	ret
                            192 ;src/game.c:45: void AI(){
                            193 ;	---------------------------------
                            194 ; Function AI
                            195 ; ---------------------------------
   41D0                     196 _AI::
                            197 ;src/game.c:46: }
   41D0 C9            [10]  198 	ret
                            199 ;src/game.c:50: void moveSprites() {
                            200 ;	---------------------------------
                            201 ; Function moveSprites
                            202 ; ---------------------------------
   41D1                     203 _moveSprites::
   41D1 DD E5         [15]  204 	push	ix
   41D3 DD 21 00 00   [14]  205 	ld	ix,#0
   41D7 DD 39         [15]  206 	add	ix,sp
   41D9 21 F6 FF      [10]  207 	ld	hl, #-10
   41DC 39            [11]  208 	add	hl, sp
   41DD F9            [ 6]  209 	ld	sp, hl
                            210 ;src/game.c:54: for (i=0; i < MAX_SPRITES; i++) {
   41DE DD 36 F8 00   [19]  211 	ld	-8 (ix), #0x00
   41E2                     212 00112$:
                            213 ;src/game.c:55: if (sprites[i].id !=0) {			//check only live sprites to optimize CPU (non-zero)
   41E2 DD 4E F8      [19]  214 	ld	c,-8 (ix)
   41E5 06 00         [ 7]  215 	ld	b,#0x00
   41E7 69            [ 4]  216 	ld	l, c
   41E8 60            [ 4]  217 	ld	h, b
   41E9 29            [11]  218 	add	hl, hl
   41EA 09            [11]  219 	add	hl, bc
   41EB 29            [11]  220 	add	hl, hl
   41EC 29            [11]  221 	add	hl, hl
   41ED 29            [11]  222 	add	hl, hl
   41EE 01 5E 5F      [10]  223 	ld	bc,#_sprites
   41F1 09            [11]  224 	add	hl,bc
   41F2 DD 75 FE      [19]  225 	ld	-2 (ix), l
   41F5 DD 74 FF      [19]  226 	ld	-1 (ix), h
   41F8 7E            [ 7]  227 	ld	a, (hl)
   41F9 DD 77 F9      [19]  228 	ld	-7 (ix), a
   41FC B7            [ 4]  229 	or	a, a
   41FD CA C0 42      [10]  230 	jp	Z, 00113$
                            231 ;src/game.c:56: collision = 0;
   4200 DD 36 F6 00   [19]  232 	ld	-10 (ix), #0x00
                            233 ;src/game.c:58: x = sprites[i].x;
   4204 DD 7E FE      [19]  234 	ld	a, -2 (ix)
   4207 C6 01         [ 7]  235 	add	a, #0x01
   4209 DD 77 FA      [19]  236 	ld	-6 (ix), a
   420C DD 7E FF      [19]  237 	ld	a, -1 (ix)
   420F CE 00         [ 7]  238 	adc	a, #0x00
   4211 DD 77 FB      [19]  239 	ld	-5 (ix), a
   4214 DD 6E FA      [19]  240 	ld	l,-6 (ix)
   4217 DD 66 FB      [19]  241 	ld	h,-5 (ix)
   421A 46            [ 7]  242 	ld	b, (hl)
                            243 ;src/game.c:59: y = sprites[i].y;
   421B DD 7E FE      [19]  244 	ld	a, -2 (ix)
   421E C6 02         [ 7]  245 	add	a, #0x02
   4220 DD 77 FC      [19]  246 	ld	-4 (ix), a
   4223 DD 7E FF      [19]  247 	ld	a, -1 (ix)
   4226 CE 00         [ 7]  248 	adc	a, #0x00
   4228 DD 77 FD      [19]  249 	ld	-3 (ix), a
   422B DD 6E FC      [19]  250 	ld	l,-4 (ix)
   422E DD 66 FD      [19]  251 	ld	h,-3 (ix)
   4231 4E            [ 7]  252 	ld	c, (hl)
                            253 ;src/game.c:61: y = y + (4*sprites[i].moveV);	//vertical movement: Y is *px, X is *byte. M0 so Y is 4 times slower
   4232 DD 6E FE      [19]  254 	ld	l,-2 (ix)
   4235 DD 66 FF      [19]  255 	ld	h,-1 (ix)
   4238 23            [ 6]  256 	inc	hl
   4239 23            [ 6]  257 	inc	hl
   423A 23            [ 6]  258 	inc	hl
   423B 7E            [ 7]  259 	ld	a, (hl)
   423C 87            [ 4]  260 	add	a, a
   423D 87            [ 4]  261 	add	a, a
   423E 6F            [ 4]  262 	ld	l, a
   423F 09            [11]  263 	add	hl, bc
   4240 4D            [ 4]  264 	ld	c, l
                            265 ;src/game.c:62: x = x + (sprites[i].moveH);
   4241 DD 6E FE      [19]  266 	ld	l,-2 (ix)
   4244 DD 66 FF      [19]  267 	ld	h,-1 (ix)
   4247 11 04 00      [10]  268 	ld	de, #0x0004
   424A 19            [11]  269 	add	hl, de
   424B 5E            [ 7]  270 	ld	e, (hl)
   424C 68            [ 4]  271 	ld	l, b
   424D 19            [11]  272 	add	hl, de
   424E DD 75 F7      [19]  273 	ld	-9 (ix), l
                            274 ;src/game.c:65: if (y > (GAME_AREA_BOTTOM - sprites[i].height))
   4251 DD 6E FE      [19]  275 	ld	l,-2 (ix)
   4254 DD 66 FF      [19]  276 	ld	h,-1 (ix)
   4257 11 09 00      [10]  277 	ld	de, #0x0009
   425A 19            [11]  278 	add	hl, de
   425B 5E            [ 7]  279 	ld	e, (hl)
   425C 16 00         [ 7]  280 	ld	d, #0x00
   425E 3E C8         [ 7]  281 	ld	a, #0xc8
   4260 93            [ 4]  282 	sub	a, e
   4261 47            [ 4]  283 	ld	b, a
   4262 3E 00         [ 7]  284 	ld	a, #0x00
   4264 9A            [ 4]  285 	sbc	a, d
   4265 5F            [ 4]  286 	ld	e, a
   4266 69            [ 4]  287 	ld	l, c
   4267 16 00         [ 7]  288 	ld	d, #0x00
   4269 78            [ 4]  289 	ld	a, b
   426A 95            [ 4]  290 	sub	a, l
   426B 7B            [ 4]  291 	ld	a, e
   426C 9A            [ 4]  292 	sbc	a, d
   426D E2 72 42      [10]  293 	jp	PO, 00141$
   4270 EE 80         [ 7]  294 	xor	a, #0x80
   4272                     295 00141$:
   4272 F2 79 42      [10]  296 	jp	P, 00102$
                            297 ;src/game.c:66: collision = collision | TOP_BOTTOM_COLLISION; //signal top collision w/bitmask
   4275 DD 36 F6 01   [19]  298 	ld	-10 (ix), #0x01
   4279                     299 00102$:
                            300 ;src/game.c:68: if (x > (GAME_AREA_RIGHT - sprites[i].width))
   4279 DD 6E FE      [19]  301 	ld	l,-2 (ix)
   427C DD 66 FF      [19]  302 	ld	h,-1 (ix)
   427F 11 0A 00      [10]  303 	ld	de, #0x000a
   4282 19            [11]  304 	add	hl, de
   4283 5E            [ 7]  305 	ld	e, (hl)
   4284 16 00         [ 7]  306 	ld	d, #0x00
   4286 3E 50         [ 7]  307 	ld	a, #0x50
   4288 93            [ 4]  308 	sub	a, e
   4289 5F            [ 4]  309 	ld	e, a
   428A 3E 00         [ 7]  310 	ld	a, #0x00
   428C 9A            [ 4]  311 	sbc	a, d
   428D 57            [ 4]  312 	ld	d, a
   428E DD 6E F7      [19]  313 	ld	l, -9 (ix)
   4291 26 00         [ 7]  314 	ld	h, #0x00
   4293 7B            [ 4]  315 	ld	a, e
   4294 95            [ 4]  316 	sub	a, l
   4295 7A            [ 4]  317 	ld	a, d
   4296 9C            [ 4]  318 	sbc	a, h
   4297 E2 9C 42      [10]  319 	jp	PO, 00142$
   429A EE 80         [ 7]  320 	xor	a, #0x80
   429C                     321 00142$:
   429C F2 A3 42      [10]  322 	jp	P, 00104$
                            323 ;src/game.c:69: collision = collision | LEFT_RIGHT_COLLISION; //signal right collision w/bitmask
   429F DD CB F6 CE   [23]  324 	set	1, -10 (ix)
   42A3                     325 00104$:
                            326 ;src/game.c:74: if ((collision & TOP_BOTTOM_COLLISION) == 0)		//if not hitting top, move sideways
   42A3 DD CB F6 46   [20]  327 	bit	0, -10 (ix)
   42A7 20 07         [12]  328 	jr	NZ,00106$
                            329 ;src/game.c:75: sprites[i].y = y;
   42A9 DD 6E FC      [19]  330 	ld	l,-4 (ix)
   42AC DD 66 FD      [19]  331 	ld	h,-3 (ix)
   42AF 71            [ 7]  332 	ld	(hl), c
   42B0                     333 00106$:
                            334 ;src/game.c:76: if ((collision & LEFT_RIGHT_COLLISION) == 0)		//if not hitting right, move up/down
   42B0 DD CB F6 4E   [20]  335 	bit	1, -10 (ix)
   42B4 20 0A         [12]  336 	jr	NZ,00113$
                            337 ;src/game.c:77: sprites[i].x = x;
   42B6 DD 6E FA      [19]  338 	ld	l,-6 (ix)
   42B9 DD 66 FB      [19]  339 	ld	h,-5 (ix)
   42BC DD 7E F7      [19]  340 	ld	a, -9 (ix)
   42BF 77            [ 7]  341 	ld	(hl), a
   42C0                     342 00113$:
                            343 ;src/game.c:54: for (i=0; i < MAX_SPRITES; i++) {
   42C0 DD 34 F8      [23]  344 	inc	-8 (ix)
   42C3 DD 7E F8      [19]  345 	ld	a, -8 (ix)
   42C6 D6 0A         [ 7]  346 	sub	a, #0x0a
   42C8 DA E2 41      [10]  347 	jp	C, 00112$
   42CB DD F9         [10]  348 	ld	sp, ix
   42CD DD E1         [14]  349 	pop	ix
   42CF C9            [10]  350 	ret
                            351 ;src/game.c:85: void init_game() {
                            352 ;	---------------------------------
                            353 ; Function init_game
                            354 ; ---------------------------------
   42D0                     355 _init_game::
                            356 ;src/game.c:88: sprites[0].id = 1;												//mark the sprite "alive" (non-zero)
   42D0 21 5E 5F      [10]  357 	ld	hl, #_sprites
   42D3 36 01         [10]  358 	ld	(hl), #0x01
                            359 ;src/game.c:89: sprites[0].x = sprites[0].y = 0;								//init position to 0,0
   42D5 21 60 5F      [10]  360 	ld	hl, #(_sprites + 0x0002)
   42D8 36 00         [10]  361 	ld	(hl), #0x00
   42DA 21 5F 5F      [10]  362 	ld	hl, #(_sprites + 0x0001)
   42DD 36 00         [10]  363 	ld	(hl), #0x00
                            364 ;src/game.c:90: sprites[0].moveV = sprites[0].moveH = 0;						//init movement to none
   42DF 21 62 5F      [10]  365 	ld	hl, #(_sprites + 0x0004)
   42E2 36 00         [10]  366 	ld	(hl), #0x00
   42E4 21 61 5F      [10]  367 	ld	hl, #(_sprites + 0x0003)
   42E7 36 00         [10]  368 	ld	(hl), #0x00
                            369 ;src/game.c:92: sprites[0].x_prev_A = sprites[0].y_prev_A = sprites[0].x_prev_B = sprites[0].y_prev_B = 0;
   42E9 21 66 5F      [10]  370 	ld	hl, #(_sprites + 0x0008)
   42EC 36 00         [10]  371 	ld	(hl), #0x00
   42EE 21 65 5F      [10]  372 	ld	hl, #(_sprites + 0x0007)
   42F1 36 00         [10]  373 	ld	(hl), #0x00
   42F3 21 64 5F      [10]  374 	ld	hl, #(_sprites + 0x0006)
   42F6 36 00         [10]  375 	ld	(hl), #0x00
   42F8 21 63 5F      [10]  376 	ld	hl, #(_sprites + 0x0005)
   42FB 36 00         [10]  377 	ld	(hl), #0x00
                            378 ;src/game.c:93: sprites[0].height = G_PITU_H;
   42FD 21 67 5F      [10]  379 	ld	hl, #(_sprites + 0x0009)
   4300 36 20         [10]  380 	ld	(hl), #0x20
                            381 ;src/game.c:94: sprites[0].width = G_PITU_W;									//!?! /2: - M0, length in bytes = /2 in px
   4302 21 68 5F      [10]  382 	ld	hl, #(_sprites + 0x000a)
   4305 36 08         [10]  383 	ld	(hl), #0x08
                            384 ;src/game.c:95: sprites[0].properties = 0;										//bitmasked properties - init to 0
   4307 01 69 5F      [10]  385 	ld	bc, #_sprites + 11
   430A AF            [ 4]  386 	xor	a, a
   430B 02            [ 7]  387 	ld	(bc), a
                            388 ;src/game.c:96: sprites[0].properties = sprites[0].properties | MASK_RENDER;	//init to "render" on screen
   430C 0A            [ 7]  389 	ld	a, (bc)
   430D CB C7         [ 8]  390 	set	0, a
   430F 02            [ 7]  391 	ld	(bc), a
                            392 ;src/game.c:97: sprites[0].frames = 2;											//main sprite has two "moves" to animate
   4310 21 6C 5F      [10]  393 	ld	hl, #(_sprites + 0x000e)
   4313 36 02         [10]  394 	ld	(hl), #0x02
                            395 ;src/game.c:98: sprites[0].sprite_f1 = (u8*)G_pitu; 							//first render for sprite. &G_pitu[0]
   4315 21 C3 43      [10]  396 	ld	hl, #_G_pitu
   4318 22 6D 5F      [16]  397 	ld	((_sprites + 0x000f)), hl
                            398 ;src/game.c:99: sprites[0].sprite_f2 = (u8*)G_pitu_walk;
   431B 21 C3 45      [10]  399 	ld	hl, #_G_pitu_walk
   431E 22 6F 5F      [16]  400 	ld	((_sprites + 0x0011)), hl
                            401 ;src/game.c:100: sprites[0].sprite_f3 = (u8*)G_pitu_jump;
   4321 21 C3 47      [10]  402 	ld	hl, #_G_pitu_jump
   4324 22 71 5F      [16]  403 	ld	((_sprites + 0x0013)), hl
                            404 ;src/game.c:101: sprites[0].sprite_f3 = (u8*)G_blast;
   4327 21 C3 4D      [10]  405 	ld	hl, #_G_blast
   432A 22 71 5F      [16]  406 	ld	((_sprites + 0x0013)), hl
                            407 ;src/game.c:102: sprites[0].turned = 0;											//start looking right/front
   432D 21 75 5F      [10]  408 	ld	hl, #(_sprites + 0x0017)
   4330 36 00         [10]  409 	ld	(hl), #0x00
                            410 ;src/game.c:105: for (i = 1; i < MAX_SPRITES; i++)
   4332 0E 01         [ 7]  411 	ld	c, #0x01
   4334                     412 00102$:
                            413 ;src/game.c:106: sprites[i].id=0;
   4334 06 00         [ 7]  414 	ld	b,#0x00
   4336 69            [ 4]  415 	ld	l, c
   4337 60            [ 4]  416 	ld	h, b
   4338 29            [11]  417 	add	hl, hl
   4339 09            [11]  418 	add	hl, bc
   433A 29            [11]  419 	add	hl, hl
   433B 29            [11]  420 	add	hl, hl
   433C 29            [11]  421 	add	hl, hl
   433D 11 5E 5F      [10]  422 	ld	de, #_sprites
   4340 19            [11]  423 	add	hl, de
   4341 36 00         [10]  424 	ld	(hl), #0x00
                            425 ;src/game.c:105: for (i = 1; i < MAX_SPRITES; i++)
   4343 0C            [ 4]  426 	inc	c
   4344 79            [ 4]  427 	ld	a, c
   4345 D6 0A         [ 7]  428 	sub	a, #0x0a
   4347 38 EB         [12]  429 	jr	C,00102$
                            430 ;src/game.c:108: anim_clock=1;
   4349 21 4E 60      [10]  431 	ld	hl,#_anim_clock + 0
   434C 36 01         [10]  432 	ld	(hl), #0x01
   434E C9            [10]  433 	ret
                            434 ;src/game.c:114: void game(){
                            435 ;	---------------------------------
                            436 ; Function game
                            437 ; ---------------------------------
   434F                     438 _game::
                            439 ;src/game.c:116: cpct_setBorder(HW_WHITE);
   434F 21 10 00      [10]  440 	ld	hl, #0x0010
   4352 E5            [11]  441 	push	hl
   4353 CD 6B 5C      [17]  442 	call	_cpct_setPALColour
                            443 ;src/game.c:118: cpct_memset ((u8*)CPCT_LVMEM_START, cpct_px2byteM0(5, 5), 0x8000); //5 is ordinal for WHITE from palette in M0 with 16c
   4356 21 05 05      [10]  444 	ld	hl, #0x0505
   4359 E5            [11]  445 	push	hl
   435A CD 31 5E      [17]  446 	call	_cpct_px2byteM0
   435D 45            [ 4]  447 	ld	b, l
   435E 21 00 80      [10]  448 	ld	hl, #0x8000
   4361 E5            [11]  449 	push	hl
   4362 C5            [11]  450 	push	bc
   4363 33            [ 6]  451 	inc	sp
   4364 2E 00         [ 7]  452 	ld	l, #0x00
   4366 E5            [11]  453 	push	hl
   4367 CD 4D 5E      [17]  454 	call	_cpct_memset
                            455 ;src/game.c:120: while (1) {
   436A                     456 00107$:
                            457 ;src/game.c:123: if (!swap_memvideo) { 					//switch
   436A 3A 52 60      [13]  458 	ld	a,(#_swap_memvideo + 0)
   436D B7            [ 4]  459 	or	a, a
   436E 20 0D         [12]  460 	jr	NZ,00102$
                            461 ;src/game.c:124: mem_start = (u8*) CPCT_LVMEM_START;	//lower VMEM page
   4370 21 00 80      [10]  462 	ld	hl, #0x8000
   4373 22 4F 60      [16]  463 	ld	(_mem_start), hl
                            464 ;src/game.c:125: mem_page = cpct_page80;				//FIXME:: can probably delete??
   4376 21 51 60      [10]  465 	ld	hl,#_mem_page + 0
   4379 36 20         [10]  466 	ld	(hl), #0x20
   437B 18 0B         [12]  467 	jr	00103$
   437D                     468 00102$:
                            469 ;src/game.c:127: mem_start = (u8*) CPCT_VMEM_START;	//upper,regular VMEM page
   437D 21 00 C0      [10]  470 	ld	hl, #0xc000
   4380 22 4F 60      [16]  471 	ld	(_mem_start), hl
                            472 ;src/game.c:128: mem_page = cpct_pageC0;
   4383 21 51 60      [10]  473 	ld	hl,#_mem_page + 0
   4386 36 30         [10]  474 	ld	(hl), #0x30
   4388                     475 00103$:
                            476 ;src/game.c:132: keyboard(); 							//user movement
   4388 CD 10 41      [17]  477 	call	_keyboard
                            478 ;src/game.c:134: moveSprites();
   438B CD D1 41      [17]  479 	call	_moveSprites
                            480 ;src/game.c:135: deleteSprites();
   438E CD B3 5A      [17]  481 	call	_deleteSprites
                            482 ;src/game.c:136: renderSprites();
   4391 CD CE 58      [17]  483 	call	_renderSprites
                            484 ;src/game.c:139: cpct_waitVSYNC();						//Wait until CRTC has printed a full frame to "repaint"
   4394 CD 29 5E      [17]  485 	call	_cpct_waitVSYNC
                            486 ;src/game.c:140: cpct_setVideoMemoryPage(mem_page);		//Tell CRTC to "paint" the new page--FIXME: can this use "mem_start" instead?
   4397 FD 21 51 60   [14]  487 	ld	iy, #_mem_page
   439B FD 6E 00      [19]  488 	ld	l, 0 (iy)
   439E CD C4 5D      [17]  489 	call	_cpct_setVideoMemoryPage
                            490 ;src/game.c:141: swap_memvideo = ~swap_memvideo; 		//flip the switch
   43A1 FD 21 52 60   [14]  491 	ld	iy, #_swap_memvideo
   43A5 FD 7E 00      [19]  492 	ld	a, 0 (iy)
   43A8 2F            [ 4]  493 	cpl
   43A9 FD 77 00      [19]  494 	ld	0 (iy), a
                            495 ;src/game.c:143: anim_clock+=ANIM_SPEED;
   43AC FD 21 4E 60   [14]  496 	ld	iy, #_anim_clock
   43B0 FD 34 00      [23]  497 	inc	0 (iy)
   43B3 FD 34 00      [23]  498 	inc	0 (iy)
                            499 ;src/game.c:144: if (anim_clock > ANIM_CYCLE)
   43B6 3E 10         [ 7]  500 	ld	a, #0x10
   43B8 FD 96 00      [19]  501 	sub	a, 0 (iy)
   43BB 30 AD         [12]  502 	jr	NC,00107$
                            503 ;src/game.c:145: anim_clock=1;
   43BD FD 36 00 01   [19]  504 	ld	0 (iy), #0x01
   43C1 18 A7         [12]  505 	jr	00107$
                            506 	.area _CODE
                            507 	.area _INITIALIZER
                            508 	.area _CABS (ABS)
