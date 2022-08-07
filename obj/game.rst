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
   663A                      34 _sprites::
   663A                      35 	.ds 240
   672A                      36 _anim_clock::
   672A                      37 	.ds 1
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
   4110 21 3E 66      [10]   68 	ld	hl, #(_sprites + 0x0004)
   4113 36 00         [10]   69 	ld	(hl), #0x00
   4115 21 3D 66      [10]   70 	ld	hl, #(_sprites + 0x0003)
   4118 36 00         [10]   71 	ld	(hl), #0x00
                             72 ;src/game.c:20: cpct_scanKeyboard_f();
   411A CD DD 62      [17]   73 	call	_cpct_scanKeyboard_f
                             74 ;src/game.c:21: if (cpct_isKeyPressed(Key_CursorUp) || cpct_isKeyPressed(Key_Q) || cpct_isKeyPressed(Joy0_Up)){	
   411D 21 00 01      [10]   75 	ld	hl, #0x0100
   4120 CD D1 62      [17]   76 	call	_cpct_isKeyPressed
   4123 7D            [ 4]   77 	ld	a, l
   4124 B7            [ 4]   78 	or	a, a
   4125 20 14         [12]   79 	jr	NZ,00101$
   4127 21 08 08      [10]   80 	ld	hl, #0x0808
   412A CD D1 62      [17]   81 	call	_cpct_isKeyPressed
   412D 7D            [ 4]   82 	ld	a, l
   412E B7            [ 4]   83 	or	a, a
   412F 20 0A         [12]   84 	jr	NZ,00101$
   4131 21 09 01      [10]   85 	ld	hl, #0x0109
   4134 CD D1 62      [17]   86 	call	_cpct_isKeyPressed
   4137 7D            [ 4]   87 	ld	a, l
   4138 B7            [ 4]   88 	or	a, a
   4139 28 05         [12]   89 	jr	Z,00102$
   413B                      90 00101$:
                             91 ;src/game.c:22: sprites[0].moveV = -1;		
   413B 21 3D 66      [10]   92 	ld	hl, #(_sprites + 0x0003)
   413E 36 FF         [10]   93 	ld	(hl), #0xff
   4140                      94 00102$:
                             95 ;src/game.c:24: if (cpct_isKeyPressed(Key_CursorDown) || cpct_isKeyPressed(Key_A) || cpct_isKeyPressed(Joy0_Down)){
   4140 21 00 04      [10]   96 	ld	hl, #0x0400
   4143 CD D1 62      [17]   97 	call	_cpct_isKeyPressed
   4146 7D            [ 4]   98 	ld	a, l
   4147 B7            [ 4]   99 	or	a, a
   4148 20 14         [12]  100 	jr	NZ,00105$
   414A 21 08 20      [10]  101 	ld	hl, #0x2008
   414D CD D1 62      [17]  102 	call	_cpct_isKeyPressed
   4150 7D            [ 4]  103 	ld	a, l
   4151 B7            [ 4]  104 	or	a, a
   4152 20 0A         [12]  105 	jr	NZ,00105$
   4154 21 09 02      [10]  106 	ld	hl, #0x0209
   4157 CD D1 62      [17]  107 	call	_cpct_isKeyPressed
   415A 7D            [ 4]  108 	ld	a, l
   415B B7            [ 4]  109 	or	a, a
   415C 28 05         [12]  110 	jr	Z,00106$
   415E                     111 00105$:
                            112 ;src/game.c:25: sprites[0].moveV = 1;
   415E 21 3D 66      [10]  113 	ld	hl, #(_sprites + 0x0003)
   4161 36 01         [10]  114 	ld	(hl), #0x01
   4163                     115 00106$:
                            116 ;src/game.c:27: if (cpct_isKeyPressed(Key_CursorLeft) || cpct_isKeyPressed(Key_O) || cpct_isKeyPressed(Joy0_Left)){
   4163 21 01 01      [10]  117 	ld	hl, #0x0101
   4166 CD D1 62      [17]  118 	call	_cpct_isKeyPressed
                            119 ;src/game.c:29: sprites[0].turned = 1;
                            120 ;src/game.c:27: if (cpct_isKeyPressed(Key_CursorLeft) || cpct_isKeyPressed(Key_O) || cpct_isKeyPressed(Joy0_Left)){
   4169 7D            [ 4]  121 	ld	a, l
   416A B7            [ 4]  122 	or	a, a
   416B 20 14         [12]  123 	jr	NZ,00109$
   416D 21 04 04      [10]  124 	ld	hl, #0x0404
   4170 CD D1 62      [17]  125 	call	_cpct_isKeyPressed
   4173 7D            [ 4]  126 	ld	a, l
   4174 B7            [ 4]  127 	or	a, a
   4175 20 0A         [12]  128 	jr	NZ,00109$
   4177 21 09 04      [10]  129 	ld	hl, #0x0409
   417A CD D1 62      [17]  130 	call	_cpct_isKeyPressed
   417D 7D            [ 4]  131 	ld	a, l
   417E B7            [ 4]  132 	or	a, a
   417F 28 0A         [12]  133 	jr	Z,00110$
   4181                     134 00109$:
                            135 ;src/game.c:28: sprites[0].moveH = -1;
   4181 21 3E 66      [10]  136 	ld	hl, #(_sprites + 0x0004)
   4184 36 FF         [10]  137 	ld	(hl), #0xff
                            138 ;src/game.c:29: sprites[0].turned = 1;
   4186 21 51 66      [10]  139 	ld	hl, #(_sprites + 0x0017)
   4189 36 01         [10]  140 	ld	(hl), #0x01
   418B                     141 00110$:
                            142 ;src/game.c:31: if (cpct_isKeyPressed(Key_CursorRight) || cpct_isKeyPressed(Key_P) || cpct_isKeyPressed(Joy0_Right)){
   418B 21 00 02      [10]  143 	ld	hl, #0x0200
   418E CD D1 62      [17]  144 	call	_cpct_isKeyPressed
   4191 7D            [ 4]  145 	ld	a, l
   4192 B7            [ 4]  146 	or	a, a
   4193 20 14         [12]  147 	jr	NZ,00113$
   4195 21 03 08      [10]  148 	ld	hl, #0x0803
   4198 CD D1 62      [17]  149 	call	_cpct_isKeyPressed
   419B 7D            [ 4]  150 	ld	a, l
   419C B7            [ 4]  151 	or	a, a
   419D 20 0A         [12]  152 	jr	NZ,00113$
   419F 21 09 08      [10]  153 	ld	hl, #0x0809
   41A2 CD D1 62      [17]  154 	call	_cpct_isKeyPressed
   41A5 7D            [ 4]  155 	ld	a, l
   41A6 B7            [ 4]  156 	or	a, a
   41A7 28 0A         [12]  157 	jr	Z,00114$
   41A9                     158 00113$:
                            159 ;src/game.c:32: sprites[0].moveH = 1;
   41A9 21 3E 66      [10]  160 	ld	hl, #(_sprites + 0x0004)
   41AC 36 01         [10]  161 	ld	(hl), #0x01
                            162 ;src/game.c:33: sprites[0].turned = 0;
   41AE 21 51 66      [10]  163 	ld	hl, #(_sprites + 0x0017)
   41B1 36 00         [10]  164 	ld	(hl), #0x00
   41B3                     165 00114$:
                            166 ;src/game.c:37: if (sprites[0].moveH !=0 || sprites[0].moveV !=0)					//sprite moved
   41B3 21 3E 66      [10]  167 	ld	hl, #(_sprites + 0x0004) + 0
   41B6 4E            [ 7]  168 	ld	c, (hl)
                            169 ;src/game.c:38: sprites[0].properties = sprites[0].properties | MASK_ANIMATE; 	//mark for animation
   41B7 11 45 66      [10]  170 	ld	de, #_sprites + 11
   41BA 1A            [ 7]  171 	ld	a, (de)
   41BB 47            [ 4]  172 	ld	b, a
                            173 ;src/game.c:37: if (sprites[0].moveH !=0 || sprites[0].moveV !=0)					//sprite moved
   41BC 79            [ 4]  174 	ld	a, c
   41BD B7            [ 4]  175 	or	a, a
   41BE 20 06         [12]  176 	jr	NZ,00117$
   41C0 3A 3D 66      [13]  177 	ld	a, (#(_sprites + 0x0003) + 0)
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
   41E2                     212 00116$:
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
   41EE 01 3A 66      [10]  223 	ld	bc,#_sprites
   41F1 09            [11]  224 	add	hl,bc
   41F2 DD 75 FE      [19]  225 	ld	-2 (ix), l
   41F5 DD 74 FF      [19]  226 	ld	-1 (ix), h
   41F8 7E            [ 7]  227 	ld	a, (hl)
   41F9 DD 77 FB      [19]  228 	ld	-5 (ix), a
   41FC B7            [ 4]  229 	or	a, a
   41FD CA CF 42      [10]  230 	jp	Z, 00117$
                            231 ;src/game.c:56: collision = 0;
   4200 DD 36 F6 00   [19]  232 	ld	-10 (ix), #0x00
                            233 ;src/game.c:58: x = sprites[i].x;
   4204 DD 7E FE      [19]  234 	ld	a, -2 (ix)
   4207 C6 01         [ 7]  235 	add	a, #0x01
   4209 DD 77 F9      [19]  236 	ld	-7 (ix), a
   420C DD 7E FF      [19]  237 	ld	a, -1 (ix)
   420F CE 00         [ 7]  238 	adc	a, #0x00
   4211 DD 77 FA      [19]  239 	ld	-6 (ix), a
   4214 DD 6E F9      [19]  240 	ld	l,-7 (ix)
   4217 DD 66 FA      [19]  241 	ld	h,-6 (ix)
   421A 4E            [ 7]  242 	ld	c, (hl)
                            243 ;src/game.c:59: y = sprites[i].y;
   421B DD 7E FE      [19]  244 	ld	a, -2 (ix)
   421E C6 02         [ 7]  245 	add	a, #0x02
   4220 DD 77 FC      [19]  246 	ld	-4 (ix), a
   4223 DD 7E FF      [19]  247 	ld	a, -1 (ix)
   4226 CE 00         [ 7]  248 	adc	a, #0x00
   4228 DD 77 FD      [19]  249 	ld	-3 (ix), a
   422B DD 6E FC      [19]  250 	ld	l,-4 (ix)
   422E DD 66 FD      [19]  251 	ld	h,-3 (ix)
   4231 46            [ 7]  252 	ld	b, (hl)
                            253 ;src/game.c:61: x = x + (sprites[i].moveH);
   4232 DD 6E FE      [19]  254 	ld	l,-2 (ix)
   4235 DD 66 FF      [19]  255 	ld	h,-1 (ix)
   4238 11 04 00      [10]  256 	ld	de, #0x0004
   423B 19            [11]  257 	add	hl, de
   423C 6E            [ 7]  258 	ld	l, (hl)
   423D 09            [11]  259 	add	hl, bc
   423E 4D            [ 4]  260 	ld	c, l
                            261 ;src/game.c:62: y = y + (4*sprites[i].moveV);	//vertical movement: Y is *px, X is *byte. M0 so Y is 4 times slower
   423F DD 6E FE      [19]  262 	ld	l,-2 (ix)
   4242 DD 66 FF      [19]  263 	ld	h,-1 (ix)
   4245 23            [ 6]  264 	inc	hl
   4246 23            [ 6]  265 	inc	hl
   4247 23            [ 6]  266 	inc	hl
   4248 7E            [ 7]  267 	ld	a, (hl)
   4249 87            [ 4]  268 	add	a, a
   424A 87            [ 4]  269 	add	a, a
   424B 5F            [ 4]  270 	ld	e, a
   424C 68            [ 4]  271 	ld	l, b
   424D 19            [11]  272 	add	hl, de
   424E DD 75 F7      [19]  273 	ld	-9 (ix), l
                            274 ;src/game.c:65: if (x > (GAME_AREA_RIGHT - sprites[i].width))
   4251 DD 6E FE      [19]  275 	ld	l,-2 (ix)
   4254 DD 66 FF      [19]  276 	ld	h,-1 (ix)
   4257 11 0A 00      [10]  277 	ld	de, #0x000a
   425A 19            [11]  278 	add	hl, de
   425B 5E            [ 7]  279 	ld	e, (hl)
   425C 16 00         [ 7]  280 	ld	d, #0x00
   425E 3E 50         [ 7]  281 	ld	a, #0x50
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
   426D E2 72 42      [10]  293 	jp	PO, 00149$
   4270 EE 80         [ 7]  294 	xor	a, #0x80
   4272                     295 00149$:
   4272 F2 79 42      [10]  296 	jp	P, 00104$
                            297 ;src/game.c:66: collision = collision | RIGHT_COLLISION;
   4275 DD 36 F6 02   [19]  298 	ld	-10 (ix), #0x02
                            299 ;src/game.c:68: collision = collision | LEFT_COLLISION;
   4279                     300 00104$:
                            301 ;src/game.c:70: if (y > (GAME_AREA_BOTTOM - sprites[i].height))
   4279 DD 6E FE      [19]  302 	ld	l,-2 (ix)
   427C DD 66 FF      [19]  303 	ld	h,-1 (ix)
   427F 11 09 00      [10]  304 	ld	de, #0x0009
   4282 19            [11]  305 	add	hl, de
   4283 5E            [ 7]  306 	ld	e, (hl)
   4284 16 00         [ 7]  307 	ld	d, #0x00
   4286 3E C8         [ 7]  308 	ld	a, #0xc8
   4288 93            [ 4]  309 	sub	a, e
   4289 5F            [ 4]  310 	ld	e, a
   428A 3E 00         [ 7]  311 	ld	a, #0x00
   428C 9A            [ 4]  312 	sbc	a, d
   428D 57            [ 4]  313 	ld	d, a
   428E DD 6E F7      [19]  314 	ld	l, -9 (ix)
   4291 26 00         [ 7]  315 	ld	h, #0x00
   4293 7B            [ 4]  316 	ld	a, e
   4294 95            [ 4]  317 	sub	a, l
   4295 7A            [ 4]  318 	ld	a, d
   4296 9C            [ 4]  319 	sbc	a, h
   4297 E2 9C 42      [10]  320 	jp	PO, 00150$
   429A EE 80         [ 7]  321 	xor	a, #0x80
   429C                     322 00150$:
   429C F2 A3 42      [10]  323 	jp	P, 00106$
                            324 ;src/game.c:71: collision = collision | BOTTOM_COLLISION;
   429F DD CB F6 C6   [23]  325 	set	0, -10 (ix)
   42A3                     326 00106$:
                            327 ;src/game.c:72: if (y < GAME_AREA_TOP)
   42A3 DD 7E F7      [19]  328 	ld	a, -9 (ix)
   42A6 D6 10         [ 7]  329 	sub	a, #0x10
   42A8 30 08         [12]  330 	jr	NC,00108$
                            331 ;src/game.c:73: collision = collision | TOP_COLLISION;
   42AA DD 7E F6      [19]  332 	ld	a, -10 (ix)
   42AD F6 05         [ 7]  333 	or	a, #0x05
   42AF DD 77 F6      [19]  334 	ld	-10 (ix), a
   42B2                     335 00108$:
                            336 ;src/game.c:77: if ((collision & LEFT_RIGHT_COLLISION) == 0)		//if not hitting right, move up/down
   42B2 DD CB F6 4E   [20]  337 	bit	1, -10 (ix)
   42B6 20 07         [12]  338 	jr	NZ,00110$
                            339 ;src/game.c:78: sprites[i].x = x;								//keep x as it was
   42B8 DD 6E F9      [19]  340 	ld	l,-7 (ix)
   42BB DD 66 FA      [19]  341 	ld	h,-6 (ix)
   42BE 71            [ 7]  342 	ld	(hl), c
   42BF                     343 00110$:
                            344 ;src/game.c:80: if ((collision & TOP_BOTTOM_COLLISION) == 0)		//if not hitting top, move sideways //
   42BF DD CB F6 46   [20]  345 	bit	0, -10 (ix)
   42C3 20 0A         [12]  346 	jr	NZ,00117$
                            347 ;src/game.c:81: sprites[i].y = y;								//keep y as it was
   42C5 DD 6E FC      [19]  348 	ld	l,-4 (ix)
   42C8 DD 66 FD      [19]  349 	ld	h,-3 (ix)
   42CB DD 7E F7      [19]  350 	ld	a, -9 (ix)
   42CE 77            [ 7]  351 	ld	(hl), a
   42CF                     352 00117$:
                            353 ;src/game.c:54: for (i=0; i < MAX_SPRITES; i++) {
   42CF DD 34 F8      [23]  354 	inc	-8 (ix)
   42D2 DD 7E F8      [19]  355 	ld	a, -8 (ix)
   42D5 D6 0A         [ 7]  356 	sub	a, #0x0a
   42D7 DA E2 41      [10]  357 	jp	C, 00116$
   42DA DD F9         [10]  358 	ld	sp, ix
   42DC DD E1         [14]  359 	pop	ix
   42DE C9            [10]  360 	ret
                            361 ;src/game.c:89: void init_game() {
                            362 ;	---------------------------------
                            363 ; Function init_game
                            364 ; ---------------------------------
   42DF                     365 _init_game::
                            366 ;src/game.c:92: sprites[0].id = 1;												//mark the sprite "alive" (non-zero)
   42DF 21 3A 66      [10]  367 	ld	hl, #_sprites
   42E2 36 01         [10]  368 	ld	(hl), #0x01
                            369 ;src/game.c:93: sprites[0].x = GAME_AREA_LEFT;									//init position to 0,0
   42E4 21 3B 66      [10]  370 	ld	hl, #(_sprites + 0x0001)
   42E7 36 00         [10]  371 	ld	(hl), #0x00
                            372 ;src/game.c:94: sprites[0].y = GAME_AREA_TOP;
   42E9 21 3C 66      [10]  373 	ld	hl, #(_sprites + 0x0002)
   42EC 36 10         [10]  374 	ld	(hl), #0x10
                            375 ;src/game.c:95: sprites[0].moveV = sprites[0].moveH = 0;						//init movement to none
   42EE 21 3E 66      [10]  376 	ld	hl, #(_sprites + 0x0004)
   42F1 36 00         [10]  377 	ld	(hl), #0x00
   42F3 21 3D 66      [10]  378 	ld	hl, #(_sprites + 0x0003)
   42F6 36 00         [10]  379 	ld	(hl), #0x00
                            380 ;src/game.c:97: sprites[0].x_prev_A = sprites[0].y_prev_A = sprites[0].x_prev_B = sprites[0].y_prev_B = 0;
   42F8 21 42 66      [10]  381 	ld	hl, #(_sprites + 0x0008)
   42FB 36 00         [10]  382 	ld	(hl), #0x00
   42FD 21 41 66      [10]  383 	ld	hl, #(_sprites + 0x0007)
   4300 36 00         [10]  384 	ld	(hl), #0x00
   4302 21 40 66      [10]  385 	ld	hl, #(_sprites + 0x0006)
   4305 36 00         [10]  386 	ld	(hl), #0x00
   4307 21 3F 66      [10]  387 	ld	hl, #(_sprites + 0x0005)
   430A 36 00         [10]  388 	ld	(hl), #0x00
                            389 ;src/game.c:98: sprites[0].height = G_PITU_H;
   430C 21 43 66      [10]  390 	ld	hl, #(_sprites + 0x0009)
   430F 36 20         [10]  391 	ld	(hl), #0x20
                            392 ;src/game.c:99: sprites[0].width = G_PITU_W;									//!?! /2: - M0, length in bytes = /2 in px
   4311 21 44 66      [10]  393 	ld	hl, #(_sprites + 0x000a)
   4314 36 07         [10]  394 	ld	(hl), #0x07
                            395 ;src/game.c:100: sprites[0].properties = 0;										//bitmasked properties - init to 0
   4316 01 45 66      [10]  396 	ld	bc, #_sprites + 11
   4319 AF            [ 4]  397 	xor	a, a
   431A 02            [ 7]  398 	ld	(bc), a
                            399 ;src/game.c:101: sprites[0].properties = sprites[0].properties | MASK_RENDER;	//init to "render" on screen
   431B 0A            [ 7]  400 	ld	a, (bc)
   431C CB C7         [ 8]  401 	set	0, a
   431E 02            [ 7]  402 	ld	(bc), a
                            403 ;src/game.c:102: sprites[0].frames = 2;											//main sprite has two "moves" to animate
   431F 21 48 66      [10]  404 	ld	hl, #(_sprites + 0x000e)
   4322 36 02         [10]  405 	ld	(hl), #0x02
                            406 ;src/game.c:103: sprites[0].sprite_f1 = (u8*)G_pitu; 							//first render for sprite. &G_pitu[0]
   4324 21 D2 43      [10]  407 	ld	hl, #_G_pitu
   4327 22 49 66      [16]  408 	ld	((_sprites + 0x000f)), hl
                            409 ;src/game.c:104: sprites[0].sprite_f2 = (u8*)G_pitu_walk;
   432A 21 52 47      [10]  410 	ld	hl, #_G_pitu_walk
   432D 22 4B 66      [16]  411 	ld	((_sprites + 0x0011)), hl
                            412 ;src/game.c:105: sprites[0].sprite_f3 = (u8*)G_pitu_jump;
   4330 21 D2 4A      [10]  413 	ld	hl, #_G_pitu_jump
   4333 22 4D 66      [16]  414 	ld	((_sprites + 0x0013)), hl
                            415 ;src/game.c:106: sprites[0].sprite_f3 = (u8*)G_blast;
   4336 21 52 55      [10]  416 	ld	hl, #_G_blast
   4339 22 4D 66      [16]  417 	ld	((_sprites + 0x0013)), hl
                            418 ;src/game.c:107: sprites[0].turned = 0;											//start looking right/front
   433C 21 51 66      [10]  419 	ld	hl, #(_sprites + 0x0017)
   433F 36 00         [10]  420 	ld	(hl), #0x00
                            421 ;src/game.c:110: for (i = 1; i < MAX_SPRITES; i++)
   4341 0E 01         [ 7]  422 	ld	c, #0x01
   4343                     423 00102$:
                            424 ;src/game.c:111: sprites[i].id=0;
   4343 06 00         [ 7]  425 	ld	b,#0x00
   4345 69            [ 4]  426 	ld	l, c
   4346 60            [ 4]  427 	ld	h, b
   4347 29            [11]  428 	add	hl, hl
   4348 09            [11]  429 	add	hl, bc
   4349 29            [11]  430 	add	hl, hl
   434A 29            [11]  431 	add	hl, hl
   434B 29            [11]  432 	add	hl, hl
   434C 11 3A 66      [10]  433 	ld	de, #_sprites
   434F 19            [11]  434 	add	hl, de
   4350 36 00         [10]  435 	ld	(hl), #0x00
                            436 ;src/game.c:110: for (i = 1; i < MAX_SPRITES; i++)
   4352 0C            [ 4]  437 	inc	c
   4353 79            [ 4]  438 	ld	a, c
   4354 D6 0A         [ 7]  439 	sub	a, #0x0a
   4356 38 EB         [12]  440 	jr	C,00102$
                            441 ;src/game.c:113: anim_clock=1;
   4358 21 2A 67      [10]  442 	ld	hl,#_anim_clock + 0
   435B 36 01         [10]  443 	ld	(hl), #0x01
   435D C9            [10]  444 	ret
                            445 ;src/game.c:119: void game(){
                            446 ;	---------------------------------
                            447 ; Function game
                            448 ; ---------------------------------
   435E                     449 _game::
                            450 ;src/game.c:121: cpct_setBorder(HW_WHITE);
   435E 21 10 00      [10]  451 	ld	hl, #0x0010
   4361 E5            [11]  452 	push	hl
   4362 CD 47 63      [17]  453 	call	_cpct_setPALColour
                            454 ;src/game.c:123: cpct_memset ((u8*)CPCT_LVMEM_START, cpct_px2byteM0(5, 5), 0x8000); //5 is ordinal for WHITE from palette in M0 with 16c
   4365 21 05 05      [10]  455 	ld	hl, #0x0505
   4368 E5            [11]  456 	push	hl
   4369 CD 0D 65      [17]  457 	call	_cpct_px2byteM0
   436C 45            [ 4]  458 	ld	b, l
   436D 21 00 80      [10]  459 	ld	hl, #0x8000
   4370 E5            [11]  460 	push	hl
   4371 C5            [11]  461 	push	bc
   4372 33            [ 6]  462 	inc	sp
   4373 2E 00         [ 7]  463 	ld	l, #0x00
   4375 E5            [11]  464 	push	hl
   4376 CD 29 65      [17]  465 	call	_cpct_memset
                            466 ;src/game.c:125: while (1) {
   4379                     467 00107$:
                            468 ;src/game.c:128: if (!swap_memvideo) { 					//switch
   4379 3A 2E 67      [13]  469 	ld	a,(#_swap_memvideo + 0)
   437C B7            [ 4]  470 	or	a, a
   437D 20 0D         [12]  471 	jr	NZ,00102$
                            472 ;src/game.c:129: mem_start = (u8*) CPCT_LVMEM_START;	//lower VMEM page
   437F 21 00 80      [10]  473 	ld	hl, #0x8000
   4382 22 2B 67      [16]  474 	ld	(_mem_start), hl
                            475 ;src/game.c:130: mem_page = cpct_page80;				//FIXME:: can probably delete??
   4385 21 2D 67      [10]  476 	ld	hl,#_mem_page + 0
   4388 36 20         [10]  477 	ld	(hl), #0x20
   438A 18 0B         [12]  478 	jr	00103$
   438C                     479 00102$:
                            480 ;src/game.c:132: mem_start = (u8*) CPCT_VMEM_START;	//upper,regular VMEM page
   438C 21 00 C0      [10]  481 	ld	hl, #0xc000
   438F 22 2B 67      [16]  482 	ld	(_mem_start), hl
                            483 ;src/game.c:133: mem_page = cpct_pageC0;
   4392 21 2D 67      [10]  484 	ld	hl,#_mem_page + 0
   4395 36 30         [10]  485 	ld	(hl), #0x30
   4397                     486 00103$:
                            487 ;src/game.c:137: keyboard(); 							//user movement
   4397 CD 10 41      [17]  488 	call	_keyboard
                            489 ;src/game.c:139: moveSprites();
   439A CD D1 41      [17]  490 	call	_moveSprites
                            491 ;src/game.c:140: deleteSprites();
   439D CD CD 61      [17]  492 	call	_deleteSprites
                            493 ;src/game.c:141: renderSprites();
   43A0 CD 51 60      [17]  494 	call	_renderSprites
                            495 ;src/game.c:144: cpct_waitVSYNC();						//Wait until CRTC has printed a full frame to "repaint"
   43A3 CD 05 65      [17]  496 	call	_cpct_waitVSYNC
                            497 ;src/game.c:145: cpct_setVideoMemoryPage(mem_page);		//Tell CRTC to "paint" the new page--FIXME: can this use "mem_start" instead?
   43A6 FD 21 2D 67   [14]  498 	ld	iy, #_mem_page
   43AA FD 6E 00      [19]  499 	ld	l, 0 (iy)
   43AD CD A0 64      [17]  500 	call	_cpct_setVideoMemoryPage
                            501 ;src/game.c:146: swap_memvideo = ~swap_memvideo; 		//flip the switch
   43B0 FD 21 2E 67   [14]  502 	ld	iy, #_swap_memvideo
   43B4 FD 7E 00      [19]  503 	ld	a, 0 (iy)
   43B7 2F            [ 4]  504 	cpl
   43B8 FD 77 00      [19]  505 	ld	0 (iy), a
                            506 ;src/game.c:148: anim_clock+=ANIM_SPEED;
   43BB FD 21 2A 67   [14]  507 	ld	iy, #_anim_clock
   43BF FD 34 00      [23]  508 	inc	0 (iy)
   43C2 FD 34 00      [23]  509 	inc	0 (iy)
                            510 ;src/game.c:149: if (anim_clock > ANIM_CYCLE)
   43C5 3E 10         [ 7]  511 	ld	a, #0x10
   43C7 FD 96 00      [19]  512 	sub	a, 0 (iy)
   43CA 30 AD         [12]  513 	jr	NC,00107$
                            514 ;src/game.c:150: anim_clock=1;
   43CC FD 36 00 01   [19]  515 	ld	0 (iy), #0x01
   43D0 18 A7         [12]  516 	jr	00107$
                            517 	.area _CODE
                            518 	.area _INITIALIZER
                            519 	.area _CABS (ABS)
