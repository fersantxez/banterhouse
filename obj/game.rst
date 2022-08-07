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
                             25 	.globl _cycle
                             26 	.globl _sprites
                             27 	.globl _coord_x
                             28 ;--------------------------------------------------------
                             29 ; special function registers
                             30 ;--------------------------------------------------------
                             31 ;--------------------------------------------------------
                             32 ; ram data
                             33 ;--------------------------------------------------------
                             34 	.area _DATA
   5DD5                      35 _coord_x::
   5DD5                      36 	.ds 1
   5DD6                      37 _sprites::
   5DD6                      38 	.ds 220
   5EB2                      39 _cycle::
   5EB2                      40 	.ds 1
                             41 ;--------------------------------------------------------
                             42 ; ram data
                             43 ;--------------------------------------------------------
                             44 	.area _INITIALIZED
                             45 ;--------------------------------------------------------
                             46 ; absolute external ram data
                             47 ;--------------------------------------------------------
                             48 	.area _DABS (ABS)
                             49 ;--------------------------------------------------------
                             50 ; global & static initialisations
                             51 ;--------------------------------------------------------
                             52 	.area _HOME
                             53 	.area _GSINIT
                             54 	.area _GSFINAL
                             55 	.area _GSINIT
                             56 ;--------------------------------------------------------
                             57 ; Home
                             58 ;--------------------------------------------------------
                             59 	.area _HOME
                             60 	.area _HOME
                             61 ;--------------------------------------------------------
                             62 ; code
                             63 ;--------------------------------------------------------
                             64 	.area _CODE
                             65 ;src/game.c:17: void keyboard(){
                             66 ;	---------------------------------
                             67 ; Function keyboard
                             68 ; ---------------------------------
   4110                      69 _keyboard::
                             70 ;src/game.c:20: sprites[0].moveV = sprites[0].moveH = 0; 						//start with no movement
   4110 21 DA 5D      [10]   71 	ld	hl, #(_sprites + 0x0004)
   4113 36 00         [10]   72 	ld	(hl), #0x00
   4115 21 D9 5D      [10]   73 	ld	hl, #(_sprites + 0x0003)
   4118 36 00         [10]   74 	ld	(hl), #0x00
                             75 ;src/game.c:22: cpct_scanKeyboard_f();											//read keyboard/joystick
   411A CD 78 5A      [17]   76 	call	_cpct_scanKeyboard_f
                             77 ;src/game.c:23: if (cpct_isKeyPressed(Key_CursorUp) || cpct_isKeyPressed(Key_Q) || cpct_isKeyPressed(Joy0_Up)){	
   411D 21 00 01      [10]   78 	ld	hl, #0x0100
   4120 CD 6C 5A      [17]   79 	call	_cpct_isKeyPressed
   4123 7D            [ 4]   80 	ld	a, l
   4124 B7            [ 4]   81 	or	a, a
   4125 20 14         [12]   82 	jr	NZ,00101$
   4127 21 08 08      [10]   83 	ld	hl, #0x0808
   412A CD 6C 5A      [17]   84 	call	_cpct_isKeyPressed
   412D 7D            [ 4]   85 	ld	a, l
   412E B7            [ 4]   86 	or	a, a
   412F 20 0A         [12]   87 	jr	NZ,00101$
   4131 21 09 01      [10]   88 	ld	hl, #0x0109
   4134 CD 6C 5A      [17]   89 	call	_cpct_isKeyPressed
   4137 7D            [ 4]   90 	ld	a, l
   4138 B7            [ 4]   91 	or	a, a
   4139 28 05         [12]   92 	jr	Z,00102$
   413B                      93 00101$:
                             94 ;src/game.c:24: sprites[0].moveV = -1;		
   413B 21 D9 5D      [10]   95 	ld	hl, #(_sprites + 0x0003)
   413E 36 FF         [10]   96 	ld	(hl), #0xff
   4140                      97 00102$:
                             98 ;src/game.c:26: if (cpct_isKeyPressed(Key_CursorDown) || cpct_isKeyPressed(Key_A) || cpct_isKeyPressed(Joy0_Down)){
   4140 21 00 04      [10]   99 	ld	hl, #0x0400
   4143 CD 6C 5A      [17]  100 	call	_cpct_isKeyPressed
   4146 7D            [ 4]  101 	ld	a, l
   4147 B7            [ 4]  102 	or	a, a
   4148 20 14         [12]  103 	jr	NZ,00105$
   414A 21 08 20      [10]  104 	ld	hl, #0x2008
   414D CD 6C 5A      [17]  105 	call	_cpct_isKeyPressed
   4150 7D            [ 4]  106 	ld	a, l
   4151 B7            [ 4]  107 	or	a, a
   4152 20 0A         [12]  108 	jr	NZ,00105$
   4154 21 09 02      [10]  109 	ld	hl, #0x0209
   4157 CD 6C 5A      [17]  110 	call	_cpct_isKeyPressed
   415A 7D            [ 4]  111 	ld	a, l
   415B B7            [ 4]  112 	or	a, a
   415C 28 05         [12]  113 	jr	Z,00106$
   415E                     114 00105$:
                            115 ;src/game.c:27: sprites[0].moveV = 1;
   415E 21 D9 5D      [10]  116 	ld	hl, #(_sprites + 0x0003)
   4161 36 01         [10]  117 	ld	(hl), #0x01
   4163                     118 00106$:
                            119 ;src/game.c:29: if (cpct_isKeyPressed(Key_CursorLeft) || cpct_isKeyPressed(Key_O) || cpct_isKeyPressed(Joy0_Left)){
   4163 21 01 01      [10]  120 	ld	hl, #0x0101
   4166 CD 6C 5A      [17]  121 	call	_cpct_isKeyPressed
   4169 7D            [ 4]  122 	ld	a, l
   416A B7            [ 4]  123 	or	a, a
   416B 20 14         [12]  124 	jr	NZ,00109$
   416D 21 04 04      [10]  125 	ld	hl, #0x0404
   4170 CD 6C 5A      [17]  126 	call	_cpct_isKeyPressed
   4173 7D            [ 4]  127 	ld	a, l
   4174 B7            [ 4]  128 	or	a, a
   4175 20 0A         [12]  129 	jr	NZ,00109$
   4177 21 09 04      [10]  130 	ld	hl, #0x0409
   417A CD 6C 5A      [17]  131 	call	_cpct_isKeyPressed
   417D 7D            [ 4]  132 	ld	a, l
   417E B7            [ 4]  133 	or	a, a
   417F 28 05         [12]  134 	jr	Z,00110$
   4181                     135 00109$:
                            136 ;src/game.c:30: sprites[0].moveH = -1;
   4181 21 DA 5D      [10]  137 	ld	hl, #(_sprites + 0x0004)
   4184 36 FF         [10]  138 	ld	(hl), #0xff
   4186                     139 00110$:
                            140 ;src/game.c:33: if (cpct_isKeyPressed(Key_CursorRight) || cpct_isKeyPressed(Key_P) || cpct_isKeyPressed(Joy0_Right)){
   4186 21 00 02      [10]  141 	ld	hl, #0x0200
   4189 CD 6C 5A      [17]  142 	call	_cpct_isKeyPressed
   418C 7D            [ 4]  143 	ld	a, l
   418D B7            [ 4]  144 	or	a, a
   418E 20 13         [12]  145 	jr	NZ,00113$
   4190 21 03 08      [10]  146 	ld	hl, #0x0803
   4193 CD 6C 5A      [17]  147 	call	_cpct_isKeyPressed
   4196 7D            [ 4]  148 	ld	a, l
   4197 B7            [ 4]  149 	or	a, a
   4198 20 09         [12]  150 	jr	NZ,00113$
   419A 21 09 08      [10]  151 	ld	hl, #0x0809
   419D CD 6C 5A      [17]  152 	call	_cpct_isKeyPressed
   41A0 7D            [ 4]  153 	ld	a, l
   41A1 B7            [ 4]  154 	or	a, a
   41A2 C8            [11]  155 	ret	Z
   41A3                     156 00113$:
                            157 ;src/game.c:34: sprites[0].moveH = 1;
   41A3 21 DA 5D      [10]  158 	ld	hl, #(_sprites + 0x0004)
   41A6 36 01         [10]  159 	ld	(hl), #0x01
   41A8 C9            [10]  160 	ret
                            161 ;src/game.c:41: void AI(){
                            162 ;	---------------------------------
                            163 ; Function AI
                            164 ; ---------------------------------
   41A9                     165 _AI::
                            166 ;src/game.c:42: }
   41A9 C9            [10]  167 	ret
                            168 ;src/game.c:46: void moveSprites() {
                            169 ;	---------------------------------
                            170 ; Function moveSprites
                            171 ; ---------------------------------
   41AA                     172 _moveSprites::
   41AA DD E5         [15]  173 	push	ix
   41AC DD 21 00 00   [14]  174 	ld	ix,#0
   41B0 DD 39         [15]  175 	add	ix,sp
   41B2 21 F3 FF      [10]  176 	ld	hl, #-13
   41B5 39            [11]  177 	add	hl, sp
   41B6 F9            [ 6]  178 	ld	sp, hl
                            179 ;src/game.c:50: for (i=0; i < MAX_SPRITES; i++) {
   41B7 DD 36 F5 00   [19]  180 	ld	-11 (ix), #0x00
   41BB                     181 00108$:
                            182 ;src/game.c:51: if (sprites[i].id !=0) {			//check only live sprites to optimize CPU (non-zero)
   41BB DD 4E F5      [19]  183 	ld	c,-11 (ix)
   41BE 06 00         [ 7]  184 	ld	b,#0x00
   41C0 69            [ 4]  185 	ld	l, c
   41C1 60            [ 4]  186 	ld	h, b
   41C2 29            [11]  187 	add	hl, hl
   41C3 29            [11]  188 	add	hl, hl
   41C4 09            [11]  189 	add	hl, bc
   41C5 29            [11]  190 	add	hl, hl
   41C6 09            [11]  191 	add	hl, bc
   41C7 29            [11]  192 	add	hl, hl
   41C8 01 D6 5D      [10]  193 	ld	bc,#_sprites
   41CB 09            [11]  194 	add	hl,bc
   41CC DD 75 FA      [19]  195 	ld	-6 (ix), l
   41CF DD 74 FB      [19]  196 	ld	-5 (ix), h
   41D2 7E            [ 7]  197 	ld	a, (hl)
   41D3 DD 77 F8      [19]  198 	ld	-8 (ix), a
   41D6 B7            [ 4]  199 	or	a, a
   41D7 CA 75 42      [10]  200 	jp	Z, 00109$
                            201 ;src/game.c:54: x = sprites[i].x;
   41DA DD 7E FA      [19]  202 	ld	a, -6 (ix)
   41DD C6 01         [ 7]  203 	add	a, #0x01
   41DF DD 77 FE      [19]  204 	ld	-2 (ix), a
   41E2 DD 7E FB      [19]  205 	ld	a, -5 (ix)
   41E5 CE 00         [ 7]  206 	adc	a, #0x00
   41E7 DD 77 FF      [19]  207 	ld	-1 (ix), a
   41EA DD 6E FE      [19]  208 	ld	l,-2 (ix)
   41ED DD 66 FF      [19]  209 	ld	h,-1 (ix)
   41F0 7E            [ 7]  210 	ld	a, (hl)
   41F1 DD 77 F8      [19]  211 	ld	-8 (ix), a
                            212 ;src/game.c:55: y = sprites[i].y;
   41F4 DD 7E FA      [19]  213 	ld	a, -6 (ix)
   41F7 C6 02         [ 7]  214 	add	a, #0x02
   41F9 DD 77 F6      [19]  215 	ld	-10 (ix), a
   41FC DD 7E FB      [19]  216 	ld	a, -5 (ix)
   41FF CE 00         [ 7]  217 	adc	a, #0x00
   4201 DD 77 F7      [19]  218 	ld	-9 (ix), a
   4204 DD 6E F6      [19]  219 	ld	l,-10 (ix)
   4207 DD 66 F7      [19]  220 	ld	h,-9 (ix)
   420A 7E            [ 7]  221 	ld	a, (hl)
   420B DD 77 F9      [19]  222 	ld	-7 (ix), a
                            223 ;src/game.c:57: y = y + (4*sprites[i].moveV);	//vertical movement: Y is *px, X is *byte. M0 so Y is 4 times slower
   420E DD 7E FA      [19]  224 	ld	a, -6 (ix)
   4211 DD 77 FC      [19]  225 	ld	-4 (ix), a
   4214 DD 7E FB      [19]  226 	ld	a, -5 (ix)
   4217 DD 77 FD      [19]  227 	ld	-3 (ix), a
   421A DD 6E FC      [19]  228 	ld	l,-4 (ix)
   421D DD 66 FD      [19]  229 	ld	h,-3 (ix)
   4220 23            [ 6]  230 	inc	hl
   4221 23            [ 6]  231 	inc	hl
   4222 23            [ 6]  232 	inc	hl
   4223 7E            [ 7]  233 	ld	a, (hl)
   4224 DD 77 FC      [19]  234 	ld	-4 (ix), a
   4227 87            [ 4]  235 	add	a, a
   4228 87            [ 4]  236 	add	a, a
   4229 DD 77 FC      [19]  237 	ld	-4 (ix), a
   422C DD 7E F9      [19]  238 	ld	a, -7 (ix)
   422F DD 86 FC      [19]  239 	add	a, -4 (ix)
   4232 DD 77 FC      [19]  240 	ld	-4 (ix), a
   4235 DD 77 F3      [19]  241 	ld	-13 (ix), a
                            242 ;src/game.c:58: x = x + (sprites[i].moveH);
   4238 DD 7E FA      [19]  243 	ld	a, -6 (ix)
   423B DD 77 FC      [19]  244 	ld	-4 (ix), a
   423E DD 7E FB      [19]  245 	ld	a, -5 (ix)
   4241 DD 77 FD      [19]  246 	ld	-3 (ix), a
   4244 DD 6E FC      [19]  247 	ld	l,-4 (ix)
   4247 DD 66 FD      [19]  248 	ld	h,-3 (ix)
   424A 11 04 00      [10]  249 	ld	de, #0x0004
   424D 19            [11]  250 	add	hl, de
   424E 7E            [ 7]  251 	ld	a, (hl)
   424F DD 77 FC      [19]  252 	ld	-4 (ix), a
   4252 DD 7E F8      [19]  253 	ld	a, -8 (ix)
   4255 DD 77 F9      [19]  254 	ld	-7 (ix), a
   4258 DD 86 FC      [19]  255 	add	a, -4 (ix)
   425B DD 77 FC      [19]  256 	ld	-4 (ix), a
   425E DD 77 F4      [19]  257 	ld	-12 (ix), a
                            258 ;src/game.c:68: sprites[i].y = y;
   4261 DD 6E F6      [19]  259 	ld	l,-10 (ix)
   4264 DD 66 F7      [19]  260 	ld	h,-9 (ix)
   4267 DD 7E F3      [19]  261 	ld	a, -13 (ix)
   426A 77            [ 7]  262 	ld	(hl), a
                            263 ;src/game.c:70: sprites[i].x = x;
   426B DD 6E FE      [19]  264 	ld	l,-2 (ix)
   426E DD 66 FF      [19]  265 	ld	h,-1 (ix)
   4271 DD 7E F4      [19]  266 	ld	a, -12 (ix)
   4274 77            [ 7]  267 	ld	(hl), a
   4275                     268 00109$:
                            269 ;src/game.c:50: for (i=0; i < MAX_SPRITES; i++) {
   4275 DD 34 F5      [23]  270 	inc	-11 (ix)
   4278 DD 7E F5      [19]  271 	ld	a, -11 (ix)
   427B D6 0A         [ 7]  272 	sub	a, #0x0a
   427D DA BB 41      [10]  273 	jp	C, 00108$
   4280 DD F9         [10]  274 	ld	sp, ix
   4282 DD E1         [14]  275 	pop	ix
   4284 C9            [10]  276 	ret
                            277 ;src/game.c:78: void init_game() {
                            278 ;	---------------------------------
                            279 ; Function init_game
                            280 ; ---------------------------------
   4285                     281 _init_game::
                            282 ;src/game.c:81: sprites[0].id = 1;												//mark the sprite "alive" (non-zero)
   4285 21 D6 5D      [10]  283 	ld	hl, #_sprites
   4288 36 01         [10]  284 	ld	(hl), #0x01
                            285 ;src/game.c:82: sprites[0].x = sprites[0].y = 0;								//init position to 0,0
   428A 21 D8 5D      [10]  286 	ld	hl, #(_sprites + 0x0002)
   428D 36 00         [10]  287 	ld	(hl), #0x00
   428F 21 D7 5D      [10]  288 	ld	hl, #(_sprites + 0x0001)
   4292 36 00         [10]  289 	ld	(hl), #0x00
                            290 ;src/game.c:83: sprites[0].moveV = sprites[0].moveH = 0;						//init movement to none
   4294 21 DA 5D      [10]  291 	ld	hl, #(_sprites + 0x0004)
   4297 36 00         [10]  292 	ld	(hl), #0x00
   4299 21 D9 5D      [10]  293 	ld	hl, #(_sprites + 0x0003)
   429C 36 00         [10]  294 	ld	(hl), #0x00
                            295 ;src/game.c:85: sprites[0].x_prev_A = sprites[0].y_prev_A = sprites[0].x_prev_B = sprites[0].y_prev_B = 0;
   429E 21 DE 5D      [10]  296 	ld	hl, #(_sprites + 0x0008)
   42A1 36 00         [10]  297 	ld	(hl), #0x00
   42A3 21 DD 5D      [10]  298 	ld	hl, #(_sprites + 0x0007)
   42A6 36 00         [10]  299 	ld	(hl), #0x00
   42A8 21 DC 5D      [10]  300 	ld	hl, #(_sprites + 0x0006)
   42AB 36 00         [10]  301 	ld	(hl), #0x00
   42AD 21 DB 5D      [10]  302 	ld	hl, #(_sprites + 0x0005)
   42B0 36 00         [10]  303 	ld	(hl), #0x00
                            304 ;src/game.c:86: sprites[0].height = G_PITU_H;
   42B2 21 DF 5D      [10]  305 	ld	hl, #(_sprites + 0x0009)
   42B5 36 20         [10]  306 	ld	(hl), #0x20
                            307 ;src/game.c:87: sprites[0].width = G_PITU_W;									//!?! /2: - M0, length in bytes = /2 in px
   42B7 21 E0 5D      [10]  308 	ld	hl, #(_sprites + 0x000a)
   42BA 36 08         [10]  309 	ld	(hl), #0x08
                            310 ;src/game.c:88: sprites[0].properties = 0;										//bitmasked properties - init to 0
   42BC 01 E1 5D      [10]  311 	ld	bc, #_sprites + 11
   42BF AF            [ 4]  312 	xor	a, a
   42C0 02            [ 7]  313 	ld	(bc), a
                            314 ;src/game.c:89: sprites[0].properties = sprites[0].properties | MASK_RENDER;	//init to "render"
   42C1 0A            [ 7]  315 	ld	a, (bc)
   42C2 CB C7         [ 8]  316 	set	0, a
   42C4 02            [ 7]  317 	ld	(bc), a
                            318 ;src/game.c:90: sprites[0].sprite_f1 = (u8*)&G_pitu[0]; //&G_pitu[0]			//first position render
   42C5 21 71 43      [10]  319 	ld	hl, #_G_pitu
   42C8 22 E4 5D      [16]  320 	ld	((_sprites + 0x000e)), hl
                            321 ;src/game.c:91: sprites[0].sprite_f2 = (u8*)G_pitu_walk;
   42CB 21 71 45      [10]  322 	ld	hl, #_G_pitu_walk
   42CE 22 E6 5D      [16]  323 	ld	((_sprites + 0x0010)), hl
                            324 ;src/game.c:92: sprites[0].sprite_f3 = (u8*)G_pitu_jump;
   42D1 21 71 47      [10]  325 	ld	hl, #_G_pitu_jump
   42D4 22 E8 5D      [16]  326 	ld	((_sprites + 0x0012)), hl
                            327 ;src/game.c:93: sprites[0].sprite_f3 = (u8*)G_blast;
   42D7 21 71 4D      [10]  328 	ld	hl, #_G_blast
   42DA 22 E8 5D      [16]  329 	ld	((_sprites + 0x0012)), hl
                            330 ;src/game.c:97: for (i = 1; i < MAX_SPRITES; i++)
   42DD 0E 01         [ 7]  331 	ld	c, #0x01
   42DF                     332 00102$:
                            333 ;src/game.c:98: sprites[i].id=0;
   42DF 06 00         [ 7]  334 	ld	b,#0x00
   42E1 69            [ 4]  335 	ld	l, c
   42E2 60            [ 4]  336 	ld	h, b
   42E3 29            [11]  337 	add	hl, hl
   42E4 29            [11]  338 	add	hl, hl
   42E5 09            [11]  339 	add	hl, bc
   42E6 29            [11]  340 	add	hl, hl
   42E7 09            [11]  341 	add	hl, bc
   42E8 29            [11]  342 	add	hl, hl
   42E9 11 D6 5D      [10]  343 	ld	de, #_sprites
   42EC 19            [11]  344 	add	hl, de
   42ED 36 00         [10]  345 	ld	(hl), #0x00
                            346 ;src/game.c:97: for (i = 1; i < MAX_SPRITES; i++)
   42EF 0C            [ 4]  347 	inc	c
   42F0 79            [ 4]  348 	ld	a, c
   42F1 D6 0A         [ 7]  349 	sub	a, #0x0a
   42F3 38 EA         [12]  350 	jr	C,00102$
                            351 ;src/game.c:100: cycle=0;
   42F5 21 B2 5E      [10]  352 	ld	hl,#_cycle + 0
   42F8 36 00         [10]  353 	ld	(hl), #0x00
   42FA C9            [10]  354 	ret
                            355 ;src/game.c:107: void game(){
                            356 ;	---------------------------------
                            357 ; Function game
                            358 ; ---------------------------------
   42FB                     359 _game::
                            360 ;src/game.c:109: cpct_setBorder(HW_WHITE);
   42FB 21 10 00      [10]  361 	ld	hl, #0x0010
   42FE E5            [11]  362 	push	hl
   42FF CD E2 5A      [17]  363 	call	_cpct_setPALColour
                            364 ;src/game.c:111: cpct_memset ((u8*)CPCT_LVMEM_START, cpct_px2byteM0(5, 5), 0x8000); //5 is ordinal for WHITE from palette in M0 with 16c
   4302 21 05 05      [10]  365 	ld	hl, #0x0505
   4305 E5            [11]  366 	push	hl
   4306 CD A8 5C      [17]  367 	call	_cpct_px2byteM0
   4309 45            [ 4]  368 	ld	b, l
   430A 21 00 80      [10]  369 	ld	hl, #0x8000
   430D E5            [11]  370 	push	hl
   430E C5            [11]  371 	push	bc
   430F 33            [ 6]  372 	inc	sp
   4310 2E 00         [ 7]  373 	ld	l, #0x00
   4312 E5            [11]  374 	push	hl
   4313 CD C4 5C      [17]  375 	call	_cpct_memset
                            376 ;src/game.c:113: coord_x = 0;
   4316 21 D5 5D      [10]  377 	ld	hl,#_coord_x + 0
   4319 36 00         [10]  378 	ld	(hl), #0x00
                            379 ;src/game.c:115: while (1) {
   431B                     380 00107$:
                            381 ;src/game.c:118: if (!swap_memvideo) { 					//switch
   431B 3A B6 5E      [13]  382 	ld	a,(#_swap_memvideo + 0)
   431E B7            [ 4]  383 	or	a, a
   431F 20 0D         [12]  384 	jr	NZ,00102$
                            385 ;src/game.c:119: mem_start = (u8*) CPCT_LVMEM_START;	//lower VMEM page
   4321 21 00 80      [10]  386 	ld	hl, #0x8000
   4324 22 B3 5E      [16]  387 	ld	(_mem_start), hl
                            388 ;src/game.c:120: mem_page = cpct_page80;				//FIXME:: can probably delete??
   4327 21 B5 5E      [10]  389 	ld	hl,#_mem_page + 0
   432A 36 20         [10]  390 	ld	(hl), #0x20
   432C 18 0B         [12]  391 	jr	00103$
   432E                     392 00102$:
                            393 ;src/game.c:122: mem_start = (u8*) CPCT_VMEM_START;	//upper,regular VMEM page
   432E 21 00 C0      [10]  394 	ld	hl, #0xc000
   4331 22 B3 5E      [16]  395 	ld	(_mem_start), hl
                            396 ;src/game.c:123: mem_page = cpct_pageC0;
   4334 21 B5 5E      [10]  397 	ld	hl,#_mem_page + 0
   4337 36 30         [10]  398 	ld	(hl), #0x30
   4339                     399 00103$:
                            400 ;src/game.c:127: keyboard(); 							//user movement
   4339 CD 10 41      [17]  401 	call	_keyboard
                            402 ;src/game.c:129: moveSprites();
   433C CD AA 41      [17]  403 	call	_moveSprites
                            404 ;src/game.c:130: deleteSprites();
   433F CD 67 59      [17]  405 	call	_deleteSprites
                            406 ;src/game.c:131: renderSprites();
   4342 CD 7C 58      [17]  407 	call	_renderSprites
                            408 ;src/game.c:134: cpct_waitVSYNC();						//Wait until CRTC has printed a full frame to "repaint"
   4345 CD A0 5C      [17]  409 	call	_cpct_waitVSYNC
                            410 ;src/game.c:135: cpct_setVideoMemoryPage(mem_page);		//Tell CRTC to "paint" the new page--FIXME: can this use "mem_start" instead?
   4348 FD 21 B5 5E   [14]  411 	ld	iy, #_mem_page
   434C FD 6E 00      [19]  412 	ld	l, 0 (iy)
   434F CD 3B 5C      [17]  413 	call	_cpct_setVideoMemoryPage
                            414 ;src/game.c:136: swap_memvideo = ~swap_memvideo; 		//flip the switch
   4352 FD 21 B6 5E   [14]  415 	ld	iy, #_swap_memvideo
   4356 FD 7E 00      [19]  416 	ld	a, 0 (iy)
   4359 2F            [ 4]  417 	cpl
   435A FD 77 00      [19]  418 	ld	0 (iy), a
                            419 ;src/game.c:138: cycle++;
   435D FD 21 B2 5E   [14]  420 	ld	iy, #_cycle
   4361 FD 34 00      [23]  421 	inc	0 (iy)
                            422 ;src/game.c:139: if (cycle == 16)
   4364 FD 7E 00      [19]  423 	ld	a, 0 (iy)
   4367 D6 10         [ 7]  424 	sub	a, #0x10
   4369 20 B0         [12]  425 	jr	NZ,00107$
                            426 ;src/game.c:140: cycle=0;
   436B FD 36 00 00   [19]  427 	ld	0 (iy), #0x00
   436F 18 AA         [12]  428 	jr	00107$
                            429 	.area _CODE
                            430 	.area _INITIALIZER
                            431 	.area _CABS (ABS)
